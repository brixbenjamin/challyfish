import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:sqlite3/sqlite3.dart';
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

  group('upgrading a real v5 file', () {
    /// A genuine v5 install: the old `actions` table with UNIQUE(campaign_id,
    /// day_index), a run, and a reported day log, at user_version 5.
    ///
    /// The DDL is hand-written rather than read from drift, because the whole
    /// point is to reproduce a constraint the current schema no longer has.
    Future<File> writeV5Database() async {
      final dir = await Directory.systemTemp.createTemp('feral-v5');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/feral.sqlite');

      final raw = sqlite3.open(file.path);
      try {
        raw.execute(
          'CREATE TABLE "actions" ("id" TEXT NOT NULL, "campaign_id" TEXT NOT '
          'NULL, "day_index" INTEGER NOT NULL, "title" TEXT NOT NULL, '
          '"archetype_id" TEXT NOT NULL, "why_doctrine_id" TEXT NULL, '
          '"effort" INTEGER NOT NULL DEFAULT 1, "updated_at" INTEGER NOT NULL, '
          'PRIMARY KEY ("id"), UNIQUE ("campaign_id", "day_index"))',
        );
        raw.execute(
          'CREATE TABLE "campaign_runs" ("id" TEXT NOT NULL, "user_id" TEXT '
          'NOT NULL, "campaign_id" TEXT NOT NULL, "status" TEXT NOT NULL, '
          '"is_hardened" INTEGER NOT NULL DEFAULT 0, "started_at" INTEGER NOT '
          'NULL, "completed_at" INTEGER NULL, "grade" TEXT NULL, "updated_at" '
          'INTEGER NOT NULL, "dirty" INTEGER NOT NULL DEFAULT 1, '
          'PRIMARY KEY ("id"))',
        );
        raw.execute(
          'CREATE TABLE "day_logs" ("id" TEXT NOT NULL, "user_id" TEXT NOT '
          'NULL, "run_id" TEXT NOT NULL, "day_index" INTEGER NOT NULL, '
          '"action_id" TEXT NOT NULL, "committed_at" INTEGER NULL, "outcome" '
          'TEXT NULL, "note" TEXT NULL, "updated_at" INTEGER NOT NULL, '
          '"dirty" INTEGER NOT NULL DEFAULT 1, PRIMARY KEY ("id"), '
          'UNIQUE ("run_id", "day_index"))',
        );

        final at = DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch ~/ 1000;
        raw.execute(
          'INSERT INTO actions (id, campaign_id, day_index, title, '
          'archetype_id, effort, updated_at) '
          "VALUES ('legacy-action', 'campaign-1', 1, 'The old day', "
          "'arch-1', 3, $at)",
        );
        raw.execute(
          'INSERT INTO campaign_runs (id, user_id, campaign_id, status, '
          'is_hardened, started_at, updated_at, dirty) '
          "VALUES ('legacy-run', 'user-1', 'campaign-1', 'active', 0, "
          '$at, $at, 1)',
        );
        raw.execute(
          'INSERT INTO day_logs (id, user_id, run_id, day_index, action_id, '
          'outcome, updated_at, dirty) '
          "VALUES ('legacy-log', 'user-1', 'legacy-run', 1, 'legacy-action', "
          "'done', $at, 1)",
        );
        raw.execute('PRAGMA user_version = 5');
      } finally {
        raw.close();
      }
      return file;
    }

    test('the run and the day log survive', () async {
      final migrated = FeralDatabase(NativeDatabase(await writeV5Database()));
      addTearDown(migrated.close);

      expect(await migrated.select(migrated.campaignRuns).get(), hasLength(1));
      expect(await migrated.select(migrated.dayLogs).get(), hasLength(1));
    });

    test('the authored action survives, with its effort intact', () async {
      final migrated = FeralDatabase(NativeDatabase(await writeV5Database()));
      addTearDown(migrated.close);

      final action = await migrated.select(migrated.actions).getSingle();
      expect(action.id, 'legacy-action');
      expect(action.effort, 3, reason: 'effort is the points value now');
      expect(
        action.isOptional,
        isFalse,
        reason: "an existing action becomes its day mandatory one",
      );
      expect(action.sort, 0);
    });

    test(
      'the radar does not collapse: the reported day gained a tick',
      () async {
        final migrated = FeralDatabase(NativeDatabase(await writeV5Database()));
        addTearDown(migrated.close);

        final ticks = await migrated.select(migrated.dayLogActions).get();
        expect(ticks, hasLength(1));
        expect(ticks.single.actionId, 'legacy-action');
        expect(ticks.single.completed, isTrue);
      },
    );

    test(
      'the archetype survives the column being dropped for a join table',
      () async {
        // v5 to v7 in one open, which is the case that nearly went wrong: the
        // v6 step recreates `actions` against the current schema and takes
        // archetype_id with it, so the pairs have to be read before any step
        // runs rather than inside the v7 block.
        final migrated = FeralDatabase(NativeDatabase(await writeV5Database()));
        addTearDown(migrated.close);

        final shares = await migrated.select(migrated.actionArchetypes).get();
        expect(shares, hasLength(1));
        expect(shares.single.actionId, 'legacy-action');
        expect(shares.single.archetypeId, 'arch-1');
        expect(
          shares.single.share,
          1,
          reason:
              'one row at share 1 normalises to the weight 1.0 the '
              'dropped column meant, so no upgraded radar moves',
        );
      },
    );

    test(
      'the day slot constraint moved, so an optional can be stored',
      () async {
        // The reason the v6 step recreates `actions` rather than adding two
        // columns to it. Under the v5 UNIQUE(campaign_id, day_index) this
        // insert is rejected, and an upgraded install could never hold an
        // optional action -- which is the entire feature.
        final migrated = FeralDatabase(NativeDatabase(await writeV5Database()));
        addTearDown(migrated.close);

        await migrated
            .into(migrated.actions)
            .insert(
              ActionsCompanion.insert(
                id: 'new-optional',
                campaignId: 'campaign-1',
                dayIndex: 1,
                title: 'An optional act',
                isOptional: const Value(true),
                sort: const Value(1),
                updatedAt: DateTime.utc(2026, 9, 11),
              ),
            );

        final onDayOne = await (migrated.select(
          migrated.actions,
        )..where((a) => a.dayIndex.equals(1))).get();
        expect(onDayOne, hasLength(2));
      },
    );
  });
}
