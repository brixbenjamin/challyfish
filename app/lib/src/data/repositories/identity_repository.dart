import 'package:drift/drift.dart';

import '../../domain/identity.dart';
import '../local/database.dart';
import '../remote/auth_gateway.dart';
import '../remote/purchase_gateway.dart';
import 'entitlement_repository.dart';

class IdentityRepository {
  // Fields are public, as elsewhere here, so the constructor can use
  // initializing formals for its named parameters.
  IdentityRepository({
    required this.db,
    required this.auth,
    required this.entitlements,
    required this.purchases,
  });

  final FeralDatabase db;
  final AuthGateway auth;
  final EntitlementRepository entitlements;
  final PurchaseGateway purchases;

  bool get isLinked => auth.linkedIdentity != null;
  LinkedIdentity? get linkedIdentity => auth.linkedIdentity;

  /// Try to link. Fall back to signing in only when the provider says the
  /// identity already belongs to someone else — and then only with consent.
  ///
  /// The user never chooses between these two operations; they are structural,
  /// not a preference (ADR-0014).
  Future<AttachOutcome> attach({
    required AuthProvider provider,
    required Object? credential,
  }) async {
    if (credential == null) return const Cancelled();

    try {
      await auth.linkIdentity(provider, credential);
      // Linking preserves the user id (ADR-0014), and the RevenueCat app user
      // id IS the user id (ADR-0017), so entitlements need no work here. Do not
      // add a switchUser call for symmetry with sign-in: it would ask the store
      // to move a purchase to the id it already belongs to, and can produce a
      // transfer event that revokes it from its owner.
      return Linked(auth.linkedIdentity!);
    } on IdentityAlreadyAttached {
      final summary = await localProgressSummary();
      if (summary.hasProgress) {
        // Stop here. Nothing is destroyed before the user has seen what it is.
        return NeedsReplaceConfirmation(summary);
      }
      // The reinstall case: nothing to lose, so no confirmation to ask for.
      return _signIn(provider, credential);
    } catch (error) {
      return Failed(error);
    }
  }

  /// Step one of email: claim the address.
  ///
  /// Asking for the address IS the test of whether it is free, so this is where
  /// the link-versus-sign-in branch is decided — before a code is sent, and
  /// long before anything on this device is at risk. Apple and Google learn the
  /// same thing from `attach`; email learns it one step earlier, because a
  /// sign-in code must not be mailed to an address the user cannot use.
  Future<AttachOutcome> sendEmailCode(String email) async {
    try {
      await auth.sendEmailCode(email, link: true);
      return const CodeSent(link: true);
    } on IdentityAlreadyAttached {
      final summary = await localProgressSummary();
      if (summary.hasProgress) {
        // Stop here. Nothing is sent and nothing is destroyed before the user
        // has seen what signing in would cost (ADR-0014).
        return NeedsReplaceConfirmation(summary);
      }
      // The reinstall case again: nothing to lose, so nothing to ask.
      return _sendSignInCode(email);
    } catch (error) {
      return Failed(error);
    }
  }

  /// Called only after the user confirmed the replacement.
  Future<AttachOutcome> confirmEmailReplacement(String email) =>
      _sendSignInCode(email);

  Future<AttachOutcome> _sendSignInCode(String email) async {
    try {
      await auth.sendEmailCode(email, link: false);
      return const CodeSent(link: false);
    } catch (error) {
      return Failed(error);
    }
  }

  /// Step two: the six digits.
  ///
  /// [link] is the answer `sendEmailCode` already worked out, carried back so
  /// the code is verified against the flow that actually produced it.
  Future<AttachOutcome> verifyEmailCode({
    required String email,
    required String code,
    required bool link,
  }) async {
    try {
      final userId = await auth.verifyEmailCode(
        email: email,
        code: code,
        link: link,
      );
      if (link) return Linked(auth.linkedIdentity!);
      await _replaceLocalUserState();
      await _switchStoreUser(userId);
      return SignedIn(userId, auth.linkedIdentity!);
    } catch (error) {
      // A wrong or expired code lands here, and it must cost nothing: the local
      // wipe is deliberately downstream of a verification that succeeded.
      return Failed(error);
    }
  }

  /// Called only after the user confirmed the replacement.
  Future<AttachOutcome> completeSignIn({
    required AuthProvider provider,
    required Object credential,
  }) => _signIn(provider, credential);

  Future<AttachOutcome> _signIn(
    AuthProvider provider,
    Object credential,
  ) async {
    try {
      final userId = await auth.signIn(provider, credential);
      await _replaceLocalUserState();
      await _switchStoreUser(userId);
      return SignedIn(userId, auth.linkedIdentity!);
    } catch (error) {
      return Failed(error);
    }
  }

  /// What signing in would cost, in terms the user can weigh.
  Future<LocalProgressSummary> localProgressSummary() async {
    final run =
        await (db.select(db.campaignRuns)
              ..where((r) => r.status.equals('active'))
              ..limit(1))
            .getSingleOrNull();
    if (run == null) {
      final anyLog = await (db.select(db.dayLogs)..limit(1)).getSingleOrNull();
      return LocalProgressSummary(hasProgress: anyLog != null);
    }

    final campaign = await (db.select(
      db.campaigns,
    )..where((c) => c.id.equals(run.campaignId))).getSingleOrNull();
    final reported = await (db.select(
      db.dayLogs,
    )..where((l) => l.runId.equals(run.id) & l.outcome.isNotNull())).get();

    return LocalProgressSummary(
      hasProgress: true,
      campaignTitle: campaign?.title,
      reportedDays: reported.length,
      totalDays: campaign?.lengthDays ?? 0,
    );
  }

  /// Clear this device's user state so the signed-in account's record can be
  /// pulled cleanly.
  ///
  /// See [replaceLocalUserState], which holds the body so it can be tested
  /// against a real database.
  Future<void> _replaceLocalUserState() => replaceLocalUserState(db);

  /// After account deletion: wipe local user state and start over anonymously,
  /// so the app lands on a first-run screen rather than a broken signed-out one.
  Future<void> resetToFreshAnonymous() async {
    // The store account keeps the purchase; a restore on the new anonymous id
    // is the supported way back to it.
    try {
      await purchases.forgetUser();
    } catch (_) {}
    await _replaceLocalUserState();
    await auth.signInAnonymously();
  }

  /// Points the store at the account this device now belongs to.
  ///
  /// The account switch has already happened. Refusing to finish it because a
  /// purchase SDK is unreachable would leave the app matching neither account —
  /// the next launch configures the store again, and a restore is always
  /// available in settings.
  Future<void> _switchStoreUser(String userId) async {
    try {
      await purchases.switchUser(userId);
    } catch (_) {}
  }
}

/// Clear this device's user state so the signed-in account's record can be
/// pulled cleanly.
///
/// Content tables are deliberately untouched. They are user-agnostic, and
/// re-downloading the library after a sign-in would be a pointless round trip on
/// a connection we already know is working.
///
/// The two body tables are no longer purged here, because they no longer need to
/// be: the cached content version is dropped below, which turns the next
/// ordinary refresh into a full one, and that replaces both tables with exactly
/// what row-level security returns for whoever is now signed in.
///
/// This is a sign-in, not a refund. The difference is timing: a sign-in is
/// immediately followed by a boot that refreshes content, so the gap is a
/// moment; a refund arrives during a background sync with no such follow-up,
/// which is why revocation still deletes the rows itself
/// (see SyncRepository._revokeUnentitledContent, ADR-0025, ADR-0034).
///
/// The discarded rows are NOT pushed first. Uploading records the user just
/// agreed to discard would be worse than discarding them.
///
/// Extracted to a top-level function so it can be tested against a real
/// database. [IdentityRepository] remains the only production caller.
Future<void> replaceLocalUserState(FeralDatabase db) async {
  await db.transaction(() async {
    // Before day_logs, mirroring the foreign-key direction on the server.
    // Leaving these behind would feed the previous account's acts into this
    // one's radar and points total -- the same class of bug the entitlements
    // note below describes, and the reason that note exists.
    await db.delete(db.dayLogActions).go();
    await db.delete(db.dayLogs).go();
    await db.delete(db.campaignRuns).go();
    await db.delete(db.diagnosticResults).go();
    await db.delete(db.profiles).go();
    // This device now belongs to a different account. Old rows would show a
    // pack the new account does not own. A user table the wipe does not know
    // about is exactly the bug plan 3's tests were written to prevent.
    await db.delete(db.entitlements).go();

    // The cached content version. This is what turns the next ordinary,
    // version-gated refresh into a full one, which is how the body tables get
    // re-filtered for whoever is now signed in.
    await db.delete(db.clientState).go();

    // Everything this device still owed the previous account. Sending it now
    // would write the account the user left into the account they just joined,
    // and these are rows they have already agreed to discard.
    await db.delete(db.outbox).go();
  });
}
