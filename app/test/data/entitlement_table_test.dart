import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/domain/entitlement.dart';
import 'package:test/test.dart';

void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('an entitlement round-trips', () async {
    await db
        .into(db.entitlements)
        .insert(
          EntitlementsCompanion.insert(
            userId: 'user-1',
            packId: 'pack-1',
            source: 'store',
            acquiredAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );

    final row = await db.select(db.entitlements).getSingle();
    expect(row.userId, 'user-1');
    expect(row.packId, 'pack-1');
    expect(row.source, 'store');
    expect(row.local, isFalse, reason: 'a pulled row is not a local grant');
  });

  test('the same pack twice is one row, not two', () async {
    Future<void> put(String source) => db
        .into(db.entitlements)
        .insertOnConflictUpdate(
          EntitlementRow(
            userId: 'user-1',
            packId: 'pack-1',
            source: source,
            acquiredAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
            local: false,
          ),
        );

    await put('store');
    await put('grant');

    final rows = await db.select(db.entitlements).get();
    expect(rows, hasLength(1));
    expect(rows.single.source, 'grant');
  });

  test('two users can own the same pack', () async {
    for (final user in ['user-1', 'user-2']) {
      await db
          .into(db.entitlements)
          .insert(
            EntitlementsCompanion.insert(
              userId: user,
              packId: 'pack-1',
              source: 'store',
              acquiredAt: DateTime.utc(2026, 6, 1),
              updatedAt: DateTime.utc(2026, 6, 1),
            ),
          );
    }
    expect(await db.select(db.entitlements).get(), hasLength(2));
  });

  test('a local grant is flagged as local', () async {
    await db
        .into(db.entitlements)
        .insert(
          EntitlementsCompanion.insert(
            userId: 'user-1',
            packId: 'pack-1',
            source: 'store',
            acquiredAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
            local: const Value(true),
          ),
        );
    expect((await db.select(db.entitlements).getSingle()).local, isTrue);
  });

  test('the source keys round-trip', () {
    expect(EntitlementSource.fromKey('store'), EntitlementSource.store);
    expect(EntitlementSource.fromKey('grant'), EntitlementSource.grant);
    expect(EntitlementSource.store.key, 'store');
    // An unknown source from a future server version must not crash a client.
    expect(EntitlementSource.fromKey('something-new'), EntitlementSource.grant);
  });
}
