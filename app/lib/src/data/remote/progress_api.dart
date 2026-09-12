import 'package:supabase_flutter/supabase_flutter.dart';

/// The narrow seam between the sync repository and Supabase.
///
/// It is an interface so every sync rule can be tested against a fake. The
/// implementation holds no logic: if a decision is being made in
/// [SupabaseProgressApi], it is in the wrong file.
abstract class ProgressApi {
  Future<void> upsert(String table, List<Map<String, dynamic>> rows);

  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  );
}

class SupabaseProgressApi implements ProgressApi {
  SupabaseProgressApi(this._client);

  final SupabaseClient _client;

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
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async {
    final query = _client.from(table).select().eq('user_id', userId);
    final rows = since == null
        ? await query.order('updated_at').limit(1000)
        : await query
              .gt('updated_at', since.toUtc().toIso8601String())
              .order('updated_at')
              .limit(1000);
    return rows.cast<Map<String, dynamic>>();
  }
}
