import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:test/test.dart';

import '../support/fake_purchase_gateway.dart';
// The fake auth gateway lives in plan 3's identity test rather than in
// test/support, so it is imported from there — the same way the settings tests
// share FakeScheduler.
import 'identity_repository_test.dart' show FakeAuthGateway;

void main() {
  late FeralDatabase db;
  late FakePurchaseGateway purchases;
  late FakeAuthGateway auth;
  late IdentityRepository repo;

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    purchases = FakePurchaseGateway();
    auth = FakeAuthGateway()..userId = 'user-1';
    repo = IdentityRepository(
      db: db,
      auth: auth,
      entitlements: EntitlementRepository(
        db: db,
        gateway: purchases,
        clock: FixedClock(DateTime.utc(2026, 6, 1)),
      ),
      purchases: purchases,
    );
  });

  tearDown(() async {
    await purchases.dispose();
    await db.close();
  });

  Future<void> ownedRow(String userId) => db
      .into(db.entitlements)
      .insert(
        EntitlementsCompanion.insert(
          userId: userId,
          packId: 'p-edge',
          source: 'store',
          acquiredAt: DateTime.utc(2026, 5, 1),
          updatedAt: DateTime.utc(2026, 5, 1),
        ),
      );

  test('linking keeps every entitlement and never touches the store', () async {
    await ownedRow('user-1');
    await purchases.configure('user-1');

    final outcome = await repo.attach(
      provider: AuthProvider.apple,
      credential: 'credential',
    );

    expect(outcome, isA<Linked>());
    expect(
      await db.select(db.entitlements).get(),
      hasLength(1),
      reason: 'the user id is unchanged, so nothing moves',
    );
    expect(
      purchases.switchUserCalls,
      0,
      reason:
          'asking the store to move a purchase to the id it already has '
          'can produce a transfer that revokes it',
    );
  });

  test(
    'signing in wipes local entitlements and switches the store user',
    () async {
      await ownedRow('user-1');
      await purchases.configure('user-1');
      auth.identityTaken = true;

      await repo.completeSignIn(
        provider: AuthProvider.apple,
        credential: 'credential',
      );

      expect(
        await db.select(db.entitlements).get(),
        isEmpty,
        reason: 'this device now belongs to another account',
      );
      expect(purchases.switchUserCalls, 1);
      expect(purchases.currentUserId, 'existing-user');
    },
  );

  test(
    'a fresh anonymous session forgets the store user and wipes rows',
    () async {
      await ownedRow('user-1');
      await purchases.configure('user-1');

      await repo.resetToFreshAnonymous();

      expect(await db.select(db.entitlements).get(), isEmpty);
      expect(purchases.forgetUserCalls, 1);
    },
  );

  test(
    'a store that fails during sign-in does not abort the sign-in',
    () async {
      // The account switch has already happened server-side. Refusing to finish
      // it because a purchase SDK is unreachable would leave the app in a state
      // that matches neither account.
      await ownedRow('user-1');
      purchases.failSwitchUser = true;

      final outcome = await repo.completeSignIn(
        provider: AuthProvider.apple,
        credential: 'credential',
      );

      expect(outcome, isA<SignedIn>(), reason: 'the sign-in still completes');
      expect(await db.select(db.entitlements).get(), isEmpty);
    },
  );

  test('the local wipe knows about entitlements and their watermark', () async {
    // A user table the wipe does not know about is exactly the bug plan 3's
    // tests were written to prevent.
    await ownedRow('user-1');
    await db.setWatermark('entitlements', DateTime.utc(2026, 5, 1));

    await repo.completeSignIn(
      provider: AuthProvider.apple,
      credential: 'credential',
    );

    expect(await db.select(db.entitlements).get(), isEmpty);
    expect(
      await db.watermarkFor('entitlements'),
      isNull,
      reason: 'a stale watermark would skip the new account\'s rows',
    );
  });
}
