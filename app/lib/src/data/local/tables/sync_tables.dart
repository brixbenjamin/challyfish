import 'package:drift/drift.dart';

/// One row per synced table, holding the newest `updated_at` this device has
/// committed locally.
///
/// This is a watermark, not a clock reading: it is the newest row seen, not the
/// time the sync ran. The difference is what makes an interrupted pull safe to
/// retry — a clock reading would silently skip the rows that were fetched but
/// never written.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  /// The remote table name, e.g. `campaigns` or `day_logs`.
  ///
  /// Named `syncTable` in Dart because `tableName` is drift's own hook for
  /// overriding a table's SQL name; the column itself is still `table_name`.
  TextColumn get syncTable => text().named('table_name')();

  /// Newest `updated_at` committed locally. Null means "never pulled".
  DateTimeColumn get watermark => dateTime().nullable()();

  /// When the last successful pull for this table finished. Diagnostics only —
  /// never used to decide what to fetch.
  DateTimeColumn get lastPulledAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {syncTable};
}
