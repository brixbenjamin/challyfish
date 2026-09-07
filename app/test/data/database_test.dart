import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:test/test.dart';

void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('the schema opens and every table is empty', () async {
    expect(await db.select(db.archetypes).get(), isEmpty);
    expect(await db.select(db.campaigns).get(), isEmpty);
    expect(await db.select(db.dayLogs).get(), isEmpty);
  });

  test('a run and a day log round-trip', () async {
    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: 'run-1',
            userId: 'user-1',
            campaignId: 'campaign-1',
            status: 'active',
            startedAt: DateTime.utc(2026, 6, 1, 9),
            updatedAt: DateTime.utc(2026, 6, 1, 9),
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
            updatedAt: DateTime.utc(2026, 6, 1, 9),
          ),
        );

    final logs = await db.select(db.dayLogs).get();
    expect(logs, hasLength(1));
    expect(logs.single.dayIndex, 1);
    expect(logs.single.outcome, isNull);
    expect(logs.single.dirty, isTrue, reason: 'local writes start dirty');
  });

  test(
    'two logs for the same run and day are rejected, as in Postgres',
    () async {
      await db
          .into(db.campaignRuns)
          .insert(
            CampaignRunsCompanion.insert(
              id: 'run-1',
              userId: 'user-1',
              campaignId: 'campaign-1',
              status: 'active',
              startedAt: DateTime.utc(2026, 6, 1, 9),
              updatedAt: DateTime.utc(2026, 6, 1, 9),
            ),
          );

      Future<void> insertDayOne(String id) => db
          .into(db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              id: id,
              userId: 'user-1',
              runId: 'run-1',
              dayIndex: 1,
              actionId: 'action-1',
              updatedAt: DateTime.utc(2026, 6, 1, 9),
            ),
          );

      await insertDayOne('log-1');
      expect(insertDayOne('log-2'), throwsA(isA<SqliteException>()));
    },
  );
}
