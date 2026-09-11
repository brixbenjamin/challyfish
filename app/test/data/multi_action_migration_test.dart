import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:test/test.dart';

/// The backfill is what stops every existing user's radar collapsing to zero on
/// upgrade. Once the balance reads ticks rather than day outcomes, a day log
/// with no tick contributes nothing, and every day recorded before this schema
/// version has no tick.
void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> insertRun() => db
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

  Future<void> insertLog(int day, String? outcome) => db
      .into(db.dayLogs)
      .insert(
        DayLogsCompanion.insert(
          id: 'log-$day',
          userId: 'user-1',
          runId: 'run-1',
          dayIndex: day,
          actionId: 'action-$day',
          outcome: Value(outcome),
          updatedAt: DateTime.utc(2026, 6, day),
        ),
      );

  test('a day log with an outcome gains a tick on upgrade', () async {
    await insertRun();
    await insertLog(1, 'done');

    await db.backfillDayLogActions();

    final ticks = await db.select(db.dayLogActions).get();
    expect(ticks, hasLength(1));
    expect(ticks.single.actionId, 'action-1');
    expect(ticks.single.completed, isTrue);
    expect(ticks.single.runId, 'run-1');
    expect(ticks.single.dayIndex, 1);
    expect(
      ticks.single.dirty,
      isTrue,
      reason: 'a backfilled row pushes like any other local write',
    );
  });

  test('a partial day is backfilled too', () async {
    await insertRun();
    await insertLog(1, 'partial');

    await db.backfillDayLogActions();

    expect(await db.select(db.dayLogActions).get(), hasLength(1));
  });

  test('a skipped day gains no tick', () async {
    await insertRun();
    await insertLog(1, 'skipped');

    await db.backfillDayLogActions();

    expect(await db.select(db.dayLogActions).get(), isEmpty);
  });

  test('a missed or unreported day gains no tick', () async {
    await insertRun();
    await insertLog(1, 'missed');
    await insertLog(2, null);

    await db.backfillDayLogActions();

    expect(await db.select(db.dayLogActions).get(), isEmpty);
  });

  test('running the backfill twice is a no-op, not a duplicate', () async {
    await insertRun();
    await insertLog(1, 'done');

    await db.backfillDayLogActions();
    await db.backfillDayLogActions();

    expect(await db.select(db.dayLogActions).get(), hasLength(1));
  });

  test('a day can hold several actions once optionals exist', () async {
    // The constraint this schema version relaxes. Under the old unique key on
    // (campaign_id, day_index) the second row here was rejected outright, so an
    // upgraded install could not store an optional action at all.
    await db
        .into(db.actions)
        .insert(
          ActionsCompanion.insert(
            id: 'a-mandatory',
            campaignId: 'campaign-1',
            dayIndex: 1,
            title: 'The mandatory act',
            archetypeId: 'arch-1',
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    await db
        .into(db.actions)
        .insert(
          ActionsCompanion.insert(
            id: 'a-optional',
            campaignId: 'campaign-1',
            dayIndex: 1,
            title: 'An optional act',
            archetypeId: 'arch-2',
            isOptional: const Value(true),
            sort: const Value(1),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );

    final rows = await (db.select(
      db.actions,
    )..where((a) => a.dayIndex.equals(1))).get();
    expect(rows, hasLength(2));
    expect(rows.where((a) => a.isOptional), hasLength(1));
  });
}
