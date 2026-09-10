import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/clock.dart';
import '../data/local/database.dart';
import '../data/remote/account_api.dart';
import '../data/remote/auth_gateway.dart';
import '../data/remote/content_api.dart';
import '../data/remote/progress_api.dart';
import '../data/remote/purchase_gateway.dart';
import '../data/remote/revenuecat_gateway.dart';
import '../data/remote/seed_snapshot.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/diagnostic_repository.dart';
import '../data/repositories/entitlement_repository.dart';
import '../data/repositories/identity_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/sync_repository.dart';
import '../domain/campaign.dart';
import '../domain/pack.dart';
import '../notifications/reminder_scheduler.dart';
import '../ui/browse/pack_list_screen.dart' show PackView;
import '../sync/sync_scheduler.dart';
import 'link_prompt_state.dart';
import 'purchase_state.dart';

final databaseProvider = Provider<FeralDatabase>((ref) {
  final db = FeralDatabase(driftDatabase(name: 'feral'));
  ref.onDispose(db.close);
  return db;
});

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Overridden in main() once the device zone has been read.
final zoneProvider = Provider<tz.Location>((ref) => tz.UTC);

/// Whoever the session belongs to right now.
///
/// Read from the gateway rather than captured at launch, because the id
/// changes: signing in to an existing account and deleting an account both
/// replace it. A value fixed in main() would leave every repository reading and
/// writing rows under a user this device is no longer authenticated as. Callers
/// that change the session invalidate this (see HomeRouter).
final userIdProvider = Provider<String>((ref) {
  final userId = ref.watch(authGatewayProvider).currentUserId;
  if (userId == null) {
    throw StateError('no session: ensureAnonymousSession() runs before runApp');
  }
  return userId;
});

final contentRepositoryProvider = Provider<ContentRepository>((ref) {
  return ContentRepository(
    db: ref.watch(databaseProvider),
    api: SupabaseContentApi(Supabase.instance.client),
  );
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  return ProgressRepository(
    db: ref.watch(databaseProvider),
    clock: ref.watch(clockProvider),
    zone: ref.watch(zoneProvider),
  );
});

final diagnosticRepositoryProvider = Provider<DiagnosticRepository>((ref) {
  return DiagnosticRepository(
    db: ref.watch(databaseProvider),
    content: ref.watch(contentRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});

final seedSnapshotLoaderProvider = Provider<SeedSnapshotLoader>((ref) {
  return SeedSnapshotLoader(
    db: ref.watch(databaseProvider),
    content: ref.watch(contentRepositoryProvider),
  );
});

final reminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  return LocalReminderScheduler(FlutterLocalNotificationsPlugin());
});

final progressApiProvider = Provider<ProgressApi>(
  (ref) => SupabaseProgressApi(Supabase.instance.client),
);

final syncRepositoryProvider = Provider<SyncRepository>((ref) {
  return SyncRepository(
    db: ref.watch(databaseProvider),
    api: ref.watch(progressApiProvider),
    clock: ref.watch(clockProvider),
  );
});

final connectivityGateProvider = Provider<ConnectivityGate>(
  (ref) => ConnectivityPlusGate(),
);

final syncSchedulerProvider = Provider<SyncScheduler>((ref) {
  final scheduler = SyncScheduler(
    runner: ref.watch(syncRepositoryProvider),
    gate: ref.watch(connectivityGateProvider),
    clock: ref.watch(clockProvider),
  );
  ref.onDispose(scheduler.dispose);
  return scheduler;
});

final authGatewayProvider = Provider<AuthGateway>(
  (ref) => SupabaseAuthGateway(Supabase.instance.client),
);

final identityRepositoryProvider = Provider<IdentityRepository>(
  (ref) => IdentityRepository(
    db: ref.watch(databaseProvider),
    auth: ref.watch(authGatewayProvider),
    entitlements: ref.watch(entitlementRepositoryProvider),
    purchases: ref.watch(purchaseGatewayProvider),
  ),
);

/// SharedPreferences is resolved once at startup and overridden into the
/// container in main(), so nothing in the UI has to await it.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('overridden in main()'),
);

final linkPromptStateProvider = Provider<LinkPromptState>(
  (ref) => LinkPromptState(ref.watch(sharedPreferencesProvider)),
);

final accountApiProvider = Provider<AccountApi>(
  (ref) => SupabaseAccountApi(Supabase.instance.client),
);

/// Assembles the browse screen's data.
///
/// Pure, so that "a locked pack still lists its campaigns" is a unit test and
/// not a widget test with three fakes behind it.
List<PackView> packViewsFrom({
  required List<Pack> packs,
  required Map<String, List<Campaign>> campaignsByPack,
  required Set<String> unlockedPackIds,
}) => [
  for (final pack in packs)
    PackView(
      pack: pack,
      campaigns: campaignsByPack[pack.id] ?? const [],
      isUnlocked: unlockedPackIds.contains(pack.id),
    ),
];

/// The store. One instance for the process: the SDK is configured once, with
/// the Supabase user id as the app user id (ADR-0017).
final purchaseGatewayProvider = Provider<PurchaseGateway>((ref) {
  const iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');
  const androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
  final key = defaultTargetPlatform == TargetPlatform.iOS ? iosKey : androidKey;
  return RevenueCatGateway(apiKey: key);
});

final entitlementRepositoryProvider = Provider<EntitlementRepository>((ref) {
  return EntitlementRepository(
    db: ref.watch(databaseProvider),
    gateway: ref.watch(purchaseGatewayProvider),
    clock: ref.watch(clockProvider),
  );
});

final packsProvider = FutureProvider<List<Pack>>((ref) async {
  return ref.watch(contentRepositoryProvider).packs();
});

final ownedProductChangesProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(purchaseGatewayProvider).ownedProductChanges;
});

/// Recomputed whenever ownership changes — a purchase, a restore, a pulled row,
/// a refund seen by the SDK.
final unlockedPackIdsProvider = FutureProvider<Set<String>>((ref) async {
  final userId = ref.watch(userIdProvider);
  final packs = await ref.watch(packsProvider.future);

  // Re-runs this provider when the store's view of ownership changes, including
  // changes that started on another device.
  ref.watch(ownedProductChangesProvider);

  return ref
      .watch(entitlementRepositoryProvider)
      .unlockedPackIds(userId: userId, packs: packs);
});

final packViewsProvider = FutureProvider<List<PackView>>((ref) async {
  final packs = await ref.watch(packsProvider.future);
  final unlocked = await ref.watch(unlockedPackIdsProvider.future);
  final content = ref.watch(contentRepositoryProvider);

  final campaignsByPack = <String, List<Campaign>>{};
  for (final pack in packs) {
    campaignsByPack[pack.id] = await content.campaignsFor(pack.id);
  }

  return packViewsFrom(
    packs: packs,
    campaignsByPack: campaignsByPack,
    unlockedPackIds: unlocked,
  );
});

final purchaseControllerProvider = Provider<PurchaseController>((ref) {
  return PurchaseController(
    entitlements: ref.watch(entitlementRepositoryProvider),
    gateway: ref.watch(purchaseGatewayProvider),
    content: ref.watch(contentRepositoryProvider),
    sync: ref.watch(syncRepositoryProvider),
    clock: ref.watch(clockProvider),
  );
});
