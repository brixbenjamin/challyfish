import 'package:feral/src/ui/settings/delete_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  late int deleted;
  late int cancels;
  late bool serverSucceeds;

  Future<void> pump(WidgetTester tester, {bool isLinked = true}) {
    deleted = 0;
    cancels = 0;
    serverSucceeds = true;
    return tester.pumpWidget(
      wrap(
        DeleteAccountScreen(
          isLinked: isLinked,
          onConfirmDelete: () async => serverSucceeds,
          onCancel: () => cancels++,
          onDeleted: () => deleted++,
        ),
      ),
    );
  }

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => (t.data ?? '').toLowerCase())
      .join(' ');

  Future<void> arm(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(DeleteAccountScreen.inputKey),
      DeleteAccountScreen.confirmWord,
    );
    await tester.pump();
  }

  testWidgets('the button is disabled until the word is typed exactly', (
    tester,
  ) async {
    await pump(tester);

    var button = tester.widget<FilledButton>(
      find.byKey(DeleteAccountScreen.confirmKey),
    );
    expect(button.onPressed, isNull);

    await tester.enterText(find.byKey(DeleteAccountScreen.inputKey), 'delet');
    await tester.pump();
    button = tester.widget<FilledButton>(
      find.byKey(DeleteAccountScreen.confirmKey),
    );
    expect(button.onPressed, isNull);

    await arm(tester);
    button = tester.widget<FilledButton>(
      find.byKey(DeleteAccountScreen.confirmKey),
    );
    expect(button.onPressed, isNotNull);
  });

  testWidgets('it lists what goes and what does not', (tester) async {
    await pump(tester);

    final texts = allText(tester);
    expect(texts, contains('every run'));
    expect(texts, contains('note'));
    expect(texts, contains('cannot be undone'));
    // Purchases sit outside the cascade and the copy has to say so.
    expect(texts, contains('purchase'));
  });

  testWidgets('an unlinked user is told deleting the app does the same', (
    tester,
  ) async {
    await pump(tester, isLinked: false);
    expect(allText(tester), contains('deleting the app'));
  });

  testWidgets('a linked user is not told to delete the app', (tester) async {
    await pump(tester, isLinked: true);
    expect(allText(tester), isNot(contains('deleting the app')));
  });

  testWidgets('a successful delete reports once', (tester) async {
    await pump(tester);
    await arm(tester);

    await tester.tap(find.byKey(DeleteAccountScreen.confirmKey));
    await tester.pumpAndSettle();

    expect(deleted, 1);
  });

  testWidgets('a failed delete stays on the screen and says so', (
    tester,
  ) async {
    await pump(tester);
    serverSucceeds = false;
    await arm(tester);

    await tester.tap(find.byKey(DeleteAccountScreen.confirmKey));
    await tester.pumpAndSettle();

    expect(
      deleted,
      0,
      reason: 'nothing local is wiped unless the server agreed',
    );
    expect(find.byKey(DeleteAccountScreen.errorKey), findsOneWidget);
  });

  testWidgets('cancel is available at every point', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(DeleteAccountScreen.cancelKey));
    await tester.pump();

    expect(cancels, 1);
  });
}
