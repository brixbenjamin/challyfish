import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/app/balance_summary.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

const archetypes = [
  Archetype(
    id: 'a-1',
    key: 'first',
    name: 'First',
    blurb: 'b',
    color: '#000000',
    sort: 1,
  ),
  Archetype(
    id: 'a-2',
    key: 'second',
    name: 'Second',
    blurb: 'b',
    color: '#000000',
    sort: 2,
  ),
  Archetype(
    id: 'a-3',
    key: 'third',
    name: 'Third',
    blurb: 'b',
    color: '#000000',
    sort: 3,
  ),
  Archetype(
    id: 'a-4',
    key: 'fourth',
    name: 'Fourth',
    blurb: 'b',
    color: '#000000',
    sort: 4,
  ),
];

/// Values here are already normalised: maxValue 1 makes normalizedFor the
/// identity, so a threshold test states the threshold it is testing.
BalanceState state({
  Map<String, double> balance = const {},
  Map<String, int> marks = const {},
}) => BalanceState(
  balance: balance,
  marks: marks,
  archetypes: archetypes,
  maxValue: 1,
  allTimePoints: 0,
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  test('a state with no activity at all says nothing is recorded', () {
    expect(balanceSummary(state(), l10n), l10n.radarSummaryEmpty);
  });

  test('band thresholds land exactly where the figure draws them', () {
    // A second live axis keeps the summary out of its empty state, so the
    // band for a zeroed axis is still something the sentence says out loud.
    String bandOf(double value) {
      final summary = balanceSummary(
        state(balance: {'a-1': value, 'a-2': 1}),
        l10n,
      );
      for (final band in [
        l10n.radarBandHigh,
        l10n.radarBandMedium,
        l10n.radarBandLow,
        l10n.radarBandNone,
      ]) {
        if (summary.contains(l10n.radarAxisBand('First', band))) return band;
      }
      return '<none matched>';
    }

    expect(bandOf(0), l10n.radarBandNone);
    expect(bandOf(0.33), l10n.radarBandLow);
    expect(bandOf(0.339), l10n.radarBandLow);
    expect(bandOf(0.34), l10n.radarBandMedium);
    expect(bandOf(0.66), l10n.radarBandMedium);
    expect(bandOf(0.67), l10n.radarBandHigh);
    expect(bandOf(1), l10n.radarBandHigh);
  });

  test('the distribution is read in sort order, not by value', () {
    final summary = balanceSummary(
      state(balance: {'a-1': 0.1, 'a-2': 0.9, 'a-3': 0.5, 'a-4': 0.7}),
      l10n,
    );

    final positions = [
      for (final name in ['First', 'Second', 'Third', 'Fourth'])
        summary.indexOf(name),
    ];

    expect(positions.every((p) => p >= 0), isTrue);
    for (var i = 1; i < positions.length; i++) {
      expect(
        positions[i],
        greaterThan(positions[i - 1]),
        reason: 'the screen reader hears the four axes in sort order',
      );
    }
  });

  test('an axis with activity but no mark says nothing about marks', () {
    final summary = balanceSummary(state(balance: {'a-1': 0.5}), l10n);
    expect(summary, contains(l10n.radarMarks(0, '')));
  });

  test('one mark and several marks both read', () {
    final one = balanceSummary(
      state(balance: {'a-1': 0.5}, marks: {'a-1': 1}),
      l10n,
    );
    expect(one, contains(l10n.radarMarkEntry('First', 1)));

    final many = balanceSummary(
      state(balance: {'a-1': 0.5, 'a-3': 0.8}, marks: {'a-1': 2, 'a-3': 1}),
      l10n,
    );
    expect(many, contains(l10n.radarMarkEntry('First', 2)));
    expect(many, contains(l10n.radarMarkEntry('Third', 1)));
    expect(
      many.indexOf('First'),
      lessThan(many.lastIndexOf('Third')),
      reason: 'marks are listed in sort order too',
    );
  });

  test('marks on a never-acted radar do not resurrect the empty state', () {
    // Marks are permanent; the balance decays to nothing. The empty string is
    // about the distribution, and it must still be what a reader hears.
    expect(
      balanceSummary(state(marks: {'a-1': 3}), l10n),
      l10n.radarSummaryEmpty,
    );
  });

  test('the summary never frames the decay as a loss', () {
    final summary = balanceSummary(
      state(balance: {'a-1': 0.2, 'a-2': 0.9}, marks: {'a-2': 1}),
      l10n,
    );

    for (final banned in ['lost', 'losing', 'decay', 'fading', 'expired']) {
      expect(summary.toLowerCase(), isNot(contains(banned)));
    }
  });
}
