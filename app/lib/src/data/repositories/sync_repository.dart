import 'package:drift/drift.dart';

import '../../core/clock.dart';
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

  Future<PushResult> push(String userId) async {
    var pushed = 0;
    for (final table in pushOrder) {
      final batch = await _dirtyRows(table, userId);
      if (batch.isEmpty) continue;
      try {
        await api.upsert(table, batch.map((r) => r.payload).toList());
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
}
