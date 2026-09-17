import 'dart:convert';

import 'package:drift/drift.dart';

import 'tables/client_state.dart';
import 'tables/content_tables.dart';
import 'outbox_payloads.dart';
import 'tables/outbox.dart';
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
    Outbox,
    ClientState,
  ],
)
class FeralDatabase extends _$FeralDatabase {
  FeralDatabase(super.executor);

  @override
  int get schemaVersion => 12;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // Before the ladder, not inside it (ADR-0040).
      //
      // The steps below are not independent of the current schema: drift's
      // generated `select` lists every column the Dart table declares, so the
      // moment a later step adds one, every earlier step that reads a user
      // table starts failing on a column the file does not have yet — which is
      // what `_enqueueDirtyRowsBeforeDropping` does in the v10 step.
      //
      // Bringing the three user tables up to the current column set first
      // makes the rest of the ladder safe to run at any `from`. Each add is
      // guarded, so a file that already has the column is left alone.
      await _addColumnIfMissing(m, dayLogs, dayLogs.workedOn);
      await _addColumnIfMissing(m, dayLogs, dayLogs.resolvedOn);
      await _addColumnIfMissing(m, campaignRuns, campaignRuns.abandonedOn);

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
        // Strictly additive, for the same reason.
        await m.createTable(profiles);

        // `sync_state` was created here, and v10 drops it. Raw SQL because the
        // generated schema no longer declares the table at all, and a v2 file
        // still has to pass through this step on its way to v10.
        await customStatement(
          'create table if not exists sync_state ('
          'table_name text not null primary key, '
          'watermark int null, '
          'last_pulled_at int null)',
        );
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

        // No backfill from the dropped `actions.archetype_id` column any more.
        // The v9 step below rebuilds every content table from nothing, so
        // anything carried across here would be deleted before it was ever read.
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
      }
      if (from < 9) {
        // Content stops being a store worth migrating and becomes a cache worth
        // discarding. A refresh now fetches each table whole and replaces it, so
        // there is no watermark to keep consistent and no partially-migrated
        // shape to reason about: drop every content table, recreate it against
        // the current schema, and let the first refresh refill it.
        //
        // This is the same rule every content step since v5 has relied on, stated
        // once instead of per-table -- the content store holds no user data and
        // has a server behind it. campaign_runs, day_logs, day_log_actions,
        // diagnostic_results and profiles are still never touched, because a
        // user's own record has no other copy.
        await m.createTable(clientState);

        for (final table in <TableInfo<Table, dynamic>>[
          diagnosticOptions,
          diagnosticQuestions,
          doctrineEntries,
          doctrineGroups,
          actionBodies,
          actionArchetypes,
          actions,
          dayBodies,
          days,
          campaignArchetypes,
          campaigns,
          packs,
          archetypes,
        ]) {
          await m.deleteTable(table.actualTableName);
          await m.createTable(table);
        }
      }
      if (from < 10) {
        // The record stops being authoritative on this device and becomes a
        // cache of the server's, with a queue of what this device still owes.
        //
        // Nothing here moves a user's own rows. `dirty` is dropped from all five
        // user tables and `sync_state` goes with it, but campaign_runs, day_logs,
        // day_log_actions, diagnostic_results and profiles keep every row they
        // hold -- the rule that has protected them since v2 is not relaxed now.
        await m.createTable(outbox);

        // Anything still flagged dirty at the moment of the upgrade is a write
        // the server has not seen. It has to survive as a queue entry, or the
        // upgrade silently discards the user's last offline day.
        await _enqueueDirtyRowsBeforeDropping();

        for (final table in <TableInfo<Table, dynamic>>[
          campaignRuns,
          dayLogs,
          dayLogActions,
          diagnosticResults,
          profiles,
        ]) {
          // Only where the table is actually there. Every one of these is created
          // by an earlier step, so a genuine file has all five -- but a table that
          // does not exist has no column to drop, and a migration that throws on
          // that is a migration that strands the file it was meant to move.
          if (!await _tableExists(table.actualTableName)) continue;

          // Copies the rows across against the current schema, which no longer
          // declares `dirty` -- so the column is dropped and every row is kept.
          await m.alterTable(TableMigration(table));
        }

        // `if exists` because a database created fresh at v10 never had it, and
        // a retried upgrade must not fail on a table it already dropped.
        await customStatement('drop table if exists sync_state');
      }

      if (from < 11) {
        // ADR-0040. Purely additive, and deliberately so: the three user
        // tables are never dropped or recreated, because a user's own record
        // has no other copy.
        //
        // The three date columns were already added above, before the ladder.
        // They arrive null on every existing row rather than being backfilled
        // from `started_at + day_index - 1`: that arithmetic is the thing
        // ADR-0040 found to be wrong, and inventing a date the user never
        // acted on would put a fiction into the honest record.
        //
        // `action_id` becomes nullable, which sqlite cannot do in place: the
        // table is copied across against the current schema, keeping its rows.
        await m.alterTable(TableMigration(dayLogs));
      }

      if (from < 12) {
        // ADR-0041 drops `days.primary_archetype_id`: the One Drive Per Loop
        // Rule is retired, a day's drives are folded from its actions, and no
        // surface ever read the column.
        //
        // The rows are copied across against the current schema rather than
        // dropped and refilled by the next refresh, which every content step
        // since v5 would have licensed. A column that nothing reads is not
        // worth a cache a user who upgrades offline would find empty -- they
        // would open a campaign with no days in it and nothing to tell them
        // why. `days` also has no local foreign keys pointing at it, so the
        // copy cannot take actions or day bodies with it.
        //
        // Guarded on the table being there, for the reason the v10 step states:
        // a table that does not exist has no column to drop, and a migration
        // that throws on that strands the file it was meant to move.
        if (await _tableExists(days.actualTableName)) {
          await m.alterTable(TableMigration(days));
        }
      }
    },
  );

  /// Adds [column] to [table] unless this file already has it.
  ///
  /// The ladder's steps are not independent: one that creates a table builds it
  /// from the *current* schema, so a file arriving from far enough back can
  /// already carry a column a later step was written to add.
  Future<void> _addColumnIfMissing(
    Migrator m,
    TableInfo<Table, dynamic> table,
    GeneratedColumn<Object> column,
  ) async {
    final existing = await customSelect(
      'select name from pragma_table_info(?1)',
      variables: [Variable<String>(table.actualTableName)],
    ).get();
    final names = existing.map((row) => row.read<String>('name')).toSet();
    if (names.contains(column.name)) return;
    await m.addColumn(table, column);
  }

  /// Whether [table] exists in this file.
  Future<bool> _tableExists(String table) async {
    final rows = await customSelect(
      "select name from sqlite_master where type = 'table' and name = ?1",
      variables: [Variable<String>(table)],
    ).get();
    return rows.isNotEmpty;
  }

  /// Turns whatever is still flagged `dirty` into outbox entries, before the
  /// column is dropped.
  ///
  /// Without this, the v10 upgrade silently discards the user's last offline
  /// writes: the rows survive, but nothing is left to say the server has not seen
  /// them, so they would never be sent.
  ///
  /// The ids are read with raw SQL because the generated schema no longer
  /// declares `dirty`. The rows themselves are read normally, so the payloads
  /// come from the same builders the write path uses. Inserted straight into
  /// `outbox` rather than through OutboxQueue: this file cannot import the
  /// repository layer, because the repository layer imports the schema this file
  /// generates, and drift answers that cycle by generating nothing.
  Future<void> _enqueueDirtyRowsBeforeDropping() async {
    final now = DateTime.now().toUtc();
    var order = 0;

    Future<void> queue(
      String table,
      String key,
      Map<String, dynamic> payload,
    ) async {
      await into(outbox).insert(
        OutboxCompanion.insert(
          remoteTable: table,
          rowKey: key,
          payload: jsonEncode(payload),
          queuedAt: now.add(Duration(microseconds: order++)),
        ),
        // A retried upgrade must not fail on entries it already wrote.
        mode: InsertMode.insertOrIgnore,
      );
    }

    // Returns nothing when the table has no `dirty` column, which covers two
    // cases. A table created by an earlier step of this same upgrade was created
    // from the current schema, which no longer declares it; and a table this
    // file's version never had does not exist at all, so `pragma table_info`
    // comes back empty. `day_log_actions` on a v5 file is
    // exactly that case: its rows come from backfillDayLogActions, and the server
    // ran the same backfill, so the upsert would converge on a row it already has.
    Future<Set<String>> dirtyIds(String table, String idColumn) async {
      final columns = await customSelect('pragma table_info($table)').get();
      final hasDirty = columns.any(
        (column) => column.read<String>('name') == 'dirty',
      );
      if (!hasDirty) return const {};

      final rows = await customSelect(
        'select $idColumn as id from $table where dirty = 1',
      ).get();
      return rows.map((r) => r.read<String>('id')).toSet();
    }

    final dirtyProfiles = await dirtyIds('profiles', 'user_id');
    if (dirtyProfiles.isNotEmpty) {
      for (final row in await select(profiles).get()) {
        if (!dirtyProfiles.contains(row.userId)) continue;
        await queue(
          OutboxPayloads.profiles,
          row.userId,
          OutboxPayloads.profile(
            userId: row.userId,
            displayName: row.displayName,
            onboardedAt: row.onboardedAt,
            updatedAt: row.updatedAt,
          ),
        );
      }
    }

    // Runs, then day logs, then ticks. The queue's order is its ids, and the
    // server's foreign keys care about it.
    final dirtyRuns = await dirtyIds('campaign_runs', 'id');
    if (dirtyRuns.isNotEmpty) {
      for (final row in await select(campaignRuns).get()) {
        if (!dirtyRuns.contains(row.id)) continue;
        await queue(
          OutboxPayloads.campaignRuns,
          row.id,
          OutboxPayloads.run(
            id: row.id,
            userId: row.userId,
            campaignId: row.campaignId,
            status: row.status,
            isHardened: row.isHardened,
            startedAt: row.startedAt,
            completedAt: row.completedAt,
            grade: row.grade,
            updatedAt: row.updatedAt,
          ),
        );
      }
    }

    final dirtyLogs = await dirtyIds('day_logs', 'id');
    if (dirtyLogs.isNotEmpty) {
      for (final row in await select(dayLogs).get()) {
        if (!dirtyLogs.contains(row.id)) continue;
        await queue(
          OutboxPayloads.dayLogs,
          OutboxPayloads.keyForDayLog(row.runId, row.dayIndex),
          OutboxPayloads.dayLog(
            id: row.id,
            userId: row.userId,
            runId: row.runId,
            dayIndex: row.dayIndex,
            actionId: row.actionId,
            committedAt: row.committedAt,
            outcome: row.outcome,
            note: row.note,
            workedOn: row.workedOn,
            resolvedOn: row.resolvedOn,
            updatedAt: row.updatedAt,
          ),
        );
      }
    }

    final dirtyTicks = await dirtyIds('day_log_actions', 'id');
    if (dirtyTicks.isNotEmpty) {
      for (final row in await select(dayLogActions).get()) {
        if (!dirtyTicks.contains(row.id)) continue;
        await queue(
          OutboxPayloads.dayLogActions,
          OutboxPayloads.keyForTick(row.runId, row.dayIndex, row.actionId),
          OutboxPayloads.tick(
            userId: row.userId,
            runId: row.runId,
            dayIndex: row.dayIndex,
            actionId: row.actionId,
            completed: row.completed,
            updatedAt: row.updatedAt,
          ),
        );
      }
    }

    final dirtyDiagnostics = await dirtyIds('diagnostic_results', 'id');
    if (dirtyDiagnostics.isNotEmpty) {
      for (final row in await select(diagnosticResults).get()) {
        if (!dirtyDiagnostics.contains(row.id)) continue;
        await queue(
          OutboxPayloads.diagnosticResults,
          row.id,
          OutboxPayloads.diagnostic(
            id: row.id,
            userId: row.userId,
            takenAt: row.takenAt,
            scores: row.scores,
            weakestArchetypeId: row.weakestArchetypeId,
            recommendedCampaignId: row.recommendedCampaignId,
            updatedAt: row.updatedAt,
          ),
        );
      }
    }
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
        // A day whose content was never cached has no action to have ticked
        // (ADR-0040 made the column nullable). There is nothing to backfill.
        final actionId = log.actionId;
        if (actionId == null) continue;

        b.insert(
          dayLogActions,
          DayLogActionsCompanion.insert(
            // Deterministic rather than random: two devices that both upgrade
            // offline derive the same id for the same tick, so the first sync
            // converges instead of racing to adopt one of two uuids.
            id: '${log.runId}:${log.dayIndex}:$actionId',
            userId: log.userId,
            runId: log.runId,
            dayIndex: log.dayIndex,
            actionId: actionId,
            updatedAt: log.updatedAt,
            // Deliberately not queued for the server. This table is created from
            // the current schema during the upgrade, so it carries no `dirty`
            // column for the v10 step to drain -- and it does not need one: the
            // server ran the same backfill from the same day logs, so there is
            // nothing here it does not already have.
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }
}
