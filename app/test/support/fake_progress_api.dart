import 'package:feral/src/data/remote/progress_api.dart';

/// Shared by every sync test. It records what was asked of it and can be made
/// to fail in the specific ways the real API fails.
class FakeProgressApi implements ProgressApi {
  FakeProgressApi([Map<String, List<Map<String, dynamic>>>? rows]) {
    if (rows != null) remote.addAll(rows);
  }

  final List<({String table, List<Map<String, dynamic>> rows})> pushes = [];
  final Map<String, List<Map<String, dynamic>>> remote = {};
  final List<String> callLog = [];

  /// Tables a fetch was asked for, in order. Separate from [callLog] because
  /// the entitlement tests care about which tables were asked for and not about
  /// the pushes interleaved with them.
  final List<String> asked = [];

  Object? throwOnUpsert;
  final Map<String, Object> throwOnUpsertForTable = {};
  Object? failFetch;
  final Map<String, Object> failFetchForTable = {};

  /// Runs while a push for [table] is in flight — after its rows have been
  /// read, before the flags are cleared. The only way to write the race that
  /// matters here, since drift serializes statements on one queue.
  Future<void> Function(String table)? whileUpserting;

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    callLog.add('upsert:$table');
    await whileUpserting?.call(table);
    final perTable = throwOnUpsertForTable[table];
    if (perTable != null) throw perTable;
    if (throwOnUpsert != null) throw throwOnUpsert!;
    pushes.add((table: table, rows: rows));
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllFor(
    String table,
    String userId,
  ) async {
    callLog.add('fetch:$table');
    asked.add(table);
    final perTable = failFetchForTable[table];
    if (perTable != null) throw perTable;
    if (failFetch != null) throw failFetch!;
    return remote[table] ?? const [];
  }
}
