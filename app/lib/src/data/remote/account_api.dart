import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AccountApi {
  /// Deletes the calling user's own account. No parameter is sent, because the
  /// function takes none (ADR-0015).
  Future<void> deleteAccount();
}

class SupabaseAccountApi implements AccountApi {
  SupabaseAccountApi(this._client);

  final SupabaseClient _client;

  @override
  Future<void> deleteAccount() async {
    final response = await _client.functions.invoke('delete-account');
    if (response.status != 204 && response.status != 200) {
      throw AccountDeletionFailed('delete-account returned ${response.status}');
    }
  }
}

class AccountDeletionFailed implements Exception {
  const AccountDeletionFailed(this.message);
  final String message;

  @override
  String toString() => 'AccountDeletionFailed: $message';
}
