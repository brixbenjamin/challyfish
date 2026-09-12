import '../domain/archetype.dart';
import '../engine/balance.dart';
import 'balance_scenario.dart';

/// One-tap worlds worth looking at, each named for the question it answers.
///
/// They are scenarios, not assertions: the playground shows what the engine
/// makes of them. The claims in the descriptions are what the widget test
/// checks.
class BalancePreset {
  const BalancePreset({
    required this.label,
    required this.blurb,
    required this.build,
  });

  final String label;
  final String blurb;
  final BalanceScenario Function(List<Archetype> archetypes) build;

  static const capBuster = BalancePreset(
    label: 'Cap buster',
    blurb: '10 effort ticked into one drive on one day. The day cap should '
        'hold it to exactly one day of contribution.',
    build: _capBuster,
  );

  static const fullAxis = BalancePreset(
    label: 'Full axis',
    blurb: 'The cap hit in one drive every day for a year. Should sit just '
        'under the fixed ceiling without ever reaching it.',
    build: _fullAxis,
  );

  static const lopsided = BalancePreset(
    label: 'Lopsided',
    blurb: 'A fortnight of heavy work in one drive and a single act in '
        'another. The shape the radar was drawn for.',
    build: _lopsided,
  );

  static const even = BalancePreset(
    label: 'Even four',
    blurb: 'The same act in all four drives, today. Every axis equal.',
    build: _even,
  );

  static const all = <BalancePreset>[capBuster, fullAxis, lopsided, even];
}

BalanceScenario _capBuster(List<Archetype> archetypes) =>
    BalanceScenario(archetypes: archetypes).tick(archetypes.first.id, [2, 4, 4]);

BalanceScenario _fullAxis(List<Archetype> archetypes) {
  const days = 365;
  final cap = BalanceWeights.standard.pointsPerFullDay.round();
  var scenario = BalanceScenario(
    archetypes: archetypes,
    clockOffsetDays: days - 1,
  );
  for (var day = 1; day <= days; day++) {
    scenario = scenario.tick(archetypes.first.id, [cap], dayIndex: day);
  }
  return scenario;
}

BalanceScenario _lopsided(List<Archetype> archetypes) {
  var scenario = BalanceScenario(archetypes: archetypes, clockOffsetDays: 13);
  for (var day = 1; day <= 14; day++) {
    scenario = scenario.tick(archetypes.first.id, [3, 2], dayIndex: day);
  }
  return scenario.tick(archetypes[1].id, [1], dayIndex: 14);
}

BalanceScenario _even(List<Archetype> archetypes) {
  var scenario = BalanceScenario(archetypes: archetypes);
  for (final archetype in archetypes) {
    scenario = scenario.tick(archetype.id, [3]);
  }
  return scenario;
}
