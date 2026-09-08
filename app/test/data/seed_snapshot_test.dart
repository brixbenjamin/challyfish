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

  test('primes each table watermark from the snapshot', () async {
    await loader.loadIfEmpty();

    // Set too low and the first pull re-downloads the library; too high and
    // genuine edits are missed forever.
    expect(
      content.watermarks['archetypes'],
      DateTime.parse('2026-06-01T09:00:00Z'),
    );
    expect(content.watermarks['packs'], DateTime.parse('2026-06-02T09:00:00Z'));
    expect(
      content.watermarks['campaigns'],
      DateTime.parse('2026-06-03T09:00:00Z'),
    );
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
    expect(await content.archetypeIdsFor(campaign.id), isNotEmpty);
    expect(await content.archetypesById(), hasLength(4));
  });
}

class _NoopApi implements ContentApi {
  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async => [];
}
