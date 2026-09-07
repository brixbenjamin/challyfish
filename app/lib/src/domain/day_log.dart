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
  });

  final String id;
  final String runId;
  final int dayIndex;
  final String actionId;

  /// Set by the morning commit tap. Never required — reporting is not gated on it.
  final DateTime? committedAt;

  /// Null means not yet reported. For a past day, rollover turns that into `missed`.
  final Outcome? outcome;
  final String? note;

  bool get isReported => outcome != null;
}
