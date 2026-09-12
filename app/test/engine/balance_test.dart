import 'dart:math' as math;

import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/engine/balance.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

ActionSpec action(String id, String archetypeId, {int effort = 1}) =>
    ActionSpec(
      id: id,
      campaignId: 'campaign-1',
      dayIndex: 1,
      title: 'do the thing',
      bodyMd: 'body',
      archetypeId: archetypeId,
      effort: effort,
    );

/// Ticks default from the outcome, because that is exactly what the migration
/// backfill does to every day recorded before ADR-0030.
DayLog log(int day, String actionId, Outcome? outcome, {Set<String>? ticks}) =>
    DayLog(
      id: 'log-$day',
      runId: 'run-1',
      dayIndex: day,
      actionId: actionId,
      outcome: outcome,
      completedActionIds:
          ticks ??
          (outcome == Outcome.done || outcome == Outcome.partial
              ? {actionId}
              : const {}),
    );

void main() {
  tzdata.initializeTimeZones();

  const calculator = BalanceCalculator();
  final berlin = tz.getLocation('Europe/Berlin');

  // Invented keys, not the product's four. The balance calculator groups by
  // whatever archetype key an action carries and has no opinion about which keys
  // exist — writing the tests against 'psycho' and 'killer' would hide the day
  // that stopped being true. This is the cheap half of ADR-0021: the engine's
  // independence from the taxonomy is asserted here rather than asserted in a
  // document.
  final actions = {
    'a-axis-a': action('a-axis-a', 'axis-a'),
    'a-axis-b': action('a-axis-b', 'axis-b'),
    'a-heavy': action('a-heavy', 'axis-b', effort: 3),
    'a-full': action('a-full', 'axis-a', effort: 5),
  };

  final runStart = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
  final starts = {'run-1': runStart};

  /// `now` set to `daysAfterStart` local days after the run began.
  DateTime nowPlus(int daysAfterStart) =>
      tz.TZDateTime(berlin, 2026, 6, 1 + daysAfterStart, 12).toUtc();

  Map<String, double> balanceAt(int daysAfterStart, List<DayLog> logs) =>
      calculator.compute(
        logs: logs,
        actionsById: actions,
        runStartedAt: starts,
        zone: berlin,
        now: nowPlus(daysAfterStart),
      );

  test('a day acted today counts its full weight', () {
    final result = balanceAt(0, [log(1, 'a-axis-a', Outcome.done)]);
    expect(result['axis-a'], closeTo(1 / 5, 1e-9));
  });

  test('a day exactly one half-life old counts half', () {
    // Day 1 of the run, evaluated 60 local days later.
    final result = balanceAt(60, [log(1, 'a-axis-a', Outcome.done)]);
    expect(result['axis-a'], closeTo(0.5 / 5, 1e-9));
  });

  test('two half-lives is a quarter', () {
    final result = balanceAt(120, [log(1, 'a-axis-a', Outcome.done)]);
    expect(result['axis-a'], closeTo(0.25 / 5, 1e-9));
  });

  test('partial counts the same as done', () {
    final a = balanceAt(0, [log(1, 'a-axis-a', Outcome.done)]);
    final b = balanceAt(0, [log(1, 'a-axis-a', Outcome.partial)]);
    expect(b['axis-a'], closeTo(a['axis-a']!, 1e-9));
  });

  test('skipped, missed and unreported days count for nothing', () {
    final result = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.skipped),
      log(2, 'a-axis-a', Outcome.missed),
      log(3, 'a-axis-a', null),
    ]);
    expect(result['axis-a'], isNull);
  });

  test('a heavier action moves its axis further than a lighter one', () {
    // ADR-0030 reversed ADR-0010's "effort is not used", which this file
    // previously asserted. Effort is the points value now, and it weights the
    // contribution.
    final heavy = balanceAt(0, [log(1, 'a-heavy', Outcome.done)]);
    final light = balanceAt(0, [log(1, 'a-axis-b', Outcome.done)]);
    expect(heavy['axis-b']! / light['axis-b']!, closeTo(3.0, 1e-9));
  });

  test('a full day of effort contributes about one', () {
    // pointsPerFullDay is 5, so a single 5-effort day lands at 1.0.
    final balance = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.done, ticks: const {'a-full'}),
    ]);
    expect(balance['axis-a'], closeTo(1.0, 1e-9));
  });

  test('the day cap holds even when several ticks stack the same axis', () {
    // 'a-full' (5) plus 'a-axis-a' (1) is 6 effort in axis-a on one day —
    // more than pointsPerFullDay. The cap clamps it to the same contribution
    // as a single 5-effort day, not 6/5.
    final stacked = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.done, ticks: const {'a-full', 'a-axis-a'}),
    ]);
    final single = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.done, ticks: const {'a-full'}),
    ]);
    expect(stacked['axis-a'], closeTo(single['axis-a']!, 1e-9));
    expect(stacked['axis-a'], closeTo(1.0, 1e-9));
  });

  test('the day cap is per archetype, not per day', () {
    // 'a-full' (axis-a, 5) and 'a-heavy' (axis-b, 3) ticked the same day: each
    // archetype gets its own cap, so axis-b is not throttled by axis-a's take.
    final balance = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.done, ticks: const {'a-full', 'a-heavy'}),
    ]);
    expect(balance['axis-a'], closeTo(1.0, 1e-9));
    expect(balance['axis-b'], closeTo(3 / 5, 1e-9));
  });

  test('one day moves several axes', () {
    // The property ADR-0030 was built for: the radar is fed by what the user
    // did, not by what the day was labelled.
    final balance = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.done, ticks: const {'a-axis-a', 'a-axis-b'}),
    ]);
    expect(balance['axis-a'], greaterThan(0));
    expect(balance['axis-b'], greaterThan(0));
  });
  test('test proper calc', () {
    final balance = balanceAt(33, [
      log(1, 'a-axis-a', Outcome.done, ticks: const {'a-axis-a', 'a-axis-b'}),
      log(2, 'a-axis-a', Outcome.done, ticks: const {'a-axis-a', 'a-axis-b'}),
      log(3, 'a-axis-a', Outcome.done, ticks: const {'a-axis-a', 'a-axis-b'}),
      log(3, 'a-axis-a', Outcome.done, ticks: const {'a-axis-a', 'a-axis-b'}),
      log(4, 'a-axis-a', Outcome.missed, ticks: const {'a-axis-a'}),
      log(32, 'a-axis-a', Outcome.done, ticks: const {'a-axis-a'}),
    ]);
    expect(balance['axis-a'], greaterThan(0));
    expect(balance['axis-b'], greaterThan(0));
  });

  test('an unticked day contributes nothing', () {
    final balance = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.skipped, ticks: const {}),
    ]);
    expect(balance, isEmpty);
  });

  test('the points scale is injectable, like the half-life', () {
    final result = calculator.compute(
      logs: [log(1, 'a-full', Outcome.done)],
      actionsById: actions,
      runStartedAt: starts,
      zone: berlin,
      now: nowPlus(0),
      weights: const BalanceWeights(pointsPerFullDay: 10),
    );
    expect(result['axis-a'], closeTo(0.5, 1e-9));
  });

  test('recent action outweighs old action in the same archetype', () {
    // One day acted 100 days ago, one acted today.
    final result = balanceAt(100, [
      log(1, 'a-axis-a', Outcome.done),
      log(101, 'a-axis-b', Outcome.done),
    ]);
    expect(result['axis-b']! > result['axis-a']!, isTrue);
  });

  test('a user who stops sees the balance fall, which is the design', () {
    final logs = [log(1, 'a-axis-a', Outcome.done)];
    final fresh = balanceAt(0, logs)['axis-a']!;
    final stale = balanceAt(180, logs)['axis-a']!;
    expect(stale < fresh, isTrue);
    expect(stale, lessThan(0.15 / 5));
  });

  test(
    'a log whose action is missing from the cache is skipped, not fatal',
    () {
      // Content can lag behind progress after a partial sync. Losing the
      // contribution is acceptable; crashing the dashboard is not.
      final result = balanceAt(0, [
        log(1, 'a-unknown', Outcome.done),
        log(2, 'a-axis-a', Outcome.done),
      ]);
      expect(result.keys, ['axis-a']);
    },
  );

  test('a log whose run start is unknown is skipped, not fatal', () {
    final result = calculator.compute(
      logs: [
        DayLog(
          id: 'x',
          runId: 'run-missing',
          dayIndex: 1,
          actionId: 'a-axis-a',
          outcome: Outcome.done,
          completedActionIds: const {'a-axis-a'},
        ),
      ],
      actionsById: actions,
      runStartedAt: starts,
      zone: berlin,
      now: nowPlus(0),
    );
    expect(result, isEmpty);
  });

  test('days from a Broken run still count — effort is never erased', () {
    final result = balanceAt(0, [
      log(1, 'a-axis-a', Outcome.done),
      log(2, 'a-axis-b', Outcome.done),
      log(3, 'a-axis-a', Outcome.missed),
      log(4, 'a-axis-a', Outcome.missed),
      log(5, 'a-axis-a', Outcome.skipped),
    ]);
    expect(result.keys.toSet(), {'axis-a', 'axis-b'});
  });

  test('a future-dated log is never amplified above full weight', () {
    // Clock skew or travel can put a log a day ahead. It must not count double.
    final result = balanceAt(0, [log(5, 'a-axis-a', Outcome.done)]);
    expect(result['axis-a'], closeTo(1 / 5, 1e-9));
  });

  test('no logs produce an empty balance, not a crash', () {
    expect(balanceAt(0, const []), isEmpty);
  });

  test('fullAxisValue is the closed-form asymptote of the decay curve', () {
    // sum(0.5^(k/halfLifeDays)) for k from 0 to infinity has closed form
    // 1 / (1 - 0.5^(1/halfLifeDays)) — verify it against a large finite sum
    // rather than trusting the same formula twice.
    const weights = BalanceWeights(halfLifeDays: 60);
    var approx = 0.0;
    for (var k = 0; k < 100000; k++) {
      approx += math.pow(0.5, k / 60);
    }
    expect(weights.fullAxisValue, closeTo(approx, 1e-6));
  });

  test('fullAxisValue rises with a longer half-life', () {
    const shorter = BalanceWeights(halfLifeDays: 30);
    const longer = BalanceWeights(halfLifeDays: 60);
    expect(longer.fullAxisValue, greaterThan(shorter.fullAxisValue));
  });

  test('the half-life is injectable', () {
    final result = calculator.compute(
      logs: [log(1, 'a-axis-a', Outcome.done)],
      actionsById: actions,
      runStartedAt: starts,
      zone: berlin,
      now: nowPlus(30),
      weights: const BalanceWeights(halfLifeDays: 30),
    );
    expect(result['axis-a'], closeTo(0.5 / 5, 1e-9));
  });
}
