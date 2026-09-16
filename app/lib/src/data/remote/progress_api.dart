import 'package:supabase_flutter/supabase_flutter.dart';

/// The narrow seam between the sync repository and Supabase.
///
/// It is an interface so every sync rule can be tested against a fake. The
/// implementation holds no logic: if a decision is being made in
/// [SupabaseProgressApi], it is in the wrong file.
abstract class ProgressApi {
  Future<void> upsert(String table, List<Map<String, dynamic>> rows);

  /// Every row of [table] belonging to [userId].
  ///
  /// Complete, not incremental. Filtering on `updated_at` cannot observe a
  /// deletion — a deleted row carries no newer timestamp — so a row removed on
  /// the server would survive on this device forever.
  Future<List<Map<String, dynamic>>> fetchAllFor(String table, String userId);
}

class SupabaseProgressApi implements ProgressApi {
  SupabaseProgressApi(this._client);

  final SupabaseClient _client;

  /// How many rows one request asks for. A user generates roughly one day log a
  /// day, so this is years of record per round trip, and the keyset below means
  /// the number bounds the request rather than the answer.
  static const _pageSize = 1000;

  /// The natural key each table is upserted on. `day_logs` is deliberately not
  /// `id`: two offline devices generate different uuids for the same day, and
  /// `(run_id, day_index)` is what actually identifies it.
  static const _conflictTargets = <String, String>{
    'profiles': 'user_id',
    'campaign_runs': 'id',
    'day_logs': 'run_id,day_index',
    'day_log_actions': 'run_id,day_index,action_id',
    'diagnostic_results': 'id',
  };

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) return;
    await _client.from(table).upsert(rows, onConflict: _conflictTargets[table]);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAllFor(
    String table,
    String userId,
  ) async {
    // Keyset on `updated_at`, not an offset: rows written while this loop runs
    // would shift an offset and make it skip one. Paging until a short page
    // arrives, so a long-standing record is fetched in full rather than
    // truncated at the limit the way a single capped request would truncate it.
    final out = <Map<String, dynamic>>[];
    String? after;
    while (true) {
      var query = _client.from(table).select().eq('user_id', userId);
      if (after != null) query = query.gt('updated_at', after);
      final page = await query.order('updated_at').limit(_pageSize);
      final rows = page.cast<Map<String, dynamic>>();
      out.addAll(rows);
      if (rows.length < _pageSize) break;

      final last = rows.last['updated_at'] as String;
      // Rows sharing the cutoff timestamp would page forever. Not expected for a
      // per-user record, but a loop that can never end is worse than a rare
      // duplicate, and the caller upserts.
      if (last == after) break;
      after = last;
    }
    return out;
  }
}
