import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/run.dart';
import 'package:test/test.dart';

/// A ProgressApi that answers `entitlements` from a fixed list, or throws.
///
/// It records what it was asked, so the complete-set contract can be asserted:
/// a refund deletes the server row, and a deleted row carries no newer
/// updated_at, so an incremental fetch structurally cannot observe it.
class FakeProgressApi implements ProgressApi {
  FakeProgressApi({this.packIds = const [], this.throws = false});

  final List<String> packIds;
  final bool throws;
  final List<(String, DateTime?)> asked = [];

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async {
    asked.add((table, since));
    if (throws) throw StateError('the network is not evidence');
    if (table != 'entitlements') return const [];
    return [
      for (final packId in packIds)
        {
          'user_id': userId,
          'pack_id': packId,
          'source': 'store',
          'acquired_at': '2026-09-09T00:00:00Z',
          'updated_at': '2026-09-09T00:00:00Z',
        },
    ];
  }
}

class Harness {
  Harness(this.db, this.sync, this.api);

  final FeralDatabase db;
  final SyncRepository sync;
  final FakeProgressApi api;
}

/// A core and a paid pack, one campaign each, one action and one body each, an
/// active run on the paid campaign with two reported day logs.
Future<Harness> seededHarness({
  List<String> serverReturns = const [],
  bool apiThrows = false,
  bool paidRowIsLocal = false,
}) async {
  final db = FeralDatabase(NativeDatabase.memory());
  final at = DateTime.utc(2026, 9, 9);

  await db
      .into(db.packs)
      .insert(
        PacksCompanion.insert(
          id: 'core',
          key: 'core',
          title: 'Core',
          description: 'd',
          isCore: const Value(true),
          sort: 1,
          updatedAt: at,
        ),
      );
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
          id: 'cCore',
          packId: 'core',
          key: 'k1',
          title: 'Free',
          introMd: 'i',
          lengthDays: 2,
          sort: 1,
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
          lengthDays: 2,
          sort: 2,
          updatedAt: at,
        ),
      );
  for (final (id, campaign) in [('aCore', 'cCore'), ('aPaid', 'cPaid')]) {
    final dayId = id == 'aCore' ? 'dCore' : 'dPaid';
    await db
        .into(db.days)
        .insert(
          DaysCompanion.insert(
            id: dayId,
            campaignId: campaign,
            dayIndex: 1,
            title: 'Day one',
            updatedAt: at,
          ),
        );
    await db
        .into(db.actions)
        .insert(
          ActionsCompanion.insert(
            id: id,
            dayId: dayId,
            title: 't',
            updatedAt: at,
          ),
        );
    await db
        .into(db.actionBodies)
        .insert(
          ActionBodiesCompanion.insert(
            actionId: id,
            bodyMd: 'copy',
            updatedAt: at,
          ),
        );
  }

  await db
      .into(db.entitlements)
      .insert(
        EntitlementRow(
          userId: 'u1',
          packId: 'paid',
          source: 'store',
          acquiredAt: at,
          updatedAt: at,
          local: paidRowIsLocal,
        ),
      );

  await db
      .into(db.campaignRuns)
      .insert(
        CampaignRunsCompanion.insert(
          id: 'run1',
          userId: 'u1',
          campaignId: 'cPaid',
          status: RunStatus.active.key,
          startedAt: at,
          updatedAt: at,
        ),
      );
  for (var day = 1; day <= 2; day++) {
    await db
        .into(db.dayLogs)
        .insert(
          DayLogsCompanion.insert(
            id: 'log$day',
            userId: 'u1',
            runId: 'run1',
            dayIndex: day,
            actionId: 'aPaid',
            outcome: const Value('done'),
            updatedAt: at,
          ),
        );
  }

  final api = FakeProgressApi(packIds: serverReturns, throws: apiThrows);
  return Harness(
    db,
    SyncRepository(db: db, api: api, clock: FixedClock(at)),
    api,
  );
}

void main() {
  test(
    'a server set without the pack purges its bodies and abandons the run',
    () async {
      final h = await seededHarness(); // core + paid pack, bodies for both,
      addTearDown(h.db.close); // an active run on the paid campaign

      await h.sync.reconcileEntitlements('u1'); // server returns [] — refunded

      final bodies = await h.db.select(h.db.actionBodies).get();
      expect(bodies.map((b) => b.actionId), [
        'aCore',
      ], reason: 'the free pack is never purged');

      final run = await (h.db.select(
        h.db.campaignRuns,
      )..where((r) => r.id.equals('run1'))).getSingle();
      expect(run.status, RunStatus.abandoned.key);
      expect(
        run.dirty,
        isTrue,
        reason: 'the abandonment must reach the server',
      );

      final logs = await h.db.select(h.db.dayLogs).get();
      expect(logs, hasLength(2), reason: 'effort is never erased (ADR-0003)');
    },
  );

  test('a failed pull purges nothing', () async {
    final h = await seededHarness(apiThrows: true);
    addTearDown(h.db.close);

    await expectLater(h.sync.reconcileEntitlements('u1'), throwsA(anything));

    final bodies = await h.db.select(h.db.actionBodies).get();
    expect(
      bodies.map((b) => b.actionId),
      containsAll(['aCore', 'aPaid']),
      reason: 'absence of confirmation is not evidence of revocation',
    );
  });

  test('a set that still contains the pack purges nothing', () async {
    final h = await seededHarness(serverReturns: ['paid']);
    addTearDown(h.db.close);

    await h.sync.reconcileEntitlements('u1');

    final bodies = await h.db.select(h.db.actionBodies).get();
    expect(bodies.map((b) => b.actionId), containsAll(['aCore', 'aPaid']));
  });

  test('a locally-granted row is not treated as revoked', () async {
    // The window after a purchase and before the webhook lands. The server
    // legitimately returns nothing yet, and that must not undo the purchase.
    final h = await seededHarness(paidRowIsLocal: true);
    addTearDown(h.db.close);

    await h.sync.reconcileEntitlements('u1');

    final bodies = await h.db.select(h.db.actionBodies).get();
    expect(bodies.map((b) => b.actionId), containsAll(['aCore', 'aPaid']));
  });

  test('the fetch is a complete set, not an incremental one', () async {
    // A refund deletes the server row, and a deleted row carries no newer
    // updated_at. An incremental fetch can never observe a revocation, so
    // purge-on-evidence cannot be built on one.
    final h = await seededHarness(serverReturns: ['paid']);
    addTearDown(h.db.close);

    await h.sync.reconcileEntitlements('u1');

    expect(h.api.asked, [('entitlements', null)]);
  });
}
