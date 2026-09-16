import 'package:drift/drift.dart';

/// Small facts this device remembers about itself, keyed by name.
///
/// Replaces the per-table `sync_state` watermarks, which existed to make an
/// incremental content pull possible and could not survive their own design: a
/// mark is a claim that everything older has been seen, and a deletion makes
/// nothing older. There is one fact here now — the content version this device
/// has cached — and a key/value shape so the next one does not need a migration.
@DataClassName('ClientStateRow')
class ClientState extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}
