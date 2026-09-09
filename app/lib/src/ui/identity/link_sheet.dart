import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/l10n_ext.dart';
import '../../domain/identity.dart';

/// Why the sheet is open. The providers and the mechanics are identical; the
/// words are not. [keep] is offered to a user whose record is on this phone and
/// who might lose it; [signIn] to a user whose record is on an account and who
/// wants it here.
enum LinkPurpose { keep, signIn }

class LinkSheet extends StatelessWidget {
  const LinkSheet({
    required this.providers,
    required this.onChoose,
    required this.onCancel,
    this.purpose = LinkPurpose.keep,
    super.key,
  });

  final List<AuthProvider> providers;
  final LinkPurpose purpose;
  final void Function(AuthProvider) onChoose;
  final VoidCallback onCancel;

  static const cancelKey = Key('link-cancel'); // niche:allow widget key
  static const explanationKey = Key('link-explanation'); // niche:allow key

  static Key keyFor(AuthProvider p) => Key('link-${p.name}'); // niche:allow key

  /// Takes the bundle rather than reading a literal per provider: every word a
  /// user sees comes from one file (ADR-0022).
  static String labelFor(AppLocalizations l10n, AuthProvider p) => switch (p) {
    AuthProvider.apple => l10n.continueWithApple,
    AuthProvider.google => l10n.continueWithGoogle,
    AuthProvider.email => l10n.continueWithEmail,
  };

  /// Chosen here rather than passed in, for the same reason as [labelFor]:
  /// every word a user sees comes from one file (ADR-0022).
  String _title(AppLocalizations l10n) => switch (purpose) {
    LinkPurpose.keep => l10n.linkSheetTitle,
    LinkPurpose.signIn => l10n.signInSheetTitle,
  };

  String _body(AppLocalizations l10n) => switch (purpose) {
    LinkPurpose.keep => l10n.linkSheetBody,
    LinkPurpose.signIn => l10n.signInSheetBody,
  };

  /// App Store Review Guideline 4.8: offering a third-party social login
  /// obliges an equivalent privacy-preserving option. Enforcing it here means
  /// no call site can omit it by accident.
  List<AuthProvider> get _effectiveProviders {
    final list = [...providers];
    if (list.contains(AuthProvider.google) &&
        !list.contains(AuthProvider.apple)) {
      list.insert(0, AuthProvider.apple);
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _title(l10n),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            // Says what is at stake once, plainly, and never again (ADR-0013).
            Text(_body(l10n), key: explanationKey),
            const SizedBox(height: 20),
            for (final provider in _effectiveProviders) ...[
              FilledButton(
                key: keyFor(provider),
                onPressed: () => onChoose(provider),
                child: Text(labelFor(l10n, provider)),
              ),
              const SizedBox(height: 8),
            ],
            TextButton(
              key: cancelKey,
              onPressed: onCancel,
              child: Text(l10n.notNowButton),
            ),
          ],
        ),
      ),
    );
  }
}

/// Native Sign in with Apple. Returns null when the user cancels, which is a
/// normal outcome and must not surface as an error.
abstract final class AppleCredentials {
  static String _randomNonce([int length = 32]) {
    const chars = // niche:allow nonce alphabet, never read by a user
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._'; // niche:allow
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  static Future<AppleGoogleToken?> request() async {
    if (!Platform.isIOS && !Platform.isMacOS) return null;
    final rawNonce = _randomNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email],
        nonce: hashedNonce,
      );
      final idToken = credential.identityToken;
      if (idToken == null) return null;
      // Supabase verifies the raw nonce against the hash inside the token.
      return AppleGoogleToken(idToken: idToken, nonce: rawNonce);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}

abstract final class GoogleCredentials {
  static bool _initialized = false;

  /// google_sign_in 7 requires one initialize() before any authenticate(), and
  /// cancellation arrives as an exception rather than a null account.
  static Future<AppleGoogleToken?> request() async {
    if (!_initialized) {
      await GoogleSignIn.instance.initialize();
      _initialized = true;
    }
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) return null;
      return AppleGoogleToken(idToken: idToken);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }
}
