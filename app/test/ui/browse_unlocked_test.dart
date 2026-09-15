import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/app/providers.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/ui/browse/campaign_detail_screen.dart';
import 'package:feral/src/ui/browse/pack_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/pump.dart';

const core = Pack(
  id: 'p-core',
  key: 'core',
  title: 'The Core',
  description: 'Free.',
  isCore: true,
  sort: 1,
);
const edge = Pack(
  id: 'p-edge',
  key: 'edge',
  title: 'The Edge',
  description: 'Harder.',
  isCore: false,
  storeProductId: 'pack.edge',
  sort: 2,
);
const paid = Campaign(
  id: 'c-2',
  packId: 'p-edge',
  key: 'edge-thirty',
  title: 'Thirty',
  introMd: 'x',
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

  testWidgets('an unowned pack renders as locked from real entitlements', (
    tester,
  ) async {
    final views = packViewsFrom(
      packs: const [core, edge],
      campaignsByPack: const {
        'p-edge': [paid],
      },
      unlockedPackIds: const {'p-core'},
      priceLabelsByPack: const {},
      archetypesByCampaign: const {
        'c-2': [killer],
      },
    );

    await tester.pumpWidget(wrap(PackListScreen(packs: views, onOpen: (_) {})));

    expect(find.text(l10n.lockedBadge), findsOneWidget);
    expect(find.text('Thirty'), findsOneWidget);
  });

  testWidgets('the detail screen offers Unlock and refuses Start', (
    tester,
  ) async {
    var started = 0;
    var unlocks = 0;

    await tester.pumpWidget(
      wrap(
        CampaignDetailScreen(
          campaign: paid,
          targets: const [killer],
          missAllowance: 3,
          days: const [],
          archetypesById: const {},
          isUnlocked: false,
          hasActiveRun: false,
          onStart: () => started++,
          onUnlock: () => unlocks++,
        ),
      ),
    );

    expect(find.text(l10n.startButton), findsNothing);
    await tester.tap(find.text(l10n.unlockButton));
    await tester.pump();

    expect(unlocks, 1);
    expect(started, 0);
  });
}
