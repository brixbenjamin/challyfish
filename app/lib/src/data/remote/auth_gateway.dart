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
  ///
  /// [link] picks between the only two things this can mean: attaching the
  /// address to the record already on this device, or asking the account that
  /// owns the address for a way back in. They are different calls, they send
  /// different mail, and their codes verify differently — so the caller says
  /// which it wants rather than the gateway guessing.
  ///
  /// Throws [IdentityAlreadyAttached] when linking an address that belongs to
  /// someone else. That is decided before any mail is sent.
  Future<void> sendEmailCode(String email, {required bool link});
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
  Future<void> sendEmailCode(String email, {required bool link}) async {
    if (!link) {
      // shouldCreateUser is false because the only reason to be on this branch
      // is an account that already exists. Letting a typo create a new empty
      // account here would strand the record this device is holding in it.
      await _client.auth.signInWithOtp(email: email, shouldCreateUser: false);
      return;
    }
    try {
      // Attaching an address to the anonymous user is an email *change* on that
      // user, not a sign-in. It is the only form that keeps the user id, which
      // is the whole point: the record does not move (ADR-0014).
      await _client.auth.updateUser(UserAttributes(email: email));
    } on AuthException catch (e) {
      // 422 email_exists is the second-device branch, not a failure.
      if (e.code == 'email_exists' || e.statusCode == '422') {
        throw IdentityAlreadyAttached(e.message);
      }
      rethrow;
    }
  }

  @override
  Future<String> verifyEmailCode({
    required String email,
    required String code,
    required bool link,
  }) async {
    final response = await _client.auth.verifyOTP(
      email: email,
      token: code,
      // A code from an email change verifies as emailChange and a sign-in code
      // as email. The wrong type here rejects a code the user typed correctly,
      // which is indistinguishable from a wrong code at the screen.
      type: link ? OtpType.emailChange : OtpType.email,
    );
    return response.user!.id;
  }

  @override
  Future<void> signInAnonymously() => _client.auth.signInAnonymously();
}
