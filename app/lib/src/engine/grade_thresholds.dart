import '../domain/grade.dart';

/// Where a run's miss count turns into a grade.
///
/// The allowance scales with campaign length (ADR-0012), because three misses
/// is 43% of a seven-day campaign and 10% of a thirty-day one, and those are
/// not the same performance. Sovereign is zero misses at every length and is
/// never scaled — a perfect run is perfect.
class GradeThresholds {
  const GradeThresholds({this.daysPerAllowedMiss = 10});

  /// Roughly one forgiven day per this many committed days. A judgement, not a
  /// finding, and the only number to change if it turns out wrong.
  final int daysPerAllowedMiss;

  static const GradeThresholds standard = GradeThresholds();

  /// How many misses this campaign tolerates before Broken.
  ///
  /// Floored at one: a campaign where a single miss is fatal would make
  /// reporting `skipped` honestly feel catastrophic, and a user who will not
  /// report honestly is the one failure the product cannot survive.
  int allowanceFor(int lengthDays) {
    final scaled = (lengthDays / daysPerAllowedMiss).round();
    return scaled < 1 ? 1 : scaled;
  }

  Grade gradeFor({required int missCount, required int lengthDays}) {
    if (missCount == 0) return Grade.sovereign;
    return missCount <= allowanceFor(lengthDays) ? Grade.passed : Grade.broken;
  }
}
