import 'package:drift/drift.dart' show InsertMode, Value;
import 'package:drift/native.dart';
import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/providers.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:feral/src/domain/sync_status.dart';
import 'package:feral/src/sync/sync_scheduler.dart';
import 'package:feral/src/ui/home_router.dart';
import 'package:feral/src/ui/identity/email_code_screen.dart';
import 'package:feral/src/ui/identity/link_sheet.dart';
import 'package:feral/src/ui/identity/replace_confirm_screen.dart';
import 'package:feral/src/ui/onboarding/diagnostic_screen.dart';
import 'package:feral/src/ui/onboarding/doctrine_intro_screen.dart';
import 'package:feral/src/ui/onboarding/privacy_notice_screen.dart';
import 'package:feral/src/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_sync_wiring_test.dart' show SilentContentApi, pumpUntil;
import '../data/identity_repository_test.dart' show FakeAuthGateway;
import '../support/fake_purchase_gateway.dart';
import '../sync/sync_scheduler_test.dart' show FakeGate;
import 'settings_screen_test.dart' show FakeScheduler;

/// A pull that actually brings the signed-in account's record back.
///
/// The bug this file exists for is a race, and a runner that writes nothing
/// cannot lose it. This one behaves like the real thing: the account's
/// diagnostic arrives in the local store only when a sync for that account
/// completes, and never a frame earlier.
class RestoringSync implements SyncRunner {
  RestoringSync(this.db);

  final FeralDatabase db;
  final List<String> userIds = [];
  bool succeed = true;

  @override
  Future<SyncOutcome> sync(String userId) async {
    userIds.add(userId);
    const ok = PushResult(succeeded: true);
    const bad = PushResult(succeeded: false, error: 'boom');
    if (!succeed) {
      return const SyncOutcome(
        push: bad,
        pull: PullResult(succeeded: false, error: 'boom'),
      );
    }
    if (userId == 'existing-user') {
      await db
          .into(db.diagnosticResults)
          .insert(
            DiagnosticResultsCompanion.insert(
              id: 'dr-existing',
              userId: 'existing-user',
              takenAt: DateTime.utc(2026, 5, 1),
              scores: '{"a":0.5,"b":0.5}',
              weakestArchetypeId: 'arch-a',
              recommendedCampaignId: 'campaign-1',
              updatedAt: DateTime.utc(2026, 5, 1),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
    return const SyncOutcome(push: ok, pull: PullResult(succeeded: true));
  }

  @override
  List<SyncNotice> consumeNotices() => const [];
}

void main() {
  late AppLocalizations l10n;
  late FeralDatabase db;
  late RestoringSync runner;
  late FakeGate gate;
  late SyncScheduler scheduler;
  late FakeAuthGateway auth;
  late SharedPreferences prefs;

  final now = DateTime.utc(2026, 6, 5);

  // A failed sync leaves a backoff timer armed, which the framework reports as
  // a leak if the tree is torn down first. Tests that end on a failure stop the
  // scheduler themselves; the guard keeps the tearDown from disposing twice.
  var schedulerStopped = false;
  void stopScheduler() {
    if (schedulerStopped) return;
    schedulerStopped = true;
    scheduler.dispose();
  }


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
    await db
        .into(db.campaignArchetypes)
        .insert(
          CampaignArchetypesCompanion.insert(
            campaignId: 'campaign-1',
            archetypeId: 'arch-a',
            updatedAt: now,
          ),
        );
    for (var day = 1; day <= 7; day++) {
      await db
          .into(db.actions)
          .insert(
            ActionsCompanion.insert(
              id: 'action-$day',
              campaignId: 'campaign-1',
              dayIndex: day,
              title: 'Day $day',
              bodyMd: 'do it',
              archetypeId: 'arch-a',
              updatedAt: now,
            ),
          );
    }
  }

  /// What the user built on this phone under an anonymous account: a diagnostic
  /// they answered and a campaign they are three days into. It is what makes
  /// the replace confirmation appear, and it is what signing in destroys.
  Future<void> seedAnonymousProgress() async {
    await db
        .into(db.diagnosticResults)
        .insert(
          DiagnosticResultsCompanion.insert(
            id: 'dr-anon',
            userId: 'anon-user',
            takenAt: DateTime.utc(2026, 6, 1),
            scores: '{"a":0.5,"b":0.5}',
            weakestArchetypeId: 'arch-a',
            recommendedCampaignId: 'campaign-1',
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: 'run-1',
            userId: 'anon-user',
            campaignId: 'campaign-1',
            status: 'active',
            startedAt: DateTime.utc(2026, 6, 3),
            updatedAt: DateTime.utc(2026, 6, 3),
          ),
        );
  }

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    runner = RestoringSync(db);
    gate = FakeGate();
    scheduler = SyncScheduler(
      runner: runner,
      gate: gate,
      clock: FixedClock(now),
    );
    auth = FakeAuthGateway()..addressTaken = true;
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    schedulerStopped = false;
    await seedContent();
    await seedAnonymousProgress();
  });

  tearDown(() async {
    stopScheduler();
    gate.dispose();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    // A phone, not the 800x600 default. The link sheet is a real bottom sheet
    // with three provider buttons in it and does not fit the default surface,
    // and an overflow is an error in a widget test.
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
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomeRouter(),
        ),
      ),
    );
    await pumpUntil(tester, () => find.byIcon(Icons.settings).evaluate().isNotEmpty);
  }

  /// Settings, link, email, the taken address, the confirmation, the code.
  /// Driven through the real screens rather than by calling the repository,
  /// because the defect was never in the repository — it was in what the app
  /// did with the answer.
  Future<void> signInWithATakenAddress(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SettingsScreen.linkRowKey));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(LinkSheet.keyFor(AuthProvider.email)));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(EmailCodeScreen.emailFieldKey),
      'you@example.com',
    );
    await tester.tap(find.byKey(EmailCodeScreen.sendKey));
    await tester.pumpAndSettle();

    // The one screen standing between a user and losing a record.
    expect(find.byKey(ReplaceConfirmScreen.confirmKey), findsOneWidget);
    await tester.tap(find.byKey(ReplaceConfirmScreen.confirmKey));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(EmailCodeScreen.codeFieldKey), '123456');
    await tester.tap(find.byKey(EmailCodeScreen.verifyKey));
  }

  testWidgets(
    'signing in to an account that has a diagnostic never asks for one again',
    (tester) async {
      await pumpApp(tester);
      await signInWithATakenAddress(tester);
      await pumpUntil(
        tester,
        () => find.byIcon(Icons.settings).evaluate().isNotEmpty,
      );

      // The reported bug, exactly: the doctrine intro, the privacy notice and
      // the diagnostic, shown to a returning user whose account answered all
      // three long ago. Routing happened against a store that had just been
      // emptied, before the pull that refills it had landed (ADR-0024).
      expect(find.byType(DoctrineIntroScreen), findsNothing);
      expect(find.byType(PrivacyNoticeScreen), findsNothing);
      expect(
        find.byType(DiagnosticScreen),
        findsNothing,
        reason:
            'answering it again writes a second, contradictory result to an '
            'account that already had one, and the newer wrong one then wins',
      );
      expect(auth.currentUserId, 'existing-user');
    },
  );

  testWidgets('the restore is waited for, not fired and forgotten', (
    tester,
  ) async {
    await pumpApp(tester);
    await signInWithATakenAddress(tester);
    await pumpUntil(
      tester,
      () => find.byIcon(Icons.settings).evaluate().isNotEmpty,
    );

    expect(
      runner.userIds,
      contains('existing-user'),
      reason: 'the signed-in account has to be pulled, and pulled as itself',
    );
    expect(
      await (db.select(
        db.diagnosticResults,
      )..where((r) => r.userId.equals('existing-user'))).get(),
      hasLength(1),
      reason:
          'the account record is in the local store by the time the app has '
          'decided where to send the user',
    );
  });

  testWidgets('the wait says what it is waiting for', (tester) async {
    await pumpApp(tester);
    runner.succeed = false;
    await signInWithATakenAddress(tester);
    await pumpUntil(
      tester,
      () => find.byKey(HomeRouter.restoreRetryKey).evaluate().isNotEmpty,
    );

    // A bare spinner is what launch shows. This user is waiting for a record
    // that exists, and on failure has to be told it still does — this is the
    // moment they most fear having lost it (ADR-0024).
    expect(find.text(l10n.restoringRecordTitle), findsOneWidget);
    expect(find.text(l10n.restoringRecordFailed), findsOneWidget);
    stopScheduler();
  });

  testWidgets('a restore that fails offers a retry rather than onboarding', (
    tester,
  ) async {
    await pumpApp(tester);
    runner.succeed = false;
    await signInWithATakenAddress(tester);
    await pumpUntil(tester, () => find.byType(DoctrineIntroScreen).evaluate().isNotEmpty);

    // The session has already swapped and the local rows are already gone.
    // Onboarding would invite a second diagnostic; an empty dashboard would
    // read as "your record is gone". Neither is true, so neither is shown.
    expect(find.byType(DoctrineIntroScreen), findsNothing);
    expect(find.byType(DiagnosticScreen), findsNothing);
    expect(
      find.byKey(HomeRouter.restoreRetryKey),
      findsOneWidget,
      reason: 'retrying is the only honest thing left to offer',
    );
    stopScheduler();
  });

  testWidgets('a retry that succeeds lands the user on their record', (
    tester,
  ) async {
    await pumpApp(tester);
    runner.succeed = false;
    await signInWithATakenAddress(tester);
    await pumpUntil(
      tester,
      () => find.byKey(HomeRouter.restoreRetryKey).evaluate().isNotEmpty,
    );

    runner.succeed = true;
    await tester.tap(find.byKey(HomeRouter.restoreRetryKey));
    await pumpUntil(
      tester,
      () => find.byIcon(Icons.settings).evaluate().isNotEmpty,
    );

    expect(find.byKey(HomeRouter.restoreRetryKey), findsNothing);
    expect(find.byType(DiagnosticScreen), findsNothing);
    expect(scheduler.status, SyncStatus.idle);
  });
}
