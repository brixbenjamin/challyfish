import 'package:feral/src/app/run_state.dart';
import 'package:feral/src/domain/campaign.dart';
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
    campaignId: 'campaign-1',
    dayIndex: dayIndex,
    title: 'Do not explain yourself',
    bodyMd: 'body',
    archetypeId: 'arch-killer',
    effort: effort,
    isOptional: isOptional,
    sort: sort,
  );

  final mandatory = action('action-3');

  DayLog log(int day, Outcome? outcome, {Set<String> ticks = const {}}) =>
      DayLog(
        id: 'log-$day',
        runId: 'run-1',
        dayIndex: day,
        actionId: 'action-$day',
        outcome: outcome,
        completedActionIds: ticks,
      );

  RunState stateOn(DateTime now, List<DayLog> logs) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: logs,
    todayActions: [mandatory],
    zone: berlin,
    now: now,
  );

  /// Day 3 of the run, with whatever actions and ticks the case needs.
  RunState stateWith({
    required List<ActionSpec> todayActions,
    Set<String> ticks = const {},
    Map<String, ActionSpec>? actionsById,
    List<DayLog> otherLogs = const [],
  }) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: [
      ...otherLogs,
      log(3, null, ticks: ticks),
    ],
    todayActions: todayActions,
    actionsById: actionsById ?? {for (final a in todayActions) a.id: a},
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

      expect(state.currentDay, 3);
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
    final now = tz.TZDateTime(berlin, 2026, 6, 5, 10).toUtc();
    final state = stateOn(now, [
      log(1, Outcome.missed),
      log(2, Outcome.missed),
      log(3, Outcome.skipped),
      log(4, Outcome.done),
    ]);

    expect(state.grade, Grade.broken);
    expect(state.currentDay, 5, reason: 'a Broken run runs to its final day');
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

  group('the day as a list of actions', () {
    test('puts the mandatory action first, whatever the authored sort', () {
      final state = stateWith(
        todayActions: [
          action('o2', isOptional: true, sort: 2),
          action('m', sort: 5),
          action('o1', isOptional: true, sort: 1),
        ],
      );

      expect(state.todayActions.map((a) => a.id), ['m', 'o1', 'o2']);
      expect(state.mandatoryToday?.id, 'm');
      expect(state.optionalsToday.map((a) => a.id), ['o1', 'o2']);
    });

    test('mandatoryToday is null when content is not cached', () {
      final state = stateWith(todayActions: const []);
      expect(state.mandatoryToday, isNull);
      expect(
        state.derivedOutcomeToday,
        isNull,
        reason: 'the derivation has nothing to key on',
      );
    });
  });

  group('derivedOutcomeToday', () {
    test('is partial when only an optional was ticked', () {
      final state = stateWith(
        todayActions: [action('m'), action('o1', isOptional: true, sort: 1)],
        ticks: const {'o1'},
      );
      expect(state.derivedOutcomeToday, Outcome.partial);
    });

    test('is done when the mandatory action was ticked', () {
      final state = stateWith(
        todayActions: [action('m'), action('o1', isOptional: true, sort: 1)],
        ticks: const {'m'},
      );
      expect(state.derivedOutcomeToday, Outcome.done);
    });

    test('is skipped when nothing was ticked', () {
      final state = stateWith(todayActions: [action('m')]);
      expect(state.derivedOutcomeToday, Outcome.skipped);
    });
  });

  group('points', () {
    test('day points are the plain sum of ticked effort', () {
      final state = stateWith(
        todayActions: [
          action('m', effort: 2),
          action('o1', isOptional: true, sort: 1, effort: 3),
        ],
        ticks: const {'m', 'o1'},
      );
      expect(state.todayPoints, 5);
    });

    test('an unticked action earns nothing', () {
      final state = stateWith(
        todayActions: [
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
        todayActions: [action('m', effort: 2)],
        ticks: const {'m'},
        actionsById: {'m': action('m', effort: 2), 'action-1': earlier},
        otherLogs: [
          log(1, Outcome.done, ticks: const {'action-1'}),
        ],
      );

      expect(state.runPoints, 6);
      expect(state.todayPoints, 2, reason: 'today is still only today');
    });

    test('a tick whose action is not cached is skipped, not fatal', () {
      final state = stateWith(
        todayActions: [action('m', effort: 2)],
        ticks: const {'m', 'vanished'},
      );
      expect(state.todayPoints, 2);
    });
  });
}
