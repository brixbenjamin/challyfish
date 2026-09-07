import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/clock.dart';
import '../data/local/database.dart';
import '../data/remote/content_api.dart';
import '../data/repositories/content_repository.dart';
import '../data/repositories/progress_repository.dart';

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
