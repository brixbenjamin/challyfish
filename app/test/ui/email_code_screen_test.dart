import 'package:feral/src/ui/identity/email_code_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  late List<String> sent;
  late List<(String, String)> verified;
  late List<String> authenticated;
  late EmailCodeResult nextResult;

  Future<void> pump(WidgetTester tester) {
    sent = [];
    verified = [];
    authenticated = [];
    nextResult = const CodeAccepted('user-1');
    return tester.pumpWidget(
      wrap(
        EmailCodeScreen(
          onSendCode: (email) async => sent.add(email),
          onVerify: (email, code) async {
            verified.add((email, code));
            return nextResult;
          },
          onAuthenticated: authenticated.add,
          onCancel: () {},
        ),
      ),
    );
  }

  Future<void> reachCodeStep(WidgetTester tester) async {
    await tester.enterText(
      find.byKey(EmailCodeScreen.emailFieldKey),
      'you@example.com',
    );
    await tester.tap(find.byKey(EmailCodeScreen.sendKey));
    await tester.pumpAndSettle();
  }

  testWidgets('it starts on the address step', (tester) async {
    await pump(tester);

    expect(find.byKey(EmailCodeScreen.emailFieldKey), findsOneWidget);
    expect(find.byKey(EmailCodeScreen.codeFieldKey), findsNothing);
  });

  testWidgets('sending a code advances to the code step', (tester) async {
    await pump(tester);
    await reachCodeStep(tester);

    expect(sent, ['you@example.com']);
    expect(find.byKey(EmailCodeScreen.codeFieldKey), findsOneWidget);
  });

  testWidgets('the code step shows the address it was sent to', (tester) async {
    await pump(tester);
    await reachCodeStep(tester);

    expect(find.textContaining('you@example.com'), findsOneWidget);
  });

  testWidgets('an obviously invalid address does not send anything', (
    tester,
  ) async {
    await pump(tester);

    await tester.enterText(
      find.byKey(EmailCodeScreen.emailFieldKey),
      'not-an-address',
    );
    await tester.tap(find.byKey(EmailCodeScreen.sendKey));
    await tester.pumpAndSettle();

    expect(sent, isEmpty);
    expect(find.byKey(EmailCodeScreen.codeFieldKey), findsNothing);
  });

  testWidgets('a correct code authenticates', (tester) async {
    await pump(tester);
    await reachCodeStep(tester);

    await tester.enterText(find.byKey(EmailCodeScreen.codeFieldKey), '481209');
    await tester.tap(find.byKey(EmailCodeScreen.verifyKey));
    await tester.pumpAndSettle();

    expect(verified, [('you@example.com', '481209')]);
    expect(authenticated, ['user-1']);
  });

  testWidgets('a wrong code stays on the code step and keeps the address', (
    tester,
  ) async {
    await pump(tester);
    await reachCodeStep(tester);

    nextResult = const CodeRejected('That code is not right.');
    await tester.enterText(find.byKey(EmailCodeScreen.codeFieldKey), '000000');
    await tester.tap(find.byKey(EmailCodeScreen.verifyKey));
    await tester.pumpAndSettle();

    expect(
      find.byKey(EmailCodeScreen.codeFieldKey),
      findsOneWidget,
      reason: 'never dead-end back to the address step',
    );
    expect(find.textContaining('you@example.com'), findsOneWidget);
    expect(find.text('That code is not right.'), findsOneWidget);
    expect(authenticated, isEmpty);
  });

  testWidgets('a short code cannot be submitted', (tester) async {
    await pump(tester);
    await reachCodeStep(tester);

    await tester.enterText(find.byKey(EmailCodeScreen.codeFieldKey), '4812');
    await tester.tap(find.byKey(EmailCodeScreen.verifyKey));
    await tester.pumpAndSettle();

    expect(verified, isEmpty);
  });

  testWidgets('resend is disabled during the cooldown', (tester) async {
    await pump(tester);
    await reachCodeStep(tester);

    final resend = tester.widget<TextButton>(
      find.byKey(EmailCodeScreen.resendKey),
    );
    expect(resend.onPressed, isNull, reason: 'cooldown is running');

    await tester.pump(EmailCodeScreen.resendCooldown);
    final after = tester.widget<TextButton>(
      find.byKey(EmailCodeScreen.resendKey),
    );
    expect(after.onPressed, isNotNull);
  });

  testWidgets('changing the address keeps what was already typed', (
    tester,
  ) async {
    await pump(tester);
    await reachCodeStep(tester);

    await tester.tap(find.byKey(EmailCodeScreen.changeEmailKey));
    await tester.pumpAndSettle();

    final field = tester.widget<TextField>(
      find.byKey(EmailCodeScreen.emailFieldKey),
    );
    expect(
      field.controller!.text,
      'you@example.com',
      reason: 'their typing is not thrown away',
    );
  });
}
