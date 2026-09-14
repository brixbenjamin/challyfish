import 'package:timezone/timezone.dart' as tz;

import '../app/balance_state.dart';
import '../domain/archetype.dart';
import '../domain/campaign.dart';
import '../domain/day_log.dart';
import '../domain/run.dart';
import '../engine/balance.dart';

/// A throwaway, in-memory world for the balance playground.
///
/// It exists so the playground can move days and clocks around without a
/// database, a sync, or a wait. It computes nothing itself: [resolve] hands
/// everything to the real [BalanceState.load], so a number on the debug screen
/// is the number production would draw. If that ever stops being true this
/// file is the bug, not the engine.
///
/// Dev-only. Nothing outside lib/src/dev and its test may import it.
class BalanceScenario {
  BalanceScenario({
    required this.archetypes,
    this.days = const {},
    this.clockOffsetDays = 0,
    this.weights = BalanceWeights.standard,
    this.nextActionSeq = 0,
  });

  /// The run's start date, and therefore day index 1. A fixed instant rather
  /// than `DateTime.now()` so the same taps always produce the same numbers —
  /// the playground is for reading values, and a value that drifts with the
  /// wall clock cannot be read.
  static final DateTime epoch = DateTime.utc(2026, 1, 1, 12);

  /// UTC on purpose. The engine's DST handling has its own tests; mixing it in
  /// here would only make a decay reading ambiguous by an hour.
  static final tz.Location zone = tz.UTC;

  final List<Archetype> archetypes;

  /// Keyed by day index, 1-based from [epoch]. A day is one log, so ticking a
  /// second action into a day that already exists adds to it.
  final Map<int, List<ScenarioTick>> days;

  /// How far "today" has moved past [epoch]. Advancing this and nothing else
  /// is what isolates decay: the logs do not change, only their age.
  final int clockOffsetDays;

  final BalanceWeights weights;

  /// Makes every tick a distinct action id. Two ticks of the same archetype and
  /// effort in one day must both count, and `completedActionIds` is a Set.
  final int nextActionSeq;

  /// The day index that "today" falls on. Day 1 is [epoch].
  int get todayIndex => clockOffsetDays + 1;

  DateTime get now => epoch.add(Duration(days: clockOffsetDays));

  BalanceScenario copyWith({
    Map<int, List<ScenarioTick>>? days,
    int? clockOffsetDays,
    BalanceWeights? weights,
    int? nextActionSeq,
  }) => BalanceScenario(
    archetypes: archetypes,
    days: days ?? this.days,
    clockOffsetDays: clockOffsetDays ?? this.clockOffsetDays,
    weights: weights ?? this.weights,
    nextActionSeq: nextActionSeq ?? this.nextActionSeq,
  );

  /// Ticks [efforts] worth of actions in [archetypeId] onto [dayIndex],
  /// defaulting to today. Several calls stack into the same day, which is what
  /// makes the day cap visible.
  BalanceScenario tick(
    String archetypeId,
    List<int> efforts, {
    int? dayIndex,
  }) => tickSplit({archetypeId: 1}, efforts, dayIndex: dayIndex);

  /// The same, for actions authored against more than one drive. [shares] are
  /// the integer ratios content writes; each action still contributes only its
  /// own effort, divided between them.
  BalanceScenario tickSplit(
    Map<String, int> shares,
    List<int> efforts, {
    int? dayIndex,
  }) {
    final index = dayIndex ?? todayIndex;
    final next = {
      for (final entry in days.entries) entry.key: [...entry.value],
    };
    var seq = nextActionSeq;
    final onDay = next.putIfAbsent(index, () => []);
    for (final effort in efforts) {
      onDay.add(
        ScenarioTick(actionId: 'act-${seq++}', shares: shares, effort: effort),
      );
    }
    return copyWith(days: next, nextActionSeq: seq);
  }

  BalanceScenario advance(int byDays) =>
      copyWith(clockOffsetDays: clockOffsetDays + byDays);

  BalanceScenario withWeights(BalanceWeights next) => copyWith(weights: next);

  BalanceScenario cleared() =>
      BalanceScenario(archetypes: archetypes, weights: weights);

  /// Every tick in the scenario, oldest day first. The playground's readout
  /// and its tests both walk this rather than the map.
  List<MapEntry<int, List<ScenarioTick>>> get orderedDays {
    final entries = days.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries;
  }

  int get tickCount =>
      days.values.fold(0, (total, ticks) => total + ticks.length);

  /// Runs the real pipeline. No arithmetic of its own, by design.
  BalanceState resolve() {
    final actionsById = <String, ActionSpec>{};
    final logs = <DayLog>[];

    for (final entry in orderedDays) {
      for (final tick in entry.value) {
        actionsById[tick.actionId] = ActionSpec(
          id: tick.actionId,
          dayId: 'day-${entry.key}',
          title: tick.actionId,
          archetypeWeights: archetypeWeightsFromShares(tick.shares),
          effort: tick.effort,
        );
      }
      logs.add(
        DayLog(
          id: 'log-${entry.key}',
          runId: 'run',
          dayIndex: entry.key,
          actionId: entry.value.first.actionId,
          completedActionIds: {for (final t in entry.value) t.actionId},
        ),
      );
    }

    return BalanceState.load(
      runs: [
        CampaignRun(
          id: 'run',
          userId: 'dev',
          campaignId: 'camp',
          status: RunStatus.active,
          startedAt: epoch,
        ),
      ],
      logs: logs,
      actionsById: actionsById,
      archetypes: archetypes,
      archetypeIdsByCampaign: const {},
      zone: zone,
      now: now,
      weights: weights,
    );
  }
}

/// One ticked action: which drives it serves, in what ratio, and what it cost.
class ScenarioTick {
  const ScenarioTick({
    required this.actionId,
    required this.shares,
    required this.effort,
  });

  final String actionId;

  /// Authored integer shares by archetype id, exactly as content writes them.
  /// One entry is the ordinary case.
  final Map<String, int> shares;

  final int effort;
}
