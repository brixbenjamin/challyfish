import 'package:feral/src/app/run_state.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day.dart';
import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();

  final berlin = tz.getLocation('Europe/Berlin');
  final started = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();

  const campaign = Campaign(
    id: 'campaign-1',
    packId: 'pack-1',
    key: 'first-week',
    title: 'The First Week',
    introMd: 'i',
    lengthDays: 7,
  );

  final run = CampaignRun(
    id: 'run-1',
    userId: 'user-1',
    campaignId: 'campaign-1',
    status: RunStatus.active,
    startedAt: started,
  );

  ActionSpec action(
    String id, {
    int dayIndex = 3,
    int effort = 1,
    bool isOptional = false,
    int sort = 0,
  }) => ActionSpec(
    id: id,
    dayId: 'day-$dayIndex',
    title: 'Do not explain yourself',
    bodyMd: 'body',
    archetypeWeights: const {'arch-killer': 1.0},
    effort: effort,
    isOptional: isOptional,
    sort: sort,
  );

  final mandatory = action('action-3');

  /// Day 3 of the run, as the repository hands it over: already ordered,
  /// carrying its own title and framing copy.
  DaySpec day3(List<ActionSpec> actions, {String? bodyMd = 'Say it once.'}) =>
      DaySpec(
        id: 'day-3',
        campaignId: 'campaign-1',
        dayIndex: 3,
        title: 'The day you stop hedging',
        bodyMd: bodyMd,
        actions: actions,
      );

  /// A day of the run, dated to the calendar day of the same number — the
  /// ordinary case where the user has not fallen behind, so the story position
  /// and the calendar still line up. Absence is a gap in these dates now, so a
  /// log without them reads as a day the user was never there for (ADR-0040).
  DayLog log(int day, Outcome? outcome, {Set<String> ticks = const {}}) {
    final date = DateTime.utc(2026, 6, day);
    return DayLog(
      id: 'log-$day',
      runId: 'run-1',
      dayIndex: day,
      actionId: 'action-$day',
      outcome: outcome,
      completedActionIds: ticks,
      workedOn: date,
      resolvedOn: outcome == null ? null : date,
    );
  }

  RunState stateOn(DateTime now, List<DayLog> logs) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: logs,
    today: day3([mandatory]),
    zone: berlin,
    now: now,
  );

  /// Day 3 of the run, with whatever day, actions and ticks the case needs.
  /// `dayCached: false` is the partial-sync state: the run is there, the day
  /// is not.
  RunState stateWith({
    List<ActionSpec> actions = const [],
    bool dayCached = true,
    Set<String> ticks = const {},
    Map<String, ActionSpec>? actionsById,
    List<DayLog> otherLogs = const [],
    Set<String> dayOneTicks = const {},
  }) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: [
      // Days 1 and 2 resolved on their own calendar days, so the story stands
      // on day 3 — which is what every case in this group is about.
      log(1, Outcome.done, ticks: dayOneTicks),
      log(2, Outcome.done),
      ...otherLogs,
      log(3, null, ticks: ticks),
    ],
    today: dayCached ? day3(actions) : null,
    actionsById: actionsById ?? {for (final a in actions) a.id: a},
    zone: berlin,
    now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
  );

  test(
    'derives the day, miss count, allowance and standing grade together',
    () {
      final now = tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc();
      final state = stateOn(now, [
        log(1, Outcome.done),
        log(2, Outcome.skipped),
      ]);

      expect(state.storyPosition, 3);
      expect(state.lengthDays, 7);
      expect(state.missCount, 1);
      expect(state.missAllowance, 1, reason: 'max(1, round(7 / 10))');
      expect(state.grade, Grade.passed);
    },
  );

  test('a clean run stands at Sovereign', () {
    final now = tz.TZDateTime(berlin, 2026, 6, 2, 10).toUtc();
    expect(stateOn(now, [log(1, Outcome.done)]).grade, Grade.sovereign);
  });

  test('a second miss breaks this 7-day run, because it allows only one', () {
    // Absent on the 1st and the 2nd — two misses, and never three in a row, so
    // the run survives — then day 1 resolved on the 3rd and day 2 on the 4th.
    final now = tz.TZDateTime(berlin, 2026, 6, 5, 10).toUtc();
    final state = RunState.derive(
      run: run,
      campaign: campaign,
      logs: [
        DayLog(
          id: 'log-1',
          runId: 'run-1',
          dayIndex: 1,
          actionId: 'action-1',
          outcome: Outcome.done,
          workedOn: DateTime.utc(2026, 6, 3),
          resolvedOn: DateTime.utc(2026, 6, 3),
        ),
        DayLog(
          id: 'log-2',
          runId: 'run-1',
          dayIndex: 2,
          actionId: 'action-2',
          outcome: Outcome.done,
          workedOn: DateTime.utc(2026, 6, 4),
          resolvedOn: DateTime.utc(2026, 6, 4),
        ),
      ],
      zone: berlin,
      now: now,
    );

    expect(state.missCount, 2);
    expect(state.grade, Grade.broken);
    expect(
      state.storyPosition,
      3,
      reason: 'a Broken run still runs on, and the story never skips ahead',
    );
  });

  test('todayLog is the log for the current day, or null if untouched', () {
    final now = tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc();

    expect(stateOn(now, [log(1, Outcome.done)]).todayLog, isNull);
    expect(stateOn(now, [log(3, Outcome.done)]).todayLog?.dayIndex, 3);
  });

  test('isReportedToday reflects only the current day', () {
    final now = tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc();
    expect(stateOn(now, [log(3, Outcome.done)]).isReportedToday, isTrue);
    expect(stateOn(now, [log(3, null)]).isReportedToday, isFalse);
  });

  group('the day', () {
    test('the mandatory action and the optionals are read off the day', () {
      final state = stateWith(
        actions: [
          action('m'),
          action('o1', isOptional: true, sort: 1),
          action('o2', isOptional: true, sort: 2),
        ],
      );

      expect(state.mandatoryToday?.id, 'm');
      expect(state.optionalsToday.map((a) => a.id), ['o1', 'o2']);
    });

    test('the mandatory action is found by predicate, not by position', () {
      // The defensive re-sort is gone: content_repository.dart already orders
      // by is_optional then sort in SQL, and DaySpec.mandatory reads the flag
      // rather than the index. A day handed over in the wrong order still
      // cannot bury the one action the grade depends on.
      final state = stateWith(
        actions: [
          action('o1', isOptional: true, sort: 1),
          action('m', sort: 5),
        ],
      );

      expect(state.mandatoryToday?.id, 'm');
      expect(state.optionalsToday.map((a) => a.id), ['o1']);
    });

    test('an uncached day yields no mandatory action and no optionals', () {
      final state = stateWith(dayCached: false);

      expect(state.today, isNull);
      expect(state.mandatoryToday, isNull);
      expect(state.optionalsToday, isEmpty);
      expect(
        state.derivedOutcomeToday,
        isNull,
        reason: 'the derivation has nothing to key on',
      );
      expect(state.todayPoints, 0);
    });

    test('a cached day with no actions yet is the same recoverable state', () {
      // A partial sync can land the day row ahead of its actions.
      final state = stateWith(actions: const []);

      expect(state.today, isNotNull);
      expect(state.mandatoryToday, isNull);
      expect(state.derivedOutcomeToday, isNull);
    });
  });

  group('derivedOutcomeToday', () {
    test('is partial when only an optional was ticked', () {
      final state = stateWith(
        actions: [action('m'), action('o1', isOptional: true, sort: 1)],
        ticks: const {'o1'},
      );
      expect(state.derivedOutcomeToday, Outcome.partial);
    });

    test('is done when the mandatory action was ticked', () {
      final state = stateWith(
        actions: [action('m'), action('o1', isOptional: true, sort: 1)],
        ticks: const {'m'},
      );
      expect(state.derivedOutcomeToday, Outcome.done);
    });

    test('is skipped when nothing was ticked', () {
      final state = stateWith(actions: [action('m')]);
      expect(state.derivedOutcomeToday, Outcome.skipped);
    });
  });

  group('points', () {
    test('day points are the plain sum of ticked effort', () {
      final state = stateWith(
        actions: [
          action('m', effort: 2),
          action('o1', isOptional: true, sort: 1, effort: 3),
        ],
        ticks: const {'m', 'o1'},
      );
      expect(state.todayPoints, 5);
    });

    test('an unticked action earns nothing', () {
      final state = stateWith(
        actions: [
          action('m', effort: 2),
          action('o1', isOptional: true, sort: 1, effort: 3),
        ],
        ticks: const {'m'},
      );
      expect(state.todayPoints, 2);
    });

    test('run points span every day logged, not only today', () {
      final earlier = action('action-1', dayIndex: 1, effort: 4);
      final state = stateWith(
        actions: [action('m', effort: 2)],
        ticks: const {'m'},
        actionsById: {'m': action('m', effort: 2), 'action-1': earlier},
        dayOneTicks: const {'action-1'},
      );

      expect(state.runPoints, 6);
      expect(state.todayPoints, 2, reason: 'today is still only today');
    });

    test('a tick whose action is not cached is skipped, not fatal', () {
      final state = stateWith(
        actions: [action('m', effort: 2)],
        ticks: const {'m', 'vanished'},
      );
      expect(state.todayPoints, 2);
    });
  });
}
