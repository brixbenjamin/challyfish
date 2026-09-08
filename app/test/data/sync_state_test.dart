import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  // The v2 probe below opens a second FeralDatabase on its own executor, the
  // same way database_migration_test does.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  test('a watermark survives closing and reopening the database', () async {
    final dir = Directory.systemTemp.createTempSync('feral_watermark');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    var db = FeralDatabase(NativeDatabase(file));
    await db.setWatermark('campaigns', DateTime.utc(2026, 6, 1, 12));
    expect(await db.watermarkFor('campaigns'), DateTime.utc(2026, 6, 1, 12));
    await db.close();

    db = FeralDatabase(NativeDatabase(file));
    expect(
      await db.watermarkFor('campaigns'),
      DateTime.utc(2026, 6, 1, 12),
      reason: 'the whole point: it is database state, not heap state',
    );
    await db.close();

    final fresh = FeralDatabase(NativeDatabase.memory());
    expect(
      await fresh.watermarkFor('campaigns'),
      isNull,
      reason: 'a genuinely fresh database has no watermark',
    );
    await fresh.close();
  });

  test('an unknown table has a null watermark rather than throwing', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    expect(await db.watermarkFor('nothing_here'), isNull);
    await db.close();
  });

  test('setting a watermark twice keeps the latest value', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    await db.setWatermark('actions', DateTime.utc(2026, 6, 1));
    await db.setWatermark('actions', DateTime.utc(2026, 6, 8));
    expect(await db.watermarkFor('actions'), DateTime.utc(2026, 6, 8));
    await db.close();
  });

  test('a profile round-trips and starts dirty', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            userId: 'user-1',
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    final row = await db.select(db.profiles).getSingle();
    expect(row.userId, 'user-1');
    expect(row.onboardedAt, isNull);
    expect(row.dirty, isTrue);
    await db.close();
  });

  test('upgrading from v2 adds the new tables and keeps existing rows', () async {
    // A plan 2 install left a real v2 file behind. Opening it at v3 must run
    // the migration over that file rather than create the schema afresh.
    final dir = Directory.systemTemp.createTempSync('feral_v3_migration');
    addTearDown(() => dir.deleteSync(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    await _writeV2Database(file);

    final upgraded = FeralDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    final runs = await upgraded.select(upgraded.campaignRuns).get();
    final logs = await upgraded.select(upgraded.dayLogs).get();
    expect(runs, hasLength(1), reason: 'the run survived the migration');
    expect(logs, hasLength(1), reason: 'the day log survived the migration');
    expect(logs.single.note, 'kept across the migration');
    expect(await upgraded.select(upgraded.profiles).get(), isEmpty);
    expect(await upgraded.watermarkFor('campaigns'), isNull);
  });
}

/// The tables added at schema v3, which a v2 file must not have.
const _v3Tables = {'profiles', 'sync_state'};

/// Writes a genuine v2 file: every v2 table at user_version 2, with a run and a
/// day log in them.
///
/// As in database_migration_test, the DDL comes from drift's own schema rather
/// than being hand-copied, so the probe cannot drift out of step.
Future<void> _writeV2Database(File file) async {
  final ddl = await _v2SchemaStatements();

  final raw = sqlite3.open(file.path);
  try {
    for (final statement in ddl) {
      raw.execute(statement);
    }
    final at = DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO campaign_runs '
      '(id, user_id, campaign_id, status, is_hardened, started_at, updated_at, dirty) '
      "VALUES ('run-keep', 'user-1', 'campaign-1', 'active', 0, $at, $at, 1)",
    );
    raw.execute(
      'INSERT INTO day_logs '
      '(id, user_id, run_id, day_index, action_id, note, updated_at, dirty) '
      "VALUES ('log-keep', 'user-1', 'run-keep', 1, 'action-1', "
      "'kept across the migration', $at, 1)",
    );
    raw.execute('PRAGMA user_version = 2');
  } finally {
    raw.close();
  }
}

Future<List<String>> _v2SchemaStatements() async {
  final probe = FeralDatabase(NativeDatabase.memory());
  try {
    final rows = await probe
        .customSelect(
          'SELECT sql, tbl_name FROM sqlite_master WHERE sql IS NOT NULL',
        )
        .get();
    return [
      for (final row in rows)
        if (!_v3Tables.contains(row.read<String>('tbl_name')))
          row.read<String>('sql'),
    ];
  } finally {
    await probe.close();
  }
}
