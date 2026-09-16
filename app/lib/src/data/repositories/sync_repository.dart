import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../core/clock.dart';
import '../../domain/run.dart';
import '../../domain/sync_status.dart';
import '../local/database.dart';
import '../../sync/sync_scheduler.dart';
import '../remote/progress_api.dart';
import 'outbox.dart';

/// What one flush attempt did. [error] is carried rather than thrown so the
/// scheduler can decide about backoff without wrapping everything in a catch.
class PushResult {
  const PushResult({required this.succeeded, this.pushedRows = 0, this.error});

  final bool succeeded;
  final int pushedRows;
  final Object? error;
}

class PullResult {
  const PullResult({required this.succeeded, this.mergedRows = 0, this.error});

  final bool succeeded;
  final int mergedRows;
  final Object? error;
}

/// One round trip: what the flush did, then what the refresh did.
class SyncOutcome {
  const SyncOutcome({required this.push, required this.pull});

  final PushResult push;
  final PullResult pull;

  bool get succeeded => push.succeeded && pull.succeeded;
  Object? get error => push.error ?? pull.error;
}

/// Sends what this device owes, then replaces its copy with the server's.
///
/// There is no merge here, and that is the point. The server owns the user's
/// record; this device owns a queue of writes and a cache of the answer. What
/// this replaced had to decide, per row, whether the local or remote version won
/// -- and to do that it carried a `dirty` flag cleared only where `updated_at`
/// still matched, a watermark per table, and a delete-and-reinsert dance so two
/// devices could converge on one uuid. None of that has anywhere to live now:
/// a refresh takes the server's rows, and the only rows it leaves alone are the
/// ones still sitting in the outbox.
class SyncRepository implements SyncRunner {
  SyncRepository({required this.db, required this.api, required this.clock})
    : outbox = OutboxQueue(db: db, clock: clock.nowUtc);

  final FeralDatabase db;
  final ProgressApi api;

  /// Carried for the abandonment a revoked entitlement writes, and to stamp
  /// queue entries.
  final Clock clock;

  final OutboxQueue outbox;

  /// Every table the user's record spans, parents first. Used by the refresh;
  /// the flush needs no such list because the queue is already in order.
  static const refreshOrder = [
    'profiles',
    'campaign_runs',
    'day_logs',
    'day_log_actions',
    'diagnostic_results',
  ];

  /// Postgres unique-violation. The partial unique index on
  /// `(user_id) where status = 'active'` raises this, and it is the expected
  /// outcome of two devices starting a run offline -- not an error.
  static const _uniqueViolation = '23505';

  final List<SyncNotice> _notices = [];

  List<SyncNotice> get pendingNotices => List.unmodifiable(_notices);

  /// Returns the queued notices and empties the queue, so a reconciliation is
  /// reported once rather than on every subsequent sync.
  @override
  List<SyncNotice> consumeNotices() {
    final out = List<SyncNotice>.unmodifiable(_notices);
    _notices.clear();
    return out;
  }

  @override
  Future<SyncOutcome> sync(String userId) async {
    // Flush first, always. Refreshing first would replace a row this device has
    // written and not yet sent with the server's older copy, losing a write the
    // user already saw succeed.
    final pushResult = await flush(userId);
    final pullResult = await refresh(userId);
    return SyncOutcome(push: pushResult, pull: pullResult);
  }

  /// Drains the outbox in order, removing each entry the server accepts.
  ///
  /// Stops at the first failure and leaves the rest queued: the next attempt
  /// resends from exactly that point. An entry is removed only when the server
  /// has acknowledged that entry, which is the whole reason this is a queue and
  /// not a flag.
  Future<PushResult> flush(String userId) async {
    var pushed = 0;
    for (final entry in await outbox.pending()) {
      var payload = OutboxQueue.decode(entry);
      try {
        await api.upsert(entry.remoteTable, [payload]);
      } on PostgrestException catch (error) {
        if (entry.remoteTable == 'campaign_runs' &&
            error.code == _uniqueViolation) {
          // The server already has an active run for this user, so ours lost the
          // slot. The entry is rewritten as abandoned rather than dropped: the
          // run and every day log under it still reach the server, because effort
          // is never erased (ADR-0003). Whichever run got there first keeps the
          // slot -- the rule is first to the server, not earliest started, and it
          // needs no agreement between two devices that cannot talk.
          payload = await _abandonQueuedRun(entry, payload, userId);
          try {
            await api.upsert(entry.remoteTable, [payload]);
          } catch (retryError) {
            return PushResult(
              succeeded: false,
              pushedRows: pushed,
              error: retryError,
            );
          }
        } else {
          return PushResult(succeeded: false, pushedRows: pushed, error: error);
        }
      } catch (error) {
        return PushResult(succeeded: false, pushedRows: pushed, error: error);
      }
      await outbox.remove(entry.id);
      pushed++;
    }
    return PushResult(succeeded: true, pushedRows: pushed);
  }

  /// Rewrites a rejected active-run entry as abandoned, locally and in the queue,
  /// and tells the user what happened.
  Future<Map<String, dynamic>> _abandonQueuedRun(
    OutboxRow entry,
    Map<String, dynamic> payload,
    String userId,
  ) async {
    final now = clock.nowUtc();
    final updated = {
      ...payload,
      'status': RunStatus.abandoned.key,
      'updated_at': now.toIso8601String(),
    };

    await outbox.rewrite(entry.id, updated);
    await (db.update(
      db.campaignRuns,
    )..where((r) => r.id.equals(entry.rowKey))).write(
      CampaignRunsCompanion(
        status: Value(RunStatus.abandoned.key),
        updatedAt: Value(now),
      ),
    );

    _notices.add(
      SyncNotice(
        kind: SyncNoticeKind.runReconciled,
        message:
            'A campaign was already running on another device. That one '
            'continues; the one started here has been closed, and every day '
            'reported against it has been kept.',
        occurredAt: now,
      ),
    );
    return updated;
  }

  /// Replaces this device's copy of the user's record with the server's.
  ///
  /// Rows named by a pending outbox entry are left exactly as they are. That is
  /// the whole of the conflict policy: a write the user has seen succeed but the
  /// server has not acknowledged stays visible until it lands.
  ///
  /// Fetched as a complete set, not since a watermark, for the reason the
  /// entitlement reconcile already worked this way: a deleted row carries no
  /// newer `updated_at`, so an incremental fetch can never observe one going.
  Future<PullResult> refresh(String userId) async {
    var merged = 0;
    for (final table in refreshOrder) {
      final List<Map<String, dynamic>> rows;
      try {
        rows = await api.fetchAllFor(table, userId);
      } catch (error) {
        return PullResult(succeeded: false, mergedRows: merged, error: error);
      }

      final pending = await outbox.pendingKeysFor(table);
      final arrived = {for (final row in rows) _keyFor(table, row)};

      await db.transaction(() async {
        // Gone from the server means gone here, unless this device still owes a
        // write for it -- in which case it is not gone, it has not arrived yet.
        await _deleteMissing(table, userId, arrived.union(pending));
        for (final row in rows) {
          if (pending.contains(_keyFor(table, row))) continue;
          await _store(table, row);
          merged++;
        }
      });
    }

    // Entitlements last, and as a complete set. A throw here is "we did not
    // find out", never "they own nothing", so it fails the refresh rather than
    // purging on an unanswered question.
    try {
      merged += (await reconcileEntitlements(userId)).length;
    } catch (error) {
      return PullResult(succeeded: false, mergedRows: merged, error: error);
    }
    return PullResult(succeeded: true, mergedRows: merged);
  }

  /// The key that identifies a remote row, matching what the outbox queues it
  /// under. For `day_logs` and `day_log_actions` that is the natural key, never
  /// the uuid.
  String _keyFor(String table, Map<String, dynamic> row) => switch (table) {
    'profiles' => row['user_id'] as String,
    'campaign_runs' => row['id'] as String,
    'day_logs' => '${row['run_id']}:${row['day_index']}',
    'day_log_actions' =>
      '${row['run_id']}:${row['day_index']}:${row['action_id']}',
    'diagnostic_results' => row['id'] as String,
    _ => throw ArgumentError('unknown table: $table'),
  };

  Future<void> _deleteMissing(
    String table,
    String userId,
    Set<String> keep,
  ) async {
    switch (table) {
      case 'profiles':
        final rows = await (db.select(
          db.profiles,
        )..where((p) => p.userId.equals(userId))).get();
        for (final row in rows) {
          if (keep.contains(row.userId)) continue;
          await (db.delete(
            db.profiles,
          )..where((p) => p.userId.equals(row.userId))).go();
        }
      case 'campaign_runs':
        final rows = await (db.select(
          db.campaignRuns,
        )..where((r) => r.userId.equals(userId))).get();
        for (final row in rows) {
          if (keep.contains(row.id)) continue;
          await (db.delete(
            db.campaignRuns,
          )..where((r) => r.id.equals(row.id))).go();
        }
      case 'day_logs':
        final rows = await (db.select(
          db.dayLogs,
        )..where((l) => l.userId.equals(userId))).get();
        for (final row in rows) {
          if (keep.contains('${row.runId}:${row.dayIndex}')) continue;
          await (db.delete(db.dayLogs)..where((l) => l.id.equals(row.id))).go();
        }
      case 'day_log_actions':
        final rows = await (db.select(
          db.dayLogActions,
        )..where((t) => t.userId.equals(userId))).get();
        for (final row in rows) {
          if (keep.contains('${row.runId}:${row.dayIndex}:${row.actionId}')) {
            continue;
          }
          await (db.delete(
            db.dayLogActions,
          )..where((t) => t.id.equals(row.id))).go();
        }
      case 'diagnostic_results':
        final rows = await (db.select(
          db.diagnosticResults,
        )..where((d) => d.userId.equals(userId))).get();
        for (final row in rows) {
          if (keep.contains(row.id)) continue;
          await (db.delete(
            db.diagnosticResults,
          )..where((d) => d.id.equals(row.id))).go();
        }
    }
  }

  /// Writes a remote row into the cache, adopting the server's uuid.
  ///
  /// No conflict check, and no delete-and-reinsert to converge on an id: the
  /// server's row is simply the answer, and the natural key it is keyed on here
  /// is the same one the outbox uses.
  Future<void> _store(String table, Map<String, dynamic> row) async {
    switch (table) {
      case 'profiles':
        await db
            .into(db.profiles)
            .insertOnConflictUpdate(
              ProfileRow(
                userId: row['user_id'] as String,
                displayName: row['display_name'] as String?,
                onboardedAt: _optional(row['onboarded_at']),
                updatedAt: _remoteUpdatedAt(row),
              ),
            );
      case 'campaign_runs':
        await db
            .into(db.campaignRuns)
            .insertOnConflictUpdate(
              CampaignRunRow(
                id: row['id'] as String,
                userId: row['user_id'] as String,
                campaignId: row['campaign_id'] as String,
                status: row['status'] as String,
                isHardened: (row['is_hardened'] as bool?) ?? false,
                startedAt: DateTime.parse(row['started_at'] as String).toUtc(),
                completedAt: _optional(row['completed_at']),
                grade: row['grade'] as String?,
                updatedAt: _remoteUpdatedAt(row),
              ),
            );
      case 'day_logs':
        // Deleted first, by natural key, because the server's uuid may differ
        // from the one this device minted for the same day.
        await (db.delete(db.dayLogs)..where(
              (l) =>
                  l.runId.equals(row['run_id'] as String) &
                  l.dayIndex.equals(row['day_index'] as int),
            ))
            .go();
        await db
            .into(db.dayLogs)
            .insertOnConflictUpdate(
              DayLogRow(
                id: row['id'] as String,
                userId: row['user_id'] as String,
                runId: row['run_id'] as String,
                dayIndex: row['day_index'] as int,
                actionId: row['action_id'] as String,
                committedAt: _optional(row['committed_at']),
                outcome: row['outcome'] as String?,
                note: row['note'] as String?,
                updatedAt: _remoteUpdatedAt(row),
              ),
            );
      case 'day_log_actions':
        await (db.delete(db.dayLogActions)..where(
              (t) =>
                  t.runId.equals(row['run_id'] as String) &
                  t.dayIndex.equals(row['day_index'] as int) &
                  t.actionId.equals(row['action_id'] as String),
            ))
            .go();
        await db
            .into(db.dayLogActions)
            .insertOnConflictUpdate(
              DayLogActionRow(
                id: row['id'] as String,
                userId: row['user_id'] as String,
                runId: row['run_id'] as String,
                dayIndex: row['day_index'] as int,
                actionId: row['action_id'] as String,
                completed: (row['completed'] as bool?) ?? true,
                updatedAt: _remoteUpdatedAt(row),
              ),
            );
      case 'diagnostic_results':
        await db
            .into(db.diagnosticResults)
            .insertOnConflictUpdate(
              DiagnosticResultRow(
                id: row['id'] as String,
                userId: row['user_id'] as String,
                takenAt: DateTime.parse(row['taken_at'] as String).toUtc(),
                scores: row['scores'] as String,
                weakestArchetypeId: row['weakest_archetype_id'] as String,
                recommendedCampaignId: row['recommended_campaign_id'] as String,
                updatedAt: _remoteUpdatedAt(row),
              ),
            );
    }
  }

  DateTime _remoteUpdatedAt(Map<String, dynamic> row) =>
      DateTime.parse(row['updated_at'] as String).toUtc();

  DateTime? _optional(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toUtc();

  /// Entitlements are pulled as a complete set rather than incrementally.
  ///
  /// A refund deletes the server row, and a deleted row carries no newer
  /// `updated_at` — so an incremental pull can never observe a revocation. This
  /// is affordable here and nowhere else: it is one row per owned pack.
  ///
  /// Throws if the fetch fails, and deliberately purges nothing in that case.
  /// The caller treats a throw as "we did not find out", never as "they own
  /// nothing" (ADR-0025).
  Future<Set<String>> reconcileEntitlements(String userId) async {
    final remote = await api.fetchAllFor('entitlements', userId);
    final confirmed = {for (final row in remote) row['pack_id'] as String};

    await db.transaction(() async {
      for (final row in remote) {
        await db
            .into(db.entitlements)
            .insertOnConflictUpdate(
              EntitlementRow(
                userId: row['user_id'] as String,
                packId: row['pack_id'] as String,
                source: row['source'] as String,
                acquiredAt: DateTime.parse(
                  row['acquired_at'] as String,
                ).toUtc(),
                updatedAt: _remoteUpdatedAt(row),
                local: false,
              ),
            );
      }

      // Server-sourced rows the server has stopped returning. A local grant is
      // an optimistic guess about a purchase the webhook has not confirmed yet,
      // not a claim the server has contradicted, so it is left alone.
      await (db.delete(db.entitlements)..where(
            (e) =>
                e.userId.equals(userId) &
                e.local.equals(false) &
                e.packId.isNotIn(confirmed),
          ))
          .go();
    });

    await _revokeUnentitledContent(userId, confirmed);
    return confirmed;
  }

  /// Takes back the copy for packs this account does not own, and closes any run
  /// standing on one.
  ///
  /// The bodies are deleted here rather than left to the content refresh, and the
  /// difference matters. A refund changes who may read a row without changing any
  /// row, so the content version does not move and a version-gated refresh
  /// decides there is nothing to fetch — the copy would stay readable on the
  /// device until something else forced a full refresh. The refresh is the
  /// backstop; this is the mechanism (ADR-0025, ADR-0034).
  ///
  /// The run is abandoned rather than deleted: `campaign_runs.status` already
  /// models that state, and every day_log under it survives, because effort is
  /// never erased (ADR-0003).
  ///
  /// Called only with a set that actually arrived — a throw upstream means "we
  /// did not find out", and revoking on that would be the worst possible reading
  /// of silence.
  Future<void> _revokeUnentitledContent(
    String userId,
    Set<String> confirmed,
  ) async {
    // A local grant is an optimistic guess about a purchase the webhook has not
    // confirmed yet, not a claim the server has contradicted.
    final locallyGranted = await (db.select(
      db.entitlements,
    )..where((e) => e.userId.equals(userId) & e.local.equals(true))).get();
    final owned = {...confirmed, ...locallyGranted.map((e) => e.packId)};

    // Days first, then the actions hanging off them: both bodies are gated by the
    // same entitlement, so both go back on the same refund.
    final unentitled =
        db.selectOnly(db.days).join([
            innerJoin(
              db.campaigns,
              db.campaigns.id.equalsExp(db.days.campaignId),
            ),
            innerJoin(db.packs, db.packs.id.equalsExp(db.campaigns.packId)),
          ])
          ..addColumns([db.days.id, db.campaigns.id])
          ..where(db.packs.isCore.equals(false) & db.packs.id.isNotIn(owned));
    final rows = await unentitled.get();
    final dayIds = rows.map((r) => r.read(db.days.id)!).toSet().toList();
    final campaignIds = rows.map((r) => r.read(db.campaigns.id)!).toSet();
    if (campaignIds.isEmpty) return;

    final actionIds = dayIds.isEmpty
        ? const <String>[]
        : (await (db.selectOnly(db.actions)
                    ..addColumns([db.actions.id])
                    ..where(db.actions.dayId.isIn(dayIds)))
                  .get())
              .map((r) => r.read(db.actions.id)!)
              .toList();

    await db.transaction(() async {
      if (actionIds.isNotEmpty) {
        await (db.delete(
          db.actionBodies,
        )..where((b) => b.actionId.isIn(actionIds))).go();
      }
      if (dayIds.isNotEmpty) {
        await (db.delete(
          db.dayBodies,
        )..where((b) => b.dayId.isIn(dayIds))).go();
      }
    });

    // Dirty, so the abandonment is pushed. The row and its day logs stay.
    final affected =
        await (db.select(db.campaignRuns)..where(
              (r) =>
                  r.userId.equals(userId) &
                  r.campaignId.isIn(campaignIds) &
                  r.status.equals(RunStatus.active.key),
            ))
            .get();
    if (affected.isEmpty) return;

    await db.transaction(() async {
      for (final run in affected) {
        await (db.update(
          db.campaignRuns,
        )..where((r) => r.id.equals(run.id))).write(
          CampaignRunsCompanion(
            status: Value(RunStatus.abandoned.key),
            updatedAt: Value(clock.nowUtc()),
          ),
        );

        // Queued, so the abandonment reaches the server. Read back rather than
        // reusing `run`, which still holds the pre-update status.
        final updated = await (db.select(
          db.campaignRuns,
        )..where((r) => r.id.equals(run.id))).getSingle();
        await outbox.add(entryForRun(updated));
      }
    });
  }
}
