import 'outcome.dart';

/// The user's record for one day of a run. One per run per day index.
class DayLog {
  const DayLog({
    required this.id,
    required this.runId,
    required this.dayIndex,
    this.actionId,
    this.committedAt,
    this.outcome,
    this.note,
    this.completedActionIds = const {},
    this.workedOn,
    this.resolvedOn,
  });

  final String id;
  final String runId;
  final int dayIndex;

  /// The day's *mandatory* action. An optional tick never rewrites it.
  ///
  /// Null when the day's content was never cached on this device. Rollover
  /// still resolves such a day (ADR-0040) — a day it has to skip is a day that
  /// silently becomes an absence and can end a run the user was present for.
  final String? actionId;

  /// Which of the day's actions the user ticked. Assembled by the repository
  /// from the tick table; the day's outcome is derived from it rather than
  /// chosen (ADR-0030).
  final Set<String> completedActionIds;

  /// Set by the morning commit tap. Never required — reporting is not gated on it.
  final DateTime? committedAt;

  /// Null means not yet reported. For a day the user worked on, rollover
  /// resolves it to its derived outcome at the day's close; a day nobody
  /// touched simply stays null and its calendar date becomes an absence
  /// instead (ADR-0040).
  final Outcome? outcome;
  final String? note;

  /// The local calendar date the user first touched this day — committed,
  /// ticked, or reported. Set once and never moved.
  ///
  /// A **bare date** carried on a UTC instant, not an instant in its own
  /// right: absence is counted in local days, and storing the date the user
  /// was actually in when they acted is what keeps the promise that travel
  /// never retroactively converts a past day into a miss.
  final DateTime? workedOn;

  /// The local calendar date this day's outcome was written. Null while the
  /// day is in progress.
  ///
  /// Rollover stamps this with [workedOn], never with the day it happens to
  /// run — a day ticked on Monday and resolved by Wednesday's app open was
  /// worked on Monday, and dating it Wednesday would charge the user an
  /// absence for a day they showed up.
  final DateTime? resolvedOn;

  bool get isReported => outcome != null;

  /// The local dates on which this day shows the user was present. Usually one
  /// date; two only when a day was worked on and resolved on different dates.
  Iterable<DateTime> get presenceDates => [?workedOn, ?resolvedOn];
}
