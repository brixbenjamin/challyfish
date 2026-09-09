import 'package:feral/src/app/providers.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/pack.dart';
import 'package:feral/src/ui/browse/pack_list_screen.dart';
import 'package:test/test.dart';

const core = Pack(
  id: 'p-core',
  key: 'core',
  title: 'The Core',
  description: 'Free, forever.',
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

const free = Campaign(
  id: 'c-1',
  packId: 'p-core',
  key: 'first',
  title: 'The First Week',
  introMd: 'x',
  lengthDays: 7,
);
const paid = Campaign(
  id: 'c-2',
  packId: 'p-edge',
  key: 'edge-thirty',
  title: 'Thirty',
  introMd: 'x',
  lengthDays: 30,
);

void main() {
  List<PackView> views(Set<String> unlocked) => packViewsFrom(
    packs: const [core, edge],
    campaignsByPack: const {
      'p-core': [free],
      'p-edge': [paid],
    },
    unlockedPackIds: unlocked,
  );

  test('a locked pack still lists its campaigns', () {
    // The teaser is the shop window (ADR-0008). Hiding it would be a bug in the
    // store dressed up as a paywall.
    final locked = views({'p-core'}).firstWhere((v) => v.pack.id == 'p-edge');
    expect(locked.isUnlocked, isFalse);
    expect(locked.campaigns.single.title, 'Thirty');
  });

  test('an owned pack is unlocked', () {
    final owned = views({
      'p-core',
      'p-edge',
    }).firstWhere((v) => v.pack.id == 'p-edge');
    expect(owned.isUnlocked, isTrue);
  });

  test('packs keep their sort order', () {
    expect(views({'p-core'}).map((v) => v.pack.key).toList(), ['core', 'edge']);
  });

  test('a pack with no campaigns yet still appears', () {
    final result = packViewsFrom(
      packs: const [core, edge],
      campaignsByPack: const {
        'p-core': [free],
      },
      unlockedPackIds: const {'p-core'},
    );
    expect(result, hasLength(2));
    expect(result.last.campaigns, isEmpty);
  });
}
