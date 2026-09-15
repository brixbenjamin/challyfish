import 'dart:async';

import 'package:feral/src/data/remote/purchase_gateway.dart';
import 'package:feral/src/domain/purchase.dart';

/// A store that does what the test tells it to.
///
/// Lives under test/support because it is shared by the repository, controller,
/// settings and identity tests — each of which needs a different one of the
/// five outcomes.
class FakePurchaseGateway implements PurchaseGateway {
  FakePurchaseGateway({this.catalogue = const []});

  final List<StoreProduct> catalogue;

  /// What the store account owns, independent of any app user id — this is what
  /// a restore finds after a reinstall.
  final Set<String> storeOwned = {};

  /// Set to force the next purchase's outcome. Null means "succeed".
  PurchaseOutcome? nextOutcome;

  /// Awaited before [purchase] resolves, when set. Lets a test hold a purchase
  /// open to exercise what happens while the store is still working — the way
  /// a real store call sits open behind its own native purchase sheet.
  Future<void>? purchaseGate;

  /// Set to make restore fail.
  Object? restoreError;

  /// Makes [switchUser] throw, for the "the store is down mid-sign-in" case.
  bool failSwitchUser = false;

  String? currentUserId;
  int configureCalls = 0;
  int switchUserCalls = 0;
  int forgetUserCalls = 0;

  final Map<String, Set<String>> _ownedByUser = {};
  final StreamController<Set<String>> _changes =
      StreamController<Set<String>>.broadcast();

  Set<String> get _owned => _ownedByUser[currentUserId ?? ''] ??= {};

  @override
  Future<void> configure(String userId) async {
    configureCalls++;
    currentUserId = userId;
  }

  @override
  Future<void> switchUser(String userId) async {
    if (failSwitchUser) throw StateError('store unavailable');
    switchUserCalls++;
    currentUserId = userId;
    _changes.add({..._owned});
  }

  @override
  Future<void> forgetUser() async {
    forgetUserCalls++;
    currentUserId = null;
    _changes.add(const {});
  }

  @override
  Future<List<StoreProduct>> products(Iterable<String> productIds) async {
    final wanted = productIds.toSet();
    return catalogue.where((p) => wanted.contains(p.id)).toList();
  }

  @override
  Future<PurchaseOutcome> purchase(String productId) async {
    final gate = purchaseGate;
    if (gate != null) await gate;
    final forced = nextOutcome;
    if (forced != null) {
      nextOutcome = null;
      return forced;
    }
    _owned.add(productId);
    storeOwned.add(productId);
    _changes.add({..._owned});
    return PurchaseSucceeded({..._owned});
  }

  @override
  Future<RestoreResult> restore() async {
    final error = restoreError;
    if (error != null) {
      return RestoreResult(succeeded: false, error: error);
    }
    _owned.addAll(storeOwned);
    _changes.add({..._owned});
    return RestoreResult(succeeded: true, ownedProductIds: {..._owned});
  }

  @override
  Future<Set<String>> ownedProductIds() async => {..._owned};

  @override
  Stream<Set<String>> get ownedProductChanges => _changes.stream;

  Future<void> dispose() => _changes.close();
}
