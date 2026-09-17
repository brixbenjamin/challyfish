import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// v11 adds the two local dates a day log needs to say when it happened, and
/// the date a run was abandoned on (ADR-0040).
///
/// The point of this file is the invariant the whole migration ladder carries:
/// `campaign_runs`, `day_logs` and `day_log_actions` are never dropped or
/// recreated. A user's own record has no other copy, so an additive column has
/// to arrive without costing a single row.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// A genuine v10 install: a run, two day logs and a tick, at user_version 10.
  ///
  /// The DDL is hand-written rather than read from drift, because the whole
  /// point is to reproduce a schema the current code no longer declares.
  Future<File> writeV10Database() async {
    final dir = await Directory.systemTemp.createTemp('feral-v10');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    final raw = sqlite3.open(file.path);
    try {
      raw.execute(
        'CREATE TABLE "campaign_runs" ("id" TEXT NOT NULL, "user_id" TEXT NOT '
        'NULL, "campaign_id" TEXT NOT NULL, "status" TEXT NOT NULL, '
        '"is_hardened" INTEGER NOT NULL DEFAULT 0, "started_at" INTEGER NOT '
        'NULL, "completed_at" INTEGER NULL, "grade" TEXT NULL, "updated_at" '
        'INTEGER NOT NULL, PRIMARY KEY ("id"))',
      );
      raw.execute(
        'CREATE TABLE "day_logs" ("id" TEXT NOT NULL, "user_id" TEXT NOT NULL, '
        '"run_id" TEXT NOT NULL, "day_index" INTEGER NOT NULL, "action_id" '
        'TEXT NOT NULL, "committed_at" INTEGER NULL, "outcome" TEXT NULL, '
        '"note" TEXT NULL, "updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"), '
        'UNIQUE ("run_id", "day_index"))',
      );
      raw.execute(
        'CREATE TABLE "day_log_actions" ("id" TEXT NOT NULL, "user_id" TEXT '
        'NOT NULL, "run_id" TEXT NOT NULL, "day_index" INTEGER NOT NULL, '
        '"action_id" TEXT NOT NULL, "completed" INTEGER NOT NULL DEFAULT 1, '
        '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"), '
        'UNIQUE ("run_id", "day_index", "action_id"))',
      );

      const epoch = 1780000000;
      raw.execute(
        'INSERT INTO "campaign_runs" ("id", "user_id", "campaign_id", '
        '"status", "is_hardened", "started_at", "updated_at") '
        "VALUES ('run-1', 'user-1', 'camp-1', 'active', 0, $epoch, $epoch)",
      );
      raw.execute(
        'INSERT INTO "day_logs" ("id", "user_id", "run_id", "day_index", '
        '"action_id", "outcome", "note", "updated_at") VALUES '
        "('log-1', 'user-1', 'run-1', 1, 'act-1', 'done', 'held it', $epoch), "
        "('log-2', 'user-1', 'run-1', 2, 'act-2', NULL, NULL, $epoch)",
      );
      raw.execute(
        'INSERT INTO "day_log_actions" ("id", "user_id", "run_id", '
        '"day_index", "action_id", "completed", "updated_at") '
        "VALUES ('tick-1', 'user-1', 'run-1', 1, 'act-1', 1, $epoch)",
      );
      raw.execute('PRAGMA user_version = 10');
    } finally {
      raw.close();
    }
    return file;
  }

  test('the user record survives the upgrade intact', () async {
    final file = await writeV10Database();
    final db = FeralDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final runs = await db.select(db.campaignRuns).get();
    expect(runs, hasLength(1));
    expect(runs.single.id, 'run-1');
    expect(runs.single.status, 'active');

    final logs = await db.select(db.dayLogs).get();
    expect(logs, hasLength(2));
    expect(logs.firstWhere((l) => l.dayIndex == 1).note, 'held it');
    expect(logs.firstWhere((l) => l.dayIndex == 1).outcome, 'done');

    final ticks = await db.select(db.dayLogActions).get();
    expect(ticks, hasLength(1));
    expect(ticks.single.actionId, 'act-1');
  });

  test('the new date columns arrive empty rather than invented', () async {
    // A day recorded before ADR-0040 has no honest date to claim, so the
    // migration does not guess one from the run's start plus the day index —
    // that arithmetic is exactly what ADR-0040 found to be wrong.
    final file = await writeV10Database();
    final db = FeralDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final logs = await db.select(db.dayLogs).get();
    for (final log in logs) {
      expect(log.workedOn, isNull);
      expect(log.resolvedOn, isNull);
    }
    expect((await db.select(db.campaignRuns).get()).single.abandonedOn, isNull);
  });

  test('the upgrade runs the whole ladder, not just v11', () async {
    // v11 is not the head any more, so this asserts the file is carried all the
    // way to the current version rather than restating the number this file's
    // migration happened to introduce.
    final file = await writeV10Database();
    final db = FeralDatabase(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('select 1').get();

    expect(db.schemaVersion, 12);
  });

  test(
    'action_id is nullable, so rollover can resolve an uncached day',
    () async {
      final file = await writeV10Database();
      final db = FeralDatabase(NativeDatabase(file));
      addTearDown(db.close);

      await db.customStatement(
        'INSERT INTO "day_logs" ("id", "user_id", "run_id", "day_index", '
        '"action_id", "outcome", "updated_at") '
        "VALUES ('log-3', 'user-1', 'run-1', 3, NULL, 'skipped', 1780000000)",
      );

      final log = (await db.select(db.dayLogs).get()).firstWhere(
        (l) => l.dayIndex == 3,
      );
      expect(log.actionId, isNull);
      expect(log.outcome, 'skipped');
    },
  );
}
