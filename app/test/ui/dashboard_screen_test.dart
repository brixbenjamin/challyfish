import 'package:feral/src/app/run_state.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/day_log.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:feral/src/ui/dashboard_screen.dart';
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

  RunState state({
    List<DayLog> logs = const [],
    ActionSpec? todayAction = action,
  }) => RunState.derive(
    run: run,
    campaign: campaign,
    logs: logs,
    todayAction: todayAction,
    zone: berlin,
    now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
  );

  Future<void> pump(WidgetTester tester, RunState value) => tester.pumpWidget(
    wrap(DashboardScreen(state: value, onCommit: () {}, onReport: (_, _) {})),
  );

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

  testWidgets('offers all three outcomes to report', (tester) async {
    await pump(tester, state());
    expect(find.text('Done'), findsOneWidget);
    expect(find.text('Partial'), findsOneWidget);
    expect(find.text('Skipped'), findsOneWidget);
  });

  testWidgets('a reported day shows the outcome instead of the buttons', (
    tester,
  ) async {
    await pump(
      tester,
      state(
        logs: [
          DayLog(
            id: 'l3',
            runId: 'run-1',
            dayIndex: 3,
            actionId: 'a3',
            outcome: Outcome.done,
          ),
        ],
      ),
    );

    // The outcome is rendered through its ARB label, never as the raw wire key
    // (ADR-0022) — a user reads "Done", not the string stored in the column.
    expect(find.text('Reported: Done'), findsOneWidget);
    expect(find.text('Commit'), findsNothing);
  });

  testWidgets('missing content shows a recoverable state, not a crash', (
    tester,
  ) async {
    await pump(tester, state(todayAction: null));
    expect(find.textContaining('Content unavailable'), findsOneWidget);
  });

  testWidgets('there is no streak counter anywhere', (tester) async {
    await pump(tester, state());
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
        todayAction: action,
        zone: berlin,
        now: tz.TZDateTime(berlin, 2026, 6, 3, 10).toUtc(),
      ),
    );

    expect(find.text('0 of 3 misses used'), findsOneWidget);
  });
}
