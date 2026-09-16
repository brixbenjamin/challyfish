import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/app/providers.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:feral/src/sync/sync_scheduler.dart';
import 'package:feral/src/ui/home_router.dart';
import 'package:feral/src/ui/identity/email_code_screen.dart';
import 'package:feral/src/ui/identity/link_sheet.dart';
import 'package:feral/src/ui/identity/replace_confirm_screen.dart';
import 'package:feral/src/ui/onboarding/diagnostic_screen.dart';
import 'package:feral/src/ui/onboarding/doctrine_intro_screen.dart';
import 'package:feral/src/ui/onboarding/privacy_notice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_content_api.dart';
import '../support/fake_auth_gateway.dart';
import '../support/fake_purchase_gateway.dart';
import '../support/fake_sync.dart';
import 'settings_screen_test.dart' show FakeScheduler;
import 'sign_in_restore_test.dart' show RestoringSync;

import '../support/pump.dart';

/// The other end of ADR-0024.
///
/// [sign_in_restore_test.dart] covers the returning user who reaches sign-in
/// through settings — which they can only do from inside the app, having first
/// answered the diagnostic as somebody else. This file covers the user who has
/// just installed and is looking at the first screen: their record exists, it
/// is on an account, and the only thing standing between them and it used to be
/// eight questions they had already answered once.
void main() {
  late FeralDatabase db;
  late RestoringSync runner;
  late FakeGate gate;
  late SyncScheduler scheduler;
  late FakeAuthGateway auth;
  late SharedPreferences prefs;

  final now = DateTime.utc(2026, 6, 5);

  Future<void> seedContent() async {
    await db
        .into(db.archetypes)
        .insert(
          ArchetypesCompanion.insert(
            id: 'arch-a',
            key: 'a',
            name: 'A',
            blurb: 'b',
            color: '#000',
            sort: 1,
            updatedAt: now,
          ),
        );
    await db
        .into(db.packs)
        .insert(
          PacksCompanion.insert(
            id: 'pack-1',
            key: 'core',
            title: 'Core',
            description: 'd',
            isCore: const Value(true),
            sort: 1,
            updatedAt: now,
          ),
        );
    await db
        .into(db.campaigns)
        .insert(
          CampaignsCompanion.insert(
            id: 'campaign-1',
            packId: 'pack-1',
            key: 'cold-approach',
            title: 'Cold Approach',
            introMd: 'intro',
            lengthDays: 7,
            sort: 1,
            updatedAt: now,
          ),
        );
  }

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    runner = RestoringSync(db);
    gate = FakeGate();
    scheduler = SyncScheduler(
      runner: runner,
      gate: gate,
      clock: FixedClock(now),
    );
    auth = FakeAuthGateway();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    // Nothing on this phone. That is the whole point: a fresh install has no
    // diagnostic, no run and no day logs, so the app opens on the first screen.
    await seedContent();
  });

  tearDown(() async {
    scheduler.dispose();
    gate.dispose();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // A phone, not the 800x600 default: the link sheet is a real bottom sheet
    // with three provider buttons and an overflow is an error in a widget test.
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

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
          reminderSchedulerProvider.overrideWithValue(FakeScheduler()),
          clockProvider.overrideWithValue(FixedClock(now)),
        ],
        child: wrap(const HomeRouter()),
      ),
    );
    await pumpUntil(
      tester,
      () => find.byType(DoctrineIntroScreen).evaluate().isNotEmpty,
    );
  }

  /// The start screen, the sheet, the address, the code. Driven through the
  /// real screens: the question is what the app does with the answer, and that
  /// is only visible from here.
  Future<void> signInFromTheStartScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(DoctrineIntroScreen.signInKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(LinkSheet.keyFor(AuthProvider.email)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(EmailCodeScreen.emailFieldKey),
      'you@example.com',
    );
    await tester.tap(find.byKey(EmailCodeScreen.sendKey));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(EmailCodeScreen.codeFieldKey), '123456');
    await tester.tap(find.byKey(EmailCodeScreen.verifyKey));
  }

  testWidgets('a returning user reaches their record without answering the '
      'diagnostic again', (tester) async {
    auth.addressTaken = true;
    await pumpApp(tester);
    await signInFromTheStartScreen(tester);
    await pumpUntil(
      tester,
      () => find.byIcon(Icons.settings).evaluate().isNotEmpty,
    );

    expect(auth.currentUserId, 'existing-user');
    expect(find.byType(DoctrineIntroScreen), findsNothing);
    expect(find.byType(PrivacyNoticeScreen), findsNothing);
    expect(
      find.byType(DiagnosticScreen),
      findsNothing,
      reason:
          'the account answered these eight questions long ago; answering them '
          'again writes a second result that then outranks the first',
    );
  });

  testWidgets('a first install is never asked to confirm losing a record it '
      'does not have', (tester) async {
    auth.addressTaken = true;
    await pumpApp(tester);

    await tester.tap(find.byKey(DoctrineIntroScreen.signInKey));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(LinkSheet.keyFor(AuthProvider.email)));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(EmailCodeScreen.emailFieldKey),
      'you@example.com',
    );
    await tester.tap(find.byKey(EmailCodeScreen.sendKey));
    await tester.pumpAndSettle();

    // The replace confirmation names what signing in would destroy. Here that
    // is nothing, and a screen asking a brand new install to weigh the loss of
    // an empty record would be a lie (ADR-0014).
    expect(find.byType(ReplaceConfirmScreen), findsNothing);
    expect(find.byKey(EmailCodeScreen.codeFieldKey), findsOneWidget);
  });

  testWidgets('an address with no account behind it links and carries on', (
    tester,
  ) async {
    auth.addressTaken = false;
    await pumpApp(tester);
    await signInFromTheStartScreen(tester);
    await pumpUntil(
      tester,
      () => find.byType(PrivacyNoticeScreen).evaluate().isNotEmpty,
    );

    // They said they had an account and turned out not to. Nothing failed: the
    // address is theirs now, and the only thing left is the onboarding they
    // were already standing in. Landing back on the intro would read as the tap
    // having done nothing at all.
    expect(find.byType(PrivacyNoticeScreen), findsOneWidget);
    expect(find.byType(DoctrineIntroScreen), findsNothing);
    expect(auth.currentUserId, 'anon-user');
    expect(auth.linkedIdentity?.label, 'you@example.com');
  });
}
