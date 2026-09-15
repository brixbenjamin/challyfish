import 'package:feral/src/domain/diagnostic.dart';
import 'package:feral/src/engine/diagnostic_scorer.dart';
import 'package:test/test.dart';

const psycho = 'psycho';
const killer = 'killer';
const trickster = 'trickster';
const beast = 'beast';

/// Fixed order, standing in for the archetypes' `sort` column.
const order = [psycho, killer, trickster, beast];

DiagnosticQuestion pair(int n, String a, String b) => DiagnosticQuestion(
  id: 'q$n',
  prompt: 'Closer to you?',
  sort: n,
  options: [
    DiagnosticOption(
      id: 'q${n}a',
      questionId: 'q$n',
      label: a,
      archetypeId: a,
      sort: 0,
    ),
    DiagnosticOption(
      id: 'q${n}b',
      questionId: 'q$n',
      label: b,
      archetypeId: b,
      sort: 1,
    ),
  ],
);

/// The real instrument shape: six pairings plus two repeats, four appearances
/// each.
final instrument = <DiagnosticQuestion>[
  pair(1, psycho, killer),
  pair(2, psycho, trickster),
  pair(3, psycho, beast),
  pair(4, killer, trickster),
  pair(5, killer, beast),
  pair(6, trickster, beast),
  pair(7, psycho, killer),
  pair(8, trickster, beast),
];

/// Pick the option on `archetype` for each listed question number.
List<DiagnosticPick> pickAll(Map<int, String> choices) => [
  for (final entry in choices.entries)
    DiagnosticPick(
      questionId: 'q${entry.key}',
      optionId: instrument
          .firstWhere((q) => q.id == 'q${entry.key}')
          .options
          .firstWhere((o) => o.archetypeId == entry.value)
          .id,
    ),
];

void main() {
  const scorer = DiagnosticScorer();

  DiagnosticOutcome scoreOf(Map<int, String> choices) => scorer.score(
    questions: instrument,
    picks: pickAll(choices),
    archetypeOrder: order,
  );

  test('every archetype is offered exactly four times', () {
    final appearances = <String, int>{};
    for (final q in instrument) {
      for (final o in q.options) {
        appearances.update(o.archetypeId, (n) => n + 1, ifAbsent: () => 1);
      }
    }
    expect(appearances, {psycho: 4, killer: 4, trickster: 4, beast: 4});
  });

  test('a score is wins over appearances', () {
    // Killer chosen in q1, q4, q5, q7 — all four of its appearances.
    final outcome = scoreOf({
      1: killer,
      2: psycho,
      3: psycho,
      4: killer,
      5: killer,
      6: trickster,
      7: killer,
      8: trickster,
    });

    expect(outcome.scores[killer], closeTo(1.0, 1e-9));
    expect(outcome.scores[psycho], closeTo(0.5, 1e-9)); // won q2, q3 of 4
    expect(outcome.scores[trickster], closeTo(0.5, 1e-9)); // won q6, q8 of 4
    expect(outcome.scores[beast], closeTo(0.0, 1e-9)); // won nothing
  });

  test('the weakest archetype is the one never chosen', () {
    final outcome = scoreOf({
      1: killer,
      2: psycho,
      3: psycho,
      4: killer,
      5: killer,
      6: trickster,
      7: killer,
      8: trickster,
    });
    expect(outcome.weakestArchetypeId, beast);
  });

  test('every archetype gets a score, including one never chosen', () {
    final outcome = scoreOf({
      1: killer,
      2: psycho,
      3: psycho,
      4: killer,
      5: killer,
      6: trickster,
      7: killer,
      8: trickster,
    });
    expect(outcome.scores.keys.toSet(), {psycho, killer, trickster, beast});
  });

  test('scores sum to two, since eight questions award one win each', () {
    final outcome = scoreOf({
      1: psycho,
      2: trickster,
      3: beast,
      4: killer,
      5: beast,
      6: trickster,
      7: killer,
      8: beast,
    });
    final total = outcome.scores.values.reduce((a, b) => a + b);
    expect(
      total,
      closeTo(2.0, 1e-9),
      reason: '8 wins spread over 4 appearances each',
    );
  });

  group('tie-break', () {
    test('head-to-head decides a two-way tie', () {
      // Psycho and beast both end on 0.25: psycho won only q3, beast only
      // q8. They met in q3, and psycho won it, so beast is the weaker.
      final outcome = scoreOf({
        1: killer,
        2: trickster,
        3: psycho,
        4: trickster,
        5: killer,
        6: trickster,
        7: killer,
        8: beast,
      });

      expect(
        outcome.scores[psycho],
        closeTo(outcome.scores[beast]!, 1e-9),
        reason: 'the tie this case exists to test',
      );
      expect(outcome.scores[psycho], closeTo(0.25, 1e-9));
      expect(outcome.weakestArchetypeId, beast);
    });

    test('the fixed order decides when head-to-head cannot', () {
      // A flat result: every archetype wins exactly two of its four, and every
      // archetype loses exactly two head-to-head. Nothing but the fixed order
      // can separate them.
      final outcome = scoreOf({
        1: psycho,
        2: trickster,
        3: psycho,
        4: killer,
        5: beast,
        6: trickster,
        7: killer,
        8: beast,
      });

      expect(
        outcome.scores.values,
        everyElement(closeTo(0.5, 1e-9)),
        reason: 'the flat result this case exists to test',
      );
      expect(
        outcome.weakestArchetypeId,
        psycho,
        reason: 'first in archetypeOrder, never the map iteration order',
      );
    });

    test('the same answers always give the same weakest archetype', () {
      final choices = {
        1: psycho,
        2: trickster,
        3: psycho,
        4: killer,
        5: beast,
        6: trickster,
        7: killer,
        8: beast,
      };
      final first = scoreOf(choices).weakestArchetypeId;
      for (var i = 0; i < 20; i++) {
        expect(
          scoreOf(choices).weakestArchetypeId,
          first,
          reason: 'a retake must never move the recommendation',
        );
      }
    });

    test('a second flat result breaks the same way, not a different way', () {
      // Different answers, same total deadlock. The order tie-break must not
      // depend on which questions produced the flatness.
      final outcome = scoreOf({
        1: killer,
        2: psycho,
        3: beast,
        4: trickster,
        5: killer,
        6: trickster,
        7: psycho,
        8: beast,
      });
      expect(outcome.scores.values, everyElement(closeTo(0.5, 1e-9)));
      expect(outcome.weakestArchetypeId, psycho);
    });
  });

  group('input the UI should prevent but the scorer must survive', () {
    test('an unanswered question simply awards nobody a win', () {
      final outcome = scorer.score(
        questions: instrument,
        picks: pickAll({1: killer}),
        archetypeOrder: order,
      );
      expect(outcome.scores[killer], closeTo(0.25, 1e-9));
      expect(outcome.scores[beast], closeTo(0.0, 1e-9));
    });

    test('a pick for an unknown question is ignored', () {
      final outcome = scorer.score(
        questions: instrument,
        picks: [
          ...pickAll({1: killer}),
          const DiagnosticPick(questionId: 'q99', optionId: 'nope'),
        ],
        archetypeOrder: order,
      );
      expect(outcome.scores[killer], closeTo(0.25, 1e-9));
    });

    test('a pick naming an option that is not on its question is ignored', () {
      final outcome = scorer.score(
        questions: instrument,
        picks: const [DiagnosticPick(questionId: 'q1', optionId: 'q6a')],
        archetypeOrder: order,
      );
      expect(outcome.scores.values.every((v) => v == 0), isTrue);
    });

    test('an empty instrument throws rather than guessing', () {
      expect(
        () => scorer.score(
          questions: const [],
          picks: const [],
          archetypeOrder: order,
        ),
        throwsArgumentError,
      );
    });
  });
}
