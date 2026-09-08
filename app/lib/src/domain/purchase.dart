/// A product as the store describes it.
///
/// `priceString` is the store's own localized string and is displayed verbatim.
/// No price is stored in our data or hardcoded anywhere in the app (ADR-0019):
/// the store owns the number, the currency, and the formatting.
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.title,
    required this.priceString,
  });

  final String id;
  final String title;
  final String priceString;
}

/// What a purchase attempt actually did.
///
/// These are the store's outcomes, not our error codes, and they are not
/// interchangeable:
///
///  * cancelled is a decision the user made and must be silent;
///  * pending is a real purchase in progress — parental approval, a bank step —
///    that resolves later through the webhook;
///  * already-owned is what a reinstall looks like and leads to a restore.
sealed class PurchaseOutcome {
  const PurchaseOutcome();
}

class PurchaseSucceeded extends PurchaseOutcome {
  const PurchaseSucceeded(this.ownedProductIds);

  final Set<String> ownedProductIds;
}

class PurchasePending extends PurchaseOutcome {
  const PurchasePending();
}

class PurchaseCancelled extends PurchaseOutcome {
  const PurchaseCancelled();
}

class PurchaseAlreadyOwned extends PurchaseOutcome {
  const PurchaseAlreadyOwned(this.ownedProductIds);

  final Set<String> ownedProductIds;
}

class PurchaseFailed extends PurchaseOutcome {
  const PurchaseFailed(this.message);

  /// Already suitable to show a user: short, plain, and never a stack trace or
  /// a store error code.
  final String message;
}

/// The result of asking the store what this account already owns.
class RestoreResult {
  const RestoreResult({
    required this.succeeded,
    this.ownedProductIds = const {},
    this.error,
  });

  final bool succeeded;
  final Set<String> ownedProductIds;
  final Object? error;
}
