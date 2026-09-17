import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

void main() {
  // The probe below opens a second FeralDatabase on its own executor. That is
  // safe, but drift cannot tell the difference and warns loudly enough to bury
  // the rest of the suite's output.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('schemaVersion is 11', () {
    expect(db.schemaVersion, 11);
  });

  test('the new content tables exist and are empty', () async {
    expect(await db.select(db.actionBodies).get(), isEmpty);
    expect(await db.select(db.campaignArchetypes).get(), isEmpty);
    expect(await db.select(db.doctrineGroups).get(), isEmpty);
    expect(await db.select(db.doctrineEntries).get(), isEmpty);
    expect(await db.select(db.diagnosticQuestions).get(), isEmpty);
    expect(await db.select(db.diagnosticOptions).get(), isEmpty);
  });

  test('a diagnostic result round-trips with its scores', () async {
    await db
        .into(db.diagnosticResults)
        .insert(
          DiagnosticResultsCompanion.insert(
            id: 'dr-1',
            userId: 'user-1',
            takenAt: DateTime.utc(2026, 6, 1, 9),
            scores: '{"psycho":0.25,"killer":0.75,"trickster":0.5,"beast":0.5}',
            weakestArchetypeId: 'arch-psycho',
            recommendedCampaignId: 'campaign-1',
            updatedAt: DateTime.utc(2026, 6, 1, 9),
          ),
        );

    final stored = await db.select(db.diagnosticResults).getSingle();
    expect(stored.weakestArchetypeId, 'arch-psycho');
  });

  test('the upgrade turns unsent dirty rows into queue entries', () async {
    // The worst thing this upgrade could do quietly. `dirty` was the only record
    // that the server had not seen a row; dropping the column without draining it
    // would leave the rows in place and nothing to say they were still owed, so
    // the user's last offline day would never be sent and nothing would report it.
    final dir = await Directory.systemTemp.createTemp(
      'feral-migration-v3-owed',
    );
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    await _writeLegacyDatabase(file, tables: _v3Tables, version: 3);

    final migrated = FeralDatabase(NativeDatabase(file));
    addTearDown(migrated.close);

    final owed = await (migrated.select(
      migrated.outbox,
    )..orderBy([(o) => OrderingTerm.asc(o.id)])).get();

    expect(
      owed.map((o) => o.remoteTable),
      ['campaign_runs', 'day_logs'],
      reason: 'the run before the day log, as the foreign keys require',
    );
    expect(owed.map((o) => o.rowKey), ['legacy-run', 'legacy-run:1']);

    // The day log is keyed on (run_id, day_index), never the uuid.
    final log = owed.last;
    expect(jsonDecode(log.payload), containsPair('id', 'legacy-log'));
  });

  test('a row the server had already seen is not queued', () async {
    final dir = await Directory.systemTemp.createTemp('feral-migration-clean');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    await _writeLegacyDatabase(
      file,
      tables: _v3Tables,
      version: 3,
      dirty: false,
    );

    final migrated = FeralDatabase(NativeDatabase(file));
    addTearDown(migrated.close);

    // Queueing every row regardless would re-upload a user's whole history on
    // upgrade, for nothing.
    expect(await migrated.select(migrated.outbox).get(), isEmpty);
    expect(await migrated.select(migrated.campaignRuns).get(), hasLength(1));
  });

  test('two options cannot occupy the same side of a question', () async {
    Future<void> insertOption(String id, int sort) => db
        .into(db.diagnosticOptions)
        .insert(
          DiagnosticOptionsCompanion.insert(
            id: id,
            questionId: 'q-1',
            label: 'l',
            archetypeId: 'arch-1',
            sort: sort,
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );

    await insertOption('o-1', 0);
    expect(insertOption('o-2', 0), throwsA(isA<SqliteException>()));
  });

  test('a v1 database migrates to v2 without losing progress', () async {
    // A plan 1 install left a real v1 file behind: the six v1 tables, a run and
    // a day log in them, and user_version 1. Opening it at v2 must run the
    // migration over that file rather than create the schema afresh.
    final dir = await Directory.systemTemp.createTemp('feral-migration');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    await _writeLegacyDatabase(file, tables: _v1Tables, version: 1);

    final migrated = FeralDatabase(NativeDatabase(file));
    addTearDown(migrated.close);

    final runs = await migrated.select(migrated.campaignRuns).get();
    final logs = await migrated.select(migrated.dayLogs).get();
    expect(runs, hasLength(1), reason: 'the run survived the migration');
    expect(logs, hasLength(1), reason: 'the day log survived the migration');
    expect(await migrated.select(migrated.doctrineGroups).get(), isEmpty);
    expect(await migrated.select(migrated.diagnosticQuestions).get(), isEmpty);
  });

  test('a v3 database migrates to v4 without losing progress', () async {
    // The migration that adds entitlements claims to be additive. A day log
    // written before the upgrade is the thing that claim is about, so it is
    // the thing the test holds on to.
    final dir = await Directory.systemTemp.createTemp('feral-migration-v3');
    addTearDown(() => dir.delete(recursive: true));
    final file = File('${dir.path}/feral.sqlite');

    await _writeLegacyDatabase(file, tables: _v3Tables, version: 3);

    final migrated = FeralDatabase(NativeDatabase(file));
    addTearDown(migrated.close);

    expect(
      await migrated.select(migrated.campaignRuns).get(),
      hasLength(1),
      reason: 'the run survived the migration',
    );
    expect(
      await migrated.select(migrated.dayLogs).get(),
      hasLength(1),
      reason: 'the day log survived the migration',
    );
    expect(
      await migrated.select(migrated.entitlements).get(),
      isEmpty,
      reason: 'the new table exists and starts empty',
    );
  });
}

/// The tables that existed at schema v1, before plan 2.
const _v1Tables = {
  'archetypes',
  'packs',
  'campaigns',
  'actions',
  'campaign_runs',
  'day_logs',
};

/// The tables that existed at schema v3, before plan 4 added entitlements.
const _v3Tables = {
  ..._v1Tables,
  'campaign_archetypes',
  'doctrine_groups',
  'doctrine_entries',
  'diagnostic_questions',
  'diagnostic_options',
  'diagnostic_results',
  'profiles',
  'sync_state',
};

/// Writes a genuine file at an earlier schema version: [tables] only, at
/// `user_version` [version], with a run and a day log in them.
///
/// The DDL is taken from drift's own schema rather than hand-copied, so the
/// probe cannot quietly drift out of step with the tables it is imitating.
Future<void> _writeLegacyDatabase(
  File file, {
  required Set<String> tables,
  required int version,
  bool dirty = true,
}) async {
  final ddl = await _schemaStatementsFor(tables);

  final raw = sqlite3.open(file.path);
  try {
    for (final statement in ddl) {
      raw.execute(statement);
    }

    // Two things the current schema can no longer describe, which a genuine file
    // at this version certainly had. Taking the DDL from drift keeps the probe
    // honest about everything that still exists; these are what v10 removed, so
    // they have to be put back by hand or the fixture is not the file it claims
    // to be -- and the v10 step would have nothing to migrate.
    for (final table in const [
      'campaign_runs',
      'day_logs',
      'day_log_actions',
      'diagnostic_results',
      'profiles',
    ]) {
      if (!tables.contains(table)) continue;
      raw.execute(
        'ALTER TABLE $table ADD COLUMN dirty INTEGER NOT NULL DEFAULT 1',
      );
    }
    if (tables.contains('sync_state')) {
      raw.execute(
        'CREATE TABLE sync_state (table_name TEXT NOT NULL PRIMARY KEY, '
        'watermark INTEGER NULL, last_pulled_at INTEGER NULL)',
      );
    }

    final at = DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO campaign_runs '
      '(id, user_id, campaign_id, status, is_hardened, started_at, updated_at, dirty) '
      "VALUES ('legacy-run', 'user-1', 'campaign-1', 'active', 0, $at, $at, "
      '${dirty ? 1 : 0})',
    );
    raw.execute(
      'INSERT INTO day_logs '
      '(id, user_id, run_id, day_index, action_id, updated_at, dirty) '
      "VALUES ('legacy-log', 'user-1', 'legacy-run', 1, 'action-1', $at, "
      '${dirty ? 1 : 0})',
    );
    raw.execute('PRAGMA user_version = $version');
  } finally {
    raw.close();
  }
}

/// Reads the create statements drift emits, keeping only [tables] and the
/// indexes that belong to them.
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
