import 'package:timezone/timezone.dart' as tz;

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
}
