import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/domain/archetype.dart';
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

  const archetypes = [
    Archetype(
      id: 'a-psycho',
      key: 'psycho',
      name: 'Psycho',
      blurb: 'b',
      color: '#000',
      sort: 1,
    ),
    Archetype(
      id: 'a-killer',
      key: 'killer',
      name: 'Killer',
      blurb: 'b',
      color: '#111',
      sort: 2,
    ),
  ];

  final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();

  CampaignRun run(
    String id,
    String campaignId, {
    RunStatus status = RunStatus.completed,
    Grade? grade,
  }) => CampaignRun(
    id: id,
    userId: 'u',
    campaignId: campaignId,
    status: status,
    startedAt: start,
    grade: grade,
  );

  DayLog log(String runId, int day, String actionId, Outcome outcome) => DayLog(
    id: '$runId-$day',
    runId: runId,
    dayIndex: day,
    actionId: actionId,
    outcome: outcome,
  );

  final actions = {
    'act-p': const ActionSpec(
      id: 'act-p',
      campaignId: 'c-1',
      dayIndex: 1,
      title: 't',
      bodyMd: 'b',
      archetypeId: 'a-psycho',
    ),
    'act-k': const ActionSpec(
      id: 'act-k',
      campaignId: 'c-2',
      dayIndex: 1,
      title: 't',
      bodyMd: 'b',
      archetypeId: 'a-killer',
    ),
  };

  BalanceState build({
    required List<CampaignRun> runs,
    required List<DayLog> logs,
    DateTime? now,
  }) => BalanceState.load(
    runs: runs,
    logs: logs,
    actionsById: actions,
    archetypes: archetypes,
    archetypeIdsByCampaign: const {
      'c-1': ['a-psycho'],
      'c-2': ['a-killer'],
    },
    zone: berlin,
    now: now ?? tz.TZDateTime(berlin, 2026, 6, 2, 12).toUtc(),
  );

  test('the balance spans every run, not only the active one', () {
    final state = build(
      runs: [
        run('r1', 'c-1'),
        run('r2', 'c-2', status: RunStatus.active),
      ],
      logs: [
        log('r1', 1, 'act-p', Outcome.done),
        log('r2', 1, 'act-k', Outcome.done),
      ],
    );

    expect(state.balance.keys.toSet(), {'a-psycho', 'a-killer'});
  });

  test('an archetype with no action at all reads zero rather than missing', () {
    // The radar has four fixed axes; a missing key would collapse one.
    final state = build(
      runs: [run('r1', 'c-1')],
      logs: [log('r1', 1, 'act-p', Outcome.done)],
    );
    expect(state.valueFor('a-killer'), 0);
    expect(state.archetypes, hasLength(2));
  });

  test('marks come from completed graded runs and do not decay', () {
    final long = tz.TZDateTime(berlin, 2027, 6, 1, 12).toUtc();
    final state = build(
      runs: [run('r1', 'c-1', grade: Grade.sovereign)],
      logs: [log('r1', 1, 'act-p', Outcome.done)],
      now: long,
    );

    expect(
      state.marks['a-psycho'],
      1,
      reason: 'a mark a year old is still a mark',
    );
    expect(
      state.valueFor('a-psycho'),
      lessThan(0.05),
      reason: 'while the balance contribution has all but gone',
    );
  });

  test(
    'maxValue is the largest axis, and at least one, so the radar is stable',
    () {
      final empty = build(runs: const [], logs: const []);
      expect(empty.maxValue, greaterThanOrEqualTo(1.0));

      final busy = build(
        runs: [run('r1', 'c-1')],
        logs: [
          log('r1', 1, 'act-p', Outcome.done),
          log('r1', 2, 'act-p', Outcome.done),
          log('r1', 3, 'act-p', Outcome.done),
        ],
      );
      expect(busy.maxValue, greaterThan(2.0));
    },
  );

  test('an empty history yields all-zero axes rather than an empty state', () {
    final state = build(runs: const [], logs: const []);
    expect(state.balance, isEmpty);
    expect(state.archetypes, hasLength(2));
    expect(state.valueFor('a-psycho'), 0);
    expect(state.marks, isEmpty);
  });

  test('a Broken run contributes to the balance but earns no mark', () {
    final state = build(
      runs: [run('r1', 'c-1', grade: Grade.broken)],
      logs: [log('r1', 1, 'act-p', Outcome.done)],
    );

    expect(state.valueFor('a-psycho'), greaterThan(0));
    expect(state.marks, isEmpty);
  });
}
