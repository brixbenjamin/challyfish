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

Map<String, dynamic> dayRow(
  String id,
  String campaignId,
  int dayIndex,
  String updatedAt, {
  String kind = 'standard',
}) => {
  'id': id,
  'campaign_id': campaignId,
  'day_index': dayIndex,
  'title': 'Day $dayIndex',
  'kind': kind,
  'primary_archetype_id': null,
  'updated_at': updatedAt,
};

Map<String, dynamic> actionRow(
  String id,
  String dayId,
  String updatedAt, {
  bool isOptional = false,
  int sort = 0,
}) => {
  'id': id,
  'day_id': dayId,
  'title': 'An act',
  'why_doctrine_id': null,
  'effort': 1,
  'is_optional': isOptional,
  'sort': sort,
  'updated_at': updatedAt,
};

/// One share row. The action's archetypes are a join table since the split
/// landed, so a fixture action needs both halves to hydrate into a spec that
/// moves the radar.
Map<String, dynamic> actionArchetypeRow(
  String actionId,
  String archetypeId,
  String updatedAt, {
  int share = 1,
}) => {
  'action_id': actionId,
  'archetype_id': archetypeId,
  'share': share,
  'updated_at': updatedAt,
};

void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('a first pull fetches everything and stores it', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
      'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
      'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
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
      'days': [
        dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z'),
        dayRow('day-2', 'campaign-1', 2, '2026-06-01T09:00:00Z'),
      ],
      'actions': [
        actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z'),
        actionRow('action-2', 'day-2', '2026-06-01T09:00:00Z'),
      ],
      'action_archetypes': [
        actionArchetypeRow('action-2', 'arch-1', '2026-06-01T09:00:00Z'),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.pull();

    final action = await repo.actionFor('campaign-1', 2);
    expect(action?.id, 'action-2');
    expect(action?.archetypeWeights, {'arch-1': 1.0});
  });

  test(
    'a split action hydrates as normalised weights, not raw shares',
    () async {
      final api = FakeContentApi({
        'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
        'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
        'action_archetypes': [
          actionArchetypeRow(
            'action-1',
            'arch-1',
            '2026-06-01T09:00:00Z',
            share: 2,
          ),
          actionArchetypeRow(
            'action-1',
            'arch-2',
            '2026-06-01T09:00:00Z',
            share: 1,
          ),
        ],
      });
      final repo = ContentRepository(db: db, api: api);
      await repo.pull();

      final action = await repo.actionFor('campaign-1', 1);
      expect(action?.archetypeWeights, {'arch-1': 2 / 3, 'arch-2': 1 / 3});
    },
  );

  test(
    'an action pulled without its shares hydrates with no archetypes',
    () async {
      // A partial content sync: the action arrived, its archetype rows did not.
      // The dropped not-null column used to make this impossible; now it has to
      // degrade rather than throw.
      final api = FakeContentApi({
        'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
        'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
      });
      final repo = ContentRepository(db: db, api: api);
      await repo.pull();

      final action = await repo.actionFor('campaign-1', 1);
      expect(action?.archetypeWeights, isEmpty);
    },
  );

  test(
    'actionFor returns null rather than throwing when content is missing',
    () async {
      // The dashboard must degrade to a recoverable "content unavailable" state.
      final repo = ContentRepository(db: db, api: FakeContentApi(const {}));
      await repo.pull();
      expect(await repo.actionFor('campaign-1', 1), isNull);
    },
  );

  test('a pull covers every content table', () async {
    final api = FakeContentApi(const {});
    final repo = ContentRepository(db: db, api: api);

    await repo.pull();

    expect(api.calls.map((c) => c.table).toSet(), {
      'archetypes',
      'packs',
      'campaigns',
      'campaign_archetypes',
      'days',
      'day_bodies',
      'actions',
      'action_archetypes',
      'action_bodies',
      'doctrine_groups',
      'doctrine_entries',
      'diagnostic_questions',
      'diagnostic_options',
    });
  });

  test('doctrine entries come back grouped and ordered', () async {
    final api = FakeContentApi({
      'doctrine_groups': [
        {
          'id': 'g-1',
          'title': 'The Zoo',
          'blurb': null,
          'sort': 1,
          'updated_at': '2026-06-01T09:00:00Z',
        },
      ],
      'doctrine_entries': [
        {
          'id': 'e-2',
          'group_id': 'g-1',
          'title': 'The Guards',
          'body_md': 'b',
          'related_archetype_id': null,
          'sort': 2,
          'updated_at': '2026-06-01T09:00:00Z',
        },
        {
          'id': 'e-1',
          'group_id': 'g-1',
          'title': 'The Domesticated State',
          'body_md': 'b',
          'related_archetype_id': null,
          'sort': 1,
          'updated_at': '2026-06-01T09:00:00Z',
        },
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.pull();

    expect((await repo.doctrineGroups()).single.title, 'The Zoo');
    expect(
      (await repo.doctrineEntriesFor('g-1')).map((e) => e.id),
      ['e-1', 'e-2'],
      reason: 'ordered by sort, not by arrival',
    );
  });

  test('diagnostic questions come back with both their options', () async {
    final api = FakeContentApi({
      'diagnostic_questions': [
        {
          'id': 'q-1',
          'prompt': 'Closer to you?',
          'sort': 1,
          'updated_at': '2026-06-01T09:00:00Z',
        },
      ],
      'diagnostic_options': [
        {
          'id': 'o-1',
          'question_id': 'q-1',
          'label': 'Act now',
          'archetype_id': 'arch-alchemist',
          'sort': 0,
          'updated_at': '2026-06-01T09:00:00Z',
        },
        {
          'id': 'o-2',
          'question_id': 'q-1',
          'label': 'Say the hard thing',
          'archetype_id': 'arch-killer',
          'sort': 1,
          'updated_at': '2026-06-01T09:00:00Z',
        },
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.pull();

    final questions = await repo.diagnosticQuestions();
    expect(questions, hasLength(1));
    expect(questions.single.options.map((o) => o.archetypeId), [
      'arch-alchemist',
      'arch-killer',
    ]);
  });

  test('a campaign reports the archetypes it targets', () async {
    final api = FakeContentApi({
      'campaign_archetypes': [
        {
          'campaign_id': 'campaign-1',
          'archetype_id': 'arch-killer',
          'weight': 1,
          'updated_at': '2026-06-01T09:00:00Z',
        },
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.pull();

    expect(await repo.archetypeIdsFor('campaign-1'), ['arch-killer']);
  });

  /// The bundled snapshot pins whatever ids the database held when it was
  /// generated, and a re-seeded server hands out different ones for the same
  /// campaign day. Keyed on id alone that reads as a second action for a day
  /// that can only have one, the unique index refuses it, and the pull dies
  /// there — taking every table after `actions` with it, silently, for as long
  /// as the app is installed.
  test(
    'an action re-issued under a new id replaces the row it identifies',
    () async {
      final seeded = ContentRepository(db: db, api: FakeContentApi(const {}));
      await seeded.applyRows({
        'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
        'actions': [actionRow('bundled-id', 'day-1', '2026-06-01T09:00:00Z')],
      });

      final repo = ContentRepository(
        db: db,
        api: FakeContentApi({
          'actions': [actionRow('server-id', 'day-1', '2026-06-02T09:00:00Z')],
        }),
      );
      await repo.pull();

      final rows = await db.select(db.actions).get();
      expect(
        rows.map((r) => r.id),
        ['server-id'],
        reason: 'one day of one campaign is one action, whatever it is called',
      );
    },
  );

  /// The other direction, which the natural key alone would miss: the id is
  /// stable and the day moved. Both are content edits, and neither may be the
  /// one that breaks the pull.
  test('an action that moves to another day keeps its identity', () async {
    final seeded = ContentRepository(db: db, api: FakeContentApi(const {}));
    await seeded.applyRows({
      'days': [
        dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z'),
        dayRow('day-2', 'campaign-1', 2, '2026-06-01T09:00:00Z'),
      ],
      'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
    });

    final repo = ContentRepository(
      db: db,
      api: FakeContentApi({
        'actions': [actionRow('action-1', 'day-2', '2026-06-02T09:00:00Z')],
      }),
    );
    await repo.pull();

    final rows = await db.select(db.actions).get();
    expect(rows.map((r) => (r.id, r.dayId)), [('action-1', 'day-2')]);
  });

  /// A day is the second table carrying both a uuid and a natural key, so it
  /// inherits the failure `_byIdOrNaturalKey` was written for: an authoring edit
  /// re-issues the id, the row arrives as an insert, UNIQUE(campaign_id,
  /// day_index) refuses it, and the whole pull dies there -- taking `actions`
  /// and everything after it with it, silently, for as long as the app is
  /// installed.
  test('a day re-issued under a new id replaces the row it identifies', () async {
    final seeded = ContentRepository(db: db, api: FakeContentApi(const {}));
    await seeded.applyRows({
      'days': [dayRow('bundled-day', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
    });

    final repo = ContentRepository(
      db: db,
      api: FakeContentApi({
        'days': [dayRow('server-day', 'campaign-1', 1, '2026-06-02T09:00:00Z')],
      }),
    );
    await repo.pull();

    final rows = await db.select(db.days).get();
    expect(
      rows.map((r) => r.id),
      ['server-day'],
      reason: 'one day of one campaign is one row, whatever it is called',
    );
  });

  /// The other direction, which the natural key alone would miss: the id is
  /// stable and the day moved to another position in the campaign.
  test('a day that moves position keeps its identity', () async {
    final seeded = ContentRepository(db: db, api: FakeContentApi(const {}));
    await seeded.applyRows({
      'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
    });

    final repo = ContentRepository(
      db: db,
      api: FakeContentApi({
        'days': [dayRow('day-1', 'campaign-1', 2, '2026-06-02T09:00:00Z')],
      }),
    );
    await repo.pull();

    final rows = await db.select(db.days).get();
    expect(rows.map((r) => (r.id, r.dayIndex)), [('day-1', 2)]);
  });

  /// Content can lag itself after a partial sync, and `days` is now the table
  /// `actions` depends on. Drift declares no foreign keys locally, so this must
  /// degrade to an absent day rather than an exception.
  test('an action whose day has not synced reads as an absent day', () async {
    final api = FakeContentApi({
      'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.pull();

    expect(
      await db.select(db.actions).get(),
      hasLength(1),
      reason: 'drift declares no foreign keys locally, so the row inserts',
    );
    expect(
      await repo.actionsFor('campaign-1'),
      isEmpty,
      reason: 'it simply fails to join, and the day reads as absent',
    );
  });
}
