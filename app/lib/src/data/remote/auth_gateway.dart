import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/identity.dart';

/// The seam over Supabase Auth. No decisions live here — the link-versus-sign-in
/// rule is IdentityRepository's, and it is tested against a fake of this.
abstract class AuthGateway {
  String? get currentUserId;
  LinkedIdentity? get linkedIdentity;

  Future<void> linkIdentity(AuthProvider provider, Object credential);
  Future<String> signIn(AuthProvider provider, Object credential);

  /// Email is a six-digit code, never a magic link. No redirect URL is passed
  /// anywhere, because the app handles no deep links (ADR-0016).
  Future<void> sendEmailCode(String email);
  Future<String> verifyEmailCode({
    required String email,
    required String code,
    required bool link,
  });

  Future<void> signInAnonymously();
}

class SupabaseAuthGateway implements AuthGateway {
  SupabaseAuthGateway(this._client);

  final SupabaseClient _client;

  @override
  String? get currentUserId => _client.auth.currentUser?.id;

  @override
  LinkedIdentity? get linkedIdentity {
    final user = _client.auth.currentUser;
    if (user == null || user.isAnonymous) return null;
    final identities = user.identities;
    final identity = (identities == null || identities.isEmpty)
        ? null
        : identities.first;
    final provider = switch (identity?.provider) {
      'apple' => AuthProvider.apple,
      'google' => AuthProvider.google,
      _ => AuthProvider.email,
    };
    return LinkedIdentity(
      provider: provider,
      label: user.email ?? provider.name,
    );
  }

  OAuthProvider _oauth(AuthProvider provider) => switch (provider) {
    AuthProvider.apple => OAuthProvider.apple,
    AuthProvider.google => OAuthProvider.google,
    AuthProvider.email => throw ArgumentError('email is not an OAuth provider'),
  };

  @override
  Future<void> linkIdentity(AuthProvider provider, Object credential) async {
    try {
      final token = credential as AppleGoogleToken;
      await _client.auth.linkIdentityWithIdToken(
        provider: _oauth(provider),
        idToken: token.idToken,
        accessToken: token.accessToken,
        nonce: token.nonce,
      );
    } on AuthException catch (e) {
      // Supabase reports a taken identity as a 422. It is the expected
      // second-device branch, so it is translated rather than thrown on.
      if (e.code == 'identity_already_exists' || e.statusCode == '422') {
        throw IdentityAlreadyAttached(e.message);
      }
      rethrow;
    }
  }

  @override
  Future<String> signIn(AuthProvider provider, Object credential) async {
    final token = credential as AppleGoogleToken;
    final response = await _client.auth.signInWithIdToken(
      provider: _oauth(provider),
      idToken: token.idToken,
      accessToken: token.accessToken,
      nonce: token.nonce,
    );
    return response.user!.id;
  }

  @override
  Future<void> sendEmailCode(String email) =>
      _client.auth.signInWithOtp(email: email);

  @override
  Future<String> verifyEmailCode({
    required String email,
    required String code,
    required bool link,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: code,
      type: OtpType.email,
    );
    return response.user!.id;
  }

  @override
  Future<void> signInAnonymously() => _client.auth.signInAnonymously();
}
