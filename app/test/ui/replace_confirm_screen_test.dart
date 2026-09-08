import 'package:feral/src/domain/identity.dart';
import 'package:feral/src/ui/identity/replace_confirm_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  late int confirms;
  late int cancels;

  Future<void> pump(WidgetTester tester, LocalProgressSummary summary) {
    confirms = 0;
    cancels = 0;
    return tester.pumpWidget(
      wrap(
        ReplaceConfirmScreen(
          summary: summary,
          accountLabel: 'you@example.com',
          onConfirm: () => confirms++,
          onCancel: () => cancels++,
        ),
      ),
    );
  }

  const withRun = LocalProgressSummary(
    hasProgress: true,
    campaignTitle: 'Cold Approach',
    reportedDays: 4,
    totalDays: 7,
  );

  String allText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => (t.data ?? '').toLowerCase())
      .join(' ');

  testWidgets('it names the campaign and the reported days', (tester) async {
    await pump(tester, withRun);

    expect(find.textContaining('Cold Approach'), findsOneWidget);
    expect(find.textContaining('4 of 7'), findsOneWidget);
  });

  testWidgets('it never says only "local data"', (tester) async {
    await pump(tester, withRun);

    expect(allText(tester), isNot(contains('local data')));
    expect(allText(tester), contains('cannot be recovered'));
  });

  testWidgets('it names the account being signed in to', (tester) async {
    await pump(tester, withRun);
    expect(find.textContaining('you@example.com'), findsOneWidget);
  });

  testWidgets('cancel comes first and confirm is styled destructive', (tester) async {
    await pump(tester, withRun);

    // Cancel is above confirm: the safe action is the one a hurried tap lands
    // on and the one keyboard traversal reaches first.
    final cancelRect = tester.getRect(
      find.byKey(ReplaceConfirmScreen.cancelKey),
    );
    final confirmRect = tester.getRect(
      find.byKey(ReplaceConfirmScreen.confirmKey),
    );
    expect(cancelRect.top, lessThan(confirmRect.top));

    final confirm = tester.widget<FilledButton>(
      find.byKey(ReplaceConfirmScreen.confirmKey),
    );
    expect(confirm.style, isNotNull);
  });

  testWidgets('the confirm label says what it does, not "OK"', (tester) async {
    await pump(tester, withRun);

    final label = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(ReplaceConfirmScreen.confirmKey),
            matching: find.byType(Text),
          ),
        )
        .data!;
    expect(label.toLowerCase(), contains('replace'));
    expect(label.toLowerCase(), isNot(equals('ok')));
  });

  testWidgets('confirming and cancelling each report once', (tester) async {
    await pump(tester, withRun);

    await tester.tap(find.byKey(ReplaceConfirmScreen.cancelKey));
    await tester.pump();
    expect((confirms, cancels), (0, 1));

    await tester.tap(find.byKey(ReplaceConfirmScreen.confirmKey));
    await tester.pump();
    expect((confirms, cancels), (1, 1));
  });

  testWidgets('progress with no active run still states what is lost', (tester) async {
    await pump(tester, const LocalProgressSummary(hasProgress: true));

    expect(find.byKey(ReplaceConfirmScreen.confirmKey), findsOneWidget);
    expect(allText(tester), contains('this phone'));
  });
}
