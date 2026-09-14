import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

ActionSpec action(String id, {int effort = 1, bool isOptional = false}) =>
    ActionSpec(
      id: id,
      campaignId: 'campaign-1',
      dayIndex: 1,
      title: 'do the thing',
      archetypeWeights: const {'axis-a': 1.0},
      effort: effort,
      isOptional: isOptional,
    );

void main() {
  const engine = RunEngine();

  group('deriveOutcome', () {
    test('the mandatory action ticked is a done day', () {
      expect(
        engine.deriveOutcome(
          mandatoryActionId: 'm',
          completedActionIds: const {'m'},
        ),
        Outcome.done,
      );
    });

    test('the mandatory action ticked beside optionals is still done', () {
      expect(
        engine.deriveOutcome(
          mandatoryActionId: 'm',
          completedActionIds: const {'m', 'o1', 'o2'},
        ),
        Outcome.done,
      );
    });

    test('optionals only is a partial day', () {
      expect(
        engine.deriveOutcome(
          mandatoryActionId: 'm',
          completedActionIds: const {'o1'},
        ),
        Outcome.partial,
      );
    });

    test('nothing ticked is a skipped day', () {
      expect(
        engine.deriveOutcome(
          mandatoryActionId: 'm',
          completedActionIds: const {},
        ),
        Outcome.skipped,
      );
    });

    test('never returns missed, which only rollover writes', () {
      for (final ticks in const [
        <String>{},
        {'m'},
        {'o1'},
      ]) {
        expect(
          engine.deriveOutcome(
            mandatoryActionId: 'm',
            completedActionIds: ticks,
          ),
          isNot(Outcome.missed),
        );
      }
    });

    test('the derived outcomes keep the miss meanings the grade relies on', () {
      // ADR-0030 preserves the grade rules by construction rather than by
      // luck, and this is the assertion that says so: `done` and `partial`
      // are not misses, `skipped` is. If that ever stops holding, missCount
      // and the allowance silently change meaning.
      expect(
        engine
            .deriveOutcome(
              mandatoryActionId: 'm',
              completedActionIds: const {'m'},
            )
            .isMiss,
        isFalse,
      );
      expect(
        engine
            .deriveOutcome(
              mandatoryActionId: 'm',
              completedActionIds: const {'o1'},
            )
            .isMiss,
        isFalse,
      );
      expect(
        engine
            .deriveOutcome(mandatoryActionId: 'm', completedActionIds: const {})
            .isMiss,
        isTrue,
      );
    });
  });

  group('pointsFor', () {
    final actions = {
      'm': action('m', effort: 2),
      'o1': action('o1', effort: 3, isOptional: true),
    };

    test('sums the effort of every ticked action', () {
      expect(
        engine.pointsFor(
          completedActionIds: const {'m', 'o1'},
          actionsById: actions,
        ),
        5,
      );
    });

    test('skips a tick whose action is not cached', () {
      // Content can lag progress after a partial sync. Dropping the tick is
      // acceptable; crashing the dashboard is not.
      expect(
        engine.pointsFor(
          completedActionIds: const {'m', 'gone'},
          actionsById: actions,
        ),
        2,
      );
    });

    test('is zero when nothing is ticked', () {
      expect(
        engine.pointsFor(completedActionIds: const {}, actionsById: actions),
        0,
      );
    });

    test('is the plain integer sum, undivided by the radar scale', () {
      // pointsPerFullDay belongs to the balance alone. "0.75 points" is not a
      // thing this product ever shows.
      expect(
        engine.pointsFor(completedActionIds: const {'m'}, actionsById: actions),
        isA<int>().having((p) => p, 'points', 2),
      );
    });
  });
}
