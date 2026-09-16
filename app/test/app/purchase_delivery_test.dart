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
/// A server holding the paid pack's teasers all along, and its copy only once
/// the webhook has landed.
///
/// It serves the whole library rather than just the bodies, because a refresh
/// replaces every content table with what the server returns: a fake that
/// answered only for `action_bodies` would delete the very campaign the purchase
/// is meant to deliver.
class DelayedBodyContentApi implements ContentApi {
  DelayedBodyContentApi({required this.bodyPresentAfterPulls, this.onPull});

  static const _at = '2026-09-09T00:00:00Z';

  final int? bodyPresentAfterPulls;
  final void Function()? onPull;
  int pulls = 0;

  @override
  Future<int> fetchVersion() async => 1;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    if (table == 'archetypes') {
      // First table of each refresh: count the round trip once, not once per
      // table. The delivery loop forces every refresh, so the version gate never
      // short-circuits the count.
      pulls++;
      onPull?.call();
    }

    // The teaser is always readable; only the copy is gated (ADR-0025).
    switch (table) {
      case 'packs':
        return [
          {
            'id': 'paid',
            'key': 'paid',
            'title': 'Paid',
            'description': 'd',
            'is_core': false,
            'store_product_id': 'pack.paid',
            'sort': 2,
            'updated_at': _at,
          },
        ];
      case 'campaigns':
        return [
          {
            'id': 'cPaid',
            'pack_id': 'paid',
            'key': 'k2',
            'title': 'Paid',
            'intro_md': 'i',
            'length_days': 1,
            'sort': 2,
            'updated_at': _at,
          },
        ];
      case 'days':
        return [
          {
            'id': 'dPaid',
            'campaign_id': 'cPaid',
            'day_index': 1,
            'title': 'Day one',
            'updated_at': _at,
          },
        ];
      case 'actions':
        return [
          {
            'id': 'aPaid',
            'day_id': 'dPaid',
            'title': 't',
            'sort': 1,
            'effort': 1,
            'is_optional': false,
            'updated_at': _at,
          },
        ];
    }

    // Both body tables, since ADR-0034: a purchase is delivered only once day
    // one is readable in full, so a fake that withheld one of them would report
    // a delivery that never happened.
    if (table != 'action_bodies' && table != 'day_bodies') return const [];
    if (bodyPresentAfterPulls == null || pulls < bodyPresentAfterPulls!) {
      return const [];
    }
    if (table == 'day_bodies') {
      return [
        {'day_id': 'dPaid', 'body_md': 'what the day asks', 'updated_at': _at},
      ];
    }
    return [
      {
        'action_id': 'aPaid',
        'body_md': 'the copy they paid for',
        'updated_at': _at,
      },
    ];
  }
}

class SilentProgressApi implements ProgressApi {
  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchAllFor(
    String table,
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
  await db
      .into(db.packs)
      .insert(
        PacksCompanion.insert(
          id: 'paid',
          key: 'paid',
          title: 'Paid',
          description: 'd',
          isCore: const Value(false),
          storeProductId: const Value('pack.paid'),
          sort: 2,
          updatedAt: at,
        ),
      );
  await db
      .into(db.campaigns)
      .insert(
        CampaignsCompanion.insert(
          id: 'cPaid',
          packId: 'paid',
          key: 'k2',
          title: 'Paid',
          introMd: 'i',
          lengthDays: 1,
          sort: 2,
          updatedAt: at,
        ),
      );
  await db
      .into(db.days)
      .insert(
        DaysCompanion.insert(
          id: 'dPaid',
          campaignId: 'cPaid',
          dayIndex: 1,
          title: 'Day one',
          updatedAt: at,
        ),
      );
  await db
      .into(db.actions)
      .insert(
        ActionsCompanion.insert(
          id: 'aPaid',
          dayId: 'dPaid',
          title: 't',
          updatedAt: at,
        ),
      );

  final clock = InstantClock();
  final gateway = FakePurchaseGateway(
    catalogue: const [
      StoreProduct(id: 'pack.paid', title: 'Paid', priceString: '4.99'),
    ],
  )..nextOutcome = outcome;

  return PurchaseController(
    entitlements: EntitlementRepository(db: db, gateway: gateway, clock: clock),
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
    expect(
      pulls,
      greaterThanOrEqualTo(3),
      reason: 'it must keep asking until the body is actually there',
    );
  });

  test(
    'a body that never arrives ends in a retryable problem, not a blank pack',
    () async {
      final controller = await buildTestController(
        bodyPresentAfterPulls: null, // never
      );

      final state = await controller.buy(userId: 'u1', pack: paidPackFixture);

      expect(state, isA<PurchaseProblem>());
      expect(
        (state as PurchaseProblem).reason,
        PurchaseProblemReason.deliveryTimedOut,
      );
    },
  );

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
