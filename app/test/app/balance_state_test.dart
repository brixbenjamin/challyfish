import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:feral/src/engine/balance.dart';
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
    completedActionIds: outcome == Outcome.done || outcome == Outcome.partial
        ? {actionId}
        : const {},
  );

  final actions = {
    'act-p': const ActionSpec(
      id: 'act-p',
      dayId: 'day-c1-1',
      title: 't',
      bodyMd: 'b',
      archetypeWeights: {'a-psycho': 1.0},
    ),
    'act-p-high': const ActionSpec(
      id: 'act-p',
      dayId: 'day-c1-1',
      title: 't',
      bodyMd: 'b',
      archetypeWeights: {'a-psycho': 1.0},
    ),
    'act-k': const ActionSpec(
      id: 'act-k',
      dayId: 'day-c2-1',
      title: 't',
      bodyMd: 'b',
      archetypeWeights: {'a-killer': 1.0},
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
    'maxValue is the fixed full-axis ceiling, independent of the record',
    () {
      // Same ceiling whether the record is empty, thin, or busy — it comes
      // from BalanceWeights.fullAxisValue, not from any archetype's own
      // value. Peer-relative normalization is exactly the bug this replaced:
      // it always pinned whichever axis was currently highest to the rim.
      final empty = build(runs: const [], logs: const []);
      final thin = build(
        runs: [run('r1', 'c-1')],
        logs: [
          log('r1', 1, 'act-p', Outcome.done),
          log('r1', 2, 'act-p', Outcome.done),
          log('r1', 3, 'act-p', Outcome.done),
        ],
      );
      final busy = build(
        runs: [run('r1', 'c-1')],
        logs: [
          for (var day = 1; day <= 15; day++)
            log('r1', day, 'act-p', Outcome.done),
        ],
      );

      expect(empty.maxValue, BalanceWeights.standard.fullAxisValue);
      expect(thin.maxValue, empty.maxValue);
      expect(busy.maxValue, empty.maxValue);

      // A real run's worth of effort still reads as a small fraction of that
      // ceiling — not near the rim, because the ceiling represents hitting
      // the day cap in this drive every day, indefinitely.
      expect(busy.valueFor('a-psycho'), greaterThan(2.0));
      expect(busy.normalizedFor('a-psycho'), lessThan(0.2));
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

  group('allTimePoints', () {
    test('sums every point ever earned, undecayed', () {
      final runs = [run('r-1', 'c-1')];
      final logs = [
        log('r-1', 1, 'act-p', Outcome.done),
        log('r-1', 2, 'act-k', Outcome.done),
      ];

      // Every seeded action is effort 1 until Q18 is answered, so two ticked
      // days are two points.
      expect(build(runs: runs, logs: logs).allTimePoints, 2);
    });

    test('does not fall when the radar does', () {
      // The whole reason ADR-0029 permitted this figure: it stays a true
      // statement about what the user did however long they stay away. If
      // this ever starts decaying it has become a streak with extra steps.
      final runs = [run('r-1', 'c-1')];
      final logs = [log('r-1', 1, 'act-p', Outcome.done)];

      final fresh = build(runs: runs, logs: logs);
      final stale = build(
        runs: runs,
        logs: logs,
        now: tz.TZDateTime(berlin, 2027, 6, 2, 12).toUtc(),
      );

      expect(stale.valueFor('a-psycho'), lessThan(fresh.valueFor('a-psycho')));
      expect(stale.allTimePoints, fresh.allTimePoints);
      expect(stale.allTimePoints, 1);
    });

    test('a skipped day earns nothing', () {
      expect(
        build(
          runs: [run('r-1', 'c-1')],
          logs: [log('r-1', 1, 'act-p', Outcome.skipped)],
        ).allTimePoints,
        0,
      );
    });
  });
}
