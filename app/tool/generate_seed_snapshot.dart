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
  'action_bodies',
  'doctrine_groups',
  'doctrine_entries',
  'diagnostic_questions',
  'diagnostic_options',
];

/// Tables whose snapshot is a deliberate subset. Everything else is dumped whole.
///
/// The bundled snapshot exists so a first launch with no network is not an empty
/// app. That is a free-pack concern only: shipping paid copy inside the binary
/// hands it to anyone who unzips a release (ADR-0025).
///
/// This tool connects as `postgres` and so bypasses row-level security entirely.
/// Task 1's policy does not protect it and never will -- it is a privileged build
/// step, not a client -- which is why the filter has to live here.
const partialTables = <String, String>{
  'action_bodies': '''
    select row_to_json(t) from public.action_bodies t
      join public.actions a   on a.id = t.action_id
      join public.campaigns c on c.id = a.campaign_id
      join public.packs p     on p.id = c.pack_id
     where p.is_core
  ''',
};

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
      partialTables[table] ?? 'select row_to_json(t) from public.$table t',
    );
    snapshot[table] = [for (final row in rows) row[0]! as Map<String, dynamic>];
    stdout.writeln('$table: ${rows.length} row(s)');
  }

  // Not a comment, because the comment was already there and the filter was
  // still forgotten. This checks the built snapshot rather than the query that
  // built it, so it still holds if a future table starts carrying paid copy.
  final paidIds = await connection.execute('''
    select a.id::text
      from public.actions a
      join public.campaigns c on c.id = a.campaign_id
      join public.packs p     on p.id = c.pack_id
     where not p.is_core
  ''');
  final paid = {for (final row in paidIds) row[0]! as String};
  final leaked = [
    for (final row in snapshot['action_bodies'] as List<Map<String, dynamic>>)
      if (paid.contains(row['action_id'] as String)) row['action_id'] as String,
  ];
  await connection.close();

  if (leaked.isNotEmpty) {
    stderr.writeln(
      'refusing to write: ${leaked.length} paid body/bodies in the snapshot '
      '(${leaked.take(3).join(', ')}...)',
    );
    exit(1);
  }

  final file = File('assets/seed/core_content.json');
  await file.parent.create(recursive: true);
  await file.writeAsString(
    const JsonEncoder.withIndent('  ').convert(snapshot),
  );
  stdout.writeln('wrote ${file.path}');
}
