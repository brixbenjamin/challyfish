import 'package:feral/src/domain/identity.dart';
import 'package:feral/src/ui/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import 'settings_screen_test.dart' show FakeScheduler;

void main() {
  late int links;
  late int deletes;

  Future<void> pump(WidgetTester tester, {LinkedIdentity? identity}) {
    links = 0;
    deletes = 0;
    return tester.pumpWidget(
      wrap(
        SettingsScreen(
          scheduler: FakeScheduler(),
          linkedIdentity: identity,
          onLink: () => links++,
          onDeleteAccount: () => deletes++,
          onRestorePurchases: () {},
        ),
      ),
    );
  }

  testWidgets('an unlinked account offers linking, without a warning', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(SettingsScreen.linkRowKey), findsOneWidget);
    expect(find.byIcon(Icons.warning), findsNothing);
    expect(find.byIcon(Icons.error), findsNothing);
  });

  testWidgets('a linked account shows the identity instead of the link row', (
    tester,
  ) async {
    await pump(
      tester,
      identity: const LinkedIdentity(
        provider: AuthProvider.email,
        label: 'you@example.com',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('you@example.com'), findsOneWidget);
    expect(find.byKey(SettingsScreen.linkRowKey), findsNothing);
  });

  testWidgets('tapping link reports once', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SettingsScreen.linkRowKey));
    await tester.pump();

    expect(links, 1);
  });

  testWidgets('delete account is available to an unlinked user too', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(SettingsScreen.deleteRowKey));
    await tester.pump();

    expect(deletes, 1);
  });

  testWidgets('delete account is not the first thing on the screen', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    final deleteY = tester.getRect(find.byKey(SettingsScreen.deleteRowKey)).top;
    final reminderY = tester
        .getRect(find.byKey(SettingsScreen.reminderRowKey))
        .top;
    expect(deleteY, greaterThan(reminderY));
  });

  testWidgets('the reminder controls from plan 2 are still there', (tester) async {
    await pump(tester);
    await tester.pumpAndSettle();

    expect(find.byKey(SettingsScreen.reminderRowKey), findsOneWidget);
  });
}
