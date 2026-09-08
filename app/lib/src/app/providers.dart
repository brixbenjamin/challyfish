import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/clock.dart';
import '../data/local/database.dart';
import '../data/remote/content_api.dart';
import '../data/remote/progress_api.dart';
import '../data/remote/seed_snapshot.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/diagnostic_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/sync_repository.dart';
import '../notifications/reminder_scheduler.dart';
import '../sync/sync_scheduler.dart';

final databaseProvider = Provider<FeralDatabase>((ref) {
  final db = FeralDatabase(driftDatabase(name: 'feral'));
  ref.onDispose(db.close);
  return db;
});

final clockProvider = Provider<Clock>((ref) => const SystemClock());

/// Overridden in main() once the device zone has been read.
final zoneProvider = Provider<tz.Location>((ref) => tz.UTC);

/// Overridden in main() with the id from ensureAnonymousSession().
final userIdProvider = Provider<String>((ref) {
  throw UnimplementedError('userIdProvider must be overridden at bootstrap');
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
