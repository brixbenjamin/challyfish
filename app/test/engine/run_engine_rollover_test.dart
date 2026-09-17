import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

DateTime june(int day) => DateTime.utc(2026, 6, day);

DayLog log(
  int index, {
  Outcome? outcome,
  DateTime? workedOn,
  DateTime? resolvedOn,
}) => DayLog(
  id: 'log-$index',
  runId: 'run-1',
  dayIndex: index,
  actionId: 'action-$index',
  outcome: outcome,
  workedOn: workedOn,
  resolvedOn: resolvedOn,
);

void main() {
  const engine = RunEngine();

  group('days needing resolution', () {
    test('a day worked on before today resolves at its close', () {
      final logs = [log(1, workedOn: june(1))];
      expect(engine.daysNeedingResolution(logs: logs, today: june(2)), [1]);
    });

    test('today is never resolved early — the user still has it', () {
      final logs = [log(1, workedOn: june(2))];
      expect(engine.daysNeedingResolution(logs: logs, today: june(2)), isEmpty);
    });

    test('a day already resolved is never touched again', () {
      final logs = [
        log(1, outcome: Outcome.done, workedOn: june(1), resolvedOn: june(1)),
      ];
      expect(engine.daysNeedingResolution(logs: logs, today: june(5)), isEmpty);
    });

    test('a day nobody touched is not resolved — it is an absence', () {
      // This is what replaces `missed`: there is no log to write an outcome
      // on, because the user was never there (ADR-0040).
      expect(
        engine.daysNeedingResolution(logs: const [], today: june(5)),
        isEmpty,
      );
    });

    test('a log with no worked-on date is left alone', () {
      // Cannot be dated honestly, so it is not resolved by guesswork.
      final logs = [log(1)];
      expect(engine.daysNeedingResolution(logs: logs, today: june(5)), isEmpty);
    });

    test('resolution is idempotent — applying it twice yields nothing', () {
      var logs = [log(1, workedOn: june(1))];
      expect(engine.daysNeedingResolution(logs: logs, today: june(3)), [1]);

      logs = [
        log(1, outcome: Outcome.done, workedOn: june(1), resolvedOn: june(1)),
      ];
      expect(engine.daysNeedingResolution(logs: logs, today: june(3)), isEmpty);
    });

    test('several stale days come back in order', () {
      final logs = [log(3, workedOn: june(3)), log(1, workedOn: june(1))];
      expect(engine.daysNeedingResolution(logs: logs, today: june(9)), [1, 3]);
    });
  });

  group('completion', () {
    test('a run is complete when its final day is resolved', () {
      final logs = [
        for (var d = 1; d <= 3; d++)
          log(d, outcome: Outcome.done, workedOn: june(d), resolvedOn: june(d)),
      ];
      expect(engine.isComplete(logs: logs, lengthDays: 3), isTrue);
    });

    test('an unresolved final day leaves the run open', () {
      final logs = [
        log(1, outcome: Outcome.done, workedOn: june(1), resolvedOn: june(1)),
        log(2, outcome: Outcome.done, workedOn: june(2), resolvedOn: june(2)),
        log(3, workedOn: june(3)),
      ];
      expect(engine.isComplete(logs: logs, lengthDays: 3), isFalse);
    });

    test('elapsed calendar time does not complete a run', () {
      // The old rule gated completion on the calendar reaching lengthDays.
      // A user who fell behind would have been completed out of a campaign
      // they had days of content left in.
      final logs = [
        log(1, outcome: Outcome.done, workedOn: june(1), resolvedOn: june(1)),
      ];
      expect(engine.isComplete(logs: logs, lengthDays: 3), isFalse);
    });

    test('a skipped final day still completes the run', () {
      final logs = [
        for (var d = 1; d <= 2; d++)
          log(d, outcome: Outcome.done, workedOn: june(d), resolvedOn: june(d)),
        log(
          3,
          outcome: Outcome.skipped,
          workedOn: june(3),
          resolvedOn: june(3),
        ),
      ];
      expect(engine.isComplete(logs: logs, lengthDays: 3), isTrue);
    });
  });
}
