import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/providers.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/purchase.dart';
import 'package:feral/src/domain/sync_status.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/sync/sync_scheduler.dart';
import 'package:feral/src/ui/browse/campaign_detail_screen.dart';
import 'package:feral/src/ui/home_router.dart';
import 'package:feral/src/ui/purchase/unlock_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app/app_sync_wiring_test.dart' show SilentContentApi, pumpUntil;
import '../data/identity_repository_test.dart' show FakeAuthGateway;
import '../support/fake_purchase_gateway.dart';
import '../sync/sync_scheduler_test.dart' show FakeGate;
import 'settings_screen_test.dart' show FakeScheduler;

/// Answers nothing. The purchase controller reconciles entitlements during
/// delivery (ADR-0025), and without this it reaches for a live Supabase client.
class SilentProgressApi implements ProgressApi {
  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {}

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async => const [];
}

/// A sync that does nothing, so the only thing that can unlock the pack in this
/// file is the purchase itself.
class QuietSync implements SyncRunner {
  @override
  Future<SyncOutcome> sync(String userId) async => const SyncOutcome(
    push: PushResult(succeeded: true),
    pull: PullResult(succeeded: true),
  );

  @override
  List<SyncNotice> consumeNotices() => const [];
}

void main() {
  late AppLocalizations l10n;
  late FeralDatabase db;
  late FakeGate gate;
  late SyncScheduler scheduler;
  late FakeAuthGateway auth;
  late FakePurchaseGateway store;
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
            id: 'pack-edge',
            key: 'edge',
            title: 'The Edge',
            description: 'Harder.',
            isCore: const Value(false),
            storeProductId: const Value('pack.edge'),
            sort: 1,
            updatedAt: now,
          ),
        );
    await db
        .into(db.campaigns)
        .insert(
          CampaignsCompanion.insert(
            id: 'campaign-edge',
            packId: 'pack-edge',
            key: 'thirty',
            title: 'Thirty',
            introMd: 'intro',
            lengthDays: 30,
            sort: 1,
            updatedAt: now,
          ),
        );
    await db
        .into(db.campaignArchetypes)
        .insert(
          CampaignArchetypesCompanion.insert(
            campaignId: 'campaign-edge',
            archetypeId: 'arch-a',
            updatedAt: now,
          ),
        );
    // Day one and its copy. This file is about the screen behind the sheet
    // refreshing after a purchase, not about delivery: with the body already
    // present, delivery completes on its first check and the sheet closes the
    // way it did before ADR-0025. purchase_delivery_test.dart owns the fetch.
    await db
        .into(db.actions)
        .insert(
          ActionsCompanion.insert(
            id: 'action-edge-1',
            campaignId: 'campaign-edge',
            dayIndex: 1,
            title: 'Day 1',
            archetypeId: 'arch-a',
            updatedAt: now,
          ),
        );
    await db
        .into(db.actionBodies)
        .insert(
          ActionBodiesCompanion.insert(
            actionId: 'action-edge-1',
            bodyMd: 'copy',
            updatedAt: now,
          ),
        );
  }

  /// A user who has answered the diagnostic and has no run going: the state
  /// that lands on browse, which is where a pack is bought from.
  Future<void> seedAnsweredDiagnostic() async {
    await db
        .into(db.diagnosticResults)
        .insert(
          DiagnosticResultsCompanion.insert(
            id: 'dr-anon',
            userId: 'anon-user',
            takenAt: DateTime.utc(2026, 6, 1),
            scores: '{"a":0.5}',
            weakestArchetypeId: 'arch-a',
            recommendedCampaignId: 'campaign-edge',
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
  }

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    gate = FakeGate();
    scheduler = SyncScheduler(
      runner: QuietSync(),
      gate: gate,
      clock: FixedClock(now),
    );
    auth = FakeAuthGateway();
    store = FakePurchaseGateway(
      catalogue: const [
        StoreProduct(id: 'pack.edge', title: 'The Edge', priceString: r'$9.99'),
      ],
    );
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    await seedContent();
    await seedAnsweredDiagnostic();
  });

  tearDown(() async {
    scheduler.dispose();
    gate.dispose();
    await store.dispose();
    await db.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
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
          syncRepositoryProvider.overrideWithValue(
            SyncRepository(
              db: db,
              api: SilentProgressApi(),
              clock: FixedClock(now),
            ),
          ),
          authGatewayProvider.overrideWithValue(auth),
          purchaseGatewayProvider.overrideWithValue(store),
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
    await pumpUntil(tester, () => find.text('Thirty').evaluate().isNotEmpty);
  }

  testWidgets('the screen behind the sheet offers Start once the pack is paid '
      'for', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('Thirty'));
    await pumpUntil(
      tester,
      () => find.byType(CampaignDetailScreen).evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.unlockButton), findsOneWidget);

    await tester.tap(find.text(l10n.unlockButton));
    await pumpUntil(
      tester,
      () => find.byKey(UnlockSheet.buyKey).evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(UnlockSheet.buyKey));
    await pumpUntil(
      tester,
      () => find.byKey(UnlockSheet.buyKey).evaluate().isEmpty,
    );
    await tester.pumpAndSettle();

    // The reported bug: the sheet closes on a successful purchase and the
    // screen it opened from keeps asking for money for a pack the user has
    // just bought.
    expect(
      find.text(l10n.startButton),
      findsOneWidget,
      reason:
          'a paid-for campaign is startable, and the screen the user is '
          'looking at is where they find that out',
    );
    expect(find.text(l10n.unlockButton), findsNothing);
  });

  testWidgets('a restore from the sheet updates the screen behind it too', (
    tester,
  ) async {
    // Bought on another install, so the store owns it and this user does not.
    store.storeOwned.add('pack.edge');

    await pumpApp(tester);

    await tester.tap(find.text('Thirty'));
    await pumpUntil(
      tester,
      () => find.byType(CampaignDetailScreen).evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(l10n.unlockButton));
    await pumpUntil(
      tester,
      () => find.byKey(UnlockSheet.restoreKey).evaluate().isNotEmpty,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(UnlockSheet.restoreKey));
    await pumpUntil(
      tester,
      () => find.byKey(UnlockSheet.restoreKey).evaluate().isEmpty,
    );
    await tester.pumpAndSettle();

    expect(find.text(l10n.startButton), findsOneWidget);
    expect(find.text(l10n.unlockButton), findsNothing);
  });
}
