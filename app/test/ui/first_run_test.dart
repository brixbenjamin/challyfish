import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/diagnostic.dart';
import 'package:feral/src/ui/onboarding/diagnostic_screen.dart';
import 'package:feral/src/ui/onboarding/doctrine_intro_screen.dart';
import 'package:feral/src/ui/onboarding/privacy_notice_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('the privacy notice states the three things it must', (
    tester,
  ) async {
    await tester.pumpWidget(wrap(PrivacyNoticeScreen(onAccept: () {})));

    // Three separate claims, all on screen before the first byte of user data
    // is written: an account already exists, exactly what is stored, and that
    // an unlinked account cannot be recovered. A voice pass may reword any of
    // them, but dropping one is a defect rather than a copy edit.
    expect(find.text(l10n.privacyNoticeAccount), findsOneWidget);
    expect(find.text(l10n.privacyNoticeStored), findsOneWidget);
    expect(find.text(l10n.privacyNoticeLoss), findsOneWidget);
  });

  testWidgets('the intro can be moved past in one tap', (tester) async {
    var advanced = false;
    await tester.pumpWidget(
      wrap(
        DoctrineIntroScreen(
          onContinue: () => advanced = true,
          onSignIn: () {},
        ),
      ),
    );
    await tester.tap(find.text(l10n.continueButton));
    expect(advanced, isTrue);
  });

  testWidgets('a returning user can say so before answering anything', (
    tester,
  ) async {
    var signIn = 0;
    await tester.pumpWidget(
      wrap(DoctrineIntroScreen(onContinue: () {}, onSignIn: () => signIn++)),
    );

    // Someone who already has an account has already answered the diagnostic.
    // Without this the only way to it is to answer all eight again, and the
    // second set of answers then outranks the first (ADR-0024).
    await tester.tap(find.byKey(DoctrineIntroScreen.signInKey));
    expect(signIn, 1);
  });

  testWidgets('no account screen appears anywhere in onboarding', (
    tester,
  ) async {
    // ADR-0007: nothing stands between install and the diagnostic. An offer is
    // not a gate — the continue button is still the first thing here, and the
    // words below stay banned so this never grows into a sign-in wall.
    for (final screen in [
      wrap(DoctrineIntroScreen(onContinue: () {}, onSignIn: () {})),
      wrap(PrivacyNoticeScreen(onAccept: () {})),
    ]) {
      await tester.pumpWidget(screen);
      for (final banned in [
        'Sign in',
        'Sign up',
        'Log in',
        'Create account',
        'Email',
      ]) {
        expect(find.textContaining(banned, findRichText: true), findsNothing);
      }
      expect(find.byType(TextField), findsNothing);
    }
  });

  testWidgets('the diagnostic runs end to end from eight pairs', (
    tester,
  ) async {
    final questions = [
      for (var n = 1; n <= 8; n++)
        DiagnosticQuestion(
          id: 'q$n',
          prompt: 'Closer to you?',
          sort: n,
          options: [
            DiagnosticOption(
              id: 'q${n}a',
              questionId: 'q$n',
              label: 'Left $n',
              archetypeId: 'a',
              sort: 0,
            ),
            DiagnosticOption(
              id: 'q${n}b',
              questionId: 'q$n',
              label: 'Right $n',
              archetypeId: 'b',
              sort: 1,
            ),
          ],
        ),
    ];

    List<DiagnosticPick>? picks;
    await tester.pumpWidget(
      wrap(
        DiagnosticScreen(questions: questions, onComplete: (p) => picks = p),
      ),
    );

    for (var n = 1; n <= 8; n++) {
      expect(find.text(l10n.questionProgress(n, 8)), findsOneWidget);
      await tester.tap(find.text('Left $n'));
      await tester.pumpAndSettle();
    }

    expect(picks, hasLength(8));
    expect(picks!.map((p) => p.questionId), [
      for (var n = 1; n <= 8; n++) 'q$n',
    ]);
  });
}
