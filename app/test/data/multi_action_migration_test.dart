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
    // Whether a backfilled tick reaches the server is the v10 step's business,
    // not this one's: at v6 the row is marked by the `dirty` column's on-disk
    // default, and v10 turns whatever is still marked into a queue entry. That
    // handover is covered in database_migration_test.dart.
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

  // v8 drops the cached content rows rather than carrying them (ADR-0034), so
  // a v5 action no longer reaches the present and the assertions that said it
  // did have moved to day_entity_migration_test.dart, which asserts the drop.
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
          // Created at v3, so a genuine v5 file has it. The v8 step clears the
          // rebuilt content tables' watermarks and needs somewhere to clear
          // them from.
          'CREATE TABLE "sync_state" ("table_name" TEXT NOT NULL, "watermark" '
          'INTEGER NULL, "last_pulled_at" INTEGER NULL, '
          'PRIMARY KEY ("table_name"))',
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
  });
}
