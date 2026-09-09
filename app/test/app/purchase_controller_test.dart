import 'package:drift/native.dart';
import 'package:feral/src/app/purchase_state.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/domain/purchase.dart';
import 'package:test/test.dart';

import '../support/fake_purchase_gateway.dart';

const core = Pack(
  id: 'p-core',
  key: 'core',
  title: 'The Core',
  description: 'Free.',
  isCore: true,
  sort: 1,
);
const edge = Pack(
  id: 'p-edge',
  key: 'edge',
  title: 'The Edge',
  description: 'Harder.',
  isCore: false,
  storeProductId: 'pack.edge',
  sort: 2,
);
const unpriced = Pack(
  id: 'p-broken',
  key: 'broken',
  title: 'Misconfigured',
  description: 'x',
  isCore: false,
  sort: 3,
);

void main() {
  late FeralDatabase db;
  late FakePurchaseGateway gateway;
  late PurchaseController controller;

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    gateway = FakePurchaseGateway(
      catalogue: const [
        StoreProduct(id: 'pack.edge', title: 'The Edge', priceString: '4,99 €'),
      ],
    );
    controller = PurchaseController(
      entitlements: EntitlementRepository(
        db: db,
        gateway: gateway,
        clock: FixedClock(DateTime.utc(2026, 6, 1, 12)),
      ),
      gateway: gateway,
    );
  });

  tearDown(() async {
    await gateway.dispose();
    await db.close();
  });

  test('a successful purchase unlocks the pack immediately', () async {
    await gateway.configure('user-1');
    final state = await controller.buy(userId: 'user-1', pack: edge);

    expect(state, isA<PurchaseComplete>());
    expect((state as PurchaseComplete).packId, 'p-edge');

    // The row exists before any webhook has been received.
    final row = await db.select(db.entitlements).getSingle();
    expect(row.packId, 'p-edge');
    expect(row.local, isTrue);
  });

  test('a cancelled purchase returns to idle and says nothing', () async {
    await gateway.configure('user-1');
    gateway.nextOutcome = const PurchaseCancelled();

    final state = await controller.buy(userId: 'user-1', pack: edge);

    expect(state, isA<PurchaseIdle>());
    expect(await db.select(db.entitlements).get(), isEmpty);
  });

  test('a pending purchase waits, and unlocks nothing yet', () async {
    await gateway.configure('user-1');
    gateway.nextOutcome = const PurchasePending();

    final state = await controller.buy(userId: 'user-1', pack: edge);

    expect(state, isA<PurchaseWaiting>());
    expect(
      await db.select(db.entitlements).get(),
      isEmpty,
      reason: 'nothing is owned until it resolves',
    );
  });

  test('already-owned restores instead of apologising', () async {
    await gateway.configure('user-1');
    gateway.storeOwned.add('pack.edge');
    gateway.nextOutcome = const PurchaseAlreadyOwned({'pack.edge'});

    final state = await controller.buy(userId: 'user-1', pack: edge);

    expect(state, isA<PurchaseComplete>());
    expect(await db.select(db.entitlements).get(), hasLength(1));
  });

  test('a failed purchase passes the store\'s own words through', () async {
    await gateway.configure('user-1');
    gateway.nextOutcome = const PurchaseFailed(
      'The store could not be reached. Nothing was charged.',
    );

    final state = await controller.buy(userId: 'user-1', pack: edge);

    expect(state, isA<PurchaseProblem>());
    final problem = state as PurchaseProblem;
    // The reason is what the controller decides; the sentence is the store's,
    // passed through verbatim because paraphrasing a payment error is how a
    // user ends up unable to act on it (ADR-0022).
    expect(problem.reason, PurchaseProblemReason.storeReported);
    expect(
      problem.storeMessage?.toLowerCase(),
      contains('nothing was charged'),
    );
    expect(await db.select(db.entitlements).get(), isEmpty);
  });

  test('a pack with no store product cannot be bought', () async {
    await gateway.configure('user-1');
    final state = await controller.buy(userId: 'user-1', pack: unpriced);

    expect(state, isA<PurchaseProblem>());
    expect(
      (state as PurchaseProblem).reason,
      PurchaseProblemReason.unavailable,
    );
    expect(await db.select(db.entitlements).get(), isEmpty);
  });

  test('buying the core pack is refused rather than charged', () async {
    await gateway.configure('user-1');
    final state = await controller.buy(userId: 'user-1', pack: core);

    expect(state, isA<PurchaseProblem>());
    expect((state as PurchaseProblem).reason, PurchaseProblemReason.freePack);
  });

  test('the controller never composes a user-facing sentence', () async {
    // The guard behind ADR-0022: a controller has no BuildContext, so any
    // prose it invented would sit in a directory no architecture test scans.
    await gateway.configure('user-1');
    final state = await controller.buy(userId: 'user-1', pack: core);

    expect((state as PurchaseProblem).storeMessage, isNull);
  });

  test('restore reports how many packs it unlocked', () async {
    await gateway.configure('user-1');
    gateway.storeOwned.add('pack.edge');

    final summary = await controller.restore(
      userId: 'user-1',
      packs: const [core, edge],
    );

    expect(summary.succeeded, isTrue);
    expect(summary.unlockedPacks, 1);
  });
}
