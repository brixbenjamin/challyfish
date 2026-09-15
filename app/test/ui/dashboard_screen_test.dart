import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/app/run_state.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day.dart';
import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:feral/src/ui/dashboard/archetype_radar.dart';
import 'package:feral/src/ui/dashboard/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../support/pump.dart';

void main() {
  // `berlin` below is resolved at declaration time, before any setUpAll
  // callback runs — so the database must be loaded synchronously here rather
  // than deferred to setUpAll.
  tzdata.initializeTimeZones();

  final berlin = tz.getLocation('Europe/Berlin');

  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

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
    startedAt: tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc(),
  );

  const action = ActionSpec(
    id: 'action-3',
    dayId: 'day-3',
    title: 'Do not explain yourself',
    bodyMd: 'Say no once today, and stop talking after you have said it.',
    archetypeWeights: {'arch-killer': 1.0},
  );

  const optional = ActionSpec(
    id: 'optional-3',
    dayId: 'day-3',
    title: 'An optional act',
    bodyMd: 'Something extra, if there is appetite for it.',
    archetypeWeights: {'arch-killer': 1.0},
    effort: 2,
    isOptional: true,
    sort: 1,
  );

  const day = DaySpec(
    id: 'day-3',
    campaignId: 'campaign-1',
    dayIndex: 3,
    title: 'The day you stop hedging',
    bodyMd:
        'Say the thing once, in the fewest words that carry it, and let it stand.',
    actions: [action],
  );

  const dayWithOptional = DaySpec(
    id: 'day-3',
    campaignId: 'campaign-1',
    dayIndex: 3,
    title: 'The day you stop hedging',
    bodyMd:
        'Say the thing once, in the fewest words that carry it, and let it stand.',
    actions: [action, optional],
  );

  RunState state({List<DayLog> logs = const [], DaySpec? today = day}) =>
      RunState.derive(
        run: run,
        campaign: campaign,
        logs: logs,
        today: today,
        actionsById: {
          for (final a in today?.actions ?? const <ActionSpec>[]) a.id: a,
        },
        zone: berlin,
        now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
      );

  /// Day 3's log, carrying whatever ticks and outcome a case needs.
  ///
  /// Always committed. Since the reveal-on-commit split there is no path that
  /// ticks or reports a day that was never accepted: the actions do not exist
  /// on screen until the commit reveals them.
  DayLog dayLog({Outcome? outcome, Set<String> ticks = const {}}) => DayLog(
    id: 'l3',
    runId: 'run-1',
    dayIndex: 3,
    actionId: 'action-3',
    committedAt: tz.TZDateTime(berlin, 2026, 6, 3, 8).toUtc(),
    outcome: outcome,
    completedActionIds: ticks,
  );

  /// Day 3, already accepted. This is the state every checklist assertion
  /// needs: before the commit there is no checklist.
  RunState committed({
    Outcome? outcome,
    Set<String> ticks = const {},
    DaySpec today = dayWithOptional,
  }) => state(
    logs: [dayLog(outcome: outcome, ticks: ticks)],
    today: today,
  );

  const archetypes = [
    Archetype(
      id: 'arch-killer',
      key: 'killer',
      name: 'Killer',
      blurb: 'b',
      color: '#2E4057',
      sort: 1,
    ),
  ];

  const balance = BalanceState(
    balance: {},
    marks: {},
    archetypes: archetypes,
    maxValue: 1,
    allTimePoints: 0,
  );

  Future<void> pumpWith(
    WidgetTester tester,
    RunState value, {
    void Function(String?)? onReport,
    void Function(String, bool)? onToggleAction,
    double textScale = 1.0,
  }) => tester.pumpWidget(
    wrap(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
        child: DashboardScreen(
          state: value,
          balance: balance,
          onCommit: () {},
          onReport: onReport ?? (_) {},
          onToggleAction: onToggleAction ?? (_, _) {},
          onOpenDoctrine: () {},
          onOpenSettings: () {},
        ),
      ),
    ),
  );

  Future<void> pump(WidgetTester tester, RunState value) =>
      pumpWith(tester, value);

  RunState withOptionals() => state(today: dayWithOptional);

  testWidgets('shows the day, the action, and the miss count', (tester) async {
    await pump(
      tester,
      state(
        logs: [
          dayLog(),
          DayLog(
            id: 'l1',
            runId: 'run-1',
            dayIndex: 1,
            actionId: 'a1',
            outcome: Outcome.skipped,
          ),
        ],
        today: dayWithOptional,
      ),
    );

    expect(find.text('Day 3 of 7'), findsOneWidget);
    expect(find.text('Do not explain yourself'), findsOneWidget);
    // The allowance differs per campaign, so the screen states it rather than
    // leaving the user to know it (ADR-0012). A 7-day campaign allows one.
    expect(find.text('1 of 1 misses used'), findsOneWidget);
  });

  testWidgets('offers commit before the day is committed', (tester) async {
    await pump(tester, state());
    expect(find.text('Commit'), findsOneWidget);
  });

  testWidgets('missing content shows a recoverable state, not a crash', (
    tester,
  ) async {
    await pump(tester, state(today: null));
    expect(find.textContaining('Content unavailable'), findsOneWidget);
  });

  testWidgets('there is no streak counter anywhere', (tester) async {
    await pump(tester, withOptionals());
    expect(find.textContaining('streak', findRichText: true), findsNothing);
  });

  testWidgets('a longer campaign shows its larger allowance', (tester) async {
    const long = Campaign(
      id: 'campaign-2',
      packId: 'pack-1',
      key: 'thirty',
      title: 'Thirty Days',
      introMd: 'i',
      lengthDays: 30,
    );

    await pump(
      tester,
      RunState.derive(
        run: CampaignRun(
          id: 'run-2',
          userId: 'user-1',
          campaignId: 'campaign-2',
          status: RunStatus.active,
          startedAt: tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc(),
        ),
        campaign: long,
        logs: const [],
        today: day,
        zone: berlin,
        now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
      ),
    );

    expect(find.text('0 of 3 misses used'), findsOneWidget);
  });

  testWidgets('the radar is below the action, never above it', (tester) async {
    await pump(tester, committed());

    final actionY = tester.getTopLeft(find.text('Do not explain yourself')).dy;
    final radarY = tester.getTopLeft(find.byType(ArchetypeRadar)).dy;
    expect(
      actionY < radarY,
      isTrue,
      reason: "the screen answers today's question first",
    );
  });

  testWidgets('no discouraging copy attaches to skipping', (tester) async {
    await pump(tester, withOptionals());
    for (final banned in ['Are you sure', 'really', 'give up', 'failed']) {
      expect(find.textContaining(banned, findRichText: true), findsNothing);
    }
  });

  group('the checklist', () {
    testWidgets('optional actions render beneath the mandatory one', (
      tester,
    ) async {
      await pump(tester, committed());

      final mandatory = tester.getTopLeft(find.text('Do not explain yourself'));
      final extra = tester.getTopLeft(find.text('An optional act'));
      expect(extra.dy, greaterThan(mandatory.dy));
    });

    testWidgets('the mandatory action keeps its body copy inline', (
      tester,
    ) async {
      await pump(tester, committed());

      expect(find.text(action.bodyMd!), findsOneWidget);
      expect(
        find.text(optional.bodyMd!),
        findsNothing,
        reason: 'an optional row is compact; its copy expands on tap',
      );
    });

    testWidgets(
      'the mandatory action outweighs the optionals typographically',
      (tester) async {
        await pump(tester, committed());

        final mandatory = tester.widget<Text>(
          find.text('Do not explain yourself'),
        );
        final extra = tester.widget<Text>(find.text('An optional act'));
        final context = tester.element(find.byType(DashboardScreen));
        final theme = Theme.of(context).textTheme;

        expect(mandatory.style?.fontSize, theme.headlineSmall?.fontSize);
        expect(
          extra.style!.fontSize!,
          lessThan(mandatory.style!.fontSize!),
          reason: 'equal-weight rows are the failure mode (principle 6)',
        );
      },
    );

    testWidgets('a day with no optionals still reads as a whole screen', (
      tester,
    ) async {
      // The state of every campaign authored so far, so it is the default
      // case rather than the edge one.
      await pump(tester, committed(today: day));

      expect(find.text('Do not explain yourself'), findsOneWidget);
      expect(find.text('Optional'), findsNothing);
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('Report'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ticking a row hands back the action and the new state', (
      tester,
    ) async {
      String? tapped;
      bool? completed;
      await pumpWith(
        tester,
        committed(),
        onToggleAction: (id, value) {
          tapped = id;
          completed = value;
        },
      );

      await tester.tap(find.text('An optional act'));
      await tester.pumpAndSettle();

      expect(tapped, 'optional-3');
      expect(completed, isTrue);
    });

    testWidgets('a ticked row reports the untick, so ticks are reversible', (
      tester,
    ) async {
      bool? completed;
      await pumpWith(
        tester,
        state(
          logs: [
            dayLog(ticks: const {'optional-3'}),
          ],
          today: dayWithOptional,
        ),
        onToggleAction: (_, value) => completed = value,
      );

      await tester.tap(find.text('An optional act'));
      await tester.pumpAndSettle();

      expect(
        completed,
        isFalse,
        reason: 'an accidental tick is not a confession to undo',
      );
    });

    testWidgets('every tick target is at least 44 logical pixels tall', (
      tester,
    ) async {
      await pump(tester, committed());

      final row = tester.getSize(
        find.ancestor(
          of: find.text('An optional act'),
          matching: find.byType(InkWell),
        ),
      );
      expect(row.height, greaterThanOrEqualTo(44));
    });

    testWidgets('the whole row is the target, not just the control', (
      tester,
    ) async {
      await pump(tester, committed());

      final row = tester.getSize(
        find.ancestor(
          of: find.text('An optional act'),
          matching: find.byType(InkWell),
        ),
      );
      final screen = tester.getSize(find.byType(DashboardScreen));
      expect(row.width, greaterThan(screen.width / 2));
    });
  });

  group('before the commit', () {
    testWidgets('the day is what the screen is', (tester) async {
      await pump(tester, state());

      expect(find.text(day.title), findsOneWidget);
      expect(find.text(day.bodyMd!), findsOneWidget);
    });

    testWidgets('no action, no tick, no day total and no Report', (
      tester,
    ) async {
      await pump(tester, state(today: dayWithOptional));

      // Between them these are most of what makes this read as a different
      // moment rather than a stripped dashboard.
      expect(find.text(action.title), findsNothing);
      expect(find.text(optional.title), findsNothing);
      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
      expect(find.text(l10n.dayPointsTotal), findsNothing);
      expect(find.text(l10n.reportButton), findsNothing);
    });

    testWidgets('Commit is the one control, and it is filled', (tester) async {
      await pump(tester, state());

      expect(
        find.widgetWithText(FilledButton, l10n.commitButton),
        findsOneWidget,
      );
      expect(find.byType(OutlinedButton), findsNothing);
    });

    testWidgets('committing reveals the actions', (tester) async {
      await pump(tester, state());
      expect(find.text(action.title), findsNothing);

      // What _reloadHome() hands back once commitToday has written the row.
      await pump(tester, committed());

      expect(find.text(action.title), findsOneWidget);
      expect(find.text(optional.title), findsOneWidget);
      expect(find.text(l10n.commitButton), findsNothing);
      expect(
        find.widgetWithText(FilledButton, l10n.reportButton),
        findsOneWidget,
      );
    });

    testWidgets('a missing body falls back to the recoverable wording', (
      tester,
    ) async {
      const bodyless = DaySpec(
        id: 'day-3',
        campaignId: 'campaign-1',
        dayIndex: 3,
        title: 'The day you stop hedging',
        actions: [action],
      );

      await pump(tester, state(today: bodyless));

      expect(find.text(bodyless.title), findsOneWidget);
      expect(find.textContaining('Content unavailable'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, l10n.commitButton),
            )
            .onPressed,
        isNotNull,
        reason: 'a day that can still be accepted is still acceptable',
      );
    });

    testWidgets('a day with no mandatory action disables Commit and says why', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      const actionless = DaySpec(
        id: 'day-3',
        campaignId: 'campaign-1',
        dayIndex: 3,
        title: 'The day you stop hedging',
        bodyMd: 'Say the thing once and let it stand.',
      );

      await pump(tester, state(today: actionless));

      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, l10n.commitButton),
            )
            .onPressed,
        isNull,
        reason:
            'onCommit has no action id to write, and swallowing the tap '
            'would leave the user nothing to read',
      );
      expect(
        find.bySemanticsLabel(l10n.commitUnavailable),
        findsOneWidget,
        reason: 'a bare disabled control tells a screen reader nothing',
      );
      handle.dispose();
    });

    testWidgets('an uncached day keeps the day line and the radar', (
      tester,
    ) async {
      await pump(tester, state(today: null));

      expect(find.text('Day 3 of 7'), findsOneWidget);
      expect(find.byType(ArchetypeRadar), findsOneWidget);
      expect(find.textContaining('Content unavailable'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, l10n.commitButton),
            )
            .onPressed,
        isNull,
      );
    });

    testWidgets('the run total reads in both phases', (tester) async {
      await pump(tester, state());
      expect(find.text(l10n.runPointsTotal), findsOneWidget);

      await pump(tester, committed());
      expect(find.text(l10n.runPointsTotal), findsOneWidget);
    });
  });

  group('points', () {
    testWidgets('the day total is the sum of what was ticked', (tester) async {
      await pump(
        tester,
        state(
          logs: [
            dayLog(ticks: const {'action-3', 'optional-3'}),
          ],
          today: dayWithOptional,
        ),
      );

      // action is worth 1, optional 2.
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('3 points'), findsWidgets);
    });

    testWidgets('a point is announced as a count, not a bare numeral', (
      tester,
    ) async {
      await pump(tester, committed());
      expect(find.text('1 point'), findsWidgets);
      expect(find.text('2 points'), findsWidgets);
    });

    testWidgets('no target, goal or percentage sits beside a total', (
      tester,
    ) async {
      await pump(
        tester,
        state(
          logs: [
            dayLog(ticks: const {'action-3'}),
          ],
          today: dayWithOptional,
        ),
      );

      // A number with a target beside it is a score you can lose; a number on
      // its own is a record (ADR-0029).
      for (final banned in ['of 3', 'goal', 'target', '%', 'best', 'average']) {
        expect(find.textContaining(banned, findRichText: true), findsNothing);
      }
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('the all-time total sits with the radar', (tester) async {
      await pump(tester, committed());

      // Below the fold with optionals on screen, which is itself correct:
      // nothing about a points total may compete with today's action.
      await tester.scrollUntilVisible(find.text('All time'), 200);
      await tester.pumpAndSettle();

      final radarY = tester.getTopLeft(find.byType(ArchetypeRadar)).dy;
      final allTimeY = tester.getTopLeft(find.text('All time')).dy;
      expect(
        allTimeY,
        greaterThan(radarY),
        reason: 'the undecayed record sits beside the marks (ADR-0010)',
      );
    });
  });

  group('report', () {
    testWidgets('there is exactly one report control', (tester) async {
      await pump(tester, committed());

      // The three outcome buttons are gone: the outcome is derived, so
      // skipped has no control of its own to feel exposed by (principle 10).
      expect(find.text('Report'), findsOneWidget);
      expect(find.text(l10n.outcomeDone), findsNothing);
      expect(find.text(l10n.outcomePartial), findsNothing);
      expect(find.text(l10n.outcomeSkipped), findsNothing);
    });

    testWidgets('Commit and Report never render at once', (tester) async {
      await pump(tester, state());
      expect(
        find.widgetWithText(FilledButton, l10n.commitButton),
        findsOneWidget,
      );
      expect(
        find.text(l10n.reportButton),
        findsNothing,
        reason: 'the uncommitted phase owns Commit exclusively',
      );

      await pump(tester, committed());
      expect(
        find.widgetWithText(FilledButton, l10n.reportButton),
        findsOneWidget,
      );
      expect(find.text(l10n.commitButton), findsNothing);
    });

    testWidgets('report becomes the filled control once committed', (
      tester,
    ) async {
      await pumpWith(tester, committed());

      expect(find.widgetWithText(FilledButton, 'Report'), findsOneWidget);
      expect(find.text('Commit'), findsNothing);
    });

    testWidgets('the sheet states the derived outcome before confirming', (
      tester,
    ) async {
      await pumpWith(
        tester,
        state(
          logs: [
            dayLog(ticks: const {'optional-3'}),
          ],
          today: dayWithOptional,
        ),
      );

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();

      // Optionals only, so the day is partial. The user sees that before the
      // control that records it.
      expect(find.text('This records: Partial'), findsOneWidget);
    });

    testWidgets('reporting hands back the note', (tester) async {
      String? note;
      var called = false;
      await pumpWith(
        tester,
        committed(),
        onReport: (n) {
          note = n;
          called = true;
        },
      );

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'said it');
      await tester.tap(find.text(l10n.recordButton));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(note, 'said it');
    });

    testWidgets('the note is optional', (tester) async {
      String? note = 'unset';
      var called = false;
      await pumpWith(
        tester,
        committed(),
        onReport: (n) {
          note = n;
          called = true;
        },
      );

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l10n.recordButton));
      await tester.pumpAndSettle();

      expect(called, isTrue);
      expect(note, isNull);
    });

    testWidgets('dismissing the sheet records nothing', (tester) async {
      var called = false;
      await pumpWith(tester, committed(), onReport: (_) => called = true);

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(TextField))).pop();
      await tester.pumpAndSettle();

      expect(called, isFalse);
    });

    testWidgets('a reported day shows the outcome and freezes its ticks', (
      tester,
    ) async {
      var toggled = false;
      await pumpWith(
        tester,
        state(
          logs: [
            dayLog(outcome: Outcome.done, ticks: const {'action-3'}),
          ],
          today: dayWithOptional,
        ),
        onToggleAction: (_, _) => toggled = true,
      );

      // The outcome is rendered through its ARB label, never as the raw wire
      // key (ADR-0022) — a user reads "Done", not the stored string.
      expect(find.text('Reported: Done'), findsOneWidget);
      expect(find.text('Commit'), findsNothing);
      expect(find.text('Report'), findsNothing);

      await tester.tap(find.text('An optional act'));
      await tester.pumpAndSettle();
      expect(
        toggled,
        isFalse,
        reason: 'changing the record after the fact is not a flow we offer',
      );
    });
  });

  group('hostile content', () {
    testWidgets('a long day title and a long body hold at 200%', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      // 63 characters, past the 60 the brief's accessibility bar names.
      const hostile = DaySpec(
        id: 'day-3',
        campaignId: 'campaign-1',
        dayIndex: 3,
        title:
            'The day you stop hedging and say the plain thing right out loud',
        bodyMd:
            'Say it once, in the fewest words that carry it, and then stop '
            'talking. The silence afterwards is not yours to fill, and the '
            'discomfort of leaving it unfilled is the whole of the exercise.',
        actions: [action],
      );

      await pumpWith(tester, state(today: hostile), textScale: 2.0);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(
        find.text(hostile.title),
        findsOneWidget,
        reason: 'it wraps; it never truncates',
      );
    });

    testWidgets('the checklist holds at 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpWith(tester, committed(), textScale: 2.0);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('a 60-character title and a 4-digit total do not collide', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      const long = ActionSpec(
        id: 'optional-3',
        dayId: 'day-3',
        title: 'Ask the one person whose answer you are most afraid of hearing',
        archetypeWeights: {'arch-killer': 1.0},
        effort: 1000,
        isOptional: true,
        sort: 1,
      );

      const crowded = DaySpec(
        id: 'day-3',
        campaignId: 'campaign-1',
        dayIndex: 3,
        title: 'The day you stop hedging',
        bodyMd:
            'Say the thing once, in the fewest words that carry it, and let it stand.',
        actions: [action, long],
      );

      await pumpWith(
        tester,
        state(
          logs: [
            dayLog(ticks: const {'optional-3'}),
          ],
          today: crowded,
        ),
        textScale: 2.0,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(long.title), findsOneWidget);
    });
  });
}
