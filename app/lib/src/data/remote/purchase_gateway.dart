import '../../domain/purchase.dart';

/// Everything the app needs from a store, and nothing else.
///
/// `revenuecat_gateway.dart` is the only file permitted to import
/// `purchases_flutter` (ADR-0017). Keeping the SDK behind this interface is
/// what makes the vendor decision reversible, and what makes pending,
/// cancelled, already-owned and failed reachable in a unit test instead of only
/// in a sandbox.
abstract class PurchaseGateway {
  /// Called once per session, with the Supabase user id as the app user id.
  /// Never an email, never a device id (ADR-0017).
  Future<void> configure(String userId);

  /// The signed-in user changed. Entitlements belong to an app user id, so the
  /// owned set changes with it.
  Future<void> switchUser(String userId);

  /// Detach from the current app user id — after account deletion, or a sign-in
  /// that replaced local progress.
  Future<void> forgetUser();

  /// Store metadata for the given product ids. Unknown ids are omitted rather
  /// than reported: a product that is not yet live in a store is a
  /// configuration state, not an app error.
  Future<List<StoreProduct>> products(Iterable<String> productIds);

  Future<PurchaseOutcome> purchase(String productId);

  /// Ask the store what this account owns. Safe to call at any time.
  Future<RestoreResult> restore();

  /// What the SDK's cached customer info says right now. Available offline,
  /// which is why an owned pack keeps working with no network.
  Future<Set<String>> ownedProductIds();

  /// Emits whenever the owned set changes, including changes that originate
  /// outside the app — a purchase made on another device, a refund.
  Stream<Set<String>> get ownedProductChanges;
}
