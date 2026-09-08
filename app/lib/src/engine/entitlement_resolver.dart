import '../domain/pack.dart';

/// Decides which packs are unlocked.
///
/// Three inputs from three places, and each one covers a case the others
/// cannot:
///
///  * `isCore` — the free pack works for a user with no rows, no account
///    history and no network (ADR-0008).
///  * `entitledPackIds` — the durable answer, from rows the purchase webhook
///    wrote and the client pulled read-only (ADR-0017).
///  * `ownedProductIds` — the immediate answer, from RevenueCat's device-local
///    customer info. True the moment the store confirms, which is before the
///    webhook lands, and still true on a device whose webhook was lost.
///
/// Pure: no database, no SDK, no clock. Whether someone who paid gets what they
/// paid for is decided here, and it should be readable as a truth table.
class EntitlementResolver {
  const EntitlementResolver();

  Set<String> unlockedPackIds({
    required Iterable<Pack> packs,
    required Set<String> entitledPackIds,
    required Set<String> ownedProductIds,
  }) {
    final unlocked = <String>{};
    for (final pack in packs) {
      if (isUnlocked(
        pack: pack,
        entitledPackIds: entitledPackIds,
        ownedProductIds: ownedProductIds,
      )) {
        unlocked.add(pack.id);
      }
    }
    return unlocked;
  }

  bool isUnlocked({
    required Pack pack,
    required Set<String> entitledPackIds,
    required Set<String> ownedProductIds,
  }) {
    if (pack.isCore) return true;
    if (entitledPackIds.contains(pack.id)) return true;

    // Fail closed on a misconfigured pack: no product id means nothing can
    // match it, and guessing would hand out content for free.
    final productId = pack.storeProductId;
    if (productId == null || productId.isEmpty) return false;

    return ownedProductIds.contains(productId);
  }
}
