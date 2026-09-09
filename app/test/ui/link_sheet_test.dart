import 'package:feral/src/domain/identity.dart';
import 'package:feral/src/ui/identity/link_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

void main() {
  late List<AuthProvider> chosen;
  late int cancels;

  Future<void> pump(
    WidgetTester tester,
    List<AuthProvider> providers, {
    LinkPurpose purpose = LinkPurpose.keep,
  }) {
    chosen = [];
    cancels = 0;
    return tester.pumpWidget(
      wrap(
        Scaffold(
          body: LinkSheet(
            providers: providers,
            purpose: purpose,
            onChoose: chosen.add,
            onCancel: () => cancels++,
          ),
        ),
      ),
    );
  }

  testWidgets('every offered provider is a distinct control', (tester) async {
    await pump(tester, AuthProvider.values);

    expect(find.byKey(LinkSheet.keyFor(AuthProvider.apple)), findsOneWidget);
    expect(find.byKey(LinkSheet.keyFor(AuthProvider.google)), findsOneWidget);
    expect(find.byKey(LinkSheet.keyFor(AuthProvider.email)), findsOneWidget);
  });

  testWidgets('choosing a provider reports it', (tester) async {
    await pump(tester, AuthProvider.values);

    await tester.tap(find.byKey(LinkSheet.keyFor(AuthProvider.google)));
    await tester.pump();

    expect(chosen, [AuthProvider.google]);
  });

  testWidgets('cancelling is always available', (tester) async {
    await pump(tester, AuthProvider.values);

    await tester.tap(find.byKey(LinkSheet.cancelKey));
    await tester.pump();

    expect(cancels, 1);
  });

  testWidgets('it states plainly why linking exists, without pressure', (
    tester,
  ) async {
    await pump(tester, AuthProvider.values);

    final body = tester
        .widget<Text>(find.byKey(LinkSheet.explanationKey))
        .data!;
    expect(body.toLowerCase(), contains('this phone'));
    for (final banned in [
      "don't lose",
      'hurry',
      'last chance',
      'warning',
      'risk',
    ]) {
      expect(body.toLowerCase(), isNot(contains(banned)));
    }
  });

  testWidgets('signing in is not described as keeping what is on this phone', (
    tester,
  ) async {
    await pump(tester, AuthProvider.values, purpose: LinkPurpose.signIn);

    // Opened from the start screen there is nothing on this phone yet, so the
    // linking copy would be describing something that does not exist. What this
    // user needs to hear is the opposite: their record is elsewhere and this
    // brings it back.
    final body = tester
        .widget<Text>(find.byKey(LinkSheet.explanationKey))
        .data!;
    expect(body.toLowerCase(), isNot(contains('lives only on this phone')));
    expect(body.toLowerCase(), contains('already answered'));
  });

  testWidgets('Apple is offered whenever Google is', (tester) async {
    await pump(tester, [AuthProvider.google, AuthProvider.email]);

    // Guideline 4.8: a social login without an equivalent privacy-preserving
    // option is an App Store rejection. The sheet enforces it rather than
    // trusting every call site to remember.
    expect(find.byKey(LinkSheet.keyFor(AuthProvider.apple)), findsOneWidget);
  });
}
