import 'package:feral/src/domain/purchase.dart';
import 'package:test/test.dart';

import 'fake_purchase_gateway.dart';

void main() {
  late FakePurchaseGateway gateway;

  setUp(() {
    gateway = FakePurchaseGateway(
      catalogue: const [
        StoreProduct(
          id: 'com.example.feral.pack.edge',
          title: 'The Edge',
          priceString: '4,99 €',
        ),
      ],
    );
  });

  tearDown(() => gateway.dispose());

  test('configure records the app user id', () async {
    await gateway.configure('user-1');
    expect(gateway.currentUserId, 'user-1');
  });

  test('a purchase succeeds and reports what is now owned', () async {
    await gateway.configure('user-1');
    final outcome = await gateway.purchase('com.example.feral.pack.edge');

    expect(outcome, isA<PurchaseSucceeded>());
    expect((outcome as PurchaseSucceeded).ownedProductIds, {
      'com.example.feral.pack.edge',
    });
    expect(await gateway.ownedProductIds(), {'com.example.feral.pack.edge'});
  });

  test('a cancelled purchase owns nothing and is not an error', () async {
    gateway.nextOutcome = const PurchaseCancelled();
    final outcome = await gateway.purchase('com.example.feral.pack.edge');

    expect(outcome, isA<PurchaseCancelled>());
    expect(await gateway.ownedProductIds(), isEmpty);
  });

  test('a pending purchase owns nothing yet', () async {
    gateway.nextOutcome = const PurchasePending();
    expect(
      await gateway.purchase('com.example.feral.pack.edge'),
      isA<PurchasePending>(),
    );
    expect(await gateway.ownedProductIds(), isEmpty);
  });

  test('restore returns what the store account already owns', () async {
    gateway.storeOwned.add('com.example.feral.pack.edge');
    final result = await gateway.restore();

    expect(result.succeeded, isTrue);
    expect(result.ownedProductIds, {'com.example.feral.pack.edge'});
    expect(await gateway.ownedProductIds(), {'com.example.feral.pack.edge'});
  });

  test('restore with nothing to restore succeeds and is empty', () async {
    final result = await gateway.restore();
    expect(result.succeeded, isTrue);
    expect(result.ownedProductIds, isEmpty);
  });

  test('switching user swaps the owned set', () async {
    await gateway.configure('user-1');
    await gateway.purchase('com.example.feral.pack.edge');

    await gateway.switchUser('user-2');
    expect(gateway.currentUserId, 'user-2');
    expect(
      await gateway.ownedProductIds(),
      isEmpty,
      reason: 'entitlements belong to an app user id, not to a device',
    );
  });

  test('ownership changes are broadcast', () async {
    await gateway.configure('user-1');
    final seen = <Set<String>>[];
    final sub = gateway.ownedProductChanges.listen(seen.add);

    await gateway.purchase('com.example.feral.pack.edge');
    await Future<void>.delayed(Duration.zero);

    expect(seen, [
      {'com.example.feral.pack.edge'},
    ]);
    await sub.cancel();
  });

  test('products come back for known ids only', () async {
    final products = await gateway.products(const [
      'com.example.feral.pack.edge',
      'com.example.feral.pack.ghost',
    ]);
    expect(products, hasLength(1));
    expect(products.single.priceString, '4,99 €');
  });
}
