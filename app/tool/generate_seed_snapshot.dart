// Regenerates the bundled first-launch content from the local Supabase stack.
//
// Run with `supabase start` up, from the app directory:
//   cd app && dart run tool/generate_seed_snapshot.dart
//
// The output is checked in. Regenerate it whenever core content changes; a
// stale snapshot is a release-time concern, not a runtime one, because the
// watermark pull reconciles it on first connection.
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
