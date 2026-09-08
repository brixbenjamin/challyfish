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

  test('schemaVersion is 2', () {
    expect(db.schemaVersion, 2);
  });

  test('the new content tables exist and are empty', () async {
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
            scores:
                '{"psycho":0.25,"killer":0.75,"alchemist":0.5,"creature":0.5}',
            weakestArchetypeId: 'arch-psycho',
            recommendedCampaignId: 'campaign-1',
            updatedAt: DateTime.utc(2026, 6, 1, 9),
          ),
        );

    final stored = await db.select(db.diagnosticResults).getSingle();
    expect(stored.weakestArchetypeId, 'arch-psycho');
    expect(stored.dirty, isTrue);
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

    await _writeV1Database(file);

    final migrated = FeralDatabase(NativeDatabase(file));
    addTearDown(migrated.close);

    final runs = await migrated.select(migrated.campaignRuns).get();
    final logs = await migrated.select(migrated.dayLogs).get();
    expect(runs, hasLength(1), reason: 'the run survived the migration');
    expect(logs, hasLength(1), reason: 'the day log survived the migration');
    expect(await migrated.select(migrated.doctrineGroups).get(), isEmpty);
    expect(await migrated.select(migrated.diagnosticQuestions).get(), isEmpty);
  });
}

/// The tables that existed at schema v1, before this plan.
const _v1Tables = {
  'archetypes',
  'packs',
  'campaigns',
  'actions',
  'campaign_runs',
  'day_logs',
};

/// Writes a genuine v1 file: the v1 tables only, at user_version 1, with a run
/// and a day log in them.
///
/// The DDL is taken from drift's own schema rather than hand-copied, so the
/// probe cannot quietly drift out of step with the tables it is imitating.
Future<void> _writeV1Database(File file) async {
  final ddl = await _v1SchemaStatements();

  final raw = sqlite3.open(file.path);
  try {
    for (final statement in ddl) {
      raw.execute(statement);
    }
    final at = DateTime.utc(2026, 6, 1, 9).millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO campaign_runs '
      '(id, user_id, campaign_id, status, is_hardened, started_at, updated_at, dirty) '
      "VALUES ('legacy-run', 'user-1', 'campaign-1', 'active', 0, $at, $at, 1)",
    );
    raw.execute(
      'INSERT INTO day_logs '
      '(id, user_id, run_id, day_index, action_id, updated_at, dirty) '
      "VALUES ('legacy-log', 'user-1', 'legacy-run', 1, 'action-1', $at, 1)",
    );
    raw.execute('PRAGMA user_version = 1');
  } finally {
    raw.close();
  }
}

/// Reads the create statements drift emits, keeping only the v1 tables and the
/// indexes that belong to them.
Future<List<String>> _v1SchemaStatements() async {
  final probe = FeralDatabase(NativeDatabase.memory());
  try {
    final rows = await probe
        .customSelect(
          'SELECT sql, tbl_name FROM sqlite_master WHERE sql IS NOT NULL',
        )
        .get();
    return [
      for (final row in rows)
        if (_v1Tables.contains(row.read<String>('tbl_name')))
          row.read<String>('sql'),
    ];
  } finally {
    await probe.close();
  }
}
