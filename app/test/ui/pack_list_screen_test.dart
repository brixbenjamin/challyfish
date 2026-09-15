import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/ui/browse/pack_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const _core = Pack(
  id: 'p-core',
  key: 'core',
  title: 'The Core',
  description: 'Free.',
  isCore: true,
  sort: 1,
);
const _edge = Pack(
  id: 'p-edge',
  key: 'edge',
  title: 'The Edge',
  description: 'Paid, locked.',
  isCore: false,
  storeProductId: 'pack.edge',
  sort: 2,
);
const _owned = Pack(
  id: 'p-owned',
  key: 'owned',
  title: 'The Long Road',
  description: 'Paid, already unlocked.',
  isCore: false,
  storeProductId: 'pack.longroad',
  sort: 3,
);

const _c1 = Campaign(
  id: 'c-1',
  packId: 'p-core',
  key: 'first',
  title: 'The First Week',
  introMd: 'x',
  lengthDays: 7,
);
const _c2 = Campaign(
  id: 'c-2',
  packId: 'p-edge',
  key: 'thirty',
  title: 'Thirty Days of No',
  introMd: 'x',
  lengthDays: 30,
);
const _c3 = Campaign(
  id: 'c-3',
  packId: 'p-owned',
  key: 'road-1',
  title: 'Mile One',
  introMd: 'x',
  lengthDays: 45,
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  Widget buildScreen({required void Function(Pack pack) onPurchase}) =>
      wrap(
        PackListScreen(
          packs: const [
            PackView(
              pack: _core,
              campaigns: [_c1],
              isUnlocked: true,
              priceLabel: null,
              archetypesByCampaign: {},
            ),
            PackView(
              pack: _edge,
              campaigns: [_c2],
              isUnlocked: false,
              priceLabel: r'$6.99',
              archetypesByCampaign: {},
            ),
            PackView(
              pack: _owned,
              campaigns: [_c3],
              isUnlocked: true,
              priceLabel: null,
              archetypesByCampaign: {},
            ),
          ],
          onOpen: (_) {},
          onPurchase: onPurchase,
        ),
      );

  testWidgets('a locked pack shows a purchase CTA, unlocked packs do not', (
    tester,
  ) async {
    await tester.pumpWidget(buildScreen(onPurchase: (_) {}));

    expect(find.widgetWithText(FilledButton, l10n.unlockButton), findsOneWidget);
  });

  testWidgets('tapping the CTA reports the pack it belongs to', (
    tester,
  ) async {
    Pack? purchased;
    await tester.pumpWidget(
      buildScreen(onPurchase: (pack) => purchased = pack),
    );

    await tester.tap(find.widgetWithText(FilledButton, l10n.unlockButton));
    await tester.pump();

    expect(purchased, _edge);
  });
}
