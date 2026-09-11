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
    ActionBodies,
    DoctrineGroups,
    DoctrineEntries,
    DiagnosticQuestions,
    DiagnosticOptions,
    // user
    Profiles,
    CampaignRuns,
    DayLogs,
    DayLogActions,
    DiagnosticResults,
    Entitlements,
    // sync
    SyncState,
  ],
)
class FeralDatabase extends _$FeralDatabase {
  FeralDatabase(super.executor);

  @override
  int get schemaVersion => 6;

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
      if (from < 5) {
        // The first migration that is not purely additive. The principle above
        // protects campaign_runs and day_logs -- a user's own record, which has
        // no other copy -- and neither is touched here.
        //
        // Bodies are not carried across. Pre-launch there is no install holding
        // content worth preserving, and content is a cache with a server behind
        // it: the next pull refills it, and a development device that is offline
        // at the moment it upgrades can reinstall. Once the app ships this is no
        // longer true, and a migration at that point must copy rather than drop.
        await m.createTable(actionBodies);
        await m.alterTable(TableMigration(actions));
      }
      if (from < 6) {
        // day_logs is read but never altered; the ticks are a new table beside
        // it, so the rule protecting a user's own record still holds.
        await m.createTable(dayLogActions);

        // alterTable, not addColumn: `actions` gains two columns AND a new
        // unique key, and drift bakes uniqueKeys into CREATE TABLE. addColumn
        // cannot touch it, so an upgraded install would keep
        // UNIQUE(campaign_id, day_index) and reject every optional action --
        // the whole point of this version. Recreating the table is the only
        // way to move that constraint, and is what the v5 step already does.
        // Content is a cache with a server behind it, so a recreate is cheap.
        //
        // newColumns is not optional here: without it drift copies every
        // column of the new schema out of the old table, and the old table
        // has no is_optional to read. Both take their declared defaults, so
        // every existing action becomes its day's mandatory action at sort 0.
        await m.alterTable(
          TableMigration(
            actions,
            newColumns: [actions.isOptional, actions.sort],
          ),
        );

        await backfillDayLogActions();
      }
    },
  );

  /// Gives every already-reported day a tick for the action it was assigned.
  ///
  /// Without this, the balance — which reads ticks from here on — sees nothing
  /// for any day recorded before the upgrade, and every existing radar
  /// collapses to zero. Idempotent: the unique key makes a second run a no-op.
  Future<void> backfillDayLogActions() async {
    final logs = await (select(
      dayLogs,
    )..where((l) => l.outcome.isIn(const ['done', 'partial']))).get();

    await batch((b) {
      for (final log in logs) {
        b.insert(
          dayLogActions,
          DayLogActionsCompanion.insert(
            // Deterministic rather than random: two devices that both upgrade
            // offline derive the same id for the same tick, so the first sync
            // converges instead of racing to adopt one of two uuids.
            id: '${log.runId}:${log.dayIndex}:${log.actionId}',
            userId: log.userId,
            runId: log.runId,
            dayIndex: log.dayIndex,
            actionId: log.actionId,
            updatedAt: log.updatedAt,
            // Backfilled rows push like any other local write: the server ran
            // the same backfill, and the upsert converges on one row.
            dirty: const Value(true),
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

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

  /// Drops [table]'s high-water mark, so the next pull asks for everything the
  /// server is willing to give rather than only what changed. Used when the
  /// visible row set moves without any row changing — which is true of exactly
  /// one table, `action_bodies` (ADR-0025).
  Future<void> clearWatermark(String table) =>
      (delete(syncState)..where((s) => s.syncTable.equals(table))).go();
}
