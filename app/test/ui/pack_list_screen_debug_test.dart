// Not a `flutter test` widget test — a `flutter run` entrypoint for looking
// at PackListScreen in isolation.
//
// Run it with:
//   flutter run -d chrome -t test/ui/pack_list_screen_debug_test.dart
//
// That launches the real engine in a browser tab, so the screen can be
// screenshotted and iterated on visually without booting the whole app
// (database, auth, the store). Lives under test/ despite the file suffix so it
// sits next to the screen it previews and stays out of lib/; `flutter test`
// picks it up too, but with no `test()`/`testWidgets()` calls registered it
// just runs main() once against the fake test binding and exits — it does not
// hang CI.
import 'package:feral/l10n/app_localizations.dart';
import 'package:feral/src/domain/archetype.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/ui/browse/pack_list_screen.dart';
import 'package:feral/src/ui/theme/theme.dart';
import 'package:flutter/material.dart';

const _core = Pack(
  id: 'p-core',
  key: 'core',
  title: 'The Core',
  description: 'The free run everyone starts on. No purchase, no expiry.',
  isCore: true,
  sort: 1,
);
const _edge = Pack(
  id: 'p-edge',
  key: 'edge',
  title: 'The Edge',
  description: 'Three campaigns for the ones who already know what they avoid.',
  isCore: false,
  storeProductId: 'pack.edge',
  sort: 2,
);
const _quiet = Pack(
  id: 'p-quiet',
  key: 'quiet',
  title: 'The Quiet Room',
  description: 'A slower arc. Still asks something every day.',
  isCore: false,
  storeProductId: 'pack.quiet',
  sort: 3,
);
const _owned = Pack(
  id: 'p-owned',
  key: 'owned',
  title: 'The Long Road',
  description: 'Bought once. Yours for good.',
  isCore: false,
  storeProductId: 'pack.longroad',
  sort: 4,
);

const _killer = Archetype(
  id: 'a-killer',
  key: 'killer',
  name: 'Killer',
  blurb: 'b',
  color: '#000',
  sort: 2,
);
const _alchemist = Archetype(
  id: 'a-alchemist',
  key: 'alchemist',
  name: 'Alchemist',
  blurb: 'b',
  color: '#000',
  sort: 3,
);
const _creature = Archetype(
  id: 'a-creature',
  key: 'creature',
  name: 'Creature',
  blurb: 'b',
  color: '#000',
  sort: 4,
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
  packId: 'p-edge',
  key: 'reckoning',
  title: 'The Reckoning',
  introMd: 'x',
  lengthDays: 14,
);
// A title long enough to prove the layout wraps rather than clips at phone
// width and at large OS text scale.
const _c4 = Campaign(
  id: 'c-4',
  packId: 'p-edge',
  key: 'untitled-hours',
  title: 'The Hours You Would Otherwise Have Explained Away',
  introMd: 'x',
  lengthDays: 21,
);
const _c5 = Campaign(
  id: 'c-5',
  packId: 'p-quiet',
  key: 'quiet-1',
  title: 'Sit With It',
  introMd: 'x',
  lengthDays: 10,
);
const _c6 = Campaign(
  id: 'c-6',
  packId: 'p-owned',
  key: 'road-1',
  title: 'Mile One',
  introMd: 'x',
  lengthDays: 45,
);

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appDarkTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PackListScreen(
        packs: const [
          // Core: unlocked, free, one single-archetype campaign.
          PackView(
            pack: _core,
            campaigns: [_c1],
            isUnlocked: true,
            priceLabel: null,
            archetypesByCampaign: {
              'c-1': [_killer],
            },
          ),
          // Locked, price resolved. One campaign has two targets (no tag),
          // one has a long title (wrap check), one is single-archetype.
          PackView(
            pack: _edge,
            campaigns: [_c2, _c3, _c4],
            isUnlocked: false,
            priceLabel: r'$6.99',
            archetypesByCampaign: {
              'c-2': [_alchemist, _creature, _killer],
              'c-3': [_creature],
            },
          ),
          // Locked, price still resolving (or unreachable) — falls back to
          // the "Locked" reading instead of a blank status line.
          PackView(
            pack: _quiet,
            campaigns: [_c5],
            isUnlocked: false,
            priceLabel: null,
            archetypesByCampaign: {
              'c-5': [_alchemist],
            },
          ),
          // Owned: paid, already unlocked. No price, no badge — just "Owned".
          PackView(
            pack: _owned,
            campaigns: [_c6],
            isUnlocked: true,
            priceLabel: null,
            archetypesByCampaign: {},
          ),
        ],
        onOpen: (campaign) {
          debugPrint('opened ${campaign.title}');
        },
        onPurchase: (pack) {
          debugPrint('purchase ${pack.title}');
        },
      ),
    ),
  );
}
