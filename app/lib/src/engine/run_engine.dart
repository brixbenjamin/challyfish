import 'package:timezone/timezone.dart' as tz;

import '../domain/campaign.dart';
import '../domain/day_log.dart';
import '../domain/grade.dart';
import '../domain/outcome.dart';
import 'grade_thresholds.dart';

/// Every rule that decides where a user stands in a run.
///
/// Pure: no I/O, no framework types, no ambient clock. Given the same inputs it
/// always returns the same answer, on client and server alike. That property is
/// what lets two devices converge without conflict resolution beyond
/// last-write-wins (see docs/technical/architecture.md).
class RunEngine {
  const RunEngine();

  /// The day of content the user is on right now — what the dashboard shows
  /// and what a commit, a tick or a report writes against.
  ///
  /// Normally [storyPosition], but a day resolved *today* holds the screen for
  /// the rest of that day. Without this, reporting would advance the pointer
  /// the instant it was tapped and hand the user tomorrow's day the same
  /// evening, which is the catch-up ADR-0040 rules out: one day of content per
  /// calendar day, so falling behind stays behind.
  int dayOnScreen({
    required Iterable<DayLog> logs,
    required int lengthDays,
    required DateTime today,
  }) {
    for (final log in logs) {
      if (log.resolvedOn == today) return log.dayIndex;
    }
    return storyPosition(logs: logs, lengthDays: lengthDays);
  }

  /// The local calendar date an instant falls on, as a bare date carried on a
  /// UTC instant.
  ///
  /// A day boundary is a local calendar date change, not 24 elapsed hours. DST
  /// days are 23 or 25 hours long and must still count as exactly one day, so
  /// everything downstream compares dates rather than durations — and the date
  /// carries no offset of its own, so two dates stamped in different zones
  /// still subtract cleanly.
  ///
  /// This is the *only* place an instant becomes a day. Stamped onto a day log
  /// at the moment the user acts, the result is a fact rather than a
  /// recomputation, which is what keeps `user-stories.md`'s promise that travel
  /// never retroactively converts a past day into a miss.
  DateTime localDateOf({required DateTime instant, required tz.Location zone}) {
    final local = tz.TZDateTime.from(instant, zone);
    return DateTime.utc(local.year, local.month, local.day);
  }

  /// The days that must be resolved now, given where the run stands.
  ///
  /// A day the user worked on — committed, ticked, or both — but never
  /// reported, whose date has since closed. Rollover resolves it to the outcome
  /// its ticks derive, stamped with the date it was worked on rather than
  /// today, so a day ticked on Monday and resolved by Wednesday's app open is
  /// still recorded as Monday's (ADR-0040).
  ///
  /// Idempotent by construction: it returns only days with no outcome, so
  /// applying the result and asking again yields an empty list. Today is never
  /// included — the user still has the day.
  ///
  /// A day nobody touched has no log to resolve and is not here. It is an
  /// absence, which is what [absence] counts and what replaced `missed`.
  List<int> daysNeedingResolution({
    required Iterable<DayLog> logs,
    required DateTime today,
  }) {
    final due = [
      for (final log in logs)
        if (!log.isReported &&
            log.workedOn != null &&
            log.workedOn!.isBefore(today))
          log.dayIndex,
    ];
    return due..sort();
  }

  /// Whether every day of the campaign has been resolved.
  ///
  /// Completion follows the content, not the clock: a run ends when its last
  /// day is reported, however many calendar days that took (ADR-0040).
  bool isComplete({required Iterable<DayLog> logs, required int lengthDays}) =>
      storyPosition(logs: logs, lengthDays: lengthDays) > lengthDays;

  /// The 1-based day of *content* the run stands on: the lowest day with no
  /// resolved log (ADR-0040).
  ///
  /// This is what the dashboard serves and what commit, ticks and report write
  /// against. It advances only when a day is resolved, never with the calendar
  /// — which is what stops an absence skipping a chapter of the campaign.
  ///
  /// A log with a null outcome does **not** advance it: the day is in progress,
  /// committed or ticked but not yet reported, and the user still has it.
  ///
  /// Returns `lengthDays + 1` for a run whose every day is resolved, which is
  /// the condition [isComplete] reads.
  int storyPosition({required Iterable<DayLog> logs, required int lengthDays}) {
    final resolved = <int>{
      for (final log in logs)
        if (log.isReported) log.dayIndex,
    };

    for (var day = 1; day <= lengthDays; day++) {
      if (!resolved.contains(day)) return day;
    }
    return lengthDays + 1;
  }

  /// How many consecutive absent days end a run (ADR-0040).
  ///
  /// Flat at every campaign length, unlike the miss allowance. ADR-0012 scales
  /// the allowance because three misses is 43% of a seven-day campaign and 10%
  /// of a thirty-day one; three consecutive days of absence is the same act at
  /// any length, so it does not scale.
  static const absencesBeforeAbandoned = 3;

  /// The days the run was live and the user resolved nothing, and the day the
  /// run ended for being abandoned (ADR-0040).
  ///
  /// Both come back together because the second truncates the first: once the
  /// run has ended, the days after it are not the user's to have missed.
  ///
  /// [startedOn] and [today] are bare local dates. Today is never absent — the
  /// user still has the day — which is also what lets a third consecutive
  /// absence be answered by acting before midnight.
  ({List<DateTime> absences, DateTime? abandonedOn}) absence({
    required DateTime startedOn,
    required DateTime today,
    required Iterable<DayLog> logs,

    /// The date the run's record closes, for a run that has ended. Days after
    /// it are not days the user missed — there was nothing left to turn up
    /// for. [lastResolvedOn] supplies it for a completed run.
    DateTime? endedOn,
  }) {
    final present = <DateTime>{for (final log in logs) ...log.presenceDates};

    final absences = <DateTime>[];
    var consecutive = 0;

    for (
      var date = startedOn;
      date.isBefore(today) && !(endedOn != null && date.isAfter(endedOn));
      date = date.add(const Duration(days: 1))
    ) {
      if (present.contains(date)) {
        consecutive = 0;
        continue;
      }

      absences.add(date);
      consecutive++;
      if (consecutive == absencesBeforeAbandoned) {
        return (absences: absences, abandonedOn: date);
      }
    }

    return (absences: absences, abandonedOn: null);
  }

  /// The latest date any day of this run was resolved on, or null if none was.
  ///
  /// For a finished run this is the date its record closes: the grade must be
  /// computed against the days the run was actually live, not against however
  /// long the user took to open the app again afterwards.
  DateTime? lastResolvedOn(Iterable<DayLog> logs) {
    DateTime? latest;
    for (final log in logs) {
      final resolved = log.resolvedOn;
      if (resolved == null) continue;
      if (latest == null || resolved.isAfter(latest)) latest = resolved;
    }
    return latest;
  }

  /// Days that count against the user: the calendar days they were absent, and
  /// the days they showed up for and reported `skipped` (ADR-0040).
  ///
  /// The difference between the two is honesty, not consequence — but only one
  /// of them can end a run, which is what makes showing up worth something even
  /// on a day the user does nothing.
  ///
  /// A lagging story position is deliberately **not** a miss. After a single
  /// absence the story trails the calendar for the rest of the run, and
  /// charging per lagging day would compound one bad day into a Broken grade.
  int missCount({
    required Iterable<DayLog> logs,
    required List<DateTime> absences,
  }) =>
      absences.length +
      logs.where((log) => log.outcome == Outcome.skipped).length;

  /// How many misses this campaign length tolerates before Broken.
  int missAllowance(
    int lengthDays, {
    GradeThresholds thresholds = GradeThresholds.standard,
  }) => thresholds.allowanceFor(lengthDays);

  /// The grade a run currently stands at. Derived, always — never read from a
  /// column. Needs the campaign length, because the length sets the allowance.
  ///
  /// Takes the miss count rather than the logs, because a miss is no longer
  /// something a log can carry on its own: absence lives in the gaps between
  /// the dates the logs were resolved on (ADR-0040). Call [missCount] with the
  /// absences from [absence] first.
  ///
  /// A run that was **abandoned** has no grade at all and never reaches here —
  /// not Broken, which would misreport a run whose misses were inside its
  /// allowance, and not Passed, which would misreport a run the user left.
  Grade grade({
    required int missCount,
    required int lengthDays,
    GradeThresholds thresholds = GradeThresholds.standard,
  }) => thresholds.gradeFor(missCount: missCount, lengthDays: lengthDays);

  /// The outcome a day resolves to, given what the user ticked (ADR-0030).
  ///
  /// Every outcome in the system now comes from here: since ADR-0040 removed
  /// `missed`, there is no outcome the product writes on a user's behalf. The
  /// three below carry exactly the meanings they carried when they were chosen
  /// from buttons, which is what leaves [missAllowance] and [grade] untouched.
  Outcome deriveOutcome({
    required String mandatoryActionId,
    required Set<String> completedActionIds,
  }) {
    if (completedActionIds.contains(mandatoryActionId)) return Outcome.done;
    if (completedActionIds.isEmpty) return Outcome.skipped;
    return Outcome.partial;
  }

  /// Points earned for a set of ticks, as displayed: the plain integer sum of
  /// each action's authored effort.
  ///
  /// Undivided. `BalanceWeights.pointsPerFullDay` scales the radar and nothing
  /// else — a user-facing "0.75 points" is not a thing this product shows.
  ///
  /// A tick whose action is not cached contributes nothing rather than
  /// throwing — content can lag progress after a partial sync.
  int pointsFor({
    required Iterable<String> completedActionIds,
    required Map<String, ActionSpec> actionsById,
  }) {
    var total = 0;
    for (final id in completedActionIds) {
      final action = actionsById[id];
      if (action != null) total += action.effort;
    }
    return total;
  }
}
