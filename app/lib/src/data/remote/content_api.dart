import 'package:supabase_flutter/supabase_flutter.dart';

/// Content sync is pull-only. The client never writes these tables.
///
/// Fetches are whole-table rather than incremental. An incremental fetch filters
/// on `updated_at`, and a deleted row carries no newer `updated_at` — so it can
/// never observe a deletion, and a campaign removed on the server survived on
/// every device that had already pulled it. [fetchVersion] is what keeps the
/// whole-table fetch cheap: it moves on any content write, deletes included, so
/// the library is refetched when it changed and not on a timer.
abstract class ContentApi {
  /// Every row of [table] this caller may read. The two body tables are gated by
  /// row-level security, so "every row" is already per-user (ADR-0025, ADR-0034).
  Future<List<Map<String, dynamic>>> fetchAll(String table);

  /// The server's current content version.
  Future<int> fetchVersion();
}

class SupabaseContentApi implements ContentApi {
  SupabaseContentApi(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async {
    final rows = await _client.from(table).select().order('updated_at');
    return rows.cast<Map<String, dynamic>>();
  }

  @override
  Future<int> fetchVersion() async {
    final row = await _client
        .from('content_version')
        .select('version')
        .single();
    return (row['version'] as num).toInt();
  }
}
