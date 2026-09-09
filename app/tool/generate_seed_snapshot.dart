// Regenerates the bundled first-launch content from the local Supabase stack.
//
// Run with `supabase start` up, from the app directory:
//   cd app && dart run tool/generate_seed_snapshot.dart
//
// The output is checked in. Regenerate it whenever core content changes.
//
// A stale snapshot used to be described here as a release-time concern that the
// watermark pull reconciles on first connection. It is not, and that sentence
// cost a day: the pull reconciles values, not identities. Ids are what the
// snapshot pins, so every seeded row needs an id that is a function of its
// content rather than of when the database was created — see the header of
// supabase/seed/actions.sql. Ids are now stable across a `db reset`; the
// created_at/updated_at columns still are not, so regenerating always produces
// a diff. That is fine, and the distinction is the whole point: the pull
// reconciles timestamps on its own, and cannot reconcile an id.
import 'dart:convert';
import 'dart:io';

import 'package:postgres/postgres.dart';

const tables = [
  'archetypes',
  'packs',
  'campaigns',
  'campaign_archetypes',
  'actions',
  'doctrine_groups',
  'doctrine_entries',
  'diagnostic_questions',
  'diagnostic_options',
];

Future<void> main() async {
  final connection = await Connection.open(
    Endpoint(
      host: '127.0.0.1',
      port: 54322,
      database: 'postgres',
      username: 'postgres',
      password: 'postgres',
    ),
    settings: const ConnectionSettings(sslMode: SslMode.disable),
  );

  final snapshot = <String, dynamic>{};
  for (final table in tables) {
    // row_to_json rather than a column map: Postgres renders each type the same
    // way PostgREST does over the wire, so the snapshot and a network pull
    // deliver identical shapes to the same descriptors. Reading columns through
    // the driver instead hands back `numeric` as a Dart String, which the
    // descriptors reject — a divergence no fabricated fixture would reveal.
    final rows = await connection.execute(
      'select row_to_json(t) from public.$table t',
    );
    snapshot[table] = [for (final row in rows) row[0]! as Map<String, dynamic>];
    stdout.writeln('$table: ${rows.length} row(s)');
  }
  await connection.close();

  final file = File('assets/seed/core_content.json');
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(snapshot),
  );
  stdout.writeln('wrote ${file.path}');
}
