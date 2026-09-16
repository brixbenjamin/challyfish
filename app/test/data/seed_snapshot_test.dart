import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/remote/seed_snapshot.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

const _snapshot = {
  'archetypes': [
    {
      'id': 'a-1',
      'key': 'psycho',
      'name': 'Psycho',
      'blurb': 'b',
      'color': '#000',
      'sort': 1,
      'updated_at': '2026-06-01T09:00:00Z',
    },
  ],
  'packs': [
    {
      'id': 'p-1',
      'key': 'core',
      'title': 'Core',
      'description': 'd',
      'is_core': true,
      'store_product_id': null,
      'cover_path': null,
      'sort': 1,
      'updated_at': '2026-06-02T09:00:00Z',
    },
  ],
  'campaigns': [
    {
      'id': 'c-1',
      'pack_id': 'p-1',
      'key': 'first',
      'title': 'The First Week',
      'subtitle': null,
      'intro_md': 'i',
      'length_days': 7,
      'ramp_days': 2,
      'difficulty': 1,
      'cover_path': null,
      'sort': 1,
      'updated_at': '2026-06-03T09:00:00Z',
    },
  ],
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FeralDatabase db;
  late ContentRepository content;
  late SeedSnapshotLoader loader;

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    content = ContentRepository(db: db, api: _NoopApi());
    loader = SeedSnapshotLoader(
      db: db,
      content: content,
      readSnapshot: () async => jsonEncode(_snapshot),
    );
  });
  tearDown(() => db.close());

  test('seeds an empty database and reports that it did', () async {
    expect(await loader.loadIfEmpty(), isTrue);
    expect(await db.select(db.campaigns).get(), hasLength(1));
    expect((await content.campaigns()).single.title, 'The First Week');
  });

  test('a first launch with no network still reaches a campaign', () async {
    await loader.loadIfEmpty();
    // Nothing here touched the network: the fake API returns nothing at all.
    expect(await content.campaigns(), isNotEmpty);
  });

  test('does nothing when content is already present', () async {
    await loader.loadIfEmpty();
    expect(await loader.loadIfEmpty(), isFalse);
    expect(await db.select(db.campaigns).get(), hasLength(1));
  });

  test('records no content version, so the first refresh is a full one', () async {
    await loader.loadIfEmpty();

    // The snapshot is a subset: it carries the free pack's bodies and none of the
    // paid ones. Claiming the server's version for it would make the first
    // refresh decide there was nothing to fetch, and a purchase would deliver
    // nothing. This replaced per-table watermark priming, which had to
    // special-case both body tables for exactly that reason (ADR-0025, ADR-0034).
    expect(await content.cachedVersion(), isNull);
  });

  test('a malformed snapshot fails loudly rather than half-seeding', () async {
    final broken = SeedSnapshotLoader(
      db: db,
      content: content,
      readSnapshot: () async => '{"campaigns": [{"id": "c-1"}]}',
    );

    await expectLater(broken.loadIfEmpty(), throwsA(isA<Object>()));
    expect(
      await db.select(db.campaigns).get(),
      isEmpty,
      reason: 'the whole seed is one transaction',
    );
  });

  test('the checked-in snapshot that actually ships loads and seeds', () async {
    // The tests above use a fabricated snapshot, which cannot catch a column
    // the generator emits in a shape the descriptors do not accept. This one
    // reads the real asset — the file a first launch with no signal depends on.
    final real = SeedSnapshotLoader(
      db: db,
      content: content,
      readSnapshot: () => File('assets/seed/core_content.json').readAsString(),
    );

    expect(await real.loadIfEmpty(), isTrue);
    expect(await content.campaigns(), isNotEmpty);
    expect(await content.packs(), isNotEmpty);
    expect(await content.diagnosticQuestions(), hasLength(8));
    expect(
      (await content.diagnosticQuestions()).every((q) => q.options.length == 2),
      isTrue,
    );

    final campaign = (await content.campaigns()).first;
    expect(
      await content.actionsFor(campaign.id),
      hasLength(campaign.lengthDays),
    );
    expect(
      await content.daysFor(campaign.id),
      hasLength(campaign.lengthDays),
      reason: 'the snapshot carries one day row per campaign day',
    );
    expect(
      (await content.daysFor(campaign.id)).every((d) => d.mandatory != null),
      isTrue,
      reason: 'every bundled day carries its mandatory action',
    );
    expect(await content.archetypeIdsFor(campaign.id), isNotEmpty);
    expect(await content.archetypesById(), hasLength(4));

    // Shares ship too. Without them a first launch with no signal would draw a
    // flat radar from a full campaign — the failure a snapshot that silently
    // stopped carrying a table would produce, and the reason this asserts on
    // the bundled asset rather than on the generator's table list.
    final seeded = await content.actionsFor(campaign.id);
    expect(
      seeded.every((a) => a.archetypeWeights.isNotEmpty),
      isTrue,
      reason: 'every seeded action carries at least one archetype',
    );
    expect(
      seeded.every(
        (a) =>
            (a.archetypeWeights.values.fold(0.0, (sum, w) => sum + w) - 1)
                .abs() <
            1e-9,
      ),
      isTrue,
      reason: 'weights are normalised, so no action outweighs its own effort',
    );
    expect(
      seeded.where((a) => a.archetypeWeights.length > 1),
      isNotEmpty,
      reason:
          'the split path is exercised by shipped content, not only by '
          'unit tests',
    );

    // The reading section ships too: a first launch with no signal that opens
    // Doctrine must not find it empty.
    final doctrine = await content.doctrineGroups();
    expect(doctrine, isNotEmpty);
    expect(await content.doctrineEntriesFor(doctrine.first.id), isNotEmpty);
  });
}

class _NoopApi implements ContentApi {
  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async => [];

  @override
  Future<int> fetchVersion() async => 1;
}
