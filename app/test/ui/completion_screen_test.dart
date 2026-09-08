import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/ui/completion/completion_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const campaign = Campaign(
  id: 'c-1',
  packId: 'p-1',
  key: 'first',
  title: 'The First Week',
  introMd: 'i',
  lengthDays: 7,
);

const killer = Archetype(
  id: 'a-killer',
  key: 'killer',
  name: 'Killer',
  blurb: 'b',
  color: '#000',
  sort: 1,
);

Future<void> pump(
  WidgetTester tester,
  Grade grade, {
  int misses = 0,
  bool showLinkPrompt = false,
  List<Archetype> marksEarned = const [],
}) => tester.pumpWidget(
  wrap(
    CompletionScreen(
      grade: grade,
      campaign: campaign,
      missCount: misses,
      missAllowance: 1,
      marksEarned: marksEarned,
      showLinkPrompt: showLinkPrompt,
      onDismissLinkPrompt: () {},
      onLink: () {},
      onBrowse: () {},
    ),
  ),
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('states the grade plainly', (tester) async {
    await pump(tester, Grade.sovereign);
    expect(find.text(l10n.gradeSovereign), findsOneWidget);
    expect(
      find.text(l10n.gradeSummarySovereign(campaign.title)),
      findsOneWidget,
    );
  });

  testWidgets('a Broken result offers no consolation and no retry', (
    tester,
  ) async {
    await pump(tester, Grade.broken, misses: 4);

    // These name the words literally on purpose: the assertion is that they
    // are absent, whatever the voice turns out to be.
    for (final banned in [
      'Better luck',
      'Try again',
      'Retry',
      'Restart',
      'Start over',
      "Don't worry",
    ]) {
      expect(
        find.textContaining(banned, findRichText: true),
        findsNothing,
        reason: 'the honest record is the product (ADR-0003)',
      );
    }
    expect(find.text(l10n.gradeBroken), findsOneWidget);
  });

  testWidgets('a Broken result says the days still counted', (tester) async {
    await pump(tester, Grade.broken, misses: 4);
    expect(find.text(l10n.noMarkNote), findsOneWidget);
    expect(find.textContaining('still count'), findsOneWidget);
  });

  testWidgets('marks earned are named rather than counted', (tester) async {
    await pump(tester, Grade.sovereign, marksEarned: const [killer]);
    expect(find.text(l10n.marksEarnedLead), findsOneWidget);
    expect(find.text('Killer'), findsOneWidget);
    expect(find.text(l10n.noMarkNote), findsNothing);
  });

  testWidgets('an unlinked user is prompted to attach an identity', (
    tester,
  ) async {
    await pump(tester, Grade.passed, misses: 1, showLinkPrompt: true);
    expect(find.text(l10n.linkIdentityButton), findsOneWidget);
  });

  testWidgets('a linked user is not prompted', (tester) async {
    await pump(tester, Grade.passed, misses: 1);
    expect(find.text(l10n.linkIdentityButton), findsNothing);
  });
}
