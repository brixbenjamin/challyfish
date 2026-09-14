import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// v8 is the first content migration that drops rows rather than moving them.
/// That is legitimate -- the content store is a pure read-only cache and no user
/// data lives in it -- but only if two things hold: the user's own record is
/// untouched, and the watermarks for the dropped tables are cleared so the next
/// pull actually refills them. A dropped table behind an intact high-water mark
/// is an app that is empty forever.
void main() {
  group('upgrading a real v7 file', () {
    /// A genuine v7 install: `actions` with campaign_id/day_index and no
    /// day_id, its archetype join rows and its bodies, plus a run, a day log
    /// and a tick, at user_version 7.
    ///
    /// The DDL is hand-written rather than read from drift, because the whole
    /// point is to reproduce columns the current schema no longer has.
    Future<File> writeV7Database() async {
      final dir = await Directory.systemTemp.createTemp('feral-v7');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/feral.sqlite');

      final raw = sqlite3.open(file.path);
      try {
        raw.execute(
          'CREATE TABLE "actions" ("id" TEXT NOT NULL, "campaign_id" TEXT NOT '
          'NULL, "day_index" INTEGER NOT NULL, "title" TEXT NOT NULL, '
          '"why_doctrine_id" TEXT NULL, "effort" INTEGER NOT NULL DEFAULT 1, '
          '"is_optional" INTEGER NOT NULL DEFAULT 0, "sort" INTEGER NOT NULL '
          'DEFAULT 0, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"), '
          'UNIQUE ("campaign_id", "day_index", "sort"))',
        );
        raw.execute(
          'CREATE TABLE "action_archetypes" ("action_id" TEXT NOT NULL, '
          '"archetype_id" TEXT NOT NULL, "share" INTEGER NOT NULL DEFAULT 1, '
          '"updated_at" INTEGER NOT NULL, '
          'PRIMARY KEY ("action_id", "archetype_id"))',
        );
        raw.execute(
          'CREATE TABLE "action_bodies" ("action_id" TEXT NOT NULL, "body_md" '
          'TEXT NOT NULL, "updated_at" INTEGER NOT NULL, '
          'PRIMARY KEY ("action_id"))',
        );
        raw.execute(
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
        raw.execute(
          'CREATE TABLE "day_log_actions" ("id" TEXT NOT NULL, "user_id" TEXT '
          'NOT NULL, "run_id" TEXT NOT NULL, "day_index" INTEGER NOT NULL, '
          '"action_id" TEXT NOT NULL, "completed" INTEGER NOT NULL DEFAULT 1, '
          '"updated_at" INTEGER NOT NULL, "dirty" INTEGER NOT NULL DEFAULT 1, '
          'PRIMARY KEY ("id"), UNIQUE ("run_id", "day_index", "action_id"))',
        );

        final at = DateTime.utc(2026, 9, 1, 9).millisecondsSinceEpoch ~/ 1000;
        raw.execute(
          'INSERT INTO actions (id, campaign_id, day_index, title, effort, '
          'is_optional, sort, updated_at) '
          "VALUES ('legacy-action', 'campaign-1', 1, 'The old day', 3, 0, 0, "
          '$at)',
        );
        raw.execute(
          'INSERT INTO action_archetypes (action_id, archetype_id, share, '
          "updated_at) VALUES ('legacy-action', 'arch-1', 1, $at)",
        );
        raw.execute(
          'INSERT INTO action_bodies (action_id, body_md, updated_at) '
          "VALUES ('legacy-action', 'the old copy', $at)",
        );
        for (final table in const [
          'actions',
          'action_archetypes',
          'action_bodies',
          'campaigns',
        ]) {
          raw.execute(
            'INSERT INTO sync_state (table_name, watermark, last_pulled_at) '
            "VALUES ('$table', $at, $at)",
          );
        }
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
        raw.execute(
          'INSERT INTO day_log_actions (id, user_id, run_id, day_index, '
          'action_id, completed, updated_at, dirty) '
          "VALUES ('legacy-tick', 'user-1', 'legacy-run', 1, 'legacy-action', "
          '1, $at, 1)',
        );
        raw.execute('PRAGMA user_version = 7');
      } finally {
        raw.close();
      }
      return file;
    }

    Future<FeralDatabase> migrated() async {
      final db = FeralDatabase(NativeDatabase(await writeV7Database()));
      addTearDown(db.close);
      // Drift runs the migration lazily, on the first statement.
      await db.select(db.actions).get();
      return db;
    }

    test('the run, the day log and the tick all survive', () async {
      final db = await migrated();

      expect(await db.select(db.campaignRuns).get(), hasLength(1));
      expect(await db.select(db.dayLogs).get(), hasLength(1));
      final ticks = await db.select(db.dayLogActions).get();
      expect(ticks, hasLength(1));
      expect(
        ticks.single.actionId,
        'legacy-action',
        reason: 'a tick references its action by id, and ids are stable',
      );
    });

    test('the day tables exist and are empty', () async {
      final db = await migrated();

      expect(await db.select(db.days).get(), isEmpty);
      expect(await db.select(db.dayBodies).get(), isEmpty);
    });

    test('the cached content is dropped rather than carried', () async {
      // There is no local value for the non-null day_id a v7 action would need,
      // and no way to derive one: the day ids live on the server. Content is a
      // cache, so dropping is correct -- what would not be correct is keeping
      // rows that cannot say which day they belong to.
      final db = await migrated();

      expect(await db.select(db.actions).get(), isEmpty);
      expect(await db.select(db.actionArchetypes).get(), isEmpty);
      expect(await db.select(db.actionBodies).get(), isEmpty);
    });

    test('the dropped tables lose their watermarks', () async {
      // The half of this that is easy to forget and fatal to miss. The rows are
      // older than the mark, so an incremental pull asks for nothing and the
      // app sits on an empty library until it is reinstalled.
      final db = await migrated();

      expect(await db.watermarkFor('actions'), isNull);
      expect(await db.watermarkFor('action_archetypes'), isNull);
      expect(await db.watermarkFor('action_bodies'), isNull);
    });

    test('untouched content keeps its watermark', () async {
      // campaigns did not move, so re-downloading the library would be a
      // pointless round trip on an upgrade that changed nothing about it.
      final db = await migrated();

      expect(await db.watermarkFor('campaigns'), isNotNull);
    });

    test('a day can hold a mandatory action and an optional one', () async {
      final db = await migrated();

      await db
          .into(db.days)
          .insert(
            DaysCompanion.insert(
              id: 'day-1',
              campaignId: 'campaign-1',
              dayIndex: 1,
              title: 'Day one',
              updatedAt: DateTime.utc(2026, 9, 14),
            ),
          );
      await db
          .into(db.actions)
          .insert(
            ActionsCompanion.insert(
              id: 'a-mandatory',
              dayId: 'day-1',
              title: 'The mandatory act',
              updatedAt: DateTime.utc(2026, 9, 14),
            ),
          );
      await db
          .into(db.actions)
          .insert(
            ActionsCompanion.insert(
              id: 'a-optional',
              dayId: 'day-1',
              title: 'An optional act',
              isOptional: const Value(true),
              sort: const Value(1),
              updatedAt: DateTime.utc(2026, 9, 14),
            ),
          );

      final onDayOne =
          await (db.select(db.actions)..where((a) => a.dayId.equals('day-1')))
              .get();
      expect(onDayOne, hasLength(2));
    });
  });
}
