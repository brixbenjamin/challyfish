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

  Future<void> insertLocalLog({
    String id = 'local-day-uuid',
    bool dirty = false,
  }) => db
      .into(db.dayLogs)
      .insert(
        DayLogsCompanion.insert(
          id: id,
          userId: 'user-1',
          runId: 'run-1',
          dayIndex: 1,
          actionId: 'action-1',
          updatedAt: DateTime.utc(2026, 6, 1),
          dirty: Value(dirty),
        ),
      );

  Future<void> insertLocalTick({
    String id = 'local-tick-uuid',
    String actionId = 'action-1',
    bool completed = true,
    bool dirty = false,
  }) => db
      .into(db.dayLogActions)
      .insert(
        DayLogActionsCompanion.insert(
          id: id,
          userId: 'user-1',
          runId: 'run-1',
          dayIndex: 1,
          actionId: actionId,
          completed: Value(completed),
          updatedAt: DateTime.utc(2026, 6, 1),
          dirty: Value(dirty),
        ),
      );

  Map<String, dynamic> remoteTick({
    String id = 'server-uuid',
    String actionId = 'action-1',
    bool completed = true,
    required DateTime updatedAt,
  }) => {
    'id': id,
    'user_id': 'user-1',
    'run_id': 'run-1',
    'day_index': 1,
    'action_id': actionId,
    'completed': completed,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  group('ordering', () {
    test('ticks push after their day log', () {
      // Foreign keys decide the order: a tick pushed before its day is
      // rejected by the server and the retry fails identically forever.
      expect(
        SyncRepository.pushOrder.indexOf('day_log_actions'),
        greaterThan(SyncRepository.pushOrder.indexOf('day_logs')),
      );
    });

    test('ticks pull after their day log, for the same reason', () {
      expect(
        SyncRepository.pullOrder.indexOf('day_log_actions'),
        greaterThan(SyncRepository.pullOrder.indexOf('day_logs')),
      );
    });
  });

  group('push', () {
    test('a dirty tick is sent and then marked clean', () async {
      await insertLocalRun();
      await insertLocalLog();
      await insertLocalTick(dirty: true);

      final result = await sync.push('user-1');

      expect(result.succeeded, isTrue);
      final push = api.pushes.firstWhere((p) => p.table == 'day_log_actions');
      expect(push.rows.single['action_id'], 'action-1');
      expect(push.rows.single['completed'], isTrue);
      expect(push.rows.single['run_id'], 'run-1');
      expect(push.rows.single['day_index'], 1);

      expect((await db.select(db.dayLogActions).getSingle()).dirty, isFalse);
    });

    test('an untick is pushed as a flag, not as an absence', () async {
      await insertLocalRun();
      await insertLocalLog();
      await insertLocalTick(completed: false, dirty: true);

      await sync.push('user-1');

      final push = api.pushes.firstWhere((p) => p.table == 'day_log_actions');
      expect(push.rows.single['completed'], isFalse);
    });

    test('a clean tick is not pushed', () async {
      await insertLocalRun();
      await insertLocalLog();
      await insertLocalTick();

      await sync.push('user-1');

      expect(api.pushes.where((p) => p.table == 'day_log_actions'), isEmpty);
    });

    test('another user\'s ticks are never pushed', () async {
      await insertLocalRun();
      await insertLocalLog();
      await db
          .into(db.dayLogActions)
          .insert(
            DayLogActionsCompanion.insert(
              id: 'someone-else',
              userId: 'user-2',
              runId: 'run-1',
              dayIndex: 1,
              actionId: 'action-1',
              updatedAt: DateTime.utc(2026, 6, 1),
              dirty: const Value(true),
            ),
          );

      await sync.push('user-1');

      expect(api.pushes.where((p) => p.table == 'day_log_actions'), isEmpty);
    });
  });

  group('merge', () {
    test('a tick the device has never seen is inserted', () async {
      await insertLocalRun();
      await insertLocalLog();
      api.remote['day_log_actions'] = [
        remoteTick(updatedAt: DateTime.utc(2026, 6, 2)),
      ];

      await sync.pull('user-1');

      final rows = await db.select(db.dayLogActions).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 'server-uuid');
      expect(rows.single.dirty, isFalse, reason: 'it came from the server');
    });

    test('a pulled tick merges on its natural identity, not its id', () async {
      await insertLocalRun();
      await insertLocalLog();
      await insertLocalTick(id: 'local-uuid');

      api.remote['day_log_actions'] = [
        remoteTick(
          id: 'server-uuid',
          completed: false,
          updatedAt: DateTime.utc(2026, 6, 2),
        ),
      ];

      await sync.pull('user-1');

      final rows = await db.select(db.dayLogActions).get();
      expect(rows, hasLength(1), reason: 'must not insert a duplicate tick');
      expect(rows.single.id, 'server-uuid');
      expect(rows.single.completed, isFalse);
    });

    test('a dirty local tick wins over an older remote one', () async {
      await insertLocalRun();
      await insertLocalLog();
      await insertLocalTick(id: 'local-uuid', completed: false, dirty: true);

      api.remote['day_log_actions'] = [
        remoteTick(id: 'server-uuid', updatedAt: DateTime.utc(2026, 6, 2)),
      ];

      await sync.pull('user-1');

      final rows = await db.select(db.dayLogActions).get();
      expect(rows.single.id, 'local-uuid');
      expect(
        rows.single.completed,
        isFalse,
        reason: 'an unsent local untick is a write the user already saw',
      );
    });

    test('two ticks on one day are separate rows', () async {
      await insertLocalRun();
      await insertLocalLog();
      api.remote['day_log_actions'] = [
        remoteTick(id: 's-1', updatedAt: DateTime.utc(2026, 6, 2)),
        remoteTick(
          id: 's-2',
          actionId: 'optional-1',
          updatedAt: DateTime.utc(2026, 6, 2),
        ),
      ];

      await sync.pull('user-1');

      expect(await db.select(db.dayLogActions).get(), hasLength(2));
    });
  });

  test('adopting a server day-log id does not lose the day\'s ticks', () async {
    // The regression this table's shape exists to prevent. The day_logs merge
    // deletes the local row to adopt the server's uuid; ticks key on
    // (run_id, day_index, action_id) and so must survive it untouched.
    await insertLocalRun();
    await insertLocalLog(id: 'local-day-uuid');
    await insertLocalTick(id: 'tick-uuid');

    api.remote['day_logs'] = [
      {
        'id': 'server-day-uuid',
        'user_id': 'user-1',
        'run_id': 'run-1',
        'day_index': 1,
        'action_id': 'action-1',
        'committed_at': null,
        'outcome': 'done',
        'note': null,
        'updated_at': DateTime.utc(2026, 6, 2).toIso8601String(),
      },
    ];

    await sync.pull('user-1');

    expect((await db.select(db.dayLogs).getSingle()).id, 'server-day-uuid');
    final ticks = await db.select(db.dayLogActions).get();
    expect(ticks, hasLength(1), reason: 'the tick must outlive the id swap');
    expect(ticks.single.id, 'tick-uuid');
    expect(ticks.single.actionId, 'action-1');
  });
}
