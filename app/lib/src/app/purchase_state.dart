import '../core/clock.dart';
import '../data/remote/purchase_gateway.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/entitlement_repository.dart';
import '../data/repositories/sync_repository.dart';
import '../domain/pack.dart';
import '../domain/purchase.dart';

/// What the unlock sheet is currently showing.
sealed class PurchaseUiState {
  const PurchaseUiState();
}

class PurchaseIdle extends PurchaseUiState {
  const PurchaseIdle();
}

class PurchaseInProgress extends PurchaseUiState {
  const PurchaseInProgress();
}

class PurchaseComplete extends PurchaseUiState {
  const PurchaseComplete(this.packId);

  final String packId;
}

/// Paid, and now fetching. The store confirmed the purchase to the device, but
/// the server only learns of it through the provider's webhook, and it will not
/// release the pack's copy until it has (ADR-0025). Showing this is the honest
/// alternative to opening a pack onto an empty day.
class PurchaseDelivering extends PurchaseUiState {
  const PurchaseDelivering(this.packId);

  final String packId;
}

/// A real purchase that has not resolved yet — parental approval, a bank step.
/// It becomes an entitlement when the webhook lands, possibly after the user
/// has closed the app.
class PurchaseWaiting extends PurchaseUiState {
  const PurchaseWaiting();
}

/// Carries a *reason*, never a sentence. A controller has no BuildContext, and
/// injecting localizations into one so it can compose user-facing prose is the
/// wrong direction — it puts UI copy in a file no guard scans (ADR-0022). The
/// UI maps the reason to a string at the moment it draws it.
///
/// `storeMessage` is the exception and is deliberately not localized: it is the
/// platform's own text for a failure we do not model, passed through verbatim
/// because paraphrasing a payment error is how a user ends up unable to act on
/// it. Null unless the store gave us something.
class PurchaseProblem extends PurchaseUiState {
  const PurchaseProblem(this.reason, {this.storeMessage});

  final PurchaseProblemReason reason;
  final String? storeMessage;
}

enum PurchaseProblemReason {
  /// Charging for the free pack. Not reachable from the UI; refused anyway.
  freePack,

  /// The pack has no store product id, or the store does not know it.
  unavailable,

  /// Already owned, and restoring it did not work.
  restoreFailedWhileOwned,

  /// A restore that succeeded and found nothing.
  nothingToRestore,

  /// The store could not be reached at all.
  storeUnreachable,

  /// The store failed for a reason it described itself; see `storeMessage`.
  storeReported,

  /// Paid for, but the copy has not arrived yet. The purchase is not lost: the
  /// local grant keeps the pack unlocked and the next launch pulls again.
  deliveryTimedOut,
}

/// Turns the five store outcomes into the five things the app does about them.
class PurchaseController {
  // Fields are public with initializing formals, as in the repositories.
  PurchaseController({
    required this.entitlements,
    required this.gateway,
    required this.content,
    required this.sync,
    required this.clock,
  });

  final EntitlementRepository entitlements;
  final PurchaseGateway gateway;
  final ContentRepository content;
  final SyncRepository sync;
  final Clock clock;

  /// [onProgress] reports a state the purchase passes *through* rather than
  /// ends on. Only delivery uses it: everything before the store answers is one
  /// awaited call, but the fetch afterwards can take seconds the user is
  /// staring at, and a sheet that shows nothing there is a sheet that looks
  /// stuck (ADR-0025).
  Future<PurchaseUiState> buy({
    required String userId,
    required Pack pack,
    void Function(PurchaseUiState)? onProgress,
  }) async {
    if (pack.isCore) {
      // Not reachable from the UI, and refused here anyway: charging for the
      // free pack is the one purchase bug that would be unforgivable.
      return const PurchaseProblem(PurchaseProblemReason.freePack);
    }

    final productId = pack.storeProductId;
    if (productId == null || productId.isEmpty) {
      return const PurchaseProblem(PurchaseProblemReason.unavailable);
    }

    final outcome = await gateway.purchase(productId);

    switch (outcome) {
      case PurchaseSucceeded():
        // Unlock now. The webhook's row replaces this one on the next pull, and
        // if it never arrives the SDK's cached product id keeps the pack open.
        // This grants nothing on the server: it is a local row, and the policy
        // that releases the copy reads the server's entitlements, not this.
        await entitlements.recordLocalGrant(userId: userId, packId: pack.id);
        return _deliver(userId, pack, onProgress);

      case PurchaseAlreadyOwned():
        // A reinstall, or a second device. Restoring is the answer; an error
        // message here would tell a paying user they cannot have what they own.
        final summary = await entitlements.restore(
          userId: userId,
          packs: [pack],
        );
        if (!summary.succeeded) {
          return const PurchaseProblem(
            PurchaseProblemReason.restoreFailedWhileOwned,
          );
        }
        await entitlements.recordLocalGrant(userId: userId, packId: pack.id);
        return _deliver(userId, pack, onProgress);

      case PurchasePending():
        return const PurchaseWaiting();

      case PurchaseCancelled():
        // Silence. The user decided; acknowledging it is a nag.
        return const PurchaseIdle();

      case PurchaseFailed(message: final message):
        return PurchaseProblem(
          PurchaseProblemReason.storeReported,
          storeMessage: message,
        );
    }
  }

  /// Pulls until the pack's first body is actually present, or gives up in a way
  /// the user can act on.
  ///
  /// The watermark is cleared first because the rows being waited for are older
  /// than this device's mark — they existed all along and were merely invisible,
  /// so an incremental pull would filter out exactly what was just paid for
  /// (ADR-0025).
  Future<PurchaseUiState> _deliver(
    String userId,
    Pack pack,
    void Function(PurchaseUiState)? onProgress,
  ) async {
    onProgress?.call(PurchaseDelivering(pack.id));
    // Both body tables, for one reason: the rows being waited for are older
    // than this device's marks -- they existed all along and were merely
    // invisible -- so an incremental pull would filter out exactly what was
    // just paid for (ADR-0025, ADR-0034).
    await content.clearWatermark('action_bodies');
    await content.clearWatermark('day_bodies');

    const backoff = [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
      Duration(seconds: 8),
      Duration(seconds: 15),
    ];

    for (final wait in backoff) {
      // A throw here is the network, not a verdict. The purchase stands either
      // way, so a failed attempt costs a retry rather than the pack.
      try {
        await sync.reconcileEntitlements(userId);
        await content.pull();
      } catch (_) {}
      if (await content.hasBodyForFirstDay(pack.id)) {
        return PurchaseComplete(pack.id);
      }
      await clock.delay(wait);
    }

    // The purchase is not lost: the local grant keeps the pack unlocked, and the
    // next launch pulls again. This reports a delivery that has not finished, not
    // a payment that failed, and the copy must say so.
    return const PurchaseProblem(PurchaseProblemReason.deliveryTimedOut);
  }

  Future<RestoreSummary> restore({
    required String userId,
    required List<Pack> packs,
  }) => entitlements.restore(userId: userId, packs: packs);
}
