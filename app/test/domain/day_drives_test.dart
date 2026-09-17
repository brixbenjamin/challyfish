import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day.dart';
import 'package:test/test.dart';

/// A day's drives are derived from its actions and nothing else (ADR-0041).
/// There is no cap on how many it may carry and no column declaring one, so
/// every surface that summarises a day has to agree on the same fold: each
/// action's points spread across its archetype weights, then normalized.
void main() {
  ActionSpec action({
    required String id,
    required Map<String, double> weights,
    int effort = 1,
    bool isOptional = false,
  }) => ActionSpec(
    id: id,
    dayId: 'day-1',
    title: id,
    archetypeWeights: weights,
    effort: effort,
    isOptional: isOptional,
  );

  DaySpec dayOf(List<ActionSpec> actions) => DaySpec(
    id: 'day-1',
    campaignId: 'camp-1',
    dayIndex: 1,
    title: 'Day 1',
    actions: actions,
  );

  test('a single-drive day is that drive at full weight', () {
    final day = dayOf([
      action(id: 'a1', weights: {'killer': 1}, effort: 3),
    ]);

    expect(day.archetypeWeights, {'killer': 1.0});
  });

  test('points weight the fold, so a heavier action pulls harder', () {
    // The optional is worth a quarter of the day's points, and that is exactly
    // what it contributes — not half, which is what counting actions would give.
    final day = dayOf([
      action(id: 'mandatory', weights: {'killer': 1}, effort: 3),
      action(
        id: 'optional',
        weights: {'beast': 1},
        effort: 1,
        isOptional: true,
      ),
    ]);

    expect(day.archetypeWeights, {'killer': 0.75, 'beast': 0.25});
  });

  test('a split action divides its own points before the fold', () {
    // ADR-0033: an action serving two drives splits its effort between them
    // rather than paying both in full.
    final day = dayOf([
      action(id: 'a1', weights: {'beast': 0.75, 'killer': 0.25}, effort: 4),
    ]);

    expect(day.archetypeWeights, {'beast': 0.75, 'killer': 0.25});
  });

  test('a day can carry every drive its actions touch', () {
    // The case the One Drive Per Loop Rule used to forbid the surface from
    // showing. Four drives on one day is legal content, not an error state.
    final day = dayOf([
      action(id: 'a1', weights: {'psycho': 0.5, 'killer': 0.5}, effort: 2),
      action(
        id: 'a2',
        weights: {'trickster': 0.5, 'beast': 0.5},
        effort: 2,
        isOptional: true,
      ),
    ]);

    expect(day.archetypeWeights, {
      'psycho': 0.25,
      'killer': 0.25,
      'trickster': 0.25,
      'beast': 0.25,
    });
  });

  test('the drives are ordered by share, heaviest first', () {
    // The order the day-preview row renders its tags in, decided here rather
    // than in the widget.
    final day = dayOf([
      action(id: 'a1', weights: {'beast': 1}, effort: 1),
      action(id: 'a2', weights: {'killer': 1}, effort: 5, isOptional: true),
    ]);

    expect(day.archetypeWeights.keys.toList(), ['killer', 'beast']);
  });

  test('a day whose actions are not cached has no drives', () {
    // The partial-sync state a day already degrades on. Empty, never a guess.
    expect(dayOf(const []).archetypeWeights, isEmpty);
  });

  test('an action whose archetype rows have not arrived contributes none', () {
    // ActionSpec.archetypeWeights is empty in exactly that state, and it must
    // not silently drag the rest of the day's shares toward it.
    final day = dayOf([
      action(id: 'a1', weights: {'killer': 1}, effort: 2),
      action(id: 'a2', weights: const {}, effort: 6, isOptional: true),
    ]);

    expect(day.archetypeWeights, {'killer': 1.0});
  });

  test('a day of zero-point actions still reports its drives', () {
    // `effort` is authored and nothing stops it being 0. Dividing by a zero
    // total would give NaN, so the fold falls back to counting the actions.
    final day = dayOf([
      action(id: 'a1', weights: {'killer': 1}, effort: 0),
      action(id: 'a2', weights: {'beast': 1}, effort: 0, isOptional: true),
    ]);

    expect(day.archetypeWeights, {'killer': 0.5, 'beast': 0.5});
  });
}
