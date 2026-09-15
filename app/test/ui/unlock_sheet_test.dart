import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/purchase_state.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/ui/purchase/unlock_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const edge = Pack(
  id: 'p-edge',
  key: 'edge',
  title: 'The Edge',
  description: 'Three campaigns for people who finished the free ones.',
  isCore: false,
  storeProductId: 'pack.edge',
  sort: 2,
);

const campaigns = [
  Campaign(
    id: 'c-1',
    packId: 'p-edge',
    key: 'edge-fourteen',
    title: 'Fourteen',
    introMd: 'x',
    lengthDays: 14,
  ),
  Campaign(
    id: 'c-2',
    packId: 'p-edge',
    key: 'edge-thirty',
    title: 'Thirty',
    introMd: 'x',
    lengthDays: 30,
  ),
];

void main() {
  late AppLocalizations l10n;
  late int buys;
  late int restores;
  late int closes;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Future<void> pump(
    WidgetTester tester, {
    PurchaseUiState state = const PurchaseIdle(),
    String? price = '4,99 €',
  }) {
    buys = 0;
    restores = 0;
    closes = 0;
    return tester.pumpWidget(
      wrap(
        Scaffold(
          body: UnlockSheet(
            pack: edge,
            campaigns: campaigns,
            priceLabel: price,
            state: state,
            onBuy: () => buys++,
            onRestore: () => restores++,
            onClose: () => closes++,
          ),
        ),
      ),
    );
  }

  testWidgets('it says what is in the pack', (tester) async {
    await pump(tester);

    expect(find.text('The Edge'), findsOneWidget);
    expect(find.text('Fourteen'), findsOneWidget);
    expect(find.text('Thirty'), findsOneWidget);
    expect(find.text(l10n.lengthInDays(14)), findsOneWidget);
  });

  testWidgets('it shows the store price verbatim', (tester) async {
    await pump(tester);
    expect(find.text('4,99 €'), findsOneWidget);
  });

  testWidgets('it says the purchase is one time', (tester) async {
    // ADR-0008: packs are one-time purchases, not a subscription, and the sheet
    // is where that promise is made.
    await pump(tester);
    expect(find.text(l10n.oneTimePurchaseNote), findsOneWidget);
  });

  testWidgets('no price still shows the pack and allows a restore', (
    tester,
  ) async {
    await pump(tester, price: null);

    expect(find.text('The Edge'), findsOneWidget);
    expect(find.byKey(UnlockSheet.restoreKey), findsOneWidget);
    expect(find.byKey(UnlockSheet.priceKey), findsNothing);
  });

  testWidgets('buying and restoring report once each', (tester) async {
    await pump(tester);

    await tester.tap(find.byKey(UnlockSheet.buyKey));
    await tester.tap(find.byKey(UnlockSheet.restoreKey));
    await tester.pump();

    expect(buys, 1);
    expect(restores, 1);
  });

  testWidgets('the close button reports once', (tester) async {
    await pump(tester);
    await tester.tap(find.byKey(UnlockSheet.closeKey));
    await tester.pump();
    expect(closes, 1);
  });

  testWidgets('while purchasing, the buy button is disabled', (tester) async {
    await pump(tester, state: const PurchaseInProgress());

    final button = tester.widget<FilledButton>(find.byKey(UnlockSheet.buyKey));
    expect(button.onPressed, isNull, reason: 'a double tap is a double charge');
  });

  testWidgets('while purchasing, the close button is disabled', (tester) async {
    await pump(tester, state: const PurchaseInProgress());

    final button = tester.widget<IconButton>(find.byKey(UnlockSheet.closeKey));
    expect(
      button.onPressed,
      isNull,
      reason:
          'closing mid-purchase abandons a charge the store still considers '
          'open',
    );
  });

  testWidgets('a pending purchase is described as waiting, not failed', (
    tester,
  ) async {
    await pump(tester, state: const PurchaseWaiting());

    expect(find.byKey(UnlockSheet.waitingKey), findsOneWidget);
    expect(find.text(l10n.purchasePendingNote), findsOneWidget);
  });

  testWidgets('a problem is shown plainly, in the store\'s own words', (
    tester,
  ) async {
    await pump(
      tester,
      state: const PurchaseProblem(
        PurchaseProblemReason.storeReported,
        storeMessage: 'The store could not be reached. Nothing was charged.',
      ),
    );

    expect(find.byKey(UnlockSheet.problemKey), findsOneWidget);
    expect(find.textContaining('Nothing was charged'), findsOneWidget);
  });

  testWidgets('a problem with no store message falls back to our own', (
    tester,
  ) async {
    await pump(
      tester,
      state: const PurchaseProblem(PurchaseProblemReason.nothingToRestore),
    );

    expect(find.text(l10n.restoreNothingFound), findsOneWidget);
  });

  testWidgets('it carries no urgency, scarcity or social proof', (
    tester,
  ) async {
    await pump(tester);

    // Design principle 5. If one of these ever appears, it will have arrived
    // one plausible word at a time.
    for (final banned in [
      'limited',
      'offer',
      'hurry',
      'only',
      'popular',
      'save ',
      'best value',
      'discount',
      '% off',
      'expires',
      'others',
    ]) {
      expect(
        find.textContaining(RegExp(banned, caseSensitive: false)),
        findsNothing,
        reason: 'the paywall must not sell like that: "$banned"',
      );
    }
  });
}
