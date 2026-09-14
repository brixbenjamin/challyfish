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
    Days,
    DayBodies,
    Actions,
    ActionArchetypes,
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
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Read before anything moves. `TableMigration` recreates a table against
      // the *current* generated schema, which no longer declares
      // actions.archetype_id — so the v6 step drops that column on its way
      // past, and a v5-to-v7 jump would find nothing left to back up if this
      // waited until the `from < 7` block below.
      final legacyArchetypes = from < 7
          ? await _legacyActionArchetypes()
          : const <QueryRow>[];

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
      }
      if (from < 6) {
        // day_logs is read but never altered; the ticks are a new table beside
        // it, so the rule protecting a user's own record still holds.
        await m.createTable(dayLogActions);

        // `actions` is deliberately not recreated here any more. It used to
        // be, to move the unique key off (campaign_id, day_index) -- but
        // TableMigration copies the *current* schema's columns out of the old
        // table, and since v8 that schema demands a day_id no pre-v8 table can
        // supply. The v8 block below reaches every upgrade that would have run
        // this one and rebuilds the table outright, so recreating it here is
        // both redundant and, from a v5 or v6 file, fatal.
        await backfillDayLogActions();
      }
      if (from < 7) {
        // An action's archetype moves out of a column and into a join table, so
        // one action can serve two drives with its effort divided between them.
        // Content-only, like v5 and v6: campaign_runs, day_logs and
        // day_log_actions are not touched, so a user's own record is safe.
        //
        await m.createTable(actionArchetypes);
        await backfillActionArchetypes(legacyArchetypes);

        // The archetype_id column is not dropped by a recreate here, for the
        // reason given in the v6 step: the v8 block rebuilds `actions` from
        // nothing, which drops the column along with every other trace of the
        // old shape.
      }
      if (from < 8) {
        // The day becomes a row that owns its actions (ADR-0034). Content-only,
        // like v5, v6 and v7: campaign_runs, day_logs and day_log_actions are
        // not touched, so a user's own record is safe.
        await m.createTable(days);
        await m.createTable(dayBodies);

        // Not alterTable, which is what every previous content step used.
        // TableMigration copies the new schema's columns out of the old table,
        // and `actions` gains a NOT NULL day_id the old table cannot supply:
        // day ids live on the server and cannot be derived from a campaign id
        // and an index. The rows are therefore dropped, which is legitimate
        // for exactly one reason -- the content store is a pure read-only
        // cache with a server behind it and no user data in it.
        //
        // action_archetypes and action_bodies go with them: both key on
        // action_id, so every row left behind would be an orphan.
        // Explicitly typed: the inferred least upper bound of the three
        // generated table classes is `Table`, which carries neither
        // `actualTableName` nor the type `createTable` expects.
        for (final table in <TableInfo<Table, dynamic>>[
          actions,
          actionArchetypes,
          actionBodies,
        ]) {
          await m.deleteTable(table.actualTableName);
          await m.createTable(table);
        }

        // The half that is easy to forget and fatal to miss. The dropped rows
        // were older than this device's marks, so an incremental pull would ask
        // for nothing and the app would sit on an empty library until it was
        // reinstalled. Cleared for the three rebuilt tables only: packs,
        // campaigns, the doctrine and the diagnostic did not move, and
        // re-downloading them would be a pointless round trip. `days` and
        // `day_bodies` are new and have no mark at all, so their first pull is
        // a full one by construction.
        for (final table in const [
          'actions',
          'action_archetypes',
          'action_bodies',
        ]) {
          await clearWatermark(table);
        }
      }
    },
  );

  /// The (action, archetype) pairs the outgoing `actions.archetype_id` column
  /// holds, read as raw rows because the generated schema no longer describes
  /// that column.
  ///
  /// Empty when the column is already gone — which is not a failure but the
  /// ordinary shape of a multi-version upgrade, and of a retried one.
  Future<List<QueryRow>> _legacyActionArchetypes() async {
    final columns = await customSelect('pragma table_info(actions)').get();
    final hasColumn = columns.any(
      (column) => column.read<String>('name') == 'archetype_id',
    );
    if (!hasColumn) return const [];

    return customSelect(
      'select id, archetype_id, updated_at from actions',
    ).get();
  }

  /// Gives every cached action the single archetype its dropped column named.
  ///
  /// Share 1 on a single row normalises to weight 1.0, which is arithmetically
  /// what the column meant, so an upgraded install draws the same radar it drew
  /// before. Any real split arrives with the next content pull: the new table
  /// has no watermark, so its first pull asks for everything.
  Future<void> backfillActionArchetypes(List<QueryRow> legacy) async {
    if (legacy.isEmpty) return;

    await batch((b) {
      for (final row in legacy) {
        b.insert(
          actionArchetypes,
          ActionArchetypesCompanion.insert(
            actionId: row.read<String>('id'),
            archetypeId: row.read<String>('archetype_id'),
            updatedAt: row.read<DateTime>('updated_at'),
          ),
          // Idempotent, like the v6 backfill beside it: a retried upgrade must
          // not fail on rows it already wrote.
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

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
  /// visible row set moves without any row changing — `action_bodies` and
  /// `day_bodies`, whose visibility is per user (ADR-0025) — and by the v8
  /// upgrade, whose cached rows are dropped outright.
  Future<void> clearWatermark(String table) =>
      (delete(syncState)..where((s) => s.syncTable.equals(table))).go();
}
