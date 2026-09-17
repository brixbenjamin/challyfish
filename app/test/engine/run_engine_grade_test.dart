import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/engine/grade_thresholds.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

void main() {
  const engine = RunEngine();

  // The miss count itself is covered in run_engine_absence_test.dart, where
  // absences are — since ADR-0040 a miss is a calendar day, not a log.
  Grade gradeFor(int misses, int length, {GradeThresholds? thresholds}) =>
      engine.grade(
        missCount: misses,
        lengthDays: length,
        thresholds: thresholds ?? GradeThresholds.standard,
      );

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
        expect(gradeFor(0, length), Grade.sovereign, reason: 'length $length');
      }
    });

    test('a 7-day campaign allows one miss, and breaks on two', () {
      expect(gradeFor(1, 7), Grade.passed);
      expect(gradeFor(2, 7), Grade.broken);
    });

    test('a 21-day campaign allows two misses, and breaks on three', () {
      expect(gradeFor(2, 21), Grade.passed);
      expect(gradeFor(3, 21), Grade.broken);
    });

    test('a 30-day campaign allows three misses, and breaks on four', () {
      expect(gradeFor(3, 30), Grade.passed);
      expect(gradeFor(4, 30), Grade.broken);
    });

    test('the same miss count grades differently at different lengths', () {
      // This is the entire point of ADR-0012: three misses is 43% of a 7-day
      // campaign and 10% of a 30-day one, and they should not grade alike.
      expect(gradeFor(3, 7), Grade.broken);
      expect(gradeFor(3, 30), Grade.passed);
    });

    test('extra misses do not make it worse than Broken', () {
      expect(gradeFor(20, 21), Grade.broken);
    });

    test('Sovereign and Passed earn the mark; Broken does not', () {
      expect(Grade.sovereign.earnsMark, isTrue);
      expect(Grade.passed.earnsMark, isTrue);
      expect(Grade.broken.earnsMark, isFalse);
    });

    test('the divisor is injectable, so the judgement can be revised', () {
      const strict = GradeThresholds(daysPerAllowedMiss: 30);
      expect(strict.allowanceFor(30), 1);
      expect(gradeFor(2, 30, thresholds: strict), Grade.broken);
    });

    test('three consecutive absences can end a run still inside allowance', () {
      // A 30-day campaign forgives three misses, so a run abandoned on its
      // third consecutive absent day would still grade Passed. It gets no
      // grade at all instead — the reason RunStatus.abandoned is terminal
      // rather than a bad result (ADR-0040).
      expect(gradeFor(RunEngine.absencesBeforeAbandoned, 30), Grade.passed);
    });
  });
}
