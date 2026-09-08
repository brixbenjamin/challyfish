import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:test/test.dart';

import 'sync_push_test.dart' show FakeProgressApi;

void main() {
  late FeralDatabase db;
  late FakeProgressApi api;
  late SyncRepository sync;

  Map<String, dynamic> remoteLog({
    required String id,
    required int dayIndex,
    String outcome = 'done',
    String? note,
    required DateTime updatedAt,
  }) => {
    'id': id,
    'user_id': 'user-1',
    'run_id': 'run-1',
    'day_index': dayIndex,
    'action_id': 'action-$dayIndex',
    'committed_at': null,
    'outcome': outcome,
    'note': note,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  Future<void> insertLocalRun() => db
      .into(db.campaignRuns)
      .insert(
        CampaignRunsCompanion.insert(
          id: 'run-1',
          userId: 'user-1',
          campaignId: 'campaign-1',
          status: 'active',
          startedAt: DateTime.utc(2026, 6, 1),
          updatedAt: DateTime.utc(2026, 6, 1),
          dirty: const Value(false),
        ),
      );

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    api = FakeProgressApi();
    sync = SyncRepository(
      db: db,
      api: api,
      clock: FixedClock(DateTime.utc(2026, 6, 10, 9)),
    );
  });
  tearDown(() => db.close());

  test('a remote row the device has never seen is inserted', () async {
    await insertLocalRun();
    api.remote['day_logs'] = [
      remoteLog(id: 'srv-3', dayIndex: 3, updatedAt: DateTime.utc(2026, 6, 3)),
    ];

    await sync.pull('user-1');

    final logs = await db.select(db.dayLogs).get();
    expect(logs, hasLength(1));
    expect(logs.single.dayIndex, 3);
    expect(logs.single.dirty, isFalse, reason: 'it came from the server');
  });

  test('a newer remote row overwrites a clean local row', () async {
    await insertLocalRun();
    await db
        .into(db.dayLogs)
        .insert(
          DayLogsCompanion.insert(
            id: 'local-3',
            userId: 'user-1',
            runId: 'run-1',
            dayIndex: 3,
            actionId: 'action-3',
            outcome: const Value('skipped'),
            updatedAt: DateTime.utc(2026, 6, 3, 8),
            dirty: const Value(false),
          ),
        );
    api.remote['day_logs'] = [
      remoteLog(
        id: 'srv-3',
        dayIndex: 3,
        note: 'reported on the other phone',
        updatedAt: DateTime.utc(2026, 6, 3, 20),
      ),
    ];

    await sync.pull('user-1');

    final logs = await db.select(db.dayLogs).get();
    expect(logs, hasLength(1), reason: 'merged on (run_id, day_index), not id');
    expect(logs.single.outcome, 'done');
    expect(logs.single.note, 'reported on the other phone');
  });

  test(
    'an older remote row does not overwrite a newer clean local row',
    () async {
      await insertLocalRun();
      await db
          .into(db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              id: 'local-3',
              userId: 'user-1',
              runId: 'run-1',
              dayIndex: 3,
              actionId: 'action-3',
              outcome: const Value('done'),
              note: const Value('the newer truth'),
              updatedAt: DateTime.utc(2026, 6, 3, 20),
              dirty: const Value(false),
            ),
          );
      api.remote['day_logs'] = [
        remoteLog(
          id: 'srv-3',
          dayIndex: 3,
          outcome: 'skipped',
          updatedAt: DateTime.utc(2026, 6, 3, 8),
        ),
      ];

      await sync.pull('user-1');

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.outcome, 'done');
      expect(log.note, 'the newer truth');
    },
  );

  test(
    'a dirty local row is never overwritten, even by a newer remote row',
    () async {
      await insertLocalRun();
      await db
          .into(db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              id: 'local-3',
              userId: 'user-1',
              runId: 'run-1',
              dayIndex: 3,
              actionId: 'action-3',
              outcome: const Value('partial'),
              note: const Value('written here, not yet acknowledged'),
              updatedAt: DateTime.utc(2026, 6, 3, 8),
              dirty: const Value(true),
            ),
          );
      api.remote['day_logs'] = [
        remoteLog(
          id: 'srv-3',
          dayIndex: 3,
          updatedAt: DateTime.utc(2026, 6, 4),
        ),
      ];

      await sync.pull('user-1');

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.outcome, 'partial');
      expect(log.dirty, isTrue, reason: 'still owed to the server');
    },
  );

  test('the watermark advances only after rows are committed', () async {
    await insertLocalRun();
    api.remote['day_logs'] = [
      remoteLog(id: 'srv-1', dayIndex: 1, updatedAt: DateTime.utc(2026, 6, 1)),
      remoteLog(id: 'srv-2', dayIndex: 2, updatedAt: DateTime.utc(2026, 6, 5)),
    ];

    await sync.pull('user-1');

    expect(await db.watermarkFor('day_logs'), DateTime.utc(2026, 6, 5));
  });

  test('a failed pull leaves the watermark where it was', () async {
    await insertLocalRun();
    await db.setWatermark('day_logs', DateTime.utc(2026, 6, 1));
    api.failFetch = StateError('connection reset');

    final result = await sync.pull('user-1');

    expect(result.succeeded, isFalse);
    expect(await db.watermarkFor('day_logs'), DateTime.utc(2026, 6, 1));
  });

  test('sync pushes before it pulls', () async {
    await insertLocalRun();
    await db
        .into(db.dayLogs)
        .insert(
          DayLogsCompanion.insert(
            id: 'local-1',
            userId: 'user-1',
            runId: 'run-1',
            dayIndex: 1,
            actionId: 'action-1',
            outcome: const Value('done'),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );

    final outcome = await sync.sync('user-1');

    expect(outcome.push.succeeded, isTrue);
    expect(outcome.pull.succeeded, isTrue);
    expect(
      api.callLog.first,
      startsWith('upsert'),
      reason: 'pushing first means the pull cannot resurrect a stale row',
    );
  });
}
