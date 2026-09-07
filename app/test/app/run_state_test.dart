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

  const action = ActionSpec(
    id: 'action-3',
    campaignId: 'campaign-1',
    dayIndex: 3,
    title: 'Do not explain yourself',
    bodyMd: 'body',
    archetypeId: 'arch-killer',
  );

  DayLog log(int day, Outcome? outcome) => DayLog(
    id: 'log-$day',
    runId: 'run-1',
    dayIndex: day,
    actionId: 'action-$day',
    outcome: outcome,
  );

  RunState stateOn(DateTime now, List<DayLog> logs) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: logs,
    todayAction: action,
    zone: berlin,
    now: now,
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
}
