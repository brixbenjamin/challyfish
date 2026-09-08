import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:test/test.dart';

/// Shared by every sync test in this plan. It records what was asked of it and
/// can be made to fail in the specific ways the real API fails.
class FakeProgressApi implements ProgressApi {
  final List<({String table, List<Map<String, dynamic>> rows})> pushes = [];
  final Map<String, List<Map<String, dynamic>>> remote = {};
  final List<String> callLog = [];

  Object? throwOnUpsert;
  final Map<String, Object> throwOnUpsertForTable = {};
  Object? failFetch;

  /// Runs while a push for [table] is in flight — after its rows have been
  /// read, before the flags are cleared. The only way to write the race that
  /// matters here, since drift serializes statements on one queue.
  Future<void> Function(String table)? whileUpserting;

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    callLog.add('upsert:$table');
    await whileUpserting?.call(table);
    final perTable = throwOnUpsertForTable[table];
    if (perTable != null) throw perTable;
    if (throwOnUpsert != null) throw throwOnUpsert!;
    pushes.add((table: table, rows: rows));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async {
    callLog.add('fetch:$table');
    if (failFetch != null) throw failFetch!;
    return remote[table] ?? const [];
  }
}

void main() {
  late FeralDatabase db;
  late FakeProgressApi api;
  late SyncRepository sync;

  Future<void> seedRunAndLog() async {
    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: 'run-1',
            userId: 'user-1',
            campaignId: 'campaign-1',
            status: 'active',
            startedAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    await db
        .into(db.dayLogs)
        .insert(
          DayLogsCompanion.insert(
            id: 'log-1',
            userId: 'user-1',
            runId: 'run-1',
            dayIndex: 1,
            actionId: 'action-1',
            outcome: const Value('done'),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
  }

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    api = FakeProgressApi();
    sync = SyncRepository(
      db: db,
      api: api,
      clock: FixedClock(DateTime.utc(2026, 6, 2, 9)),
    );
  });
  tearDown(() => db.close());

  test('dirty rows are pushed and the flag is cleared', () async {
    await seedRunAndLog();

    final result = await sync.push('user-1');

    expect(result.succeeded, isTrue);
    expect(
      api.pushes.map((p) => p.table),
      containsAllInOrder(['campaign_runs', 'day_logs']),
    );

    final runs = await db.select(db.campaignRuns).get();
    final logs = await db.select(db.dayLogs).get();
    expect(runs.single.dirty, isFalse);
    expect(logs.single.dirty, isFalse);
  });

  test('runs are pushed before day logs, because of the foreign key', () async {
    await seedRunAndLog();
    await sync.push('user-1');

    final runIdx = api.pushes.indexWhere((p) => p.table == 'campaign_runs');
    final logIdx = api.pushes.indexWhere((p) => p.table == 'day_logs');
    expect(runIdx, lessThan(logIdx));
  });

  test('a failed push leaves the rows dirty', () async {
    await seedRunAndLog();
    api.throwOnUpsert = StateError('network down');

    final result = await sync.push('user-1');

    expect(result.succeeded, isFalse);
    expect((await db.select(db.campaignRuns).get()).single.dirty, isTrue);
    expect((await db.select(db.dayLogs).get()).single.dirty, isTrue);
  });

  test('a write during the push is not falsely marked clean', () async {
    await seedRunAndLog();

    // The user reports a day while the push is in flight: the row is written
    // again, with a newer updatedAt, after it was read for pushing.
    api.whileUpserting = (table) async {
      if (table != 'day_logs') return;
      await (db.update(db.dayLogs)..where((l) => l.id.equals('log-1'))).write(
        DayLogsCompanion(
          note: const Value('changed mid-flight'),
          updatedAt: Value(DateTime.utc(2026, 6, 2, 10)),
          dirty: const Value(true),
        ),
      );
    };

    await sync.push('user-1');

    final log = await db.select(db.dayLogs).getSingle();
    expect(
      log.dirty,
      isTrue,
      reason: 'the newer write has not been sent, so it is still owed',
    );
  });

  test('nothing dirty means no network call at all', () async {
    await seedRunAndLog();
    await sync.push('user-1');
    api.pushes.clear();
    api.callLog.clear();

    final result = await sync.push('user-1');

    expect(result.succeeded, isTrue);
    expect(api.callLog, isEmpty);
  });

  test("another user's rows are never pushed", () async {
    await seedRunAndLog();
    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: 'run-other',
            userId: 'user-2',
            campaignId: 'campaign-1',
            status: 'active',
            startedAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );

    await sync.push('user-1');

    final pushedRunIds = api.pushes
        .where((p) => p.table == 'campaign_runs')
        .expand((p) => p.rows)
        .map((r) => r['id']);
    expect(pushedRunIds, ['run-1']);
  });
}
