import 'dart:io';

import 'package:feral/src/dev/balance_playground.dart';
import 'package:feral/src/dev/balance_presets.dart';
import 'package:feral/src/dev/balance_scenario.dart';
import 'package:feral/src/engine/balance.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;

import '../support/pump.dart';

/// Drives the debug bench headlessly.
///
/// The point is not to test the playground's chrome. It is to pin the numbers
/// the playground exists to show, so that reading a value off the screen and
/// trusting it is a thing CI has checked. Every assertion here is a claim about
/// the engine, reached through the same buttons a human would press.
void main() {
  setUpAll(tzdata.initializeTimeZones);

  const first = 'd-1';
  const second = 'd-2';

  /// A surface tall enough that every control is built without scrolling.
  /// The readout is pinned and would be reachable either way; this is only so
  /// `find.byKey` reaches a button near the bottom of the list.
  Future<void> open(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrap(const BalancePlayground()));
    await tester.pumpAndSettle();
  }

  /// Reads a number back off the readout, which is the only place the
  /// playground states one.
  double read(WidgetTester tester, String key) {
    final text = tester.widget<Text>(find.byKey(ValueKey(key))).data!;
    return double.parse(text);
  }

  Future<void> tap(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(ValueKey(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('an act contributes its effort divided by a full day', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'tick');

    // Effort 3 of a 5-point day. Ticked today, so no decay has been applied.
    expect(read(tester, 'balance-$first'), closeTo(3 / 5, 1e-9));
    expect(read(tester, 'balance-$second'), 0);
  });

  testWidgets('a second act on the same day stacks before the cap', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'tick');
    await tap(tester, 'tick');

    // 3 + 3 = 6 effort, capped at pointsPerFullDay = 5. Were the cap applied
    // per action instead of per day, this would read 1.2.
    expect(read(tester, 'balance-$first'), closeTo(1, 1e-9));
  });

  testWidgets('the day cap holds however much is ticked into one drive', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'preset-Cap buster');

    // 2 + 4 + 4 = 10 effort in one day, worth exactly one day.
    expect(read(tester, 'balance-$first'), closeTo(1, 1e-9));
    // The points the user is shown are the undivided, uncapped total: the cap
    // is the radar's rule, not the scoreboard's.
    expect(find.text('10'), findsOneWidget);
  });

  testWidgets('one day can move more than one axis', (tester) async {
    await open(tester);
    await tap(tester, 'tick');
    await tap(tester, 'pick-$second');
    await tap(tester, 'tick');

    // Same day, two drives: each gets its own capped contribution.
    expect(read(tester, 'balance-$first'), closeTo(3 / 5, 1e-9));
    expect(read(tester, 'balance-$second'), closeTo(3 / 5, 1e-9));
  });

  testWidgets('advancing one half-life halves the contribution', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'tick');
    final before = read(tester, 'balance-$first');

    await tap(tester, 'advance-60');

    expect(read(tester, 'balance-$first'), closeTo(before / 2, 1e-9));

    await tap(tester, 'advance-60');
    expect(read(tester, 'balance-$first'), closeTo(before / 4, 1e-9));
  });

  testWidgets('decay never touches the permanent points total', (tester) async {
    await open(tester);
    await tap(tester, 'tick');
    await tap(tester, 'advance-60');
    await tap(tester, 'advance-60');

    // The radar has fallen to a quarter; the record of what was done has not
    // moved at all (ADR-0010's mitigation).
    expect(find.text('3'), findsWidgets);
    expect(
      tester.widget<Text>(find.byKey(const ValueKey('stat-all-time points'))).data,
      '3',
    );
  });

  testWidgets('the full-axis ceiling is derived from the half-life', (
    tester,
  ) async {
    await open(tester);

    expect(
      read(tester, 'stat-full axis (maxValue)'),
      closeTo(BalanceWeights.standard.fullAxisValue, 1e-4),
    );

    // Drag the half-life to its minimum of one day. The ceiling must follow:
    // it is the sum of that decay curve, not an independent number.
    await tester.drag(find.byKey(const ValueKey('half-life')), const Offset(-800, 0));
    await tester.pumpAndSettle();

    expect(
      read(tester, 'stat-full axis (maxValue)'),
      closeTo(const BalanceWeights(halfLifeDays: 1).fullAxisValue, 1e-4),
    );
    // A one-day half-life sums to 1 + 1/2 + 1/4 + ... = 2.
    expect(read(tester, 'stat-full axis (maxValue)'), closeTo(2, 1e-4));
  });

  testWidgets('a year at the cap approaches the ceiling without reaching it', (
    tester,
  ) async {
    await open(tester);
    await tap(tester, 'preset-Full axis');

    final normalized = read(tester, 'norm-$first');
    expect(normalized, greaterThan(0.98));
    expect(normalized, lessThan(1));
  });

  testWidgets('reset empties the world but keeps the weights', (tester) async {
    await open(tester);
    await tap(tester, 'preset-Even four');
    expect(read(tester, 'balance-$second'), greaterThan(0));

    await tap(tester, 'reset');

    expect(read(tester, 'balance-$first'), 0);
    expect(read(tester, 'balance-$second'), 0);
    expect(
      read(tester, 'stat-full axis (maxValue)'),
      closeTo(BalanceWeights.standard.fullAxisValue, 1e-4),
    );
  });

  testWidgets('the figure stays put while the controls scroll', (
    tester,
  ) async {
    // A phone-sized surface on purpose: the pinning only means anything when
    // the controls genuinely do not fit beside the figure.
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(wrap(const BalancePlayground()));
    await tester.pumpAndSettle();

    final figure = find.byKey(const ValueKey('balance-$first'));
    final top = tester.getTopLeft(figure).dy;

    await tester.drag(find.byType(ListView), const Offset(0, -400));
    await tester.pumpAndSettle();

    // Same widget, same place: the controls moved under it, it did not move.
    expect(figure, findsOneWidget);
    expect(tester.getTopLeft(figure).dy, top);
  });

  /// The one rule that keeps a debug bench from becoming a liability: it must
  /// stay unreachable from the app. Not a convention — something CI checks,
  /// because the cost of getting it wrong is debug controls in a release build.
  test('nothing the app can launch imports the playground', () {
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()) {
      if (!file.path.endsWith('.dart')) continue;
      if (file.path.startsWith('lib/src/dev/')) continue;
      if (file.path == 'lib/dev_main.dart') continue;
      if (file.readAsStringSync().contains('src/dev/')) {
        offenders.add(file.path);
      }
    }

    expect(
      offenders,
      isEmpty,
      reason:
          'The balance playground is reachable only from lib/dev_main.dart.\n'
          'These would carry it into the shipped app:\n'
          '${offenders.join('\n')}',
    );
  });

  group('the scenario computes nothing of its own', () {
    test('normalised values clamp rather than overflow the ring', () {
      // Not reachable through the buttons — the ceiling is an asymptote — so
      // it is asserted here, where a scenario can be built past it directly.
      final scenario = BalanceScenario(
        archetypes: devArchetypes,
        weights: const BalanceWeights(halfLifeDays: 1),
      );
      var packed = scenario;
      for (var day = 1; day <= 3; day++) {
        packed = packed.tick(devArchetypes.first.id, [5], dayIndex: day);
      }
      final state = packed.advance(2).resolve();

      expect(state.normalizedFor(devArchetypes.first.id), lessThanOrEqualTo(1));
      expect(state.maxValue, closeTo(2, 1e-9));
    });

    test('every preset resolves through the real engine', () {
      for (final preset in BalancePreset.all) {
        final state = preset.build(devArchetypes).resolve();
        expect(state.archetypes, hasLength(4));
        expect(state.maxValue, BalanceWeights.standard.fullAxisValue);
      }
    });
  });
}
