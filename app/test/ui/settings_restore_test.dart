import 'dart:async';

import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import 'settings_screen_test.dart' show FakeScheduler; // plan 2 Task 15

void main() {
  late AppLocalizations l10n;
  late int restoreCalls;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<void> pump(WidgetTester tester, RestoreSummary summary) {
    restoreCalls = 0;
    return tester.pumpWidget(
      wrap(
        SettingsScreen(
          scheduler: FakeScheduler(),
          linkedIdentity: null,
          onLink: () {},
          onDeleteAccount: () {},
          onRestorePurchases: () async {
            restoreCalls++;
            return summary;
          },
        ),
      ),
    );
  }

  testWidgets('restoring something says what came back', (tester) async {
    await pump(tester, const RestoreSummary(succeeded: true, unlockedPacks: 1));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SettingsScreen.restoreRowKey));
    await tester.pumpAndSettle();

    expect(restoreCalls, 1);
    expect(find.byKey(SettingsScreen.restoreResultKey), findsOneWidget);
    expect(find.text(l10n.restoredPacks(1)), findsOneWidget);
  });

  testWidgets('restoring several packs says so in the plural', (tester) async {
    await pump(tester, const RestoreSummary(succeeded: true, unlockedPacks: 2));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SettingsScreen.restoreRowKey));
    await tester.pumpAndSettle();

    expect(find.text(l10n.restoredPacks(2)), findsOneWidget);
    expect(
      l10n.restoredPacks(2),
      isNot(l10n.restoredPacks(1)),
      reason: 'a real plural, not one string with a number in it',
    );
  });

  testWidgets('nothing to restore is not an error', (tester) async {
    await pump(tester, const RestoreSummary(succeeded: true));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SettingsScreen.restoreRowKey));
    await tester.pumpAndSettle();

    expect(find.text(l10n.restoreNothingFound), findsOneWidget);
  });

  testWidgets('an unreachable store reads differently from owning nothing', (
    tester,
  ) async {
    // The two must never share a message: one of these users should try again
    // and the other should not.
    await pump(
      tester,
      RestoreSummary(succeeded: false, error: StateError('offline')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(SettingsScreen.restoreRowKey));
    await tester.pumpAndSettle();

    expect(find.text(l10n.restoreNothingFound), findsNothing);
    expect(find.text(l10n.restoreUnreachable), findsOneWidget);
    expect(
      l10n.restoreUnreachable,
      isNot(l10n.restoreNothingFound),
      reason: 'owning nothing and an unreachable store are different facts',
    );
  });

  testWidgets('the row cannot be tapped twice while it is working', (
    tester,
  ) async {
    final completer = Completer<RestoreSummary>();
    var calls = 0;
    await tester.pumpWidget(
      wrap(
        SettingsScreen(
          scheduler: FakeScheduler(),
          linkedIdentity: null,
          onLink: () {},
          onDeleteAccount: () {},
          onRestorePurchases: () {
            calls++;
            return completer.future;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SettingsScreen.restoreRowKey));
    await tester.pump();

    expect(find.byKey(SettingsScreen.restoreProgressKey), findsOneWidget);

    // The second tap must not reach the store.
    await tester.tap(find.byKey(SettingsScreen.restoreRowKey));
    await tester.pump();
    expect(calls, 1, reason: 'a second tap is a second store round trip');

    completer.complete(const RestoreSummary(succeeded: true));
    await tester.pumpAndSettle();
    expect(find.byKey(SettingsScreen.restoreProgressKey), findsNothing);
  });
}
