import 'package:drift/native.dart';
import 'package:feral/src/app/providers.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/sync/sync_scheduler.dart';
import 'package:feral/src/ui/home_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_auth_gateway.dart';
import '../support/fake_purchase_gateway.dart';
import '../support/fake_sync.dart';

import '../support/fake_content_api.dart';
import '../support/pump.dart';

/// The wiring test the sync engine never had.
///
/// Every rule inside SyncRepository and SyncScheduler is covered elsewhere, and
/// all of it was dead code: nothing in the app ever asked for a sync, so no row
/// a user wrote on their phone ever reached the server. That is invisible to a
/// unit test of either piece, and it is the whole of what this file watches.
void main() {
  late FeralDatabase db;
  late FakeSync runner;
  late FakeGate gate;
  late SyncScheduler scheduler;
  late FakeAuthGateway auth;
  late SharedPreferences prefs;

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    runner = FakeSync();
    gate = FakeGate();
    scheduler = SyncScheduler(
      runner: runner,
      gate: gate,
      clock: FixedClock(DateTime.utc(2026, 6, 10, 9)),
    );
    auth = FakeAuthGateway();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  tearDown(() async {
    scheduler.dispose();
    gate.dispose();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          contentRepositoryProvider.overrideWithValue(
            ContentRepository(db: db, api: SilentContentApi()),
          ),
          authGatewayProvider.overrideWithValue(auth),
          purchaseGatewayProvider.overrideWithValue(FakePurchaseGateway()),
          syncSchedulerProvider.overrideWithValue(scheduler),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: wrap(const HomeRouter()),
      ),
    );
    await pumpUntil(tester, () => runner.userIds.isNotEmpty);
  }

  testWidgets('launching the app syncs the session it launched with', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(
      runner.userIds,
      contains('anon-user'),
      reason:
          'an anonymous user is a real account with real rows. If launch never '
          'asks for a sync, everything they do stays on the phone forever.',
    );
  });

  testWidgets('coming back to the app sends what it could not send away', (
    tester,
  ) async {
    await pumpApp(tester);
    runner.userIds.clear();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpUntil(tester, () => runner.userIds.isNotEmpty);

    expect(
      runner.userIds,
      contains('anon-user'),
      reason:
          'a phone that was offline when the user reported a day has to try '
          'again, and returning to the app is the first moment it can',
    );
  });
}
