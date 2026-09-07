import 'package:timezone/timezone.dart' as tz;

import '../domain/day_log.dart';
import '../domain/grade.dart';
import 'grade_thresholds.dart';

/// Every rule that decides where a user stands in a run.
///
/// Pure: no I/O, no framework types, no ambient clock. Given the same inputs it
/// always returns the same answer, on client and server alike. That property is
/// what lets two devices converge without conflict resolution beyond
/// last-write-wins (see docs/technical/architecture.md).
class RunEngine {
  const RunEngine();

  /// The 1-based day of the run that `now` falls on, clamped to the campaign.
  ///
  /// A day boundary is a local calendar date change, not 24 elapsed hours. DST
  /// days are 23 or 25 hours long and must still count as exactly one day, so
  /// this compares calendar dates rather than durations.
  int currentDay({
    required DateTime startedAt,
    required tz.Location zone,
    required DateTime now,
    required int lengthDays,
  }) {
    final startLocal = tz.TZDateTime.from(startedAt, zone);
    final nowLocal = tz.TZDateTime.from(now, zone);

    // Reduce both to a bare calendar date carried on a UTC instant, so that
    // subtracting them cannot be perturbed by an offset change in between.
    final startDate = DateTime.utc(
      startLocal.year,
      startLocal.month,
      startLocal.day,
    );
    final nowDate = DateTime.utc(nowLocal.year, nowLocal.month, nowLocal.day);

    final elapsedDays = nowDate.difference(startDate).inDays;
    final day = elapsedDays + 1;

    if (day < 1) return 1;
    if (day > lengthDays) return lengthDays;
    return day;
  }

  /// Days that count against the user: skipped (reported) and missed (rolled
  /// over). The difference between them is honesty, not consequence.
  int missCount(Iterable<DayLog> logs) =>
      logs.where((log) => log.outcome?.isMiss ?? false).length;

  /// How many misses this campaign length tolerates before Broken.
  int missAllowance(
    int lengthDays, {
    GradeThresholds thresholds = GradeThresholds.standard,
  }) => thresholds.allowanceFor(lengthDays);

  /// The grade a run currently stands at. Derived, always — never read from a
  /// column. Needs the campaign length, because the length sets the allowance.
  Grade grade(
    Iterable<DayLog> logs, {
    required int lengthDays,
    GradeThresholds thresholds = GradeThresholds.standard,
  }) => thresholds.gradeFor(missCount: missCount(logs), lengthDays: lengthDays);

  /// The day indices that must be written as `missed`, given where the run
  /// stands now.
  ///
  /// Idempotent by construction: it returns only days with no outcome, so
  /// applying the result and asking again yields an empty list. Today is never
  /// included — the user still has the day.
  List<int> daysNeedingMissed({
    required int currentDay,
    required Iterable<DayLog> logs,
  }) {
    final reported = <int>{
      for (final log in logs)
        if (log.isReported) log.dayIndex,
    };

    return [
      for (var day = 1; day < currentDay; day++)
        if (!reported.contains(day)) day,
    ];
  }
}
