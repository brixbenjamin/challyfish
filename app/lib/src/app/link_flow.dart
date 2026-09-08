import '../data/repositories/identity_repository.dart';
import '../domain/identity.dart';

/// The order the linking questions are asked in.
///
/// The repository knows what each answer means; this knows what to ask next,
/// and it holds the one rule the widget tree keeps losing: a confirmation comes
/// before anything irreversible, never after (ADR-0014). Keeping it out of the
/// router is what lets that rule be tested without a device, a sheet, and three
/// pushed routes.
///
/// It is deliberately ignorant of navigation. `confirmReplacement` is however
/// the caller wants to ask — a pushed screen in the app, a stubbed answer in a
/// test.
class LinkFlow {
  LinkFlow({required this.identity, required this.confirmReplacement});

  final IdentityRepository identity;

  /// Asked only when there is something to lose, with the summary that names
  /// it and the account the user would be signing in as.
  final Future<bool> Function(LocalProgressSummary summary, String accountLabel)
  confirmReplacement;

  /// Which flow the code currently in flight belongs to. Remembered here
  /// because the screen that collects the six digits has no way to know, and
  /// guessing wrong rejects a correct code.
  bool _link = true;

  /// Apple and Google, whose credential is collected before anything is asked
  /// of the server.
  Future<AttachOutcome> attach({
    required AuthProvider provider,
    required Object? credential,
    required String accountLabel,
  }) async {
    final outcome = await identity.attach(
      provider: provider,
      credential: credential,
    );
    if (outcome is! NeedsReplaceConfirmation) return outcome;

    if (!await confirmReplacement(outcome.summary, accountLabel)) {
      // Declining is an ordinary answer, not an error. Nothing has happened.
      return const Cancelled();
    }
    return identity.completeSignIn(provider: provider, credential: credential!);
  }

  /// Email step one. The address itself decides which flow this becomes, so the
  /// confirmation happens here — before a sign-in code is put in the post.
  Future<AttachOutcome> sendEmailCode(String email) async {
    var outcome = await identity.sendEmailCode(email);

    if (outcome is NeedsReplaceConfirmation) {
      // The address is the account: it is what the user is signing in as, so it
      // is what the confirmation names.
      if (!await confirmReplacement(outcome.summary, email)) {
        return const Cancelled();
      }
      outcome = await identity.confirmEmailReplacement(email);
    }

    if (outcome is CodeSent) _link = outcome.link;
    return outcome;
  }

  /// Email step two, against whichever flow step one settled on.
  Future<AttachOutcome> verifyEmailCode({
    required String email,
    required String code,
  }) => identity.verifyEmailCode(email: email, code: code, link: _link);
}
