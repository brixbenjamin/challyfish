import 'package:drift/drift.dart';

/// Writes this device owes the server, in the order they were made.
///
/// This replaces a `dirty` boolean on every user table. The flag had to be
/// cleared only where `updated_at` still matched what the push had read, because
/// a write landing mid-push would otherwise be marked clean without ever being
/// sent. A queue has no such race: an entry is removed when the server has
/// acknowledged that entry, and nothing else can mark it done.
///
/// [id] is the order. It is also why there is no push-order list any more: a run
/// is queued before the day logs under it, so ascending id already satisfies the
/// foreign keys the server enforces.
@DataClassName('OutboxRow')
class Outbox extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// The remote table this row belongs to, e.g. `day_logs`.
  ///
  /// Named `remoteTable` in Dart because `tableName` is drift's own hook for
  /// overriding a table's SQL name; the column itself is still `table_name`.
  TextColumn get remoteTable => text().named('table_name')();

  /// The row's natural key — what identifies it on the server, which for
  /// `day_logs` is `(run_id, day_index)` and never the client's uuid.
  TextColumn get rowKey => text()();

  /// The complete row to upsert, as JSON.
  TextColumn get payload => text()();

  DateTimeColumn get queuedAt => dateTime()();

  /// One pending entry per row, so a day ticked and unticked before the next
  /// sync costs one round trip carrying the final state rather than two
  /// carrying a contradiction. The entry keeps its original [id] when its
  /// payload is replaced, which is what preserves the foreign-key ordering.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {remoteTable, rowKey},
  ];
}
