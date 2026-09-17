import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

DayLog log(int day, Outcome? outcome) => DayLog(
  id: 'log-$day',
  runId: 'run-1',
  dayIndex: day,
  actionId: 'action-$day',
  outcome: outcome,
);

void main() {
  const engine = RunEngine();

  test('a run with nothing resolved is on day 1', () {
    expect(engine.storyPosition(logs: const [], lengthDays: 7), 1);
  });

  test('resolving a day advances the position by one', () {
    expect(
      engine.storyPosition(logs: [log(1, Outcome.done)], lengthDays: 7),
      2,
    );
  });

  test('a skipped day is resolved and still advances', () {
    expect(
      engine.storyPosition(logs: [log(1, Outcome.skipped)], lengthDays: 7),
      2,
    );
  });

  test('a log with no outcome is in progress and does not advance', () {
    // Committed or ticked today, not yet reported. The user still has the day.
    expect(engine.storyPosition(logs: [log(1, null)], lengthDays: 7), 1);
  });

  test(
    'the position is the lowest unresolved day, not the highest plus one',
    () {
      // Gaps cannot arise through the app, but a partial sync can deliver one.
      final logs = [log(1, Outcome.done), log(3, Outcome.done)];
      expect(engine.storyPosition(logs: logs, lengthDays: 7), 2);
    },
  );

  test('a run with every day resolved points one past the last day', () {
    final logs = [for (var d = 1; d <= 3; d++) log(d, Outcome.done)];
    expect(engine.storyPosition(logs: logs, lengthDays: 3), 4);
  });

  test('the calendar never advances the position', () {
    // The whole point of ADR-0040: elapsed time moves nothing on its own.
    expect(engine.storyPosition(logs: const [], lengthDays: 30), 1);
  });

  group('the day on screen', () {
    DateTime june(int d) => DateTime.utc(2026, 6, d);

    DayLog dated(int index, Outcome? outcome, DateTime workedOn) => DayLog(
      id: 'log-$index',
      runId: 'run-1',
      dayIndex: index,
      actionId: 'action-$index',
      outcome: outcome,
      workedOn: workedOn,
      resolvedOn: outcome == null ? null : workedOn,
    );

    int onScreen(List<DayLog> logs, DateTime today) =>
        engine.dayOnScreen(logs: logs, lengthDays: 7, today: today);

    test('is the next unresolved day', () {
      final logs = [dated(1, Outcome.done, june(1))];
      expect(onScreen(logs, june(2)), 2);
    });

    test('stays on the day just reported for the rest of that day', () {
      // Reporting must not hand the user tomorrow's chapter this evening:
      // one day of content per calendar day (ADR-0040).
      final logs = [dated(1, Outcome.done, june(1))];
      expect(onScreen(logs, june(1)), 1);
    });

    test('moves on once the calendar does', () {
      final logs = [dated(1, Outcome.done, june(1))];
      expect(onScreen(logs, june(2)), 2);
    });

    test('a day in progress is the day on screen', () {
      final logs = [dated(1, Outcome.done, june(1)), dated(2, null, june(2))];
      expect(onScreen(logs, june(2)), 2);
    });

    test('a day resolved late holds the screen on the day it was resolved', () {
      // Absent on the 2nd; came back on the 3rd and resolved day 2 then.
      final logs = [
        dated(1, Outcome.done, june(1)),
        dated(2, Outcome.done, june(3)),
      ];
      expect(onScreen(logs, june(3)), 2);
      expect(onScreen(logs, june(4)), 3);
    });
  });
}
