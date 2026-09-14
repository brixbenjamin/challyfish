import 'dart:convert';

import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/remote/seed_snapshot.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:test/test.dart';

class RecordingContentApi implements ContentApi {
  final List<(String, DateTime?)> asked = [];

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async {
    asked.add((table, since));
    return const [];
  }
}

void main() {
  test('the snapshot primes no watermark for action_bodies', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final api = RecordingContentApi();
    final content = ContentRepository(db: db, api: api);

    // A snapshot carrying only the free pack's bodies, with a timestamp newer
    // than a paid body would carry.
    final snapshot = jsonEncode({
      'days': [
        {
          'id': 'd1',
          'campaign_id': 'c1',
          'day_index': 1,
          'title': 'Day 1',
          'kind': 'standard',
          'primary_archetype_id': null,
          'updated_at': '2026-09-09T00:00:00Z',
        },
      ],
      'day_bodies': [
        {
          'day_id': 'd1',
          'body_md': 'free framing',
          'updated_at': '2026-09-09T00:00:00Z',
        },
      ],
      'actions': [
        {
          'id': 'a1',
          'day_id': 'd1',
          'title': 'Day 1',
          'effort': 1,
          'updated_at': '2026-09-09T00:00:00Z',
        },
      ],
      'action_bodies': [
        {
          'action_id': 'a1',
          'body_md': 'free copy',
          'updated_at': '2026-09-09T00:00:00Z',
        },
      ],
    });

    await SeedSnapshotLoader(
      db: db,
      content: content,
      readSnapshot: () async => snapshot,
    ).loadIfEmpty();

    expect(
      await content.watermarkFor('actions'),
      isNotNull,
      reason: 'a complete table still establishes a mark',
    );
    expect(
      await content.watermarkFor('action_bodies'),
      isNull,
      reason: 'a filtered table must not claim a high-water mark',
    );
    expect(
      await content.watermarkFor('days'),
      isNotNull,
      reason: 'days ships whole -- the teaser is public (ADR-0034)',
    );
    expect(
      await content.watermarkFor('day_bodies'),
      isNull,
      reason: 'day_bodies is filtered exactly as action_bodies is',
    );
  });

  test('a first pull therefore asks for every body', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final api = RecordingContentApi();
    final content = ContentRepository(db: db, api: api);

    await content.pull();

    for (final table in const ['action_bodies', 'day_bodies']) {
      final bodies = api.asked.where((a) => a.$1 == table);
      expect(bodies, hasLength(1), reason: '$table is pulled exactly once');
      expect(
        bodies.single.$2,
        isNull,
        reason: 'an unset mark means fetch everything the server will give us',
      );
    }
  });
}
