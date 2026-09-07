import 'package:supabase_flutter/supabase_flutter.dart';

/// Content sync is pull-only. The client never writes these tables.
abstract class ContentApi {
  Future<List<Map<String, dynamic>>> fetchSince(String table, DateTime? since);
}

class SupabaseContentApi implements ContentApi {
  SupabaseContentApi(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async {
    final query = _client.from(table).select();
    final rows = since == null
        ? await query.order('updated_at')
        : await query
              .gt('updated_at', since.toIso8601String())
              .order('updated_at');
    return rows.cast<Map<String, dynamic>>();
  }
}
