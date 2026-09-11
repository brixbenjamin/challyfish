import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/balance_state.dart';
import 'package:feral/src/app/run_state.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
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
    campaignId: 'campaign-1',
    dayIndex: 3,
    title: 'Do not explain yourself',
    bodyMd: 'Say no once today, and stop talking after you have said it.',
    archetypeId: 'arch-killer',
  );

  const optional = ActionSpec(
    id: 'optional-3',
    campaignId: 'campaign-1',
    dayIndex: 3,
    title: 'An optional act',
    bodyMd: 'Something extra, if there is appetite for it.',
    archetypeId: 'arch-killer',
    effort: 2,
    isOptional: true,
    sort: 1,
  );

  RunState state({
    List<DayLog> logs = const [],
    List<ActionSpec> todayActions = const [action],
  }) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: logs,
    todayActions: todayActions,
    actionsById: {for (final a in todayActions) a.id: a},
    zone: berlin,
    now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
  );

  /// Day 3's log, carrying whatever ticks and outcome a case needs.
  DayLog today({Outcome? outcome, Set<String> ticks = const {}}) => DayLog(
    id: 'l3',
    runId: 'run-1',
    dayIndex: 3,
    actionId: 'action-3',
    outcome: outcome,
    completedActionIds: ticks,
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

  RunState withOptionals() => state(todayActions: const [action, optional]);

  testWidgets('shows the day, the action, and the miss count', (tester) async {
    await pump(
      tester,
      state(
        logs: [
          DayLog(
            id: 'l1',
            runId: 'run-1',
            dayIndex: 1,
            actionId: 'a1',
            outcome: Outcome.skipped,
          ),
        ],
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
    await pump(tester, state(todayActions: const []));
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
        todayActions: const [action],
        zone: berlin,
        now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
      ),
    );

    expect(find.text('0 of 3 misses used'), findsOneWidget);
  });

  testWidgets('the radar is below the action, never above it', (tester) async {
    await pump(tester, state());

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
      await pump(tester, withOptionals());

      final mandatory = tester.getTopLeft(find.text('Do not explain yourself'));
      final extra = tester.getTopLeft(find.text('An optional act'));
      expect(extra.dy, greaterThan(mandatory.dy));
    });

    testWidgets('the mandatory action keeps its body copy inline', (
      tester,
    ) async {
      await pump(tester, withOptionals());

      expect(find.text(action.bodyMd!), findsOneWidget);
      expect(
        find.text(optional.bodyMd!),
        findsNothing,
        reason: 'an optional row is compact; its copy expands on tap',
      );
    });

    testWidgets('the mandatory action outweighs the optionals typographically',
        (tester) async {
      await pump(tester, withOptionals());

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
    });

    testWidgets('a day with no optionals still reads as a whole screen', (
      tester,
    ) async {
      // The state of every campaign authored so far, so it is the default
      // case rather than the edge one.
      await pump(tester, state());

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
        withOptionals(),
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
          logs: [today(ticks: const {'optional-3'})],
          todayActions: const [action, optional],
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
      await pump(tester, withOptionals());

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
      await pump(tester, withOptionals());

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

  group('points', () {
    testWidgets('the day total is the sum of what was ticked', (tester) async {
      await pump(
        tester,
        state(
          logs: [today(ticks: const {'action-3', 'optional-3'})],
          todayActions: const [action, optional],
        ),
      );

      // action is worth 1, optional 2.
      expect(find.text('Today'), findsOneWidget);
      expect(find.text('3 points'), findsWidgets);
    });

    testWidgets('a point is announced as a count, not a bare numeral', (
      tester,
    ) async {
      await pump(tester, withOptionals());
      expect(find.text('1 point'), findsWidgets);
      expect(find.text('2 points'), findsWidgets);
    });

    testWidgets('no target, goal or percentage sits beside a total', (
      tester,
    ) async {
      await pump(
        tester,
        state(
          logs: [today(ticks: const {'action-3'})],
          todayActions: const [action, optional],
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
      await pump(tester, withOptionals());

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
      await pump(tester, withOptionals());

      // The three outcome buttons are gone: the outcome is derived, so
      // skipped has no control of its own to feel exposed by (principle 10).
      expect(find.text('Report'), findsOneWidget);
      expect(find.text(l10n.outcomeDone), findsNothing);
      expect(find.text(l10n.outcomePartial), findsNothing);
      expect(find.text(l10n.outcomeSkipped), findsNothing);
    });

    testWidgets('commit is the one filled control before the day is committed',
        (tester) async {
      await pump(tester, withOptionals());

      expect(find.widgetWithText(FilledButton, 'Commit'), findsOneWidget);
      expect(
        find.widgetWithText(FilledButton, 'Report'),
        findsNothing,
        reason: 'Report is present but not yet the point',
      );
      expect(find.widgetWithText(OutlinedButton, 'Report'), findsOneWidget);
    });

    testWidgets('report becomes the filled control once committed', (
      tester,
    ) async {
      await pumpWith(
        tester,
        state(
          logs: [
            DayLog(
              id: 'l3',
              runId: 'run-1',
              dayIndex: 3,
              actionId: 'action-3',
              committedAt: tz.TZDateTime(berlin, 2026, 6, 3, 8).toUtc(),
            ),
          ],
          todayActions: const [action, optional],
        ),
      );

      expect(find.widgetWithText(FilledButton, 'Report'), findsOneWidget);
      expect(find.text('Commit'), findsNothing);
    });

    testWidgets('the sheet states the derived outcome before confirming', (
      tester,
    ) async {
      await pumpWith(
        tester,
        state(
          logs: [today(ticks: const {'optional-3'})],
          todayActions: const [action, optional],
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
        withOptionals(),
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
        withOptionals(),
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
      await pumpWith(tester, withOptionals(), onReport: (_) => called = true);

      await tester.tap(find.text('Report'));
      await tester.pumpAndSettle();
      Navigator.of(
        tester.element(find.byType(TextField)),
      ).pop();
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
          logs: [today(outcome: Outcome.done, ticks: const {'action-3'})],
          todayActions: const [action, optional],
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
    testWidgets('the checklist holds at 200% text scale', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await pumpWith(tester, withOptionals(), textScale: 2.0);
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
        campaignId: 'campaign-1',
        dayIndex: 3,
        title: 'Ask the one person whose answer you are most afraid of hearing',
        archetypeId: 'arch-killer',
        effort: 1000,
        isOptional: true,
        sort: 1,
      );

      await pumpWith(
        tester,
        state(
          logs: [today(ticks: const {'optional-3'})],
          todayActions: const [action, long],
        ),
        textScale: 2.0,
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text(long.title), findsOneWidget);
    });
  });
}
