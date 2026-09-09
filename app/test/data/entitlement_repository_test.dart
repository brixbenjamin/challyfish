import 'package:drift/native.dart';
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
  storeProductId: 'pack.edge',
  sort: 2,
);

void main() {
  late FeralDatabase db;
  late FakePurchaseGateway gateway;
  late EntitlementRepository repo;

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    gateway = FakePurchaseGateway(
      catalogue: const [
        StoreProduct(id: 'pack.edge', title: 'The Edge', priceString: '4,99 €'),
      ],
    );
    repo = EntitlementRepository(
      db: db,
      gateway: gateway,
      clock: FixedClock(DateTime.utc(2026, 6, 1, 12)),
    );
  });

  tearDown(() async {
    await gateway.dispose();
    await db.close();
  });

  Future<void> serverRow(String packId) => db
      .into(db.entitlements)
      .insert(
        EntitlementsCompanion.insert(
          userId: 'user-1',
          packId: packId,
          source: 'store',
          acquiredAt: DateTime.utc(2026, 5, 1),
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      );

  test('with nothing owned, only the core pack is unlocked', () async {
    expect(
      await repo.unlockedPackIds(userId: 'user-1', packs: const [core, edge]),
      {'p-core'},
    );
  });

  test('a pulled row unlocks the pack', () async {
    await serverRow('p-edge');
    expect(
      await repo.unlockedPackIds(userId: 'user-1', packs: const [core, edge]),
      {'p-core', 'p-edge'},
    );
  });

  test("another user's row unlocks nothing for this one", () async {
    await db
        .into(db.entitlements)
        .insert(
          EntitlementsCompanion.insert(
            userId: 'someone-else',
            packId: 'p-edge',
            source: 'store',
            acquiredAt: DateTime.utc(2026, 5, 1),
            updatedAt: DateTime.utc(2026, 5, 1),
          ),
        );
    expect(
      await repo.unlockedPackIds(userId: 'user-1', packs: const [core, edge]),
      {'p-core'},
    );
  });

  test('the SDK cache alone unlocks the pack, with no row at all', () async {
    await gateway.configure('user-1');
    await gateway.purchase('pack.edge');

    expect(
      await repo.unlockedPackIds(userId: 'user-1', packs: const [core, edge]),
      {'p-core', 'p-edge'},
    );
  });

  test('a local grant unlocks immediately and is marked local', () async {
    await repo.recordLocalGrant(userId: 'user-1', packId: 'p-edge');

    final row = await db.select(db.entitlements).getSingle();
    expect(row.local, isTrue);
    // Drift stores date times as unix seconds and hands them back in the
    // local zone, exactly as FeralDatabase.watermarkFor documents. The instant
    // is right; the comparison has to say so.
    expect(row.acquiredAt.toUtc(), DateTime.utc(2026, 6, 1, 12));
    expect(await repo.isUnlocked(userId: 'user-1', pack: edge), isTrue);
  });

  test('a local grant does not overwrite a server row', () async {
    await serverRow('p-edge');
    await repo.recordLocalGrant(userId: 'user-1', packId: 'p-edge');

    final row = await db.select(db.entitlements).getSingle();
    expect(row.local, isFalse, reason: 'the server already confirmed this');
    expect(row.acquiredAt.toUtc(), DateTime.utc(2026, 5, 1));
  });

  test('restore unlocks what the store account owns', () async {
    await gateway.configure('user-1');
    gateway.storeOwned.add('pack.edge');

    final summary = await repo.restore(
      userId: 'user-1',
      packs: const [core, edge],
    );

    expect(summary.succeeded, isTrue);
    expect(summary.unlockedPacks, 1, reason: 'the core pack was never locked');
    expect(await repo.isUnlocked(userId: 'user-1', pack: edge), isTrue);
  });

  test(
    'restore with nothing to restore succeeds and unlocks nothing',
    () async {
      await gateway.configure('user-1');
      final summary = await repo.restore(
        userId: 'user-1',
        packs: const [core, edge],
      );

      expect(summary.succeeded, isTrue);
      expect(summary.unlockedPacks, 0);
    },
  );

  test('a failed restore reports the failure and changes nothing', () async {
    await gateway.configure('user-1');
    gateway.restoreError = StateError('store unreachable');

    final summary = await repo.restore(
      userId: 'user-1',
      packs: const [core, edge],
    );

    expect(summary.succeeded, isFalse);
    expect(summary.error, isNotNull);
    expect(await db.select(db.entitlements).get(), isEmpty);
  });

  test('restore ignores products that match no pack', () async {
    await gateway.configure('user-1');
    gateway.storeOwned.add('com.example.feral.pack.from-the-future');

    final summary = await repo.restore(
      userId: 'user-1',
      packs: const [core, edge],
    );

    expect(summary.succeeded, isTrue);
    expect(summary.unlockedPacks, 0);
    expect(await db.select(db.entitlements).get(), isEmpty);
  });

  test('wipeLocal removes every row, server and local alike', () async {
    await serverRow('p-edge');
    await repo.recordLocalGrant(userId: 'user-2', packId: 'p-edge');

    await repo.wipeLocal();

    expect(await db.select(db.entitlements).get(), isEmpty);
  });
}
