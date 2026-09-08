import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/diagnostic.dart';
import 'package:feral/src/ui/onboarding/diagnostic_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

DiagnosticQuestion pair(int n, String a, String b) => DiagnosticQuestion(
  id: 'q$n',
  prompt: 'Closer to you?',
  sort: n,
  options: [
    DiagnosticOption(
      id: 'q${n}a',
      questionId: 'q$n',
      label: a,
      archetypeId: 'x',
      sort: 0,
    ),
    DiagnosticOption(
      id: 'q${n}b',
      questionId: 'q$n',
      label: b,
      archetypeId: 'y',
      sort: 1,
    ),
  ],
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  final questions = [
    pair(1, 'Act now', 'Say the hard thing'),
    pair(2, 'Hold the plan', 'Start moving'),
  ];

  testWidgets('shows both options and the progress through the set', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(DiagnosticScreen(questions: questions, onComplete: (_) {})),
    );

    expect(find.text('Act now'), findsOneWidget);
    expect(find.text('Say the hard thing'), findsOneWidget);
    expect(find.text(l10n.questionProgress(1, 2)), findsOneWidget);
  });

  testWidgets('offers no neutral answer and no skip', (tester) async {
    await tester.pumpWidget(
      wrap(DiagnosticScreen(questions: questions, onComplete: (_) {})),
    );

    // The forced part is the design (ADR-0009). These name the words literally
    // on purpose: the assertion is that they are absent, whatever the voice.
    expect(find.text('Skip'), findsNothing);
    expect(find.text('Neither'), findsNothing);
    expect(find.text('Both'), findsNothing);
    expect(find.textContaining('Not sure'), findsNothing);
  });

  testWidgets('choosing advances to the next pair', (tester) async {
    await tester.pumpWidget(
      wrap(DiagnosticScreen(questions: questions, onComplete: (_) {})),
    );

    await tester.tap(find.text('Act now'));
    await tester.pumpAndSettle();

    expect(find.text(l10n.questionProgress(2, 2)), findsOneWidget);
    expect(find.text('Hold the plan'), findsOneWidget);
  });

  testWidgets('completing hands back one pick per question, in order', (
    tester,
  ) async {
    List<DiagnosticPick>? captured;
    await tester.pumpWidget(
      wrap(
        DiagnosticScreen(questions: questions, onComplete: (p) => captured = p),
      ),
    );

    await tester.tap(find.text('Say the hard thing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start moving'));
    await tester.pumpAndSettle();

    expect(captured, hasLength(2));
    expect(captured!.map((p) => p.questionId), ['q1', 'q2']);
    expect(captured!.map((p) => p.optionId), ['q1b', 'q2b']);
  });

  testWidgets('going back and changing an answer replaces it, not appends', (
    tester,
  ) async {
    List<DiagnosticPick>? captured;
    await tester.pumpWidget(
      wrap(
        DiagnosticScreen(questions: questions, onComplete: (p) => captured = p),
      ),
    );

    await tester.tap(find.text('Act now'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.backButton));
    await tester.pumpAndSettle();

    expect(find.text(l10n.questionProgress(1, 2)), findsOneWidget);
    await tester.tap(find.text('Say the hard thing'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start moving'));
    await tester.pumpAndSettle();

    expect(captured, hasLength(2), reason: 'one pick per question, never two');
    expect(captured!.first.optionId, 'q1b');
  });

  testWidgets('there is no Back on the first question', (tester) async {
    await tester.pumpWidget(
      wrap(DiagnosticScreen(questions: questions, onComplete: (_) {})),
    );
    expect(find.text(l10n.backButton), findsNothing);
  });
}
