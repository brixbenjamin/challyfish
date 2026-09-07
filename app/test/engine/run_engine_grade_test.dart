import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/grade_thresholds.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

DayLog log(int day, Outcome? outcome) => DayLog(
  id: 'log-$day',
  runId: 'run-1',
  dayIndex: day,
  actionId: 'action-$day',
  outcome: outcome,
);

List<DayLog> misses(int count) =>
    List.generate(count, (i) => log(i + 1, Outcome.missed));

void main() {
  const engine = RunEngine();

  group('missCount', () {
    test('counts skipped and missed, and nothing else', () {
      final logs = [
        log(1, Outcome.done),
        log(2, Outcome.partial),
        log(3, Outcome.skipped),
        log(4, Outcome.missed),
        log(5, null),
      ];
      expect(engine.missCount(logs), 2);
    });

    test('an unreported day is not yet a miss', () {
      expect(engine.missCount([log(1, null)]), 0);
    });

    test('no logs means no misses', () {
      expect(engine.missCount(const []), 0);
    });
  });

  group('missAllowance', () {
    test('scales with campaign length', () {
      expect(engine.missAllowance(7), 1);
      expect(engine.missAllowance(14), 1);
      expect(engine.missAllowance(21), 2);
      expect(engine.missAllowance(25), 3);
      expect(engine.missAllowance(30), 3);
    });

    test('never drops below one, however short the campaign', () {
      // A campaign on which a single miss is fatal makes reporting `skipped`
      // honestly feel catastrophic, which produces dishonest records.
      expect(engine.missAllowance(1), 1);
      expect(engine.missAllowance(3), 1);
      expect(engine.missAllowance(4), 1);
    });
  });

  group('grade', () {
    test('zero misses is Sovereign at every length', () {
      for (final length in [7, 21, 30, 60]) {
        expect(
          engine.grade([log(1, Outcome.done)], lengthDays: length),
          Grade.sovereign,
          reason: 'length $length',
        );
      }
    });

    test('a 7-day campaign allows one miss, and breaks on two', () {
      expect(engine.grade(misses(1), lengthDays: 7), Grade.passed);
      expect(engine.grade(misses(2), lengthDays: 7), Grade.broken);
    });

    test('a 21-day campaign allows two misses, and breaks on three', () {
      expect(engine.grade(misses(2), lengthDays: 21), Grade.passed);
      expect(engine.grade(misses(3), lengthDays: 21), Grade.broken);
    });

    test('a 30-day campaign allows three misses, and breaks on four', () {
      expect(engine.grade(misses(3), lengthDays: 30), Grade.passed);
      expect(engine.grade(misses(4), lengthDays: 30), Grade.broken);
    });

    test('the same miss count grades differently at different lengths', () {
      // This is the entire point of ADR-0012: three misses is 43% of a 7-day
      // campaign and 10% of a 30-day one, and they should not grade alike.
      expect(engine.grade(misses(3), lengthDays: 7), Grade.broken);
      expect(engine.grade(misses(3), lengthDays: 30), Grade.passed);
    });

    test('extra misses do not make it worse than Broken', () {
      expect(engine.grade(misses(20), lengthDays: 21), Grade.broken);
    });

    test('Sovereign and Passed earn the mark; Broken does not', () {
      expect(Grade.sovereign.earnsMark, isTrue);
      expect(Grade.passed.earnsMark, isTrue);
      expect(Grade.broken.earnsMark, isFalse);
    });

    test('the divisor is injectable, so the judgement can be revised', () {
      const strict = GradeThresholds(daysPerAllowedMiss: 30);
      expect(strict.allowanceFor(30), 1);
      expect(
        engine.grade(misses(2), lengthDays: 30, thresholds: strict),
        Grade.broken,
      );
    });
  });
}
