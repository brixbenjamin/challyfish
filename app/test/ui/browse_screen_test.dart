import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/ui/browse/campaign_detail_screen.dart';
import 'package:feral/src/ui/browse/pack_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const corePack = Pack(
  id: 'p-1',
  key: 'core',
  title: 'The Core',
  description: 'Where everyone starts.',
  isCore: true,
  sort: 1,
);
const paidPack = Pack(
  id: 'p-2',
  key: 'edge',
  title: 'The Edge',
  description: 'Harder.',
  isCore: false,
  storeProductId: 'edge',
  sort: 2,
);

const short = Campaign(
  id: 'c-1',
  packId: 'p-1',
  key: 'first',
  title: 'The First Week',
  subtitle: 'Seven days of saying the thing.',
  introMd: 'intro text',
  lengthDays: 7,
);
const long = Campaign(
  id: 'c-2',
  packId: 'p-2',
  key: 'thirty',
  title: 'Thirty Days',
  introMd: 'intro text',
  lengthDays: 30,
);

const killer = Archetype(
  id: 'a-killer',
  key: 'killer',
  name: 'Killer',
  blurb: 'b',
  color: '#000',
  sort: 2,
);

void main() {
  late AppLocalizations l10n;

  setUpAll(() async {
    l10n = await AppLocalizations.delegate.load(const Locale('en'));
  });

  testWidgets('locked campaigns are browsable, not hidden', (tester) async {
    await tester.pumpWidget(
      wrap(
        PackListScreen(
          packs: const [
            PackView(
              pack: corePack,
              campaigns: [short],
              isUnlocked: true,
              priceLabel: null,
              archetypesByCampaign: {},
            ),
            PackView(
              pack: paidPack,
              campaigns: [long],
              isUnlocked: false,
              priceLabel: null,
              archetypesByCampaign: {},
            ),
          ],
          onOpen: (_) {},
          onPurchase: (_) {},
        ),
      ),
    );

    // A teaser is public by design (ADR-0008): the user needs to see what they
    // would be paying for.
    expect(find.text('Thirty Days'), findsOneWidget);
    expect(find.text('The Edge'), findsOneWidget);
  });

  testWidgets('a locked pack is marked as locked', (tester) async {
    await tester.pumpWidget(
      wrap(
        PackListScreen(
          packs: const [
            PackView(
              pack: paidPack,
              campaigns: [long],
              isUnlocked: false,
              priceLabel: null,
              archetypesByCampaign: {},
            ),
          ],
          onOpen: (_) {},
          onPurchase: (_) {},
        ),
      ),
    );
    expect(find.text(l10n.lockedBadge), findsOneWidget);
  });

  testWidgets('campaign detail states the miss allowance', (tester) async {
    await tester.pumpWidget(
      wrap(
        CampaignDetailScreen(
          campaign: short,
          targets: const [killer],
          missAllowance: 1,
          days: const [],
          archetypesById: const {},
          isUnlocked: true,
          hasActiveRun: false,
          onStart: () {},
          onUnlock: () {},
        ),
      ),
    );

    expect(find.text(l10n.lengthInDays(7)), findsOneWidget);
    expect(find.text('Killer'), findsOneWidget);
    // The allowance differs per campaign (ADR-0012), so it is stated here.
    expect(find.text(l10n.missesAllowed(1)), findsOneWidget);
    expect(find.text(l10n.startButton), findsOneWidget);
  });

  testWidgets('a longer campaign states its larger allowance', (tester) async {
    await tester.pumpWidget(
      wrap(
        CampaignDetailScreen(
          campaign: long,
          targets: const [killer],
          missAllowance: 3,
          days: const [],
          archetypesById: const {},
          isUnlocked: true,
          hasActiveRun: false,
          onStart: () {},
          onUnlock: () {},
        ),
      ),
    );
    expect(find.text(l10n.missesAllowed(3)), findsOneWidget);
    expect(
      l10n.missesAllowed(3),
      isNot(l10n.missesAllowed(1)),
      reason:
          'the allowance is a real plural, not one string with a number in it',
    );
  });

  testWidgets('a locked campaign offers unlock and cannot be started', (
    tester,
  ) async {
    var started = false;
    await tester.pumpWidget(
      wrap(
        CampaignDetailScreen(
          campaign: long,
          targets: const [killer],
          missAllowance: 3,
          days: const [],
          archetypesById: const {},
          isUnlocked: false,
          hasActiveRun: false,
          onStart: () => started = true,
          onUnlock: () {},
        ),
      ),
    );

    expect(find.text(l10n.startButton), findsNothing);
    expect(find.text(l10n.unlockButton), findsOneWidget);
    expect(started, isFalse);
  });

  testWidgets('an active run turns Start into a warned replacement', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        CampaignDetailScreen(
          campaign: short,
          targets: const [killer],
          missAllowance: 1,
          days: const [],
          archetypesById: const {},
          isUnlocked: true,
          hasActiveRun: true,
          onStart: () {},
          onUnlock: () {},
        ),
      ),
    );

    // Abandoning is the only destructive action in the product, so the screen
    // must say what it costs before the user taps it.
    expect(find.text(l10n.abandonActiveRunWarning), findsOneWidget);
    expect(find.text(l10n.abandonAndStartButton), findsOneWidget);
    expect(find.text(l10n.startButton), findsNothing);
  });
}
