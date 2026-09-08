/// How a pack came to be owned.
///
/// `store` is a purchase; `grant` is anything else the server decided — a
/// support gesture, a migration, a comp. The client treats them identically:
/// owning a pack is owning a pack.
enum EntitlementSource {
  store('store'),
  grant('grant');

  const EntitlementSource(this.key);

  final String key;

  /// Unknown values degrade to [grant] rather than throwing. A server that
  /// learns a new source must not crash an older client — the pack is owned
  /// either way, and refusing to parse it would lock a paying user out.
  static EntitlementSource fromKey(String key) => switch (key) {
    'store' => EntitlementSource.store,
    _ => EntitlementSource.grant,
  };
}

/// One owned pack.
class Entitlement {
  const Entitlement({
    required this.userId,
    required this.packId,
    required this.source,
    required this.acquiredAt,
  });

  final String userId;
  final String packId;
  final EntitlementSource source;
  final DateTime acquiredAt;
}
