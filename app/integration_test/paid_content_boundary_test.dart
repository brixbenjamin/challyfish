import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/remote/purchase_gateway.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/domain/purchase.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Walks the path a paying user takes, and the path a non-paying user cannot.
///
/// Every assertion here is about what the *database* hands a real session, not
/// about what the app chose to ask for. Tasks 1 through 8 each proved their own
/// layer; nothing in them proves the defect ADR-0025 was written about is gone,
/// because the three extraction paths were found from outside the app. This is
/// where that is checked.
///
/// Runs against a local Supabase stack with the seed applied. Like
/// money_path_test.dart it needs a device target; see Q14 for where these run.

/// A device that has never seen a store, so every answer comes from the rows
/// the sync pulled rather than an SDK cache.
class NoStoreGateway implements PurchaseGateway {
  @override
  Future<void> configure(String userId) async {}

  @override
  Future<void> switchUser(String userId) async {}

  @override
  Future<void> forgetUser() async {}

  @override
  Future<List<StoreProduct>> products(Iterable<String> productIds) async =>
      const [];

  @override
  Future<PurchaseOutcome> purchase(String productId) async =>
      const PurchaseFailed('no store on this device');

  @override
  Future<RestoreResult> restore() async =>
      const RestoreResult(succeeded: true, ownedProductIds: {});

  @override
  Future<Set<String>> ownedProductIds() async => const {};

  @override
  Stream<Set<String>> get ownedProductChanges => const Stream.empty();
}

class Device {
  Device(
    this.client, {
    required this.userId,
    required DateTime now,
    required tz.Location zone,
  }) : db = FeralDatabase(NativeDatabase.memory()) {
    content = ContentRepository(db: db, api: SupabaseContentApi(client));
    sync = SyncRepository(
      db: db,
      api: SupabaseProgressApi(client),
      clock: FixedClock(now),
    );
    progress = ProgressRepository(db: db, clock: FixedClock(now), zone: zone);
    entitlements = EntitlementRepository(
      db: db,
      gateway: NoStoreGateway(),
      clock: FixedClock(now),
    );
  }

  final SupabaseClient client;
  final String userId;
  final FeralDatabase db;
  late final ContentRepository content;
  late final SyncRepository sync;
  late final ProgressRepository progress;
  late final EntitlementRepository entitlements;

  Future<void> pullContent() => content.refresh(force: true);

  Future<void> syncNow() => sync.refresh(userId);

  Future<void> close() => db.close();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late SupabaseClient client;
  late SupabaseClient serviceRole;
  late String userId;
  late tz.Location zone;
  late Device device;

  const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  setUpAll(() async {
    tzdata.initializeTimeZones();
    zone = tz.getLocation('Europe/Berlin');

    await Supabase.initialize(
      url: url,
      publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    client = Supabase.instance.client;
    await client.auth.signInAnonymously();
    userId = client.auth.currentUser!.id;

    serviceRole = SupabaseClient(
      url,
      const String.fromEnvironment('SUPABASE_SERVICE_ROLE_KEY'),
    );
  });

  setUp(() {
    device = Device(
      client,
      userId: userId,
      now: DateTime.utc(2026, 6, 10, 9),
      zone: zone,
    );
  });

  tearDown(() async {
    await device.close();
    await serviceRole.from('day_logs').delete().eq('user_id', userId);
    await serviceRole.from('campaign_runs').delete().eq('user_id', userId);
    await serviceRole.from('entitlements').delete().eq('user_id', userId);
  });

  /// Exactly what supabase/functions/revenuecat-webhook does on a purchase.
  Future<void> webhookGrants(Pack pack) => serviceRole
      .from('entitlements')
      .upsert({'user_id': userId, 'pack_id': pack.id, 'source': 'store'});

  /// And on a refund: the row is deleted, carrying no newer timestamp.
  Future<void> webhookRevokes(Pack pack) => serviceRole
      .from('entitlements')
      .delete()
      .eq('user_id', userId)
      .eq('pack_id', pack.id);

  Future<Pack> paidPack() async =>
      (await device.content.packs()).firstWhere((p) => !p.isCore);

  Future<Pack> corePack() async =>
      (await device.content.packs()).firstWhere((p) => p.isCore);

  testWidgets('a locked campaign is browsable and unreadable', (tester) async {
    await device.pullContent();

    final paid = await paidPack();
    final campaign = (await device.content.campaignsFor(paid.id)).first;

    // Browsable: the teaser survives the split. Everything a locked campaign
    // shows in browse is still there (ADR-0008).
    expect(campaign.title, isNotEmpty);
    expect(campaign.introMd, isNotEmpty);
    expect(campaign.lengthDays, greaterThan(0));

    final actions = await device.content.actionsFor(campaign.id);
    expect(
      actions,
      hasLength(campaign.lengthDays),
      reason: 'every day is present as a teaser row',
    );
    expect(actions.every((a) => a.title.isNotEmpty), isTrue);

    // Unreadable: not one body came down, for any day.
    expect(
      actions.where((a) => a.bodyMd != null),
      isEmpty,
      reason:
          'the server refused the copy for a pack this account has not '
          'bought, and no client-side filter was involved',
    );

    // The free pack, by contrast, arrives whole. Without this the test above
    // would pass just as well against a pull that fetched nothing at all.
    final core = await corePack();
    final freeCampaign = (await device.content.campaignsFor(core.id)).first;
    final freeActions = await device.content.actionsFor(freeCampaign.id);
    expect(
      freeActions.every((a) => a.bodyMd != null),
      isTrue,
      reason: 'the free pack is readable by everyone, signed in or not',
    );
  });

  testWidgets('a purchase delivers the copy', (tester) async {
    await device.pullContent();

    final paid = await paidPack();
    final campaign = (await device.content.campaignsFor(paid.id)).first;
    expect(
      (await device.content.dayFor(campaign.id, 1))?.mandatory?.bodyMd,
      isNull,
      reason: 'nothing to deliver yet',
    );

    await webhookGrants(paid);

    // The rows now readable were invisible to this device a moment ago, and no
    // row's `updated_at` moved to say so — the reader changed, not the library.
    // A forced refresh is what crosses that gap (ADR-0025).
    await device.syncNow();
    await device.pullContent();

    expect(
      await device.content.hasBodyForFirstDay(paid.id),
      isTrue,
      reason: 'the pack opens onto a real day, not a blank one',
    );
    final day1 = (await device.content.dayFor(campaign.id, 1))?.mandatory;
    expect(day1?.bodyMd, isNotNull);
    expect(day1!.bodyMd, isNotEmpty);
  });

  testWidgets('a refund takes it back and keeps the record', (tester) async {
    await device.pullContent();

    final paid = await paidPack();
    final campaign = (await device.content.campaignsFor(paid.id)).first;

    await webhookGrants(paid);
    await device.syncNow();
    await device.pullContent();
    expect(await device.content.hasBodyForFirstDay(paid.id), isTrue);

    // Three days of honest effort on the pack they bought.
    final run = await device.progress.startRun(
      userId: userId,
      campaignId: campaign.id,
      isUnlocked: true,
    );
    for (var day = 1; day <= 3; day++) {
      final action = (await device.content.dayFor(
        campaign.id,
        day,
      ))!.mandatory!;
      await device.progress.commitToday(
        run: run,
        dayIndex: day,
        actionId: action.id,
      );
      await device.progress.report(
        run: run,
        dayIndex: day,
        mandatoryActionId: action.id,
        outcome: Outcome.done,
      );
    }

    await webhookRevokes(paid);

    // A refund deletes the row, which carries no newer updated_at. The complete
    // set fetch is what makes it observable at all.
    await device.syncNow();

    expect(
      await device.entitlements.isUnlocked(userId: userId, pack: paid),
      isFalse,
    );
    expect(
      await device.content.hasBodyForFirstDay(paid.id),
      isFalse,
      reason: 'the copy goes back when the entitlement does',
    );

    final after = await device.progress.runById(run.id);
    expect(
      after?.status,
      RunStatus.abandoned,
      reason: 'the run is closed, not deleted',
    );
    final logs = await device.progress.logsFor(run.id);
    expect(
      logs.where((l) => l.outcome == Outcome.done),
      hasLength(3),
      reason: 'effort is never erased (ADR-0003)',
    );

    // And the teaser is still there: a relocked campaign is browsable again,
    // exactly as it was before the purchase.
    final actions = await device.content.actionsFor(campaign.id);
    expect(actions, hasLength(campaign.lengthDays));
    expect(actions.where((a) => a.bodyMd != null), isEmpty);
  });
}
