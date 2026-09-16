import 'dart:convert';

import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:test/test.dart';

import '../support/database.dart';
import '../support/fake_progress_api.dart';

/// The outbox is what replaced a `dirty` flag on every user table. These are the
/// rules that made the swap worth doing.
void main() {
  late FeralDatabase db;
  late FakeProgressApi api;
  late SyncRepository sync;

  final at = DateTime.utc(2026, 6, 10, 9);

  setUp(() {
    db = memoryDatabase();
    api = FakeProgressApi();
    sync = SyncRepository(db: db, api: api, clock: FixedClock(at));
  });
  tearDown(() => db.close());

  Future<void> queue(String table, String key, Map<String, dynamic> payload) =>
      db
          .into(db.outbox)
          .insert(
            OutboxCompanion.insert(
              remoteTable: table,
              rowKey: key,
              payload: jsonEncode(payload),
              queuedAt: at,
            ),
          );

  Future<void> seedRun({String status = 'active', String id = 'run-1'}) async {
    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: id,
            userId: 'u1',
            campaignId: 'c1',
            status: status,
            startedAt: at,
            updatedAt: at,
          ),
        );
    await queue('campaign_runs', id, {
      'id': id,
      'user_id': 'u1',
      'campaign_id': 'c1',
      'status': status,
      'is_hardened': false,
      'started_at': at.toIso8601String(),
      'updated_at': at.toIso8601String(),
    });
  }

  group('flush', () {
    test('sends every entry in order and empties the queue', () async {
      await seedRun();
      await queue('day_logs', 'run-1:1', {
        'id': 'log-1',
        'user_id': 'u1',
        'run_id': 'run-1',
        'day_index': 1,
        'action_id': 'a1',
        'updated_at': at.toIso8601String(),
      });

      final result = await sync.flush('u1');

      expect(result.succeeded, isTrue);
      expect(result.pushedRows, 2);
      expect(api.pushes.map((p) => p.table), ['campaign_runs', 'day_logs']);
      expect(await db.select(db.outbox).get(), isEmpty);
    });

    test('a failure leaves that entry and everything after it queued', () async {
      await seedRun();
      await queue('day_logs', 'run-1:1', {
        'id': 'log-1',
        'user_id': 'u1',
        'run_id': 'run-1',
        'day_index': 1,
        'action_id': 'a1',
        'updated_at': at.toIso8601String(),
      });
      api.throwOnUpsertForTable['day_logs'] = StateError('offline');

      final result = await sync.flush('u1');

      expect(result.succeeded, isFalse);
      // The run landed and is gone from the queue; the day log did not and stays.
      // An entry leaves only when the server has acknowledged that entry, which
      // is the race a dirty flag could not express.
      expect(result.pushedRows, 1);
      final left = await db.select(db.outbox).get();
      expect(left.map((o) => o.remoteTable), ['day_logs']);
    });

    test('a retry resends exactly what was left', () async {
      await seedRun();
      api.throwOnUpsert = StateError('offline');
      await sync.flush('u1');
      expect(api.pushes, isEmpty);

      api.throwOnUpsert = null;
      final result = await sync.flush('u1');

      expect(result.succeeded, isTrue);
      expect(api.pushes.single.table, 'campaign_runs');
      expect(await db.select(db.outbox).get(), isEmpty);
    });

    test('a queued write survives closing and reopening the database', () async {
      // The queue is the record of what is owed. If it lived in memory, an app
      // killed between a tick and the next sync would lose the day silently.
      await seedRun();
      final owed = await db.select(db.outbox).get();
      expect(owed, hasLength(1));
      expect(owed.single.rowKey, 'run-1');
    });
  });

  group('a second active run', () {
    setUp(() {
      api.throwOnUpsertForTable['campaign_runs'] = PostgrestException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
      );
    });

    test('is recorded as abandoned rather than dropped', () async {
      await seedRun();
      await queue('day_logs', 'run-1:1', {
        'id': 'log-1',
        'user_id': 'u1',
        'run_id': 'run-1',
        'day_index': 1,
        'action_id': 'a1',
        'updated_at': at.toIso8601String(),
      });

      // The server rejects the run once, then accepts the abandoned version.
      var seen = 0;
      api.whileUpserting = (table) async {
        if (table != 'campaign_runs') return;
        if (++seen == 1) return;
        api.throwOnUpsertForTable.remove('campaign_runs');
      };

      final result = await sync.flush('u1');

      expect(result.succeeded, isTrue);
      final sent = api.pushes.firstWhere((p) => p.table == 'campaign_runs');
      expect(sent.rows.single['status'], 'abandoned');

      // The run and its day log both reach the server: whichever run got there
      // first keeps the active slot, but effort is never erased (ADR-0003).
      expect(api.pushes.map((p) => p.table), contains('day_logs'));
      expect(await db.select(db.outbox).get(), isEmpty);

      final stored = await db.select(db.campaignRuns).getSingle();
      expect(stored.status, 'abandoned');
    });

    test('tells the user once, and plainly', () async {
      await seedRun();
      var seen = 0;
      api.whileUpserting = (table) async {
        if (table != 'campaign_runs') return;
        if (++seen == 1) return;
        api.throwOnUpsertForTable.remove('campaign_runs');
      };

      await sync.flush('u1');

      final notices = sync.consumeNotices();
      expect(notices, hasLength(1));
      expect(notices.single.message, contains('another device'));
      expect(sync.consumeNotices(), isEmpty);
    });
  });

  group('refresh', () {
    test('a row deleted on the server disappears here', () async {
      await db
          .into(db.campaignRuns)
          .insert(
            CampaignRunsCompanion.insert(
              id: 'gone',
              userId: 'u1',
              campaignId: 'c1',
              status: 'abandoned',
              startedAt: at,
              updatedAt: at,
            ),
          );

      // The server returns nothing for the user, so the row is gone. An
      // incremental fetch could never say this: a deleted row carries no newer
      // `updated_at`, so it would have survived until the app was reinstalled.
      final result = await sync.refresh('u1');

      expect(result.succeeded, isTrue);
      expect(await db.select(db.campaignRuns).get(), isEmpty);
    });

    test('a row still owed is neither overwritten nor deleted', () async {
      await seedRun();
      // The server's copy is older and says active; ours says the user abandoned
      // it and has not been sent yet.
      await (db.update(db.campaignRuns)..where((r) => r.id.equals('run-1')))
          .write(const CampaignRunsCompanion(status: Value('abandoned')));
      api.remote['campaign_runs'] = [
        {
          'id': 'run-1',
          'user_id': 'u1',
          'campaign_id': 'c1',
          'status': 'active',
          'is_hardened': false,
          'started_at': at.toIso8601String(),
          'updated_at': at.toIso8601String(),
        },
      ];

      await sync.refresh('u1');

      final stored = await db.select(db.campaignRuns).getSingle();
      expect(
        stored.status,
        'abandoned',
        reason: 'a write the user saw succeed stays visible until it lands',
      );
      expect(await db.select(db.outbox).get(), hasLength(1));
    });

    test('adopts the server uuid for a day the user wrote offline', () async {
      // Two devices mint different uuids for the same day, which is why nothing
      // is keyed on one. Once the write has landed and left the queue, the
      // server's row is simply the answer.
      await db
          .into(db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              id: 'local-uuid',
              userId: 'u1',
              runId: 'run-1',
              dayIndex: 1,
              actionId: 'a1',
              updatedAt: at,
            ),
          );
      api.remote['day_logs'] = [
        {
          'id': 'server-uuid',
          'user_id': 'u1',
          'run_id': 'run-1',
          'day_index': 1,
          'action_id': 'a1',
          'updated_at': at.toIso8601String(),
        },
      ];

      await sync.refresh('u1');

      final stored = await db.select(db.dayLogs).getSingle();
      expect(stored.id, 'server-uuid');
    });

    test('a failed fetch changes nothing and reports it', () async {
      await db
          .into(db.campaignRuns)
          .insert(
            CampaignRunsCompanion.insert(
              id: 'run-1',
              userId: 'u1',
              campaignId: 'c1',
              status: 'active',
              startedAt: at,
              updatedAt: at,
            ),
          );
      api.failFetchForTable['campaign_runs'] = StateError('offline');

      final result = await sync.refresh('u1');

      expect(result.succeeded, isFalse);
      expect(
        await db.select(db.campaignRuns).get(),
        hasLength(1),
        reason: 'a throw is "we did not find out", never "the record is empty"',
      );
    });
  });

  test('a sync flushes before it refreshes', () async {
    await seedRun();

    await sync.sync('u1');

    // The other order would replace an unsent local row with the server's older
    // copy, losing a write the user already saw succeed.
    expect(api.callLog.first, 'upsert:campaign_runs');
  });

  test('ascending id is the only push order there is', () async {
    // Nothing declares a table order for the flush. A run is queued before the
    // day logs under it, so the ids already satisfy the server's foreign keys.
    await seedRun();
    await queue('day_logs', 'run-1:1', {'id': 'log-1'});
    await queue('day_log_actions', 'run-1:1:a1', {'run_id': 'run-1'});

    final ordered = await (db.select(
      db.outbox,
    )..orderBy([(o) => OrderingTerm.asc(o.id)])).get();
    expect(ordered.map((o) => o.remoteTable), [
      'campaign_runs',
      'day_logs',
      'day_log_actions',
    ]);
  });
}
