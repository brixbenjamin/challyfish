import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
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
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A device that has never seen a store: no SDK, no cached product ids.
///
/// This is the honest shape for these tests. It forces every answer to come
/// from the rows the sync pulled, which is the half of ADR-0017 a CI runner can
/// actually verify — the SDK cache half needs a sandbox account and is Task 15.
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

/// Every network call fails the way a phone in airplane mode does.
class OfflineApi implements ContentApi, ProgressApi {
  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async =>
      throw const SocketException('offline');

  @override
  Future<int> fetchVersion() async => throw const SocketException('offline');

  @override
  Future<List<Map<String, dynamic>>> fetchAllFor(
    String table,
    String userId,
  ) async => throw const SocketException('offline');

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async =>
      throw const SocketException('offline');
}

/// One local database over one server account, exactly as a phone would be.
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

  /// The day's mandatory action, which ProgressRepository.report requires.
  ///
  /// Two hops, because an action no longer carries a campaign or a day index: it
  /// hangs off `day_id` and the day owns both (ADR-0034). This helper queried the
  /// dropped columns until now, which nothing noticed because CI has never had a
  /// device to run these tests on.
  Future<String> actionIdFor(String campaignId, int dayIndex) async {
    final days = await client
        .from('days')
        .select('id')
        .eq('campaign_id', campaignId)
        .eq('day_index', dayIndex)
        .limit(1);
    final rows = await client
        .from('actions')
        .select('id')
        .eq('day_id', days.first['id'] as String)
        .eq('is_optional', false)
        .limit(1);
    return rows.first['id'] as String;
  }

  Future<void> close() => db.close();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Two databases at once is the point in the second test.
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

    // The webhook's client, not the app's. The app cannot do these writes at
    // all — 070_entitlement_writes.sql asserts exactly that — so a test that
    // wrote them as the user would be testing a system we do not ship.
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

  Future<Pack> paidPack() async =>
      (await device.content.packs()).firstWhere((p) => !p.isCore);

  testWidgets('a locked pack cannot be started, even past the UI', (
    tester,
  ) async {
    await device.pullContent();

    final paid = await paidPack();
    final campaign = (await device.content.campaignsFor(paid.id)).first;

    final unlocked = await device.entitlements.isUnlocked(
      userId: userId,
      pack: paid,
    );
    expect(unlocked, isFalse);

    await expectLater(
      device.progress.startRun(
        userId: userId,
        campaignId: campaign.id,
        isUnlocked: unlocked,
      ),
      throwsA(isA<PackLocked>()),
    );

    expect(
      await device.progress.activeRun(userId),
      isNull,
      reason: 'a refused start writes nothing',
    );
  });

  testWidgets(
    'an entitlement written the way the webhook writes it reaches a second '
    'device',
    (tester) async {
      await device.pullContent();
      final paid = await paidPack();

      await webhookGrants(paid);
      await device.syncNow();

      expect(
        await device.entitlements.isUnlocked(userId: userId, pack: paid),
        isTrue,
      );

      // A second device on the same account, which has never seen a store.
      final b = Device(
        client,
        userId: userId,
        now: DateTime.utc(2026, 6, 10, 9),
        zone: zone,
      );
      addTearDown(b.close);
      await b.pullContent();
      await b.syncNow();

      expect(
        await b.entitlements.isUnlocked(userId: userId, pack: paid),
        isTrue,
        reason: 'ownership is an account fact, not a device fact',
      );

      final campaign = (await b.content.campaignsFor(paid.id)).first;
      final run = await b.progress.startRun(
        userId: userId,
        campaignId: campaign.id,
        isUnlocked: true,
      );
      expect(run.campaignId, campaign.id);
    },
  );

  testWidgets('an owned pack still opens with the network gone', (
    tester,
  ) async {
    await device.pullContent();
    final paid = await paidPack();

    await webhookGrants(paid);
    await device.syncNow();

    // From here the device is offline: every network call throws, and the two
    // repositories below are the ones the daily loop actually uses.
    final offline = OfflineApi();
    final offlineSync = SyncRepository(
      db: device.db,
      api: offline,
      clock: FixedClock(DateTime.utc(2026, 6, 10, 9)),
    );
    final pull = await offlineSync.refresh(userId);
    expect(
      pull.succeeded,
      isFalse,
      reason: 'the network really is gone, not merely idle',
    );

    expect(
      await device.entitlements.isUnlocked(userId: userId, pack: paid),
      isTrue,
      reason: 'the pulled rows answer with no store and no server',
    );

    final campaign = (await device.content.campaignsFor(paid.id)).first;
    final run = await device.progress.startRun(
      userId: userId,
      campaignId: campaign.id,
      isUnlocked: true,
    );
    await device.progress.commitToday(
      run: run,
      dayIndex: 1,
      actionId: await device.actionIdFor(campaign.id, 1),
    );

    expect(await device.progress.logsFor(run.id), isNotEmpty);
  });

  testWidgets('a refund relocks the pack on the next full resync', (
    tester,
  ) async {
    await device.pullContent();
    final paid = await paidPack();

    await webhookGrants(paid);
    await device.syncNow();
    expect(
      await device.entitlements.isUnlocked(userId: userId, pack: paid),
      isTrue,
    );

    // What the webhook does on REFUND.
    await serviceRole
        .from('entitlements')
        .delete()
        .eq('user_id', userId)
        .eq('pack_id', paid.id);

    // This used to be the documented limit: a revocation reached a device only
    // on a full resync, because a deleted row carries no newer updated_at and
    // an incremental pull cannot see it. ADR-0025 needed revocation to be
    // observable -- purge-on-evidence cannot be built on a pull that
    // structurally never observes a removal -- so entitlements are now fetched
    // as a complete set on every pull. One row per owned pack, and a user owns
    // one. An ordinary sync is enough.
    await device.syncNow();
    expect(
      await device.entitlements.isUnlocked(userId: userId, pack: paid),
      isFalse,
      reason:
          'the complete-set fetch sees the deletion an incremental one '
          'could not',
    );
  });
}
