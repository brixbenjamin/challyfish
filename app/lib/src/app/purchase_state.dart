import '../data/remote/purchase_gateway.dart';
import '../data/repositories/entitlement_repository.dart';
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
}

/// Turns the five store outcomes into the five things the app does about them.
class PurchaseController {
  // Fields are public with initializing formals, as in the repositories.
  PurchaseController({required this.entitlements, required this.gateway});

  final EntitlementRepository entitlements;
  final PurchaseGateway gateway;

  Future<PurchaseUiState> buy({
    required String userId,
    required Pack pack,
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
        await entitlements.recordLocalGrant(userId: userId, packId: pack.id);
        return PurchaseComplete(pack.id);

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
        return PurchaseComplete(pack.id);

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

  Future<RestoreSummary> restore({
    required String userId,
    required List<Pack> packs,
  }) => entitlements.restore(userId: userId, packs: packs);
}
