import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;

import '../domain/campaign.dart';
import '../domain/day_log.dart';

/// How a completed action contributes to the archetype balance, and how fast a
/// contribution fades (ADR-0010, amended by ADR-0030).
///
/// `done` and `partial` are gone: the weight no longer comes from the day's
/// outcome at all. It comes from the effort of each action the user ticked.
class BalanceWeights {
  const BalanceWeights({this.pointsPerFullDay = 5, this.halfLifeDays = 60});

  /// Effort is divided by this before it enters the balance, so a typical full
  /// day lands near 1.0. It also doubles as the **day cap**: a single day's
  /// ticked effort in one archetype is clamped to `pointsPerFullDay` before
  /// decay is applied, so no day — however many optionals stack into one
  /// drive, however a pack authors `effort` — can draw more than one day's
  /// worth of contribution. That cap is what keeps `fullAxisValue` meaningful
  /// regardless of how much content exists. The user-facing points total is
  /// the undivided integer; only the radar sees this scale. A judgement, like
  /// halfLifeDays, and due a revisit once real content exists (Q18).
  final double pointsPerFullDay;

  /// Local days over which a contribution halves. A judgement, not a finding.
  final double halfLifeDays;

  /// The decayed balance that reads as a fully-drawn radar axis.
  ///
  /// Not a new dial: it is the asymptote a single archetype approaches if the
  /// day cap above is hit every day, forever, discounted by this same decay
  /// curve — `sum(0.5^(k/halfLifeDays))` for k from 0 to infinity, which is a
  /// convergent geometric series with closed form `1 / (1 - 0.5^(1/halfLifeDays))`.
  /// Deriving it from the decay curve rather than guessing a number means it
  /// can never be invalidated by adding more packs or campaigns — decay caps
  /// the sum regardless of how much content exists — and it can't drift out
  /// of calibration with `halfLifeDays` if that judgement is ever revisited.
  /// The bar it sets is deliberately high: reaching it means hitting the cap
  /// in one drive essentially every day, indefinitely.
  double get fullAxisValue => 1 / (1 - math.pow(0.5, 1 / halfLifeDays));

  static const BalanceWeights standard = BalanceWeights();
}

/// How much the user has acted in each archetype *recently*.
///
/// Pure, like RunEngine: `now` and the timezone are arguments, never ambient.
/// But the result depends on when it is asked, so it is display-only — never
/// stored, never synced, never compared for equality.
///
/// Counts every ticked action across every run regardless of that run's grade:
/// a Broken campaign earns no mark, but the acts the user performed still
/// count (ADR-0003). The marks themselves never decay; only this does.
class BalanceCalculator {
  const BalanceCalculator();

  Map<String, double> compute({
    required Iterable<DayLog> logs,
    required Map<String, ActionSpec> actionsById,
    required Map<String, DateTime> runStartedAt,
    required tz.Location zone,
    required DateTime now,
    BalanceWeights weights = BalanceWeights.standard,
  }) {
    final balance = <String, double>{};
    final today = _localDate(now, zone);

    for (final log in logs) {
      final startedAt = runStartedAt[log.runId];
      if (startedAt == null) continue;

      // The log's calendar date is the run's start date plus dayIndex - 1.
      // Working in bare dates keeps DST out of the arithmetic entirely.
      final logDate = _localDate(
        startedAt,
        zone,
      ).add(Duration(days: log.dayIndex - 1));

      // Clock skew or travel can date a log ahead of today. Clamp at zero so a
      // future log counts full weight rather than more than full weight.
      final daysAgo = math.max(0, today.difference(logDate).inDays);
      final decay = math.pow(0.5, daysAgo / weights.halfLifeDays).toDouble();

      // Summed per archetype before the day cap applies: several optional
      // actions in the same drive must combine before clamping, not after,
      // or the cap would only ever bind one action at a time.
      //
      // No outcome check: a skipped or missed day has no ticks by
      // construction, because the outcome is derived from them.
      final dayEffortByArchetype = <String, double>{};
      for (final actionId in log.completedActionIds) {
        // Content can lag progress after a partial sync. Dropping the
        // contribution is acceptable; crashing the dashboard is not.
        final action = actionsById[actionId];
        if (action == null) continue;

        // The action's own archetype, not the day's — which is what lets one
        // day move several axes (ADR-0030).
        dayEffortByArchetype.update(
          action.archetypeId,
          (existing) => existing + action.effort,
          ifAbsent: () => action.effort.toDouble(),
        );
      }

      // The day cap: at most one day's worth of effort counts toward any one
      // archetype, however much was ticked. Keeps `fullAxisValue` meaningful
      // no matter how many optionals a day stacks into a single drive.
      for (final entry in dayEffortByArchetype.entries) {
        final cappedEffort = math.min(entry.value, weights.pointsPerFullDay);
        final contribution = (cappedEffort / weights.pointsPerFullDay) * decay;

        balance.update(
          entry.key,
          (existing) => existing + contribution,
          ifAbsent: () => contribution,
        );
      }
    }

    return balance;
  }

  /// A bare calendar date carried on a UTC instant, so subtracting two of them
  /// cannot be perturbed by a DST offset change in between.
  DateTime _localDate(DateTime instant, tz.Location zone) {
    final local = tz.TZDateTime.from(instant, zone);
    return DateTime.utc(local.year, local.month, local.day);
  }
}
