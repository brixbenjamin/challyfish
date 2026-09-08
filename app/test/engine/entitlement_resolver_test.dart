import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/engine/entitlement_resolver.dart';
import 'package:test/test.dart';

const core = Pack(
  id: 'p-core',
  key: 'core',
  title: 'The Core',
  description: 'Free, forever.',
  isCore: true,
  sort: 1,
);
const edge = Pack(
  id: 'p-edge',
  key: 'edge',
  title: 'The Edge',
  description: 'Harder.',
  isCore: false,
  storeProductId: 'com.example.feral.pack.edge',
  sort: 2,
);
const unpriced = Pack(
  id: 'p-broken',
  key: 'broken',
  title: 'Misconfigured',
  description: 'No product id.',
  isCore: false,
  sort: 3,
);

void main() {
  const resolver = EntitlementResolver();

  Set<String> unlocked({
    Iterable<Pack> packs = const [core, edge],
    Set<String> rows = const {},
    Set<String> products = const {},
  }) => resolver.unlockedPackIds(
    packs: packs,
    entitledPackIds: rows,
    ownedProductIds: products,
  );

  test('the core pack is unlocked with no rows and no store at all', () {
    expect(unlocked(), {'p-core'});
  });

  test('an entitlement row unlocks a paid pack', () {
    expect(unlocked(rows: {'p-edge'}), {'p-core', 'p-edge'});
  });

  test('an owned store product unlocks its pack before any row exists', () {
    // This is the seconds between the store confirming and the webhook landing.
    // Without it the user pays and watches nothing happen.
    expect(unlocked(products: {'com.example.feral.pack.edge'}), {
      'p-core',
      'p-edge',
    });
  });

  test('a row and a product agreeing produce one unlock, not two', () {
    expect(
      unlocked(rows: {'p-edge'}, products: {'com.example.feral.pack.edge'}),
      {'p-core', 'p-edge'},
    );
  });

  test('an unknown product id unlocks nothing', () {
    expect(unlocked(products: {'com.example.feral.pack.something-else'}), {
      'p-core',
    });
  });

  test('a row for a pack that is not in the library unlocks nothing', () {
    // A pack removed from the library, or a row pulled before content did.
    expect(unlocked(rows: {'p-gone'}), {'p-core'});
  });

  test('a paid pack with no store product id stays locked', () {
    // Misconfiguration must fail closed. CI catches this in
    // 040_content_integrity.sql; the client still refuses to guess.
    expect(unlocked(packs: [core, unpriced], products: {''}), {'p-core'});
  });

  test('isUnlocked agrees with the set, pack by pack', () {
    expect(
      resolver.isUnlocked(
        pack: edge,
        entitledPackIds: const {},
        ownedProductIds: const {},
      ),
      isFalse,
    );
    expect(
      resolver.isUnlocked(
        pack: edge,
        entitledPackIds: const {'p-edge'},
        ownedProductIds: const {},
      ),
      isTrue,
    );
    expect(
      resolver.isUnlocked(
        pack: core,
        entitledPackIds: const {},
        ownedProductIds: const {},
      ),
      isTrue,
    );
  });

  test('an empty library resolves to an empty set rather than throwing', () {
    expect(unlocked(packs: const []), isEmpty);
  });
}
