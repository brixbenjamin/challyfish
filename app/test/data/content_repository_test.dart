import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:test/test.dart';

class FakeContentApi implements ContentApi {
  FakeContentApi(this.rows);

  final Map<String, List<Map<String, dynamic>>> rows;
  final List<({String table, DateTime? since})> calls = [];

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async {
    calls.add((table: table, since: since));
    final all = rows[table] ?? const [];
    if (since == null) return all;
    return all
        .where(
          (row) => DateTime.parse(row['updated_at'] as String).isAfter(since),
        )
        .toList();
  }
}

Map<String, dynamic> archetypeRow(String id, String key, String updatedAt) => {
  'id': id,
  'key': key,
  'name': key,
  'blurb': 'b',
  'color': '#000000',
  'sort': 1,
  'updated_at': updatedAt,
};

Map<String, dynamic> actionRow(String id, int dayIndex, String updatedAt) => {
  'id': id,
  'campaign_id': 'campaign-1',
  'day_index': dayIndex,
  'title': 'Day $dayIndex',
  'body_md': 'body',
  'archetype_id': 'arch-1',
  'why_doctrine_id': null,
  'effort': 1,
  'updated_at': updatedAt,
};

void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a first pull fetches everything and stores it', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
      'actions': [actionRow('action-1', 1, '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);

    await repo.pull();

    expect(await db.select(db.archetypes).get(), hasLength(1));
    expect(await db.select(db.actions).get(), hasLength(1));
    expect(api.calls.every((call) => call.since == null), isTrue);
  });

  test('a second pull asks only for rows newer than the watermark', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);

    await repo.pull();
    api.calls.clear();
    await repo.pull();

    final archetypeCall = api.calls.firstWhere((c) => c.table == 'archetypes');
    expect(archetypeCall.since, DateTime.parse('2026-06-01T09:00:00Z'));
  });

  test(
    'an updated row replaces the cached one rather than duplicating it',
    () async {
      final api = FakeContentApi({
        'archetypes': [
          archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z'),
        ],
      });
      final repo = ContentRepository(db: db, api: api);
      await repo.pull();

      api.rows['archetypes'] = [
        archetypeRow('arch-1', 'renamed', '2026-06-02T09:00:00Z'),
      ];
      await repo.pull();

      final stored = await db.select(db.archetypes).get();
      expect(stored, hasLength(1));
      expect(stored.single.key, 'renamed');
    },
  );

  test('actionFor returns the action for a given campaign day', () async {
    final api = FakeContentApi({
      'actions': [
        actionRow('action-1', 1, '2026-06-01T09:00:00Z'),
        actionRow('action-2', 2, '2026-06-01T09:00:00Z'),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.pull();

    final action = await repo.actionFor('campaign-1', 2);
    expect(action?.id, 'action-2');
    expect(action?.archetypeId, 'arch-1');
  });

  test(
    'actionFor returns null rather than throwing when content is missing',
    () async {
      // The dashboard must degrade to a recoverable "content unavailable" state.
      final repo = ContentRepository(db: db, api: FakeContentApi(const {}));
      await repo.pull();
      expect(await repo.actionFor('campaign-1', 1), isNull);
    },
  );
}
