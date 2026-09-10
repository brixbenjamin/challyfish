import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/app/purchase_state.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/domain/purchase.dart';
import 'package:test/test.dart';

import '../support/fake_purchase_gateway.dart';

const paidPackFixture = Pack(
  id: 'paid',
  key: 'paid',
  title: 'Paid',
  description: 'd',
  isCore: false,
  storeProductId: 'pack.paid',
  sort: 2,
);

/// Serves the pack's day-one body only from the nth pull onward, standing in
/// for a webhook that has not landed yet. Every other table is empty.
class DelayedBodyContentApi implements ContentApi {
  DelayedBodyContentApi({required this.bodyPresentAfterPulls, this.onPull});

  final int? bodyPresentAfterPulls;
  final void Function()? onPull;
  int pulls = 0;

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async {
    if (table == 'archetypes') {
      // First table of each pull: count the round trip once, not once per table.
      pulls++;
      onPull?.call();
    }
    if (table != 'action_bodies') return const [];
    if (bodyPresentAfterPulls == null || pulls < bodyPresentAfterPulls!) {
      return const [];
    }
    return [
      {
        'action_id': 'aPaid',
        'body_md': 'the copy they paid for',
        'updated_at': '2026-09-09T00:00:00Z',
      },
    ];
  }
}

class SilentProgressApi implements ProgressApi {
  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async => const [];
}

/// A clock whose delay returns immediately, so the backoff is exercised in full
/// without a test that waits thirty real seconds.
class InstantClock implements Clock {
  final List<Duration> waited = [];

  @override
  DateTime nowUtc() => DateTime.utc(2026, 9, 9);

  @override
  Future<void> delay(Duration duration) async => waited.add(duration);
}

Future<PurchaseController> buildTestController({
  void Function()? onPull,
  int? bodyPresentAfterPulls,
  PurchaseOutcome? outcome,
}) async {
  final db = FeralDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final at = DateTime.utc(2026, 9, 9);

  // The teaser is present and the copy is not: exactly what a locked pack looks
  // like on a device after ADR-0025.
  await db.into(db.packs).insert(PacksCompanion.insert(
        id: 'paid', key: 'paid', title: 'Paid', description: 'd',
        isCore: const Value(false), storeProductId: const Value('pack.paid'),
        sort: 2, updatedAt: at,
      ));
  await db.into(db.campaigns).insert(CampaignsCompanion.insert(
        id: 'cPaid', packId: 'paid', key: 'k2', title: 'Paid', introMd: 'i',
        lengthDays: 1, sort: 2, updatedAt: at,
      ));
  await db.into(db.actions).insert(ActionsCompanion.insert(
        id: 'aPaid', campaignId: 'cPaid', dayIndex: 1, title: 't',
        archetypeId: 'x1', updatedAt: at,
      ));

  final clock = InstantClock();
  final gateway = FakePurchaseGateway(
    catalogue: const [
      StoreProduct(id: 'pack.paid', title: 'Paid', priceString: '4.99'),
    ],
  )..nextOutcome = outcome;

  return PurchaseController(
    entitlements: EntitlementRepository(
      db: db,
      gateway: gateway,
      clock: clock,
    ),
    gateway: gateway,
    content: ContentRepository(
      db: db,
      api: DelayedBodyContentApi(
        bodyPresentAfterPulls: bodyPresentAfterPulls,
        onPull: onPull,
      ),
    ),
    sync: SyncRepository(db: db, api: SilentProgressApi(), clock: clock),
    clock: clock,
  );
}

void main() {
  test('a purchase waits for the body before reporting completion', () async {
    // The webhook lands on the third pull; the first two return nothing, which
    // is the ordinary case rather than an error.
    var pulls = 0;
    final controller = await buildTestController(
      onPull: () => pulls++,
      bodyPresentAfterPulls: 3,
    );

    final state = await controller.buy(userId: 'u1', pack: paidPackFixture);

    expect(state, isA<PurchaseComplete>());
    expect(pulls, greaterThanOrEqualTo(3),
        reason: 'it must keep asking until the body is actually there');
  });

  test('a body that never arrives ends in a retryable problem, not a blank pack',
      () async {
    final controller = await buildTestController(
      bodyPresentAfterPulls: null, // never
    );

    final state = await controller.buy(userId: 'u1', pack: paidPackFixture);

    expect(state, isA<PurchaseProblem>());
    expect((state as PurchaseProblem).reason,
        PurchaseProblemReason.deliveryTimedOut);
  });

  test('the delivering state is reported while the fetch runs', () async {
    // Otherwise the sheet shows nothing for the length of the fetch and looks
    // stuck, which is the thing PurchaseDelivering exists to prevent.
    final seen = <PurchaseUiState>[];
    final controller = await buildTestController(bodyPresentAfterPulls: 2);

    final state = await controller.buy(
      userId: 'u1',
      pack: paidPackFixture,
      onProgress: seen.add,
    );

    expect(seen, hasLength(1));
    expect(seen.single, isA<PurchaseDelivering>());
    expect((seen.single as PurchaseDelivering).packId, 'paid');
    expect(state, isA<PurchaseComplete>());
  });

  test('a cancelled purchase never enters delivery', () async {
    var pulls = 0;
    final controller = await buildTestController(
      onPull: () => pulls++,
      bodyPresentAfterPulls: 1,
      outcome: const PurchaseCancelled(),
    );

    final seen = <PurchaseUiState>[];
    final state = await controller.buy(
      userId: 'u1',
      pack: paidPackFixture,
      onProgress: seen.add,
    );

    expect(state, isA<PurchaseIdle>());
    expect(pulls, 0, reason: 'nothing was bought, so nothing is delivered');
    expect(seen, isEmpty);
  });
}
