enum AuthProvider { apple, google, email }

class LinkedIdentity {
  const LinkedIdentity({required this.provider, required this.label});

  final AuthProvider provider;

  /// What to show the user: an email address, or the provider name when the
  /// provider hides the address (Apple's private relay does).
  final String label;
}

/// What this device would lose by signing in to a different account.
///
/// Concrete on purpose. "Local data will be removed" is not a warning anyone
/// can weigh; "Cold Approach, 4 of 7 days reported" is.
class LocalProgressSummary {
  const LocalProgressSummary({
    required this.hasProgress,
    this.campaignTitle,
    this.reportedDays = 0,
    this.totalDays = 0,
  });

  final bool hasProgress;
  final String? campaignTitle;
  final int reportedDays;
  final int totalDays;
}

/// The result of trying to attach an identity to this session.
sealed class AttachOutcome {
  const AttachOutcome();
}

/// The identity was free; it is now attached to the same user id. Nothing moved.
class Linked extends AttachOutcome {
  const Linked(this.identity);
  final LinkedIdentity identity;
}

/// The identity belongs to another account and this device holds progress. The
/// caller must confirm with the user before anything is destroyed.
class NeedsReplaceConfirmation extends AttachOutcome {
  const NeedsReplaceConfirmation(this.summary);
  final LocalProgressSummary summary;
}

/// Signed in to the existing account. Reached directly when this device had
/// nothing to lose, or via `IdentityRepository.completeSignIn` after consent.
class SignedIn extends AttachOutcome {
  const SignedIn(this.userId, this.identity);
  final String userId;
  final LinkedIdentity identity;
}

/// A six-digit code is on its way, and the flow it belongs to is settled.
///
/// [link] carries which of the two it is, because the answer decides both what
/// the code verifies against and what happens to this device's record once it
/// does. Nobody downstream should have to guess it back.
class CodeSent extends AttachOutcome {
  const CodeSent({required this.link});

  /// True when the address is being attached to the record already on this
  /// device; false when it belongs to an account being signed in to.
  final bool link;
}

class Cancelled extends AttachOutcome {
  const Cancelled();
}

class Failed extends AttachOutcome {
  const Failed(this.error);
  final Object error;
}

/// Thrown by `AuthGateway.linkIdentity` when the identity already belongs to
/// another account. An expected branch, not an error condition.
class IdentityAlreadyAttached implements Exception {
  const IdentityAlreadyAttached(this.message);
  final String message;

  @override
  String toString() => 'IdentityAlreadyAttached: $message';
}

/// The provider credential, carried as one object so the gateway signature does
/// not grow a parameter per provider.
class AppleGoogleToken {
  const AppleGoogleToken({required this.idToken, this.accessToken, this.nonce});

  final String idToken;
  final String? accessToken;
  final String? nonce;
}
