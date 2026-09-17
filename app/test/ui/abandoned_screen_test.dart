import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/ui/completion/abandoned_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const campaign = Campaign(
    id: 'campaign-1',
    packId: 'pack-1',
    key: 'first-week',
    title: 'The First Week',
    introMd: 'i',
    lengthDays: 7,
  );

  Future<void> pump(
    WidgetTester tester, {
    int daysReported = 3,
    VoidCallback? onBrowse,
  }) => tester.pumpWidget(
    MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AbandonedScreen(
        campaign: campaign,
        abandonedOn: DateTime.utc(2026, 6, 4),
        daysReported: daysReported,
        onBrowse: onBrowse ?? () {},
      ),
    ),
  );

  testWidgets('names the campaign and the date the run ended', (tester) async {
    await pump(tester);

    expect(find.text('Abandoned'), findsOneWidget);
    expect(
      find.textContaining('The First Week'),
      findsOneWidget,
      reason: 'the consequence is named in concrete terms, not as "your run"',
    );
    expect(find.textContaining('June 4, 2026'), findsOneWidget);
  });

  testWidgets('says what the user keeps', (tester) async {
    await pump(tester, daysReported: 3);
    expect(find.textContaining('3 days reported'), findsOneWidget);
  });

  testWidgets('offers no way to start the campaign again', (tester) async {
    // Not a second chance screen. The one control leads to the shelf, which is
    // where every other "what now" in the product leads.
    await pump(tester);

    expect(find.byType(FilledButton), findsNothing);
    expect(find.byType(TextButton), findsOneWidget);
  });

  testWidgets('does not console, encourage or mention a streak', (
    tester,
  ) async {
    await pump(tester);

    for (final word in ['streak', 'again', 'try', 'sorry', 'back on track']) {
      expect(
        find.textContaining(word, findRichText: true),
        findsNothing,
        reason: 'the voice states facts and does not console: "$word"',
      );
    }
  });

  testWidgets('the one control leads to the shelf', (tester) async {
    var browsed = false;
    await pump(tester, onBrowse: () => browsed = true);

    await tester.tap(find.byType(TextButton));
    await tester.pumpAndSettle();

    expect(browsed, isTrue);
  });
}
