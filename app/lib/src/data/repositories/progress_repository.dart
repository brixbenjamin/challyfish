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
import 'outbox.dart';

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
/// that is what makes the daily loop independent of connectivity.
///
/// Each write does two things in one transaction: it updates this device's cache
/// of the record, and it queues what it just wrote for the server. Both or
/// neither. A cache updated without a queue entry is a day the user reported that
/// never leaves the phone; a queue entry without the cache is a day they cannot
/// see. The transaction is also what the read-then-write in [_upsertLog] and
/// [setActionCompleted] always needed and never had.
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

  late final OutboxQueue _outbox = OutboxQueue(db: db, clock: clock.nowUtc);

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

    await db.transaction(() async {
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
      await _queueRun(run.id);
    });

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
    await db.transaction(() async {
      await (db.update(
        db.campaignRuns,
      )..where((r) => r.id.equals(runId))).write(
        CampaignRunsCompanion(
          status: Value(RunStatus.abandoned.key),
          updatedAt: Value(clock.nowUtc()),
        ),
      );
      await _queueRun(runId);
    });
  }

  /// The key this device remembers the last acknowledged abandonment under.
  ///
  /// Device-local rather than a column on the run, because it records what this
  /// device has *shown*, not something about the run. `client_state` was given
  /// a key/value shape for exactly this (see its table doc), and it is cleared
  /// when the account changes, so a new user never inherits the flag.
  static const _abandonmentSeenKey = 'abandonment_seen_run';

  /// A run that ended for absence and has not yet been shown to the user.
  ///
  /// `activeRun` filters on status, so without this an auto-abandoned run just
  /// disappears and the user is dropped back to the shelf with no explanation.
  /// A run the user abandoned themselves is never returned: they chose it, they
  /// saw the warning, and repeating it is nagging (ADR-0040).
  Future<CampaignRun?> unacknowledgedAbandonment(String userId) async {
    final row =
        await (db.select(db.campaignRuns)
              ..where(
                (r) =>
                    r.userId.equals(userId) &
                    r.status.equals(RunStatus.abandoned.key) &
                    r.abandonedOn.isNotNull(),
              )
              ..orderBy([
                (r) => OrderingTerm(
                  expression: r.abandonedOn,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;

    final seen = await (db.select(
      db.clientState,
    )..where((s) => s.key.equals(_abandonmentSeenKey))).getSingleOrNull();
    if (seen?.value == row.id) return null;

    return _toRun(row);
  }

  /// Records that the user has seen the notice. It never returns.
  Future<void> acknowledgeAbandonment(String runId) => db
      .into(db.clientState)
      .insertOnConflictUpdate(
        ClientStateCompanion.insert(
          key: _abandonmentSeenKey,
          value: Value(runId),
        ),
      );

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
    actionId: Value(actionId),
    committedAt: Value(clock.nowUtc()),
  );

  /// Records that the user did, or did not, do one of a day's actions.
  ///
  /// Creates the day row if it is not there yet: this method does not assume
  /// the commit gate above it holds, and the day row is the tick's parent on
  /// the server, so it has to exist before the tick can be pushed.
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

    await db.transaction(() async {
      // The day log first, and inside the same transaction: the server's foreign
      // keys require the parent, and the queue sends in the order it was written.
      await _upsertLog(
        run: run,
        dayIndex: dayIndex,
        actionId: Value(mandatoryActionId),
      );

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
              ),
            );
      } else {
        await (db.update(
          db.dayLogActions,
        )..where((t) => t.id.equals(existing.id))).write(
          DayLogActionsCompanion(
            completed: Value(completed),
            updatedAt: Value(now),
          ),
        );
      }

      await _queueTick(run.id, dayIndex, actionId);
    });
  }

  /// Records the outcome derived from the day's ticks, and stamps the local
  /// date it was resolved on (ADR-0040).
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
    actionId: Value(mandatoryActionId),
    outcome: Value(outcome.key),
    note: Value(note),
  );

  /// Closes out everything the calendar has decided since the last app open.
  ///
  /// Two jobs, in order (ADR-0040):
  ///
  /// 1. **Resolve a day the user worked on but never reported.** It takes the
  ///    outcome its ticks derive, stamped with the date it was *worked on* —
  ///    never today. A day ticked on Monday and resolved by Wednesday's app
  ///    open is still Monday's day, and dating it Wednesday would charge the
  ///    user an absence for a day they showed up for.
  /// 2. **End a run left untouched for three consecutive days**, dated to the
  ///    third. Computed rather than scheduled, so a user away for a week gets
  ///    the same answer on return that they would have got each morning.
  ///
  /// A day nobody touched is deliberately left with no row at all. That is an
  /// absence — a gap between the dates the user was present — and it is what
  /// replaced the `missed` outcome this method used to write.
  ///
  /// Idempotent: safe to call on every app open.
  Future<void> applyRollover({
    required CampaignRun run,
    required int lengthDays,

    /// Null when the day's content has not been cached. Since ADR-0040 that no
    /// longer stops the day being resolved — the column is nullable, and a day
    /// rollover has to skip is a day that silently becomes an absence.
    required String? Function(int dayIndex) mandatoryActionIdForDay,
  }) async {
    if (run.status != RunStatus.active) return;

    final today = _today;
    var logs = await logsFor(run.id);

    final due = engine.daysNeedingResolution(logs: logs, today: today);
    final logsByDay = {for (final log in logs) log.dayIndex: log};

    for (final day in due) {
      final log = logsByDay[day]!;
      final mandatory = mandatoryActionIdForDay(day) ?? log.actionId;

      // With no mandatory action to compare against, no tick can be the one
      // that counted — which is exactly what `skipped` means. The day is
      // resolved rather than left to rot into an absence the user did not earn.
      final outcome = mandatory == null
          ? Outcome.skipped
          : engine.deriveOutcome(
              mandatoryActionId: mandatory,
              completedActionIds: log.completedActionIds,
            );

      await _upsertLog(
        run: run,
        dayIndex: day,
        actionId: Value(mandatory),
        outcome: Value(outcome.key),
        resolvedOn: Value(log.workedOn),
        // The app is closing the day, not the user attending it. The presence
        // date was earned when they ticked, and is already stamped.
        marksPresence: false,
      );
    }

    if (due.isNotEmpty) logs = await logsFor(run.id);

    // A run whose content is finished cannot be abandoned. It is waiting to be
    // completed and graded, which the caller does next.
    if (engine.isComplete(logs: logs, lengthDays: lengthDays)) return;

    final absence = engine.absence(
      startedOn: engine.localDateOf(instant: run.startedAt, zone: zone),
      today: today,
      logs: logs,
    );
    final abandonedOn = absence.abandonedOn;
    if (abandonedOn != null) await _abandonForAbsence(run, abandonedOn);
  }

  /// Ends a run the user stopped turning up for.
  ///
  /// Distinct from [abandonRun], which the user asks for: this one carries the
  /// date, which is what tells the two apart afterwards and what the screen on
  /// the next app open reads. No grade is written — an abandoned run has no
  /// result, and the server's `grade_only_when_completed` check agrees.
  Future<void> _abandonForAbsence(CampaignRun run, DateTime abandonedOn) async {
    await db.transaction(() async {
      await (db.update(
        db.campaignRuns,
      )..where((r) => r.id.equals(run.id))).write(
        CampaignRunsCompanion(
          status: Value(RunStatus.abandoned.key),
          abandonedOn: Value(abandonedOn),
          updatedAt: Value(clock.nowUtc()),
        ),
      );
      await _queueRun(run.id);
    });
  }

  /// Today's local calendar date, as the day log records it (ADR-0040).
  DateTime get _today =>
      engine.localDateOf(instant: clock.nowUtc(), zone: zone);

  Future<void> _upsertLog({
    required CampaignRun run,
    required int dayIndex,
    Value<String?> actionId = const Value.absent(),
    Value<DateTime?> committedAt = const Value.absent(),
    Value<String?> outcome = const Value.absent(),
    Value<String?> note = const Value.absent(),

    /// The date to record the day as resolved on. Rollover passes the day's
    /// own `workedOn`; the ordinary report path leaves it absent and takes
    /// today.
    Value<DateTime?> resolvedOn = const Value.absent(),

    /// False only for rollover, which is the app acting rather than the user.
    /// A rollover must never stamp a presence date the user did not earn.
    bool marksPresence = true,
  }) async {
    final now = clock.nowUtc();
    final today = _today;
    final existing =
        await (db.select(db.dayLogs)..where(
              (l) => l.runId.equals(run.id) & l.dayIndex.equals(dayIndex),
            ))
            .getSingleOrNull();

    // Resolving without being told when means resolving now.
    final resolved =
        outcome.present && outcome.value != null && !resolvedOn.present
        ? Value(today)
        : resolvedOn;

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
              workedOn: marksPresence ? Value(today) : const Value.absent(),
              resolvedOn: resolved,
              updatedAt: now,
            ),
          );
    } else {
      await (db.update(
        db.dayLogs,
      )..where((l) => l.id.equals(existing.id))).write(
        DayLogsCompanion(
          // An optional tick must not rewrite the day's mandatory action, so
          // this is only ever set when it is actually supplied.
          actionId: actionId,
          committedAt: committedAt,
          outcome: outcome,
          note: note,
          // Never moved once set: the day belongs to the date the user first
          // touched it, not to the date they got round to reporting it.
          workedOn: marksPresence && existing.workedOn == null
              ? Value(today)
              : const Value.absent(),
          resolvedOn: resolved,
          updatedAt: Value(now),
        ),
      );
    }

    await _queueDayLog(run.id, dayIndex);
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

    final logs = await logsFor(stored.id);

    // Completion follows the content, not the clock (ADR-0040): a run ends
    // when its last day is reported, however many calendar days that took.
    // The old rule also required the calendar to have reached `lengthDays`,
    // which after the pointer split would have completed a user out of a
    // campaign they still had days of content left in.
    if (!engine.isComplete(logs: logs, lengthDays: campaign.lengthDays)) {
      return null;
    }

    // Absence is counted only up to the day the last day was resolved. A user
    // who finished on Tuesday and next opened the app on Friday did not miss
    // Wednesday and Thursday — the run was already over.
    final absence = engine.absence(
      startedOn: engine.localDateOf(instant: stored.startedAt, zone: zone),
      today: _today,
      logs: logs,
      endedOn: engine.lastResolvedOn(logs),
    );
    final grade = engine.grade(
      missCount: engine.missCount(logs: logs, absences: absence.absences),
      lengthDays: campaign.lengthDays,
    );
    final now = clock.nowUtc();

    await db.transaction(() async {
      await (db.update(
        db.campaignRuns,
      )..where((r) => r.id.equals(stored.id))).write(
        CampaignRunsCompanion(
          status: Value(RunStatus.completed.key),
          completedAt: Value(now),
          grade: Value(grade.key),
          updatedAt: Value(now),
        ),
      );
      await _queueRun(stored.id);
    });

    return grade;
  }

  // ------------------------------------------------------------------ queue

  // Each of these re-reads the row it just wrote and queues that. Serialising
  // from storage rather than from the arguments means what is queued is, by
  // construction, what is stored -- there is no second place for the shape of a
  // payload to drift from the shape of a row.

  Future<void> _queueRun(String runId) async {
    final row = await (db.select(
      db.campaignRuns,
    )..where((r) => r.id.equals(runId))).getSingleOrNull();
    if (row != null) await _outbox.add(entryForRun(row));
  }

  Future<void> _queueDayLog(String runId, int dayIndex) async {
    final row =
        await (db.select(db.dayLogs)..where(
              (l) => l.runId.equals(runId) & l.dayIndex.equals(dayIndex),
            ))
            .getSingleOrNull();
    if (row != null) await _outbox.add(entryForDayLog(row));
  }

  Future<void> _queueTick(String runId, int dayIndex, String actionId) async {
    final row =
        await (db.select(db.dayLogActions)..where(
              (t) =>
                  t.runId.equals(runId) &
                  t.dayIndex.equals(dayIndex) &
                  t.actionId.equals(actionId),
            ))
            .getSingleOrNull();
    if (row != null) await _outbox.add(entryForTick(row));
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
    abandonedOn: row.abandonedOn == null ? null : _asUtc(row.abandonedOn!),
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
    // Bare dates rather than instants. Drift hands them back in the device's
    // local zone, so they are normalised here — two dates stamped in different
    // zones have to compare equal, or absence would count a day twice.
    workedOn: row.workedOn == null ? null : _asUtc(row.workedOn!),
    resolvedOn: row.resolvedOn == null ? null : _asUtc(row.resolvedOn!),
  );
}
