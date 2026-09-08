import 'package:drift/drift.dart';

import 'tables/content_tables.dart';
import 'tables/sync_tables.dart';
import 'tables/user_tables.dart';

part 'database.g.dart';

/// The runtime source of truth. Supabase is the durable store behind it, but
/// every read the UI performs comes from here — which is what makes the daily
/// loop independent of the network.
@DriftDatabase(
  tables: [
    // content
    Archetypes,
    Packs,
    Campaigns,
    CampaignArchetypes,
    Actions,
    DoctrineGroups,
    DoctrineEntries,
    DiagnosticQuestions,
    DiagnosticOptions,
    // user
    Profiles,
    CampaignRuns,
    DayLogs,
    DiagnosticResults,
    Entitlements,
    // sync
    SyncState,
  ],
)
class FeralDatabase extends _$FeralDatabase {
  FeralDatabase(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Additive only. campaign_runs and day_logs are never touched:
        // losing a user's honest record to a schema bump is the worst
        // possible bug in this product.
        await m.createTable(campaignArchetypes);
        await m.createTable(doctrineGroups);
        await m.createTable(doctrineEntries);
        await m.createTable(diagnosticQuestions);
        await m.createTable(diagnosticOptions);
        await m.createTable(diagnosticResults);
      }
      if (from < 3) {
        // Strictly additive, for the same reason. diagnostic_results already
        // carries `dirty` — it was created with that column at v2 — so there
        // is no column to add here.
        await m.createTable(profiles);
        await m.createTable(syncState);
      }
      if (from < 4) {
        // Additive, like every migration before it. Nothing existing moves,
        // so an upgrade cannot lose a day log.
        await m.createTable(entitlements);
      }
    },
  );

  /// The newest `updated_at` this device has committed for [table], or null if
  /// it has never pulled that table.
  ///
  /// Normalized to UTC on the way out: drift stores date times as unix seconds
  /// and hands them back in the local zone, while every comparison a caller
  /// makes is against a server timestamp.
  Future<DateTime?> watermarkFor(String table) async {
    final row = await (select(
      syncState,
    )..where((r) => r.syncTable.equals(table))).getSingleOrNull();
    return row?.watermark?.toUtc();
  }

  Future<void> setWatermark(String table, DateTime value) =>
      into(syncState).insertOnConflictUpdate(
        SyncStateRow(syncTable: table, watermark: value, lastPulledAt: value),
      );
}
