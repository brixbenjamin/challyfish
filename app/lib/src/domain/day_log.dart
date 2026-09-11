import 'outcome.dart';

/// The user's record for one day of a run. One per run per day index.
class DayLog {
  const DayLog({
    required this.id,
    required this.runId,
    required this.dayIndex,
    required this.actionId,
    this.committedAt,
    this.outcome,
    this.note,
    this.completedActionIds = const {},
  });

  final String id;
  final String runId;
  final int dayIndex;
  /// The day's *mandatory* action. An optional tick never rewrites it.
  final String actionId;

  /// Which of the day's actions the user ticked. Assembled by the repository
  /// from the tick table; the day's outcome is derived from it rather than
  /// chosen (ADR-0030).
  final Set<String> completedActionIds;

  /// Set by the morning commit tap. Never required — reporting is not gated on it.
  final DateTime? committedAt;

  /// Null means not yet reported. For a past day, rollover turns that into `missed`.
  final Outcome? outcome;
  final String? note;

  bool get isReported => outcome != null;
}
