import 'package:drift/drift.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;

import '../../core/clock.dart';
import '../../domain/grade.dart';
import '../../domain/run.dart';
import '../../domain/sync_status.dart';
import '../../engine/run_reconciler.dart';
import '../local/database.dart';
import '../remote/progress_api.dart';

/// What one push attempt did. [error] is carried rather than thrown so the
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

/// One round trip: what the push did, then what the pull did.
class SyncOutcome {
  const SyncOutcome({required this.push, required this.pull});

  final PushResult push;
  final PullResult pull;

  bool get succeeded => push.succeeded && pull.succeeded;
  Object? get error => push.error ?? pull.error;
}

/// One row read for pushing, remembered with the `updated_at` it was read at.
class DirtyRow {
  const DirtyRow({
    required this.key,
    required this.updatedAt,
    required this.payload,
  });

  final String key;
  final DateTime updatedAt;
  final Map<String, dynamic> payload;
}

class SyncRepository {
  // Fields are public, as in ContentRepository, so the constructor can use
  // initializing formals for its named parameters.
  SyncRepository({required this.db, required this.api, required this.clock});

  final FeralDatabase db;
  final ProgressApi api;

  /// Carried for the pull, which stamps when each table was last pulled.
  final Clock clock;

  /// Foreign keys decide this order, not preference. A day log pushed before
  /// its run is rejected by the server and the retry fails identically forever.
  static const pushOrder = [
    'profiles',
    'campaign_runs',
    'day_logs',
    'diagnostic_results',
  ];

  /// Pull order mirrors push order for the same foreign-key reason.
  static const pullOrder = [
    'profiles',
    'campaign_runs',
    'day_logs',
    'diagnostic_results',
  ];

  final List<SyncNotice> _notices = [];

  List<SyncNotice> get pendingNotices => List.unmodifiable(_notices);

  /// Returns the queued notices and empties the queue, so a reconciliation is
  /// reported once rather than on every subsequent sync.
  List<SyncNotice> consumeNotices() {
    final out = List<SyncNotice>.unmodifiable(_notices);
    _notices.clear();
    return out;
  }

  /// Postgres unique-violation. The partial unique index on
  /// `(user_id) where status = 'active'` raises this, and it is the expected
  /// outcome of two devices starting a run offline — not an error.
  static const _uniqueViolation = '23505';

  Future<SyncOutcome> sync(String userId) async {
    // Push first, always. Pulling first would merge a server row over a local
    // change that has not been sent yet, and then send the merged result —
    // quietly replacing the user's own write with an older one.
    final pushResult = await push(userId);
    final pullResult = await pull(userId);
    return SyncOutcome(push: pushResult, pull: pullResult);
  }

  Future<PushResult> push(String userId) async {
    var pushed = 0;
    for (final table in pushOrder) {
      final batch = await _dirtyRows(table, userId);
      if (batch.isEmpty) continue;
      try {
        await api.upsert(table, batch.map((r) => r.payload).toList());
      } on PostgrestException catch (error) {
        if (table == 'campaign_runs' && error.code == _uniqueViolation) {
          await _reconcileActiveRun(userId);
          continue; // resolved, not failed
        }
        return PushResult(succeeded: false, pushedRows: pushed, error: error);
      } catch (error) {
        // Leave every flag as it was. The next attempt sends the same rows.
        return PushResult(succeeded: false, pushedRows: pushed, error: error);
      }
      await _clearDirty(table, batch);
      pushed += batch.length;
    }
    return PushResult(succeeded: true, pushedRows: pushed);
  }

  Future<List<DirtyRow>> _dirtyRows(String table, String userId) async {
    switch (table) {
      case 'profiles':
        final rows = await (db.select(db.profiles)..where(
              (p) => p.dirty.equals(true) & p.userId.equals(userId),
            ))
            .get();
        return [
          for (final r in rows)
            DirtyRow(
              key: r.userId,
              updatedAt: r.updatedAt,
              payload: {
                'user_id': r.userId,
                'display_name': r.displayName,
                'onboarded_at': r.onboardedAt?.toUtc().toIso8601String(),
                'updated_at': r.updatedAt.toUtc().toIso8601String(),
              },
            ),
        ];

      case 'campaign_runs':
        final rows = await (db.select(db.campaignRuns)..where(
              (r) => r.dirty.equals(true) & r.userId.equals(userId),
            ))
            .get();
        return [
          for (final r in rows)
            DirtyRow(
              key: r.id,
              updatedAt: r.updatedAt,
              payload: {
                'id': r.id,
                'user_id': r.userId,
                'campaign_id': r.campaignId,
                'status': r.status,
                'is_hardened': r.isHardened,
                'started_at': r.startedAt.toUtc().toIso8601String(),
                'completed_at': r.completedAt?.toUtc().toIso8601String(),
                'grade': r.grade,
                'updated_at': r.updatedAt.toUtc().toIso8601String(),
              },
            ),
        ];

      case 'day_logs':
        final rows = await (db.select(db.dayLogs)..where(
              (l) => l.dirty.equals(true) & l.userId.equals(userId),
            ))
            .get();
        return [
          for (final r in rows)
            DirtyRow(
              key: r.id,
              updatedAt: r.updatedAt,
              payload: {
                'id': r.id,
                'user_id': r.userId,
                'run_id': r.runId,
                'day_index': r.dayIndex,
                'action_id': r.actionId,
                'committed_at': r.committedAt?.toUtc().toIso8601String(),
                'outcome': r.outcome,
                'note': r.note,
                'updated_at': r.updatedAt.toUtc().toIso8601String(),
              },
            ),
        ];

      case 'diagnostic_results':
        final rows = await (db.select(db.diagnosticResults)..where(
              (d) => d.dirty.equals(true) & d.userId.equals(userId),
            ))
            .get();
        return [
          for (final r in rows)
            DirtyRow(
              key: r.id,
              updatedAt: r.updatedAt,
              payload: {
                'id': r.id,
                'user_id': r.userId,
                'taken_at': r.takenAt.toUtc().toIso8601String(),
                'scores': r.scores,
                'weakest_archetype_id': r.weakestArchetypeId,
                'recommended_campaign_id': r.recommendedCampaignId,
                'updated_at': r.updatedAt.toUtc().toIso8601String(),
              },
            ),
        ];

      default:
        throw ArgumentError('unknown push table: $table');
    }
  }

  /// Clears `dirty` only where `updated_at` still equals what was read.
  ///
  /// A user reporting a day while a push is in flight would otherwise have that
  /// write marked clean without it ever being sent, and the record would differ
  /// between devices with nothing on screen to say so.
  Future<void> _clearDirty(String table, List<DirtyRow> batch) async {
    for (final row in batch) {
      switch (table) {
        case 'profiles':
          await (db.update(db.profiles)..where(
                (p) =>
                    p.userId.equals(row.key) & p.updatedAt.equals(row.updatedAt),
              ))
              .write(const ProfilesCompanion(dirty: Value(false)));
        case 'campaign_runs':
          await (db.update(db.campaignRuns)..where(
                (r) => r.id.equals(row.key) & r.updatedAt.equals(row.updatedAt),
              ))
              .write(const CampaignRunsCompanion(dirty: Value(false)));
        case 'day_logs':
          await (db.update(db.dayLogs)..where(
                (l) => l.id.equals(row.key) & l.updatedAt.equals(row.updatedAt),
              ))
              .write(const DayLogsCompanion(dirty: Value(false)));
        case 'diagnostic_results':
          await (db.update(db.diagnosticResults)..where(
                (d) => d.id.equals(row.key) & d.updatedAt.equals(row.updatedAt),
              ))
              .write(const DiagnosticResultsCompanion(dirty: Value(false)));
      }
    }
  }

  Future<PullResult> pull(String userId) async {
    var merged = 0;
    for (final table in pullOrder) {
      final List<Map<String, dynamic>> rows;
      try {
        rows = await api.fetchSince(table, await db.watermarkFor(table), userId);
      } catch (error) {
        return PullResult(succeeded: false, mergedRows: merged, error: error);
      }
      if (rows.isEmpty) continue;

      for (final row in rows) {
        await _merge(table, row);
        merged++;
      }
      // Only after every row is committed. An interrupted pull is retried,
      // never skipped: the watermark is the newest row written, not the newest
      // row seen.
      await _advanceWatermark(table, rows);
    }
    return PullResult(succeeded: true, mergedRows: merged);
  }

  Future<void> _advanceWatermark(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    var high =
        await db.watermarkFor(table) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    for (final row in rows) {
      final updated = _remoteUpdatedAt(row);
      if (updated.isAfter(high)) high = updated;
    }
    await db.setWatermark(table, high);
  }

  DateTime _remoteUpdatedAt(Map<String, dynamic> row) =>
      DateTime.parse(row['updated_at'] as String).toUtc();

  DateTime? _optional(Object? value) =>
      value == null ? null : DateTime.parse(value as String).toUtc();

  Future<void> _merge(String table, Map<String, dynamic> row) async {
    switch (table) {
      case 'profiles':
        final local = await (db.select(db.profiles)..where(
              (p) => p.userId.equals(row['user_id'] as String),
            ))
            .getSingleOrNull();
        if (!_remoteWins(
          local?.dirty,
          local?.updatedAt,
          _remoteUpdatedAt(row),
        )) {
          return;
        }
        await db
            .into(db.profiles)
            .insertOnConflictUpdate(
              ProfileRow(
                userId: row['user_id'] as String,
                displayName: row['display_name'] as String?,
                onboardedAt: _optional(row['onboarded_at']),
                updatedAt: _remoteUpdatedAt(row),
                dirty: false,
              ),
            );

      case 'campaign_runs':
        final local = await (db.select(db.campaignRuns)..where(
              (r) => r.id.equals(row['id'] as String),
            ))
            .getSingleOrNull();
        if (!_remoteWins(
          local?.dirty,
          local?.updatedAt,
          _remoteUpdatedAt(row),
        )) {
          return;
        }
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
                dirty: false,
              ),
            );

      case 'day_logs':
        // (run_id, day_index) is the identity, NOT id. Two offline devices
        // generate different uuids for the same day; keying on id would insert
        // a second row for that day and violate the local unique index.
        final runId = row['run_id'] as String;
        final dayIndex = row['day_index'] as int;
        final local =
            await (db.select(db.dayLogs)..where(
                  (l) => l.runId.equals(runId) & l.dayIndex.equals(dayIndex),
                ))
                .getSingleOrNull();
        if (!_remoteWins(
          local?.dirty,
          local?.updatedAt,
          _remoteUpdatedAt(row),
        )) {
          return;
        }

        // Adopt the server's id so both devices converge on one row rather
        // than each keeping its own uuid forever.
        if (local != null && local.id != row['id']) {
          await (db.delete(db.dayLogs)..where(
                (l) => l.id.equals(local.id),
              ))
              .go();
        }
        await db
            .into(db.dayLogs)
            .insertOnConflictUpdate(
              DayLogRow(
                id: row['id'] as String,
                userId: row['user_id'] as String,
                runId: runId,
                dayIndex: dayIndex,
                actionId: row['action_id'] as String,
                committedAt: _optional(row['committed_at']),
                outcome: row['outcome'] as String?,
                note: row['note'] as String?,
                updatedAt: _remoteUpdatedAt(row),
                dirty: false,
              ),
            );

      case 'diagnostic_results':
        final local = await (db.select(db.diagnosticResults)..where(
              (d) => d.id.equals(row['id'] as String),
            ))
            .getSingleOrNull();
        // Append-only: a diagnostic that has been taken never changes.
        if (local != null) return;
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
                dirty: false,
              ),
            );
    }
  }

  /// The whole conflict policy, in one place.
  ///
  /// A dirty local row always wins: it is a write the user already saw succeed
  /// and the server has not acknowledged. Otherwise the newer `updated_at`
  /// wins, which is what makes two devices converge.
  bool _remoteWins(
    bool? localDirty,
    DateTime? localUpdatedAt,
    DateTime remoteUpdatedAt,
  ) {
    if (localUpdatedAt == null) return true; // never seen on this device
    if (localDirty == true) return false;
    return remoteUpdatedAt.isAfter(localUpdatedAt);
  }

  /// The server already has an active run for this user and rejected ours.
  /// Fetch theirs, apply the deterministic rule, and abandon the loser locally
  /// so the next push carries the abandonment.
  Future<void> _reconcileActiveRun(String userId) async {
    final remoteRows = await api.fetchSince('campaign_runs', null, userId);
    final remoteActive = remoteRows
        .where((r) => r['status'] == 'active')
        .map(_runFromRemote)
        .toList();
    if (remoteActive.isEmpty) return;

    final localRow =
        await (db.select(db.campaignRuns)..where(
              (r) => r.userId.equals(userId) & r.status.equals('active'),
            ))
            .getSingleOrNull();
    if (localRow == null) return;

    final local = _runFromLocal(localRow);
    final remote = remoteActive.first;
    if (!RunReconciler.isConflict(local: local, remote: remote)) return;

    final result = RunReconciler.resolve(local: local, remote: remote);

    // If the survivor came from the server it is already acknowledged, so it
    // is written clean. If it is ours, it is already in the table with the
    // correct dirty state — leave it alone.
    if (!result.localSurvived) {
      await db
          .into(db.campaignRuns)
          .insertOnConflictUpdate(_rowFor(result.keep, dirty: false));
    }

    // The loser stays dirty so the abandonment reaches the server.
    await (db.update(db.campaignRuns)..where(
          (r) => r.id.equals(result.abandon.id),
        ))
        .write(
          CampaignRunsCompanion(
            status: const Value('abandoned'),
            updatedAt: Value(clock.nowUtc()),
            dirty: const Value(true),
          ),
        );

    _notices.add(
      SyncNotice(
        kind: SyncNoticeKind.runReconciled,
        message: result.localSurvived
            ? 'Another device had also started a campaign. This one was '
                  'earlier, so it is the one that continues.'
            : 'A campaign was already running on another device. It started '
                  'earlier, so it is the one that continues; the one started '
                  'here has been closed.',
        occurredAt: clock.nowUtc(),
      ),
    );
  }

  CampaignRun _runFromRemote(Map<String, dynamic> row) => CampaignRun(
    id: row['id'] as String,
    userId: row['user_id'] as String,
    campaignId: row['campaign_id'] as String,
    status: RunStatus.fromKey(row['status'] as String),
    isHardened: (row['is_hardened'] as bool?) ?? false,
    startedAt: DateTime.parse(row['started_at'] as String).toUtc(),
    completedAt: _optional(row['completed_at']),
    grade: row['grade'] == null ? null : Grade.fromKey(row['grade'] as String),
  );

  CampaignRun _runFromLocal(CampaignRunRow row) => CampaignRun(
    id: row.id,
    userId: row.userId,
    campaignId: row.campaignId,
    status: RunStatus.fromKey(row.status),
    isHardened: row.isHardened,
    startedAt: row.startedAt,
    completedAt: row.completedAt,
    grade: row.grade == null ? null : Grade.fromKey(row.grade!),
  );

  CampaignRunRow _rowFor(CampaignRun run, {required bool dirty}) =>
      CampaignRunRow(
        id: run.id,
        userId: run.userId,
        campaignId: run.campaignId,
        status: run.status.key,
        isHardened: run.isHardened,
        startedAt: run.startedAt,
        completedAt: run.completedAt,
        grade: run.grade?.key,
        updatedAt: clock.nowUtc(),
        dirty: dirty,
      );
}
