import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

DayLog log(int day, Outcome? outcome, {DateTime? committedAt}) => DayLog(
  id: 'log-$day',
  runId: 'run-1',
  dayIndex: day,
  actionId: 'action-$day',
  committedAt: committedAt,
  outcome: outcome,
);

void main() {
  const engine = RunEngine();

  test('a past day with no log at all needs a missed outcome', () {
    expect(engine.daysNeedingMissed(currentDay: 3, logs: const []), [1, 2]);
  });

  test('a past day with a log but no outcome needs a missed outcome', () {
    expect(
      engine.daysNeedingMissed(
        currentDay: 3,
        logs: [log(1, null), log(2, null)],
      ),
      [1, 2],
    );
  });

  test('committing without reporting does not save the day', () {
    final logs = [log(1, null, committedAt: DateTime.utc(2026, 6, 1, 8))];
    expect(engine.daysNeedingMissed(currentDay: 2, logs: logs), [1]);
  });

  test('today is never auto-missed', () {
    expect(engine.daysNeedingMissed(currentDay: 1, logs: const []), isEmpty);
    expect(
      engine.daysNeedingMissed(
        currentDay: 3,
        logs: [log(1, Outcome.done), log(2, Outcome.done)],
      ),
      isEmpty,
    );
  });

  test('reported days are never touched, whatever the outcome', () {
    final logs = [
      log(1, Outcome.done),
      log(2, Outcome.skipped),
      log(3, Outcome.partial),
      log(4, Outcome.missed),
    ];
    expect(engine.daysNeedingMissed(currentDay: 5, logs: logs), isEmpty);
  });

  test('only the gaps are returned, in order', () {
    final logs = [log(1, Outcome.done), log(3, Outcome.done), log(5, null)];
    expect(engine.daysNeedingMissed(currentDay: 6, logs: logs), [2, 4, 5]);
  });

  test(
    'rollover is idempotent — applying it twice yields nothing the second time',
    () {
      var logs = [log(1, Outcome.done)];
      final first = engine.daysNeedingMissed(currentDay: 4, logs: logs);
      expect(first, [2, 3]);

      logs = [...logs, for (final day in first) log(day, Outcome.missed)];
      expect(engine.daysNeedingMissed(currentDay: 4, logs: logs), isEmpty);
    },
  );

  test('a four-day absence produces exactly three misses, not four', () {
    // The user last opened the app on day 1 and returns on day 5.
    final logs = [log(1, Outcome.done)];
    expect(engine.daysNeedingMissed(currentDay: 5, logs: logs), [2, 3, 4]);
  });
}
