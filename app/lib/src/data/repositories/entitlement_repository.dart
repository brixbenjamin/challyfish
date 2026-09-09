import 'package:drift/drift.dart';

import '../../core/clock.dart';
import '../../domain/pack.dart';
import '../../engine/entitlement_resolver.dart';
import '../local/database.dart';
import '../remote/purchase_gateway.dart';

/// What a restore did, in the terms the user is owed: how many locked packs
/// stopped being locked.
class RestoreSummary {
  const RestoreSummary({
    required this.succeeded,
    this.unlockedPacks = 0,
    this.error,
  });

  final bool succeeded;
  final int unlockedPacks;
  final Object? error;
}

/// Answers one question — is this pack unlocked — from two caches that both
/// work offline: the rows the sync pulled, and the product ids the purchase
/// SDK has cached on the device.
///
/// It never writes `public.entitlements`. That table is the webhook's
/// (ADR-0017), and there is deliberately no method here that could be mistaken
/// for a way around it.
class EntitlementRepository {
  // Fields are public, as in ContentRepository and SyncRepository, so the
  // constructor can use initializing formals for its named parameters.
  EntitlementRepository({
    required this.db,
    required this.gateway,
    required this.clock,
    this.resolver = const EntitlementResolver(),
  });

  final FeralDatabase db;
  final PurchaseGateway gateway;
  final Clock clock;
  final EntitlementResolver resolver;

  Future<Set<String>> unlockedPackIds({
    required String userId,
    required List<Pack> packs,
  }) async {
    final rows = await (db.select(
      db.entitlements,
    )..where((e) => e.userId.equals(userId))).get();

    // A store that cannot be reached is not a reason to lock someone out of
    // what they bought: the rows alone still answer.
    Set<String> owned;
    final sw = Stopwatch()..start();
    try {
      owned = await gateway.ownedProductIds();
      // ignore: avoid_print
      print('[BOOTPROBE] ownedProductIds took \${sw.elapsedMilliseconds}ms');
    } catch (e) {
      // ignore: avoid_print
      print('[BOOTPROBE] ownedProductIds threw after \${sw.elapsedMilliseconds}ms: \$e');
      owned = const {};
    }

    return resolver.unlockedPackIds(
      packs: packs,
      entitledPackIds: rows.map((r) => r.packId).toSet(),
      ownedProductIds: owned,
    );
  }

  Future<bool> isUnlocked({required String userId, required Pack pack}) async =>
      (await unlockedPackIds(userId: userId, packs: [pack])).contains(pack.id);

  /// Writes the optimistic row that makes an unlock instant, in the seconds
  /// between the store confirming and the webhook's row arriving.
  ///
  /// Marked `local`, replaced by the pulled row, and never pushed. If a server
  /// row already exists, this does nothing — the server's answer is the better
  /// one and its `acquired_at` is the true one.
  Future<void> recordLocalGrant({
    required String userId,
    required String packId,
  }) async {
    final existing =
        await (db.select(db.entitlements)
              ..where((e) => e.userId.equals(userId) & e.packId.equals(packId)))
            .getSingleOrNull();
    if (existing != null) return;

    final now = clock.nowUtc();
    await db
        .into(db.entitlements)
        .insert(
          EntitlementsCompanion.insert(
            userId: userId,
            packId: packId,
            source: 'store',
            acquiredAt: now,
            updatedAt: now,
            local: const Value(true),
          ),
        );
  }

  /// Asks the store what this account owns and unlocks accordingly.
  ///
  /// Safe to call at any time, including on launch: it is idempotent, and a
  /// failure changes nothing.
  Future<RestoreSummary> restore({
    required String userId,
    required List<Pack> packs,
  }) async {
    final before = await unlockedPackIds(userId: userId, packs: packs);

    final rsw = Stopwatch()..start();
    final result = await gateway.restore();
    // ignore: avoid_print
    print('[BOOTPROBE] gateway.restore took \${rsw.elapsedMilliseconds}ms ok=\${result.succeeded}');
    if (!result.succeeded) {
      return RestoreSummary(succeeded: false, error: result.error);
    }

    // Product ids that match no pack are ignored, not an error: a product from
    // a newer library version can legitimately be owned by this account.
    for (final pack in packs) {
      final productId = pack.storeProductId;
      if (productId == null || productId.isEmpty) continue;
      if (!result.ownedProductIds.contains(productId)) continue;
      await recordLocalGrant(userId: userId, packId: pack.id);
    }

    final after = await unlockedPackIds(userId: userId, packs: packs);
    return RestoreSummary(
      succeeded: true,
      unlockedPacks: after.difference(before).length,
    );
  }

  /// Clears the local copy entirely. For the two moments a device stops being
  /// an account's: signing in to a different account (ADR-0014) and deleting
  /// the account (ADR-0015).
  Future<void> wipeLocal() => db.delete(db.entitlements).go();
}
