import '../domain/run.dart';

/// Which archetype marks the user has earned.
///
/// Derived, never stored. A mark is exactly "a completed run graded Sovereign
/// or Passed, for each archetype its campaign targeted" — a marks table would
/// be a second source of truth that could disagree with the grades.
///
/// **Marks never decay.** The archetype balance does (ADR-0010), and these are
/// the permanent record that sits beside it so a falling radar never reads as
/// erasure.
class MarkCalculator {
  const MarkCalculator();

  Map<String, int> earned({
    required Iterable<CampaignRun> runs,
    required Map<String, List<String>> archetypeIdsByCampaign,
  }) {
    final marks = <String, int>{};

    for (final run in runs) {
      if (run.status != RunStatus.completed) continue;

      // A completed run always has a grade — the schema enforces it — but a
      // corrupt row must not take the dashboard down.
      final grade = run.grade;
      if (grade == null || !grade.earnsMark) continue;

      final targets = archetypeIdsByCampaign[run.campaignId];
      if (targets == null) continue;

      for (final archetypeId in targets) {
        marks.update(archetypeId, (n) => n + 1, ifAbsent: () => 1);
      }
    }

    return marks;
  }
}
