import '../../../l10n/app_localizations.dart';
import '../../app/purchase_state.dart';

/// The store's own message wins when it gave us one: paraphrasing a payment
/// error is how a user ends up unable to act on it.
///
/// This switch lives in the UI, next to the screen that draws it, for the same
/// reason `outcomeLabel` does: a switch over an enum is code, and keeping it
/// here preserves the compiler's exhaustiveness check while the ARB bundle
/// stays pure data (ADR-0022).
String purchaseProblemText(
  AppLocalizations l10n,
  PurchaseProblemReason reason,
  String? storeMessage,
) => switch (reason) {
  PurchaseProblemReason.storeReported =>
    storeMessage ?? l10n.restoreUnreachable,
  PurchaseProblemReason.freePack => l10n.purchaseErrorFreePack,
  PurchaseProblemReason.unavailable => l10n.purchaseErrorUnavailable,
  PurchaseProblemReason.restoreFailedWhileOwned =>
    l10n.purchaseErrorRestoreOwned,
  PurchaseProblemReason.nothingToRestore => l10n.restoreNothingFound,
  PurchaseProblemReason.storeUnreachable => l10n.restoreUnreachable,
  PurchaseProblemReason.deliveryTimedOut => l10n.deliveryTimedOut,
};
