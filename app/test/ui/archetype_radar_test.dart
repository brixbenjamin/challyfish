import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/ui/dashboard/archetype_radar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const archetypes = [
  Archetype(
    id: 'a-1',
    key: 'psycho',
    name: 'Psycho',
    blurb: 'b',
    color: '#B23A48',
    sort: 1,
  ),
  Archetype(
    id: 'a-2',
    key: 'killer',
    name: 'Killer',
    blurb: 'b',
    color: '#2E4057',
    sort: 2,
  ),
  Archetype(
    id: 'a-3',
    key: 'alchemist',
    name: 'Alchemist',
    blurb: 'b',
    color: '#C98C1E',
    sort: 3,
  ),
  Archetype(
    id: 'a-4',
    key: 'creature',
    name: 'Creature',
    blurb: 'b',
    color: '#4A7C59',
    sort: 4,
  ),
];

BalanceState state({
  Map<String, double> balance = const {},
  Map<String, int> marks = const {},
}) => BalanceState(
  balance: balance,
  marks: marks,
  archetypes: archetypes,
  maxValue: balance.values.isEmpty
      ? 1
      : balance.values
            .reduce((a, b) => a > b ? a : b)
            .clamp(1, double.infinity),
);

Future<void> pump(WidgetTester tester, BalanceState value) => tester.pumpWidget(
  wrap(
    Scaffold(
      body: Center(child: ArchetypeRadar(state: value)),
    ),
  ),
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('draws all four axes even with no data at all', (tester) async {
    await pump(tester, state());

    for (final archetype in archetypes) {
      expect(find.text(archetype.name), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders with a single day of data without dividing by zero', (
    tester,
  ) async {
    await pump(tester, state(balance: {'a-1': 1.0}));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows the mark count beside an archetype that has one', (
    tester,
  ) async {
    await pump(tester, state(balance: {'a-1': 3.0}, marks: {'a-1': 2}));
    expect(find.text(l10n.markCount(2)), findsOneWidget);
  });

  testWidgets('shows a singular mark correctly', (tester) async {
    await pump(tester, state(marks: {'a-1': 1}));
    expect(find.text(l10n.markCount(1)), findsOneWidget);
    expect(
      l10n.markCount(1),
      isNot(l10n.markCount(2)),
      reason: 'a real plural, not one string with a number in it',
    );
  });

  testWidgets('never frames the balance as something being lost', (
    tester,
  ) async {
    // ADR-0010: the decay is never a countdown, a warning, or a loss.
    await pump(tester, state(balance: {'a-1': 0.2, 'a-2': 4.0}));

    for (final banned in [
      'down',
      'lost',
      'losing',
      'decay',
      'fading',
      'expired',
    ]) {
      expect(
        find.textContaining(banned, findRichText: true),
        findsNothing,
        reason: 'the radar must not frame decay as loss',
      );
    }
    expect(find.byIcon(Icons.arrow_downward), findsNothing);
    expect(find.byIcon(Icons.trending_down), findsNothing);
  });
}
