import 'package:drift/drift.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/campaign.dart';
import '../../domain/day_log.dart';
import '../../domain/grade.dart';
import '../../domain/outcome.dart';
import '../../domain/run.dart';
import '../../engine/run_engine.dart';
import '../local/database.dart';

/// Thrown when a run is started on a campaign in a pack the user does not own.
///
/// The UI hides the button, and this is the second gate. Row-level security is
/// not a third one and never will be: teasers are public by design (ADR-0008),
/// so from the server's side reading a locked campaign and starting it look the
/// same.
class PackLocked implements Exception {
  const PackLocked(this.campaignId);

  final String campaignId;

  @override
  String toString() => 'PackLocked($campaignId)';
}

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

    /// Required, and deliberately without a default. A default would let every
    /// existing call site keep compiling and keep permitting; required makes
    /// the compiler name every place that has to consult entitlements.
    required bool isUnlocked,
  }) async {
    if (!isUnlocked) throw PackLocked(campaignId);

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

  /// Every run the user has, in any status. The balance and the marks both
  /// span the user's whole history, not just the active run.
  Future<List<CampaignRun>> allRuns(String userId) async {
    final rows =
        await (db.select(db.campaignRuns)
              ..where((r) => r.userId.equals(userId))
              ..orderBy([(r) => OrderingTerm(expression: r.startedAt)]))
            .get();
    return rows.map(_toRun).toList();
  }

  Future<List<DayLog>> allDayLogs(String userId) async {
    final rows =
        await (db.select(db.dayLogs)
              ..where((l) => l.userId.equals(userId))
              ..orderBy([(l) => OrderingTerm(expression: l.dayIndex)]))
            .get();
    return _withTicks(rows);
  }

  Future<List<DayLog>> logsFor(String runId) async {
    final rows =
        await (db.select(db.dayLogs)
              ..where((l) => l.runId.equals(runId))
              ..orderBy([(l) => OrderingTerm(expression: l.dayIndex)]))
            .get();
    return _withTicks(rows);
  }

  /// One query for every tick of the given days, rather than one per day.
  Future<List<DayLog>> _withTicks(List<DayLogRow> rows) async {
    if (rows.isEmpty) return const [];

    final runIds = {for (final r in rows) r.runId};
    final ticks = await (db.select(
      db.dayLogActions,
    )..where((t) => t.runId.isIn(runIds) & t.completed.equals(true))).get();

    final byDay = <String, Set<String>>{};
    for (final tick in ticks) {
      byDay
          .putIfAbsent('${tick.runId}:${tick.dayIndex}', () => <String>{})
          .add(tick.actionId);
    }

    return [
      for (final row in rows)
        _toLog(row, byDay['${row.runId}:${row.dayIndex}'] ?? const <String>{}),
    ];
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

  /// Records that the user did, or did not, do one of a day's actions.
  ///
  /// Creates the day row if it is not there yet: ticking may precede
  /// committing, and the day row is the tick's parent on the server, so it has
  /// to exist before the tick can be pushed.
  ///
  /// Unticking flips `completed` rather than deleting the row. A delete would
  /// never propagate — nothing in this sync design carries tombstones, so the
  /// next pull would resurrect the tick on the other device.
  Future<void> setActionCompleted({
    required CampaignRun run,
    required int dayIndex,

    /// Carried separately from [actionId] because the day row must keep
    /// recording the day's *mandatory* action. An optional tick must not
    /// rewrite what the day was assigned.
    required String mandatoryActionId,
    required String actionId,
    required bool completed,
  }) async {
    final now = clock.nowUtc();

    await _upsertLog(run: run, dayIndex: dayIndex, actionId: mandatoryActionId);

    final existing =
        await (db.select(db.dayLogActions)..where(
              (t) =>
                  t.runId.equals(run.id) &
                  t.dayIndex.equals(dayIndex) &
                  t.actionId.equals(actionId),
            ))
            .getSingleOrNull();

    if (existing == null) {
      await db
          .into(db.dayLogActions)
          .insert(
            DayLogActionsCompanion.insert(
              id: _newId(),
              userId: run.userId,
              runId: run.id,
              dayIndex: dayIndex,
              actionId: actionId,
              completed: Value(completed),
              updatedAt: now,
              // Explicit for the same reason the day log's flag is: the push
              // worker drains purely on it, and a silently changed default
              // must never make a first write invisible to sync.
              dirty: const Value(true),
            ),
          );
      return;
    }

    await (db.update(
      db.dayLogActions,
    )..where((t) => t.id.equals(existing.id))).write(
      DayLogActionsCompanion(
        completed: Value(completed),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );
  }

  /// Records the outcome derived from the day's ticks.
  ///
  /// `outcome` must be `done`, `partial`, or `skipped` — never `missed`.
  /// `missed` is written only by [applyRollover]; this method writes whatever
  /// it is given unchanged, so passing `Outcome.missed` here would be a
  /// call-site bug, not a caught one.
  ///
  /// Takes the day's mandatory action rather than an arbitrary one: the
  /// outcome is derived by the engine before it gets here, and the day row
  /// still records what it was assigned.
  Future<void> report({
    required CampaignRun run,
    required int dayIndex,
    required String mandatoryActionId,
    required Outcome outcome,
    String? note,
  }) => _upsertLog(
    run: run,
    dayIndex: dayIndex,
    actionId: mandatoryActionId,
    outcome: Value(outcome.key),
    note: Value(note),
  );

  /// Resolves every elapsed day left unreported. Idempotent: safe to call on
  /// every app open, and it never touches a day that has an outcome.
  ///
  /// A day with no ticks gets `missed`. A day the user demonstrably acted on
  /// resolves to what those ticks derive instead — writing `missed` over it
  /// would be a dishonest record, which ADR-0003 forbids.
  Future<void> applyRollover({
    required CampaignRun run,
    required int lengthDays,
    required String Function(int dayIndex) mandatoryActionIdForDay,
  }) async {
    final today = engine.currentDay(
      startedAt: run.startedAt,
      zone: zone,
      now: clock.nowUtc(),
      lengthDays: lengthDays,
    );

    final logs = await logsFor(run.id);
    final pending = engine.daysNeedingMissed(currentDay: today, logs: logs);
    final ticksByDay = {
      for (final log in logs) log.dayIndex: log.completedActionIds,
    };

    for (final day in pending) {
      final mandatory = mandatoryActionIdForDay(day);
      final ticks = ticksByDay[day] ?? const <String>{};

      final outcome = ticks.isEmpty
          ? Outcome.missed
          : engine.deriveOutcome(
              mandatoryActionId: mandatory,
              completedActionIds: ticks,
            );

      await _upsertLog(
        run: run,
        dayIndex: day,
        actionId: mandatory,
        outcome: Value(outcome.key),
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

  /// Completes the run if its final day has both elapsed and been resolved.
  ///
  /// Returns the grade if it completed, or null if there was nothing to do.
  /// Idempotent: a run that is already completed is never regraded.
  ///
  /// The grade is materialized here, once, so a finished run's result is stable
  /// and queryable — but RunEngine remains the definition, and this value must
  /// always equal what it computes.
  Future<Grade?> completeRunIfFinished({
    required CampaignRun run,
    required Campaign campaign,
  }) async {
    if (run.status != RunStatus.active) return null;

    // Re-read rather than trusting the caller's copy: a run completed on an
    // earlier call is still `active` in whatever CampaignRun the caller is
    // holding, and regrading it would break the once-only guarantee.
    final stored = await runById(run.id);
    if (stored == null || stored.status != RunStatus.active) return null;

    final current = engine.currentDay(
      startedAt: stored.startedAt,
      zone: zone,
      now: clock.nowUtc(),
      lengthDays: campaign.lengthDays,
    );
    if (current < campaign.lengthDays) return null;

    final logs = await logsFor(stored.id);

    // Elapsing is not enough: the user still has the final day until it is
    // reported, or until rollover resolves it.
    final finalDay = logs.where((l) => l.dayIndex == campaign.lengthDays);
    if (finalDay.isEmpty || !finalDay.first.isReported) return null;

    final grade = engine.grade(logs, lengthDays: campaign.lengthDays);
    final now = clock.nowUtc();

    await (db.update(
      db.campaignRuns,
    )..where((r) => r.id.equals(stored.id))).write(
      CampaignRunsCompanion(
        status: Value(RunStatus.completed.key),
        completedAt: Value(now),
        grade: Value(grade.key),
        updatedAt: Value(now),
        dirty: const Value(true),
      ),
    );

    return grade;
  }

  Future<CampaignRun?> runById(String id) async {
    final row = await (db.select(
      db.campaignRuns,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toRun(row);
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
    grade: row.grade == null ? null : Grade.fromKey(row.grade!),
  );

  DayLog _toLog(DayLogRow row, Set<String> completedActionIds) => DayLog(
    id: row.id,
    runId: row.runId,
    dayIndex: row.dayIndex,
    actionId: row.actionId,
    committedAt: row.committedAt == null ? null : _asUtc(row.committedAt!),
    outcome: row.outcome == null ? null : Outcome.fromKey(row.outcome!),
    note: row.note,
    completedActionIds: completedActionIds,
  );
}
