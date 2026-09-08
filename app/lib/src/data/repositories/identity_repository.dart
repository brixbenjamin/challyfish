import 'package:drift/drift.dart';

import '../../domain/identity.dart';
import '../local/database.dart';
import '../remote/auth_gateway.dart';

class IdentityRepository {
  // Fields are public, as elsewhere here, so the constructor can use
  // initializing formals for its named parameters.
  IdentityRepository({required this.db, required this.auth});

  final FeralDatabase db;
  final AuthGateway auth;

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
  /// Content tables are deliberately untouched: they are user-agnostic, and
  /// re-downloading the library after a sign-in would be a pointless round trip
  /// on a connection we already know is working.
  ///
  /// The discarded rows are NOT pushed first. Uploading records the user just
  /// agreed to discard would be worse than discarding them.
  Future<void> _replaceLocalUserState() async {
    await db.transaction(() async {
      await db.delete(db.dayLogs).go();
      await db.delete(db.campaignRuns).go();
      await db.delete(db.diagnosticResults).go();
      await db.delete(db.profiles).go();
      // User-table watermarks only. Resetting a content watermark would force a
      // full library re-download for no reason.
      for (final table in [
        'profiles',
        'campaign_runs',
        'day_logs',
        'diagnostic_results',
      ]) {
        await (db.delete(
          db.syncState,
        )..where((s) => s.syncTable.equals(table))).go();
      }
    });
  }

  /// After account deletion: wipe local user state and start over anonymously,
  /// so the app lands on a first-run screen rather than a broken signed-out one.
  Future<void> resetToFreshAnonymous() async {
    await _replaceLocalUserState();
    await auth.signInAnonymously();
  }
}
