import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/day_log.dart';
import '../../domain/outcome.dart';
import '../../domain/run.dart';
import '../../engine/run_engine.dart';
import '../local/database.dart';

/// The only writer of user state.
///
/// Every method here writes to Drift and returns. Nothing awaits the network —
/// that is what makes the daily loop independent of connectivity. Rows are
/// marked dirty for the push worker, which arrives in Plan 3.
class ProgressRepository {
  // Fields are public (not `_db`/`_clock`/`_zone`/`_engine`) so the constructor
  // can use initializing formals — see ContentRepository for the same
  // reasoning. The constructor signature and every public method are
  // unchanged.
  ProgressRepository({
    required this.db,
    required this.clock,
    required this.zone,
    this.engine = const RunEngine(),
  });

  final FeralDatabase db;
  final Clock clock;
  final tz.Location zone;
  final RunEngine engine;

  // Not derived from the clock: an id is not a timestamp, and DateTime.now()
  // here would violate the rule that the clock is the only source of "now".
  final Uuid _uuid = const Uuid();

  String _newId() => _uuid.v4();

  Future<CampaignRun> startRun({
    required String userId,
    required String campaignId,
  }) async {
    final now = clock.nowUtc();
    final run = CampaignRun(
      id: _newId(),
      userId: userId,
      campaignId: campaignId,
      status: RunStatus.active,
      startedAt: now,
    );

    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: run.id,
            userId: run.userId,
            campaignId: run.campaignId,
            status: run.status.key,
            startedAt: run.startedAt,
            updatedAt: now,
          ),
        );

    return run;
  }

  Future<CampaignRun?> activeRun(String userId) async {
    final row =
        await (db.select(db.campaignRuns)..where(
              (r) =>
                  r.userId.equals(userId) &
                  r.status.equals(RunStatus.active.key),
            ))
            .getSingleOrNull();
    return row == null ? null : _toRun(row);
  }

  /// Abandoning is permanent and preserves every day already logged. It is the
  /// only destructive action in the product, and it deletes nothing.
  Future<void> abandonRun(String runId) async {
    await (db.update(db.campaignRuns)..where((r) => r.id.equals(runId))).write(
      CampaignRunsCompanion(
        status: Value(RunStatus.abandoned.key),
        updatedAt: Value(clock.nowUtc()),
        dirty: const Value(true),
      ),
    );
  }

  Future<List<DayLog>> logsFor(String runId) async {
    final rows =
        await (db.select(db.dayLogs)
              ..where((l) => l.runId.equals(runId))
              ..orderBy([(l) => OrderingTerm(expression: l.dayIndex)]))
            .get();
    return rows.map(_toLog).toList();
  }

  Future<void> commitToday({
    required CampaignRun run,
    required int dayIndex,
    required String actionId,
  }) => _upsertLog(
    run: run,
    dayIndex: dayIndex,
    actionId: actionId,
    committedAt: Value(clock.nowUtc()),
  );

  /// Records a user-reported outcome for a day.
  ///
  /// `outcome` must be `done`, `partial`, or `skipped` — never `missed`.
  /// `missed` is written only by [applyRollover]; this method writes whatever
  /// it is given unchanged, so passing `Outcome.missed` here would be a
  /// call-site bug, not a caught one.
  Future<void> report({
    required CampaignRun run,
    required int dayIndex,
    required String actionId,
    required Outcome outcome,
    String? note,
  }) => _upsertLog(
    run: run,
    dayIndex: dayIndex,
    actionId: actionId,
    outcome: Value(outcome.key),
    note: Value(note),
  );

  /// Writes `missed` for every elapsed day left unreported. Idempotent: safe to
  /// call on every app open, and it never touches a day that has an outcome.
  Future<void> applyRollover({
    required CampaignRun run,
    required int lengthDays,
    required String Function(int dayIndex) actionIdForDay,
  }) async {
    final today = engine.currentDay(
      startedAt: run.startedAt,
      zone: zone,
      now: clock.nowUtc(),
      lengthDays: lengthDays,
    );

    final pending = engine.daysNeedingMissed(
      currentDay: today,
      logs: await logsFor(run.id),
    );

    for (final day in pending) {
      await _upsertLog(
        run: run,
        dayIndex: day,
        actionId: actionIdForDay(day),
        outcome: Value(Outcome.missed.key),
      );
    }
  }

  Future<void> _upsertLog({
    required CampaignRun run,
    required int dayIndex,
    required String actionId,
    Value<DateTime?> committedAt = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) async {
    final now = clock.nowUtc();
    final existing =
        await (db.select(db.dayLogs)..where(
              (l) => l.runId.equals(run.id) & l.dayIndex.equals(dayIndex),
            ))
            .getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              id: _newId(),
              userId: run.userId,
              runId: run.id,
              dayIndex: dayIndex,
              actionId: actionId,
              committedAt: committedAt,
              outcome: outcome,
              note: note,
              updatedAt: now,
              // Explicit, not left to the schema default: the push worker
              // (Plan 3) drains purely on this flag, so a silently changed
              // default must never make a first write invisible to sync.
              dirty: const Value(true),
            ),
          );
      return;
    }

    await (db.update(db.dayLogs)..where((l) => l.id.equals(existing.id))).write(
      DayLogsCompanion(
        committedAt: committedAt,
        outcome: outcome,
        note: note,
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  // Drift's default sqlite storage round-trips a DateTime as a plain,
  // locale-flavored value (see database_test.dart's "round-trip" case and
  // https://drift.simonbinder.eu — the unix-timestamp column mode does not
  // preserve the UTC flag). Re-hydrating into a UTC-location TZDateTime here
  // keeps every timestamp this repository returns interchangeable with the
  // TZDateTime instants produced by Clock/RunEngine, without weakening the
  // domain layer's plain-DateTime contract.
  DateTime _asUtc(DateTime value) => tz.TZDateTime.from(value, tz.UTC);

  CampaignRun _toRun(CampaignRunRow row) => CampaignRun(
    id: row.id,
    userId: row.userId,
    campaignId: row.campaignId,
    status: RunStatus.fromKey(row.status),
    startedAt: _asUtc(row.startedAt),
    isHardened: row.isHardened,
    completedAt: row.completedAt == null ? null : _asUtc(row.completedAt!),
  );

  DayLog _toLog(DayLogRow row) => DayLog(
    id: row.id,
    runId: row.runId,
    dayIndex: row.dayIndex,
    actionId: row.actionId,
    committedAt: row.committedAt == null ? null : _asUtc(row.committedAt!),
    outcome: row.outcome == null ? null : Outcome.fromKey(row.outcome!),
    note: row.note,
  );
}
