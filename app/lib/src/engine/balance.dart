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
  /// day lands near 1.0 and `BalanceState.maxValue`'s floor keeps the meaning
  /// it was calibrated for — that floor exists so a single day cannot draw a
  /// full axis and flatter the user with a shape they did not earn. The
  /// user-facing points total is the undivided integer; only the radar sees
  /// this scale. A judgement, like halfLifeDays, and due a revisit once real
  /// content exists (Q18).
  final double pointsPerFullDay;

  /// Local days over which a contribution halves. A judgement, not a finding.
  final double halfLifeDays;

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

      // No outcome check: a skipped or missed day has no ticks by
      // construction, because the outcome is derived from them.
      for (final actionId in log.completedActionIds) {
        // Content can lag progress after a partial sync. Dropping the
        // contribution is acceptable; crashing the dashboard is not.
        final action = actionsById[actionId];
        if (action == null) continue;

        // The action's own archetype, not the day's — which is what lets one
        // day move several axes (ADR-0030).
        final contribution =
            (action.effort / weights.pointsPerFullDay) * decay;

        balance.update(
          action.archetypeId,
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
