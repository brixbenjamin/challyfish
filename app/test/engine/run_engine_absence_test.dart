import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';

/// A bare local calendar date, carried on a UTC instant — the same idiom the
/// engine uses so that subtracting two of them cannot be perturbed by an
/// offset change in between.
DateTime june(int day) => DateTime.utc(2026, 6, day);

/// A day resolved on [onDate], which is also the date it was worked on. The
/// ordinary path: the user opens the app, ticks, and reports, all on one day.
DayLog resolved(int index, DateTime onDate, {Outcome outcome = Outcome.done}) =>
    DayLog(
      id: 'log-$index',
      runId: 'run-1',
      dayIndex: index,
      actionId: 'action-$index',
      outcome: outcome,
      workedOn: onDate,
      resolvedOn: onDate,
    );

void main() {
  const engine = RunEngine();

  ({List<DateTime> absences, DateTime? abandonedOn}) absenceFrom(
    int todayDay,
    List<DayLog> logs, {
    int startDay = 1,
  }) => engine.absence(
    startedOn: june(startDay),
    today: june(todayDay),
    logs: logs,
  );

  group('absent dates', () {
    test('the day a run starts is never absent — the user still has it', () {
      expect(absenceFrom(1, const []).absences, isEmpty);
    });

    test('today is never absent, however long the run has been going', () {
      // Started the 1st, resolved it, and it is now the 2nd. The 2nd is live.
      final logs = [resolved(1, june(1))];
      expect(absenceFrom(2, logs).absences, isEmpty);
    });

    test('a closed day on which nothing was resolved is absent', () {
      final logs = [resolved(1, june(1))];
      expect(absenceFrom(3, logs).absences, [june(2)]);
    });

    test('a day worked on but resolved later is not absent', () {
      // Ticked on the 2nd, never reported; rollover resolved it dated the 2nd.
      final log = DayLog(
        id: 'log-2',
        runId: 'run-1',
        dayIndex: 2,
        actionId: 'action-2',
        outcome: Outcome.done,
        workedOn: june(2),
        resolvedOn: june(2),
      );
      expect(absenceFrom(4, [resolved(1, june(1)), log]).absences, [june(3)]);
    });

    test('a day worked on but still unresolved counts as present', () {
      // Content was not cached, so rollover could not resolve it. The user was
      // demonstrably there; charging them a miss would be a dishonest record.
      final inProgress = DayLog(
        id: 'log-2',
        runId: 'run-1',
        dayIndex: 2,
        actionId: 'action-2',
        outcome: null,
        workedOn: june(2),
      );
      final logs = [resolved(1, june(1)), inProgress];
      expect(absenceFrom(3, logs).absences, isEmpty);
    });

    test('reporting skipped is presence, not absence', () {
      final logs = [
        resolved(1, june(1)),
        resolved(2, june(2), outcome: Outcome.skipped),
      ];
      expect(absenceFrom(3, logs).absences, isEmpty);
    });

    test('absences come back in calendar order', () {
      final logs = [resolved(1, june(1)), resolved(2, june(4))];
      expect(absenceFrom(6, logs).absences, [june(2), june(3), june(5)]);
    });
  });

  group('abandonment', () {
    test('two consecutive absences do not end the run', () {
      final logs = [resolved(1, june(1))];
      final result = absenceFrom(4, logs);
      expect(result.absences, [june(2), june(3)]);
      expect(result.abandonedOn, isNull);
    });

    test('the third consecutive absence ends the run, dated to that day', () {
      final logs = [resolved(1, june(1))];
      expect(absenceFrom(5, logs).abandonedOn, june(4));
    });

    test('acting on the third day saves the run at two misses', () {
      // Absent the 2nd and 3rd, back on the 4th.
      final logs = [resolved(1, june(1)), resolved(2, june(4))];
      final result = absenceFrom(5, logs);
      expect(result.abandonedOn, isNull);
      expect(result.absences, [june(2), june(3)]);
    });

    test('a skipped report breaks a run of absences', () {
      // Absent the 2nd and 3rd, showed up and skipped on the 4th, absent the
      // 5th and 6th. Six days in, never three in a row, so the run survives.
      final logs = [
        resolved(1, june(1)),
        resolved(2, june(4), outcome: Outcome.skipped),
      ];
      expect(absenceFrom(7, logs).abandonedOn, isNull);
    });

    test('a third absence that is still today does not end the run', () {
      // Absent the 2nd and 3rd; it is now the 4th and the user has the day.
      final logs = [resolved(1, june(1))];
      expect(absenceFrom(4, logs).abandonedOn, isNull);
    });

    test('absences stop accruing at abandonment', () {
      // Away for a fortnight, but the run ended on the 4th and the ten days
      // after it are not the user's to have missed.
      final logs = [resolved(1, june(1))];
      final result = absenceFrom(15, logs);
      expect(result.abandonedOn, june(4));
      expect(result.absences, [june(2), june(3), june(4)]);
    });

    test('the first run of three ends it, not a later one', () {
      final logs = [resolved(1, june(1)), resolved(2, june(5))];
      // Absent 2,3,4 — that is the triple, and the 5th never happens.
      expect(absenceFrom(20, logs).abandonedOn, june(4));
    });

    test('a run never opened at all ends on its third day', () {
      expect(absenceFrom(9, const []).abandonedOn, june(3));
    });
  });

  group('a run that has ended', () {
    test('absence stops at the day the record closes', () {
      // Finished the content on the 3rd and opened the app again on the 10th.
      // The days between are not days the user missed — the run was over.
      final logs = [resolved(1, june(1)), resolved(2, june(3))];
      final result = engine.absence(
        startedOn: june(1),
        today: june(10),
        logs: logs,
        endedOn: june(3),
      );
      expect(result.absences, [june(2)]);
      expect(result.abandonedOn, isNull);
    });

    test('the closing date is the last day resolved', () {
      final logs = [resolved(1, june(1)), resolved(2, june(4))];
      expect(engine.lastResolvedOn(logs), june(4));
    });

    test('a run with nothing resolved has no closing date', () {
      expect(engine.lastResolvedOn(const []), isNull);
    });
  });

  group('miss count', () {
    test('an absent day and a skipped day both count once', () {
      final logs = [
        resolved(1, june(1)),
        resolved(2, june(3), outcome: Outcome.skipped),
      ];
      final result = absenceFrom(4, logs);
      expect(engine.missCount(logs: logs, absences: result.absences), 2);
    });

    test('done and partial days cost nothing', () {
      final logs = [
        resolved(1, june(1)),
        resolved(2, june(2), outcome: Outcome.partial),
      ];
      final result = absenceFrom(3, logs);
      expect(engine.missCount(logs: logs, absences: result.absences), 0);
    });

    test('a lagging story position is not itself a miss', () {
      // The whole reason a miss is an absent day rather than a lagging
      // pointer: after one absence the story trails the calendar forever, and
      // charging per lagging day would cascade one bad day into Broken.
      final logs = [
        resolved(1, june(1)),
        // absent the 2nd
        resolved(2, june(3)),
        resolved(3, june(4)),
        resolved(4, june(5)),
      ];
      final result = absenceFrom(6, logs);
      expect(engine.missCount(logs: logs, absences: result.absences), 1);
    });
  });
}
