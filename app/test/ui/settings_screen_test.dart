import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/notifications/reminder_scheduler.dart';
import 'package:feral/src/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

class FakeScheduler implements ReminderScheduler {
  bool enabled = false;
  bool permissionGranted = true;
  int permissionRequests = 0;
  TimeOfDay? scheduledAt;
  TimeOfDay saved = const TimeOfDay(hour: 8, minute: 0);

  @override
  Future<bool> isEnabled() async => enabled;

  @override
  Future<TimeOfDay> savedTime() async => saved;

  @override
  Future<bool> enable(TimeOfDay at) async {
    permissionRequests++;
    if (!permissionGranted) return false;
    enabled = true;
    scheduledAt = at;
    return true;
  }

  @override
  Future<void> disable() async {
    enabled = false;
    scheduledAt = null;
  }

  @override
  Future<void> rescheduleForActiveRun({
    required bool hasActiveRun,
    required TimeOfDay at,
  }) async {
    if (!hasActiveRun) await disable();
  }
}

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  late FakeScheduler scheduler;

  TimeOfDay? offeredTime;
  int pickerOpens = 0;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      wrap(
        SettingsScreen(
          scheduler: scheduler,
          isLinked: false,
          onLink: () {},
          onRestorePurchases: () {},
          pickTime: (_, initial) async {
            pickerOpens++;
            return offeredTime;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    scheduler = FakeScheduler();
    offeredTime = const TimeOfDay(hour: 7, minute: 30);
    pickerOpens = 0;
  });

  testWidgets('the reminder is off by default', (tester) async {
    await pump(tester);

    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isFalse);
  });

  testWidgets('there is exactly one reminder switch, not a set of them', (
    tester,
  ) async {
    // ADR-0011: one reminder. A settings screen that grows a second switch has
    // implemented a different decision.
    await pump(tester);
    expect(find.byType(SwitchListTile), findsOneWidget);
  });

  testWidgets('no permission is requested just by opening settings', (
    tester,
  ) async {
    await pump(tester);
    // ADR-0011: the prompt fires at the moment of intent, never before.
    expect(scheduler.permissionRequests, 0);
  });

  testWidgets('enabling asks for a time, then permission, then schedules', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    // ADR-0011: the user picks the time.
    expect(pickerOpens, 1);
    expect(scheduler.permissionRequests, 1);
    expect(scheduler.enabled, isTrue);
    expect(scheduler.scheduledAt, const TimeOfDay(hour: 7, minute: 30));
  });

  testWidgets('cancelling the time picker enables nothing and asks nothing', (
    tester,
  ) async {
    offeredTime = null;
    await pump(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(pickerOpens, 1);
    expect(scheduler.permissionRequests, 0, reason: 'no intent, no prompt');
    expect(scheduler.enabled, isFalse);
  });

  testWidgets('an enabled reminder shows its time and can be changed', (
    tester,
  ) async {
    scheduler.enabled = true;
    scheduler.saved = const TimeOfDay(hour: 21, minute: 15);
    await pump(tester);

    expect(find.textContaining('21:15'), findsWidgets);

    offeredTime = const TimeOfDay(hour: 6, minute: 45);
    await tester.tap(find.text(l10n.reminderChangeTime));
    await tester.pumpAndSettle();

    expect(scheduler.scheduledAt, const TimeOfDay(hour: 6, minute: 45));
  });

  testWidgets('a denied permission leaves the toggle off and offers settings', (
    tester,
  ) async {
    scheduler.permissionGranted = false;
    await pump(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    final toggle = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(toggle.value, isFalse, reason: 'reflect the real system state');
    expect(find.text(l10n.notificationsBlockedNotice), findsOneWidget);
    expect(find.textContaining('system settings'), findsOneWidget);
  });

  testWidgets('re-tapping after denial does not re-prompt', (tester) async {
    scheduler.permissionGranted = false;
    await pump(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(
      scheduler.permissionRequests,
      1,
      reason: 'a denied prompt is permanent on iOS',
    );
  });

  testWidgets('disabling cancels the schedule', (tester) async {
    scheduler.enabled = true;
    await pump(tester);
    await tester.tap(find.byType(SwitchListTile));
    await tester.pumpAndSettle();

    expect(scheduler.enabled, isFalse);
  });

  testWidgets('settings mention no streaks, misses, or decay', (tester) async {
    await pump(tester);
    for (final banned in ['streak', 'miss', 'decay', 'falling', 'lose']) {
      expect(find.textContaining(banned, findRichText: true), findsNothing);
    }
  });

  testWidgets('the reminder copy itself never mentions a miss or a streak', (
    tester,
  ) async {
    // The notification body is the one string a user reads outside the app, and
    // it is the one most tempting to make into pressure (ADR-0011).
    for (final copy in [
      l10n.reminderNotificationTitle,
      l10n.reminderNotificationBody,
      l10n.reminderOffSubtitle,
    ]) {
      for (final banned in ['streak', 'miss', 'decay', 'behind', 'lost']) {
        expect(
          copy.toLowerCase(),
          isNot(contains(banned)),
          reason: 'reminder copy applies no pressure',
        );
      }
    }
  });
}
