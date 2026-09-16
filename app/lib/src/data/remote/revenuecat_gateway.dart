import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart' as rc;
import 'package:purchases_flutter/purchases_flutter.dart'
    show PurchasesErrorCode, PurchasesErrorHelper;

import '../../domain/purchase.dart';
import 'purchase_gateway.dart';

/// REVIEW RULE: this is the only file in the app that may import
/// `purchases_flutter`. The SDK stays behind [PurchaseGateway] so the vendor
/// decision in ADR-0017 remains reversible — replacing RevenueCat should be a
/// second implementation of one interface, not a search through the UI.
/// `architecture_test.dart` enforces this.

/// Translates a RevenueCat error code into one of the five outcomes.
///
/// Pure, and therefore the part of this file that is actually tested. The
/// distinctions matter: cancelled is a user decision and must be silent,
/// pending is a real purchase that resolves later through the webhook, and
/// already-owned is a reinstall that should lead to a restore.
PurchaseOutcome outcomeForErrorCode(
  PurchasesErrorCode code, {
  required Set<String> owned,
}) {
  switch (code) {
    case PurchasesErrorCode.purchaseCancelledError:
      return const PurchaseCancelled();
    case PurchasesErrorCode.paymentPendingError:
      return const PurchasePending();
    case PurchasesErrorCode.productAlreadyPurchasedError:
      return PurchaseAlreadyOwned(owned);
    case PurchasesErrorCode.networkError:
    case PurchasesErrorCode.offlineConnectionError:
      return const PurchaseFailed(
        'The store could not be reached. Nothing was charged.',
      );
    case PurchasesErrorCode.purchaseNotAllowedError:
      return const PurchaseFailed('Purchases are not allowed on this device.');
    case PurchasesErrorCode.purchaseInvalidError:
    case PurchasesErrorCode.productNotAvailableForPurchaseError:
      return const PurchaseFailed(
        'This pack is not available from the store right now.',
      );
    case PurchasesErrorCode.storeProblemError:
      return const PurchaseFailed(
        'The store had a problem. Nothing was charged.',
      );
    case PurchasesErrorCode.operationAlreadyInProgressError:
      // A previous attempt for this pack is still open with the store — most
      // often one that was dismissed rather than explicitly cancelled. Unlike
      // the other failures here, "nothing was charged" would be a guess this
      // app cannot back up, so this says only what is true: wait, it will
      // resolve on its own.
      return const PurchaseFailed(
        'A previous attempt for this pack is still being processed by the '
        'store. Wait a moment and try again.',
      );
    default:
      return const PurchaseFailed(
        'The purchase did not go through. Nothing was charged.',
      );
  }
}

class RevenueCatGateway implements PurchaseGateway {
  RevenueCatGateway({required this.apiKey});

  final String apiKey;

  final StreamController<Set<String>> _changes =
      StreamController<Set<String>>.broadcast();
  bool _configured = false;

  @override
  Future<void> configure(String userId) async {
    if (_configured) {
      await switchUser(userId);
      return;
    }

    await rc.Purchases.setLogLevel(
      kDebugMode ? rc.LogLevel.debug : rc.LogLevel.error,
    );

    // The app user id is the Supabase user id, always (ADR-0017). This single
    // line is what makes a pack bought anonymously survive identity linking:
    // linking preserves the user id, so the purchase never has to move.
    await rc.Purchases.configure(
      rc.PurchasesConfiguration(apiKey)..appUserID = userId,
    );
    _configured = true;

    // Changes that originate outside this app — a purchase on another device,
    // a refund, a transfer — arrive here.
    rc.Purchases.addCustomerInfoUpdateListener(
      (info) => _changes.add(_ownedFrom(info)),
    );
  }

  @override
  Future<void> switchUser(String userId) async {
    final result = await rc.Purchases.logIn(userId);
    _changes.add(_ownedFrom(result.customerInfo));
  }

  @override
  Future<void> forgetUser() async {
    await rc.Purchases.logOut();
    _changes.add(const {});
  }

  @override
  Future<List<StoreProduct>> products(Iterable<String> productIds) async {
    final ids = productIds.toList();
    if (ids.isEmpty) return const [];
    final products = await rc.Purchases.getProducts(
      ids,
      productCategory: rc.ProductCategory.nonSubscription,
    );

    return [
      for (final product in products)
        StoreProduct(
          id: product.identifier,
          title: product.title,
          // The store's own localized string, displayed verbatim (ADR-0019).
          priceString: product.priceString,
        ),
    ];
  }

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    try {
      final products = await rc.Purchases.getProducts([
        productId,
      ], productCategory: rc.ProductCategory.nonSubscription);
      if (products.isEmpty) {
        return const PurchaseFailed(
          'This pack is not available from the store right now.',
        );
      }

      final info = await rc.Purchases.purchaseStoreProduct(products.first);
      return PurchaseSucceeded(_ownedFrom(info));
    } on PlatformException catch (error) {
      final code = PurchasesErrorHelper.getErrorCode(error);
      // already-owned needs to report what is owned, which means asking.
      Set<String> owned;
      try {
        owned = await ownedProductIds();
      } catch (_) {
        // The store is already misbehaving; an empty set is the honest answer
        // and the outcome below does not depend on it except for already-owned.
        owned = <String>{};
      }
      return outcomeForErrorCode(code, owned: owned);
    }
  }

  @override
  Future<RestoreResult> restore() async {
    try {
      final info = await rc.Purchases.restorePurchases();
      final owned = _ownedFrom(info);
      _changes.add(owned);
      return RestoreResult(succeeded: true, ownedProductIds: owned);
    } on PlatformException catch (error) {
      return RestoreResult(succeeded: false, error: error);
    }
  }

  @override
  Future<Set<String>> ownedProductIds() async {
    // Reads the SDK's cached customer info, which is available offline. This is
    // why a pack bought months ago still opens on a plane.
    final info = await rc.Purchases.getCustomerInfo();
    return _ownedFrom(info);
  }

  @override
  Stream<Set<String>> get ownedProductChanges => _changes.stream;

  /// Raw product identifiers, not RevenueCat entitlement identifiers.
  /// ADR-0019 makes one product equal one pack, and `packs.store_product_id` is
  /// the whole mapping — keeping it there stops our database and a vendor
  /// dashboard from disagreeing about what someone owns.
  Set<String> _ownedFrom(rc.CustomerInfo info) =>
      info.allPurchasedProductIdentifiers.toSet();
}
