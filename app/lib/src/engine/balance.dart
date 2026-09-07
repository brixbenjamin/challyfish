import 'dart:math' as math;

import 'package:timezone/timezone.dart' as tz;

import '../domain/campaign.dart';
import '../domain/day_log.dart';
import '../domain/outcome.dart';

/// How much each outcome contributes to the archetype balance, and how fast a
/// contribution fades (ADR-0010).
class BalanceWeights {
  const BalanceWeights({
    this.done = 1,
    this.partial = 1,
    this.halfLifeDays = 60,
  });

  final double done;

  /// Equal to `done`. A partial day is a day the user acted, and grading
  /// already declines to punish it.
  final double partial;

  /// Local days over which a contribution halves. A judgement, not a finding.
  final double halfLifeDays;

  static const BalanceWeights standard = BalanceWeights();

  double? baseFor(Outcome? outcome) => switch (outcome) {
    Outcome.done => done,
    Outcome.partial => partial,
    _ => null,
  };
}

/// How much the user has acted in each archetype *recently*.
///
/// Pure, like RunEngine: `now` and the timezone are arguments, never ambient.
/// But the result depends on when it is asked, so it is display-only — never
/// stored, never synced, never compared for equality.
///
/// Counts every done and partial day across every run regardless of that run's
/// grade: a Broken campaign earns no mark, but the days the user did still
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
      final base = weights.baseFor(log.outcome);
      if (base == null) continue;

      // Content can lag progress after a partial sync. Dropping the
      // contribution is acceptable; crashing the dashboard is not.
      final action = actionsById[log.actionId];
      if (action == null) continue;

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
      final contribution = base * decay;

      balance.update(
        action.archetypeId,
        (existing) => existing + contribution,
        ifAbsent: () => contribution,
      );
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
