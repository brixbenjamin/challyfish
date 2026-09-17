import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

/// v12 drops `days.primary_archetype_id` (ADR-0041). The column existed to name
/// the one colour the One Drive Per Loop Rule permitted; with the rule retired a
/// day's drives are folded from its actions, and nothing reads it.
///
/// The content store is a cache with a server behind it, but that licenses
/// dropping a *column*, not a day: an upgrade that emptied the cache would put
/// a user who upgrades offline in front of a campaign with no days in it.
void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  /// A genuine v11 install: two cached days, one of them declaring a primary
  /// drive, at user_version 11.
  ///
  /// The DDL is hand-written rather than read from drift, because the whole
  /// point is to reproduce a schema the current code no longer declares.
  Future<File> writeV11Database() async {
    final dir = await Directory.systemTemp.createTemp('feral-v11');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    // The three user tables are untouched between v11 and v12, so their DDL is
    // read from drift rather than copied by hand -- a hand-written copy would
    // only be a second thing to keep in step. `days` is written out, because
    // reproducing a schema the current code no longer declares is the point.
    final userTables = await _schemaStatementsFor({
      'campaign_runs',
      'day_logs',
      'day_log_actions',
    });

    final raw = sqlite3.open(file.path);
    try {
      for (final statement in userTables) {
        raw.execute(statement);
      }
      raw.execute(
        'CREATE TABLE "days" ("id" TEXT NOT NULL, "campaign_id" TEXT NOT NULL, '
        '"day_index" INTEGER NOT NULL, "title" TEXT NOT NULL, "kind" TEXT NOT '
        'NULL DEFAULT \'standard\', "primary_archetype_id" TEXT NULL, '
        '"updated_at" INTEGER NOT NULL, PRIMARY KEY ("id"), '
        'UNIQUE ("campaign_id", "day_index"))',
      );

      const epoch = 1780000000;
      raw.execute(
        'INSERT INTO "days" ("id", "campaign_id", "day_index", "title", '
        '"kind", "primary_archetype_id", "updated_at") VALUES '
        "('day-1', 'camp-1', 1, 'Cold open', 'standard', 'arch-killer', $epoch), "
        "('day-2', 'camp-1', 2, 'Sit with it', 'rest', NULL, $epoch)",
      );
      raw.execute('PRAGMA user_version = 11');
    } finally {
      raw.close();
    }
    return file;
  }

  test('the cached days survive the upgrade', () async {
    final file = await writeV11Database();
    final db = FeralDatabase(NativeDatabase(file));
    addTearDown(db.close);

    final days = await db.select(db.days).get();
    expect(days, hasLength(2));
    expect(days.firstWhere((d) => d.dayIndex == 1).title, 'Cold open');
    expect(days.firstWhere((d) => d.dayIndex == 2).kind, 'rest');
  });

  test('primary_archetype_id is gone from the file', () async {
    final file = await writeV11Database();
    final db = FeralDatabase(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('select 1').get();

    final columns = await db
        .customSelect("select name from pragma_table_info('days')")
        .get();
    final names = columns.map((row) => row.read<String>('name')).toSet();

    expect(names, isNot(contains('primary_archetype_id')));
    expect(names, containsAll(['id', 'campaign_id', 'day_index', 'kind']));
  });

  test(
    'the day keeps its natural key, so a re-issued day still updates',
    () async {
      final file = await writeV11Database();
      final db = FeralDatabase(NativeDatabase(file));
      addTearDown(db.close);
      await db.customSelect('select 1').get();

      // The unique key is what makes a re-issued day an update rather than a
      // duplicate. A table rebuilt without it would fail silently for a whole
      // refresh cycle, so it is asserted rather than assumed.
      await expectLater(
        db.customStatement(
          'INSERT INTO "days" ("id", "campaign_id", "day_index", "title", '
          '"kind", "updated_at") '
          "VALUES ('day-other', 'camp-1', 1, 'Duplicate', 'standard', 1780000000)",
        ),
        throwsA(isA<SqliteException>()),
      );
    },
  );

  test('the upgrade lands on the current schema version', () async {
    final file = await writeV11Database();
    final db = FeralDatabase(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('select 1').get();

    expect(db.schemaVersion, 12);
  });
}

/// Reads the create statements drift emits for [tables], indexes included.
Future<List<String>> _schemaStatementsFor(Set<String> tables) async {
  final probe = FeralDatabase(NativeDatabase.memory());
  try {
    final rows = await probe
        .customSelect(
          'SELECT sql, tbl_name FROM sqlite_master WHERE sql IS NOT NULL',
        )
        .get();
    return [
      for (final row in rows)
        if (tables.contains(row.read<String>('tbl_name')))
          row.read<String>('sql'),
    ];
  } finally {
    await probe.close();
  }
}
