import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/ui/completion/completion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';
import 'completion_screen_test.dart' show campaign;

void main() {
  late int links;
  late int dismissals;

  Future<void> pump(
    WidgetTester tester, {
    required bool showLinkPrompt,
    Grade grade = Grade.sovereign,
  }) {
    links = 0;
    dismissals = 0;
    return tester.pumpWidget(
      wrap(
        CompletionScreen(
          grade: grade,
          campaign: campaign,
          missCount: 0,
          missAllowance: 1,
          marksEarned: const [],
          showLinkPrompt: showLinkPrompt,
          onLink: () => links++,
          onDismissLinkPrompt: () => dismissals++,
          onBrowse: () {},
        ),
      ),
    );
  }

  testWidgets('an unlinked user sees the prompt below the grade', (tester) async {
    await pump(tester, showLinkPrompt: true);

    expect(find.byKey(CompletionScreen.linkPromptKey), findsOneWidget);

    // Below the grade, never above it. The grade is what the user came for.
    final gradeY = tester.getRect(find.byKey(CompletionScreen.gradeKey)).top;
    final promptY = tester
        .getRect(find.byKey(CompletionScreen.linkPromptKey))
        .top;
    expect(promptY, greaterThan(gradeY));
  });

  testWidgets('a linked user sees no prompt at all', (tester) async {
    await pump(tester, showLinkPrompt: false);

    expect(find.byKey(CompletionScreen.linkPromptKey), findsNothing);
  });

  testWidgets('the prompt is dismissible and never modal', (tester) async {
    await pump(tester, showLinkPrompt: true);

    expect(find.byType(AlertDialog), findsNothing);
    // As in the sync banner: every route carries a transparent barrier of its
    // own, so what must be absent is a painted one.
    for (final barrier in tester.widgetList<ModalBarrier>(
      find.byType(ModalBarrier),
    )) {
      expect(barrier.color, isNull);
    }

    await tester.tap(find.byKey(CompletionScreen.linkDismissKey));
    await tester.pump();

    expect(dismissals, 1);
    expect(links, 0);
  });

  testWidgets('the copy states the consequence plainly and sells nothing', (
    tester,
  ) async {
    await pump(tester, showLinkPrompt: true);

    final text = tester
        .widget<Text>(find.byKey(CompletionScreen.linkPromptTextKey))
        .data!
        .toLowerCase();
    expect(text, contains('this phone'));
    for (final banned in [
      'free',
      'unlock',
      'benefit',
      'backup',
      'sync your data',
      '!',
    ]) {
      expect(
        text,
        isNot(contains(banned)),
        reason: 'the prompt states a consequence; it does not sell a feature',
      );
    }
  });

  testWidgets('a Broken run still gets the prompt, with no change in tone', (
    tester,
  ) async {
    await pump(tester, showLinkPrompt: true, grade: Grade.broken);

    expect(find.byKey(CompletionScreen.linkPromptKey), findsOneWidget);
    final text = tester
        .widget<Text>(find.byKey(CompletionScreen.linkPromptTextKey))
        .data!
        .toLowerCase();
    expect(text, isNot(contains('next time')));
  });
}
