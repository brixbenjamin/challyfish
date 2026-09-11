import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/app/balance_summary.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/ui/dashboard/archetype_radar.dart';
import 'package:feral/src/ui/theme/archetype_palette.dart';
import 'package:feral/src/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
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
  allTimePoints: 0,
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

  /// The Text widget whose data is exactly [text], as laid out.
  Text textWidget(WidgetTester tester, String text) =>
      tester.widget<Text>(find.text(text));

  /// The radar's own painter, never a Material internal one.
  Finder figure() => find
      .descendant(
        of: find.byType(ArchetypeRadar),
        matching: find.byType(CustomPaint),
      )
      .last;

  testWidgets('an archetype name is set in that archetype role colour', (
    tester,
  ) async {
    await pump(tester, state(balance: {'a-1': 2.0}));

    const palette = ArchetypePalette.standard;
    for (final archetype in archetypes) {
      expect(
        textWidget(tester, archetype.name).style?.color,
        palette.forSort(archetype.sort),
        reason: 'colour appears only where the drive is named',
      );
    }
  });

  testWidgets('the mark count stays in Muted-ink, never the archetype colour', (
    tester,
  ) async {
    await pump(tester, state(balance: {'a-1': 3.0}, marks: {'a-1': 2}));

    final count = textWidget(tester, l10n.markCount(2));
    expect(count.style?.color, AppTokens.standard.mutedInk);
    expect(
      count.style?.color,
      isNot(ArchetypePalette.standard.forSort(1)),
      reason: 'the record is a panel reading, not a celebration',
    );
  });

  testWidgets(
    'a never-acted radar draws the rings and a centre nub, no shape',
    (tester) async {
      await pump(tester, state());

      expect(
        figure(),
        paintsExactlyCountTimes(#drawPath, 4),
        reason: 'four reference rings and no balance polygon',
      );
      expect(figure(), paintsExactlyCountTimes(#drawCircle, 1));
      expect(
        figure(),
        paints..circle(radius: 2.0, color: AppTokens.standard.mutedInk),
      );
    },
  );

  testWidgets('an axis with activity gets a dot in its role colour', (
    tester,
  ) async {
    await pump(tester, state(balance: {'a-1': 4.0, 'a-3': 1.0}));

    // Two vertex dots, each drawn as a fill plus its Panel-coloured ring.
    expect(figure(), paintsExactlyCountTimes(#drawCircle, 4));
    expect(
      figure(),
      paints..something((symbol, arguments) {
        if (symbol != #drawCircle) return false;
        // Packed ARGB, not Color ==: a Paint stores its colour as floats,
        // and the round trip is not bit-identical to a const Color.
        final paint = arguments.last as Paint;
        return paint.color.toARGB32() ==
            ArchetypePalette.standard.forSort(1).toARGB32();
      }),
    );
  });

  testWidgets(
    'the axes sit at their fixed clock positions, not in sort order',
    (tester) async {
      await pump(tester, state(balance: {'a-1': 2.0, 'a-2': 1.0}));

      final centre = tester.getCenter(find.byType(ArchetypeRadar));
      Offset at(String name) => tester.getCenter(find.text(name));

      // Psycho top, Killer right, Creature bottom, Alchemist left. The two
      // red-side hues are opposite each other, never side by side.
      expect(at('Psycho').dy, lessThan(centre.dy));
      expect(at('Creature').dy, greaterThan(centre.dy));
      expect(at('Killer').dx, greaterThan(centre.dx));
      expect(at('Alchemist').dx, lessThan(centre.dx));

      expect(
        at('Alchemist').dx,
        lessThan(at('Creature').dx),
        reason: 'sort order would have put Alchemist third, at the bottom',
      );
    },
  );

  testWidgets('the figure carries the formatter summary as its label', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    final value = state(balance: {'a-1': 3.0, 'a-3': 1.0}, marks: {'a-1': 2});
    await pump(tester, value);

    expect(find.bySemanticsLabel(balanceSummary(value, l10n)), findsOneWidget);
    handle.dispose();
  });

  testWidgets('the four labels are read in sort order, not clock order', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pump(tester, state(balance: {'a-1': 2.0}));

    double orderOf(String name) {
      final key = tester.getSemantics(find.text(name)).sortKey;
      return (key! as OrdinalSortKey).order;
    }

    // Alchemist sits at 9 o'clock, after Creature at 6, but it is sort 3 and
    // a screen reader hears it third (brief section 4.2).
    expect(orderOf('Psycho'), lessThan(orderOf('Killer')));
    expect(orderOf('Killer'), lessThan(orderOf('Alchemist')));
    expect(orderOf('Alchemist'), lessThan(orderOf('Creature')));
    handle.dispose();
  });

  /// Pumps [first], then rebuilds with [second] at the same size, so the
  /// widget sees a balance change through didUpdateWidget rather than a fresh
  /// mount.
  Future<void> pumpChange(
    WidgetTester tester,
    BalanceState first,
    BalanceState second, {
    bool disableAnimations = false,
  }) async {
    // copyWith off the ambient data, never a bare MediaQueryData: a fresh one
    // inside MaterialApp would drop the view size and lay the radar out at
    // zero.
    Widget tree(BalanceState value) => wrap(
      Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(disableAnimations: disableAnimations),
          child: Scaffold(
            body: Center(child: ArchetypeRadar(state: value)),
          ),
        ),
      ),
    );

    await tester.pumpWidget(tree(first));
    await tester.pumpWidget(tree(second));
  }

  testWidgets('a balance change morphs over the radar motion duration', (
    tester,
  ) async {
    await pumpChange(
      tester,
      state(balance: {'a-1': 4.0}),
      state(balance: {'a-1': 4.0, 'a-4': 4.0}),
    );

    // Mid-flight: the shape is on its way, not yet arrived.
    await tester.pump(const Duration(milliseconds: 100));
    expect(
      tester.hasRunningAnimations,
      isTrue,
      reason: 'the polygon morphs, it never cuts',
    );

    await tester.pump(const Duration(milliseconds: 101));
    expect(tester.hasRunningAnimations, isFalse);
    expect(AppTokens.standard.radarMorph, const Duration(milliseconds: 200));
  });

  testWidgets('the radar never animates on first build', (tester) async {
    await pump(tester, state(balance: {'a-1': 4.0, 'a-2': 2.0}));

    expect(
      tester.hasRunningAnimations,
      isFalse,
      reason: 'no entrance animation, ever',
    );
  });

  testWidgets('a rebuild with the same balance does not animate', (
    tester,
  ) async {
    await pumpChange(
      tester,
      state(balance: {'a-1': 4.0}),
      state(balance: {'a-1': 4.0}),
    );

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('the mark count swaps in only once the shape has arrived', (
    tester,
  ) async {
    await pumpChange(
      tester,
      state(balance: {'a-1': 4.0}, marks: {'a-1': 1}),
      state(balance: {'a-1': 4.0, 'a-4': 4.0}, marks: {'a-1': 1, 'a-4': 1}),
    );

    await tester.pump(const Duration(milliseconds: 100));
    expect(
      find.text(l10n.markCount(1)),
      findsOneWidget,
      reason: 'the new mark has not arrived yet, so it is not announced yet',
    );

    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text(l10n.markCount(1)), findsNWidgets(2));
  });

  testWidgets('with animations disabled the radar snaps and the count swaps', (
    tester,
  ) async {
    await pumpChange(
      tester,
      state(balance: {'a-1': 4.0}, marks: {'a-1': 1}),
      state(balance: {'a-1': 4.0, 'a-4': 4.0}, marks: {'a-1': 1, 'a-4': 1}),
      disableAnimations: true,
    );

    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text(l10n.markCount(1)), findsNWidgets(2));
  });

  /// Pumps the radar under a text scale and an optional archetype name set,
  /// in a fixed viewport so geometry assertions mean something.
  Future<void> pumpScaled(
    WidgetTester tester, {
    double scale = 1,
    List<Archetype> names = archetypes,
  }) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      wrap(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: Scaffold(
              body: Center(
                child: ArchetypeRadar(
                  state: BalanceState(
                    balance: const {'a-1': 3.0, 'a-3': 1.0},
                    marks: const {'a-1': 2},
                    archetypes: names,
                    maxValue: 3,
                    allTimePoints: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('at 200% text the figure gives up radius and nothing clips', (
    tester,
  ) async {
    await pumpScaled(tester);
    final normal = tester.getSize(figure());

    await pumpScaled(tester, scale: 2);
    expect(tester.takeException(), isNull);

    final scaled = tester.getSize(figure());

    expect(
      scaled.width,
      lessThan(normal.width),
      reason: 'the rings and the four labels win; the figure yields radius',
    );

    // The label blocks clear the ring rather than sitting on it.
    final centre = tester.getCenter(find.byType(ArchetypeRadar));
    expect(
      tester.getBottomLeft(find.text('Psycho')).dy,
      lessThan(centre.dy - scaled.width / 2),
    );
    expect(
      tester.getTopLeft(find.text('Creature')).dy,
      greaterThan(centre.dy + scaled.width / 2),
    );
  });

  testWidgets('a long name wraps inside its block instead of pushing layout', (
    tester,
  ) async {
    // Not const: indexing a const list is not a constant expression.
    final long = <Archetype>[
      const Archetype(
        id: 'a-1',
        key: 'first',
        name: 'Extraordinarily Long Archetype Name',
        blurb: 'b',
        color: '#000000',
        sort: 1,
      ),
      archetypes[1],
      archetypes[2],
      archetypes[3],
    ];

    await pumpScaled(tester, names: long);

    expect(tester.takeException(), isNull);
    final centre = tester.getCenter(find.byType(ArchetypeRadar));
    expect(
      tester.getCenter(find.text('Killer')).dx,
      greaterThan(centre.dx),
      reason: 'a long name on one axis does not move the others',
    );
  });

  testWidgets('an unbroken token breaks rather than overflowing', (
    tester,
  ) async {
    final unbroken = <Archetype>[
      const Archetype(
        id: 'a-1',
        key: 'first',
        name: 'Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        blurb: 'b',
        color: '#000000',
        sort: 1,
      ),
      archetypes[1],
      archetypes[2],
      archetypes[3],
    ];

    await pumpScaled(tester, names: unbroken);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a single-character name keeps its block positioned', (
    tester,
  ) async {
    final short = <Archetype>[
      const Archetype(
        id: 'a-1',
        key: 'first',
        name: 'X',
        blurb: 'b',
        color: '#000000',
        sort: 1,
      ),
      archetypes[1],
      archetypes[2],
      archetypes[3],
    ];

    await pumpScaled(tester, names: short);

    final centre = tester.getCenter(find.byType(ArchetypeRadar));
    expect(tester.getCenter(find.text('X')).dy, lessThan(centre.dy));
    expect(tester.takeException(), isNull);
  });
}
