import 'dart:io';

import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/domain/day.dart';
import 'package:test/test.dart';

import '../support/database.dart';
import '../support/fake_content_api.dart';

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

  setUp(() => db = memoryDatabase());
  tearDown(() => db.close());

  test('a first pull fetches everything and stores it', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
      'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
      'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);

    await repo.refresh();

    expect(await db.select(db.archetypes).get(), hasLength(1));
    expect(await db.select(db.actions).get(), hasLength(1));
  });

  test('a second refresh at the same version fetches nothing', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);

    expect(await repo.refresh(), isTrue);
    api.fetched.clear();

    // The whole point of the version: a launch that finds the library unchanged
    // costs one integer, not the library.
    expect(await repo.refresh(), isFalse);
    expect(api.fetched, isEmpty);
  });

  test('a moved version refetches, and force ignores the gate', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    api.version = 2;
    api.fetched.clear();
    expect(await repo.refresh(), isTrue);
    expect(api.fetched, isNotEmpty);

    // A purchase and a sign-in change who may read the body tables without
    // changing the library, so they force past the gate (ADR-0025, ADR-0034).
    api.fetched.clear();
    expect(await repo.refresh(force: true), isTrue);
    expect(api.fetched, isNotEmpty);
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
      await repo.refresh();

      api.rows['archetypes'] = [
        archetypeRow('arch-1', 'renamed', '2026-06-02T09:00:00Z'),
      ];
      api.version = 2;
      await repo.refresh();

      final stored = await db.select(db.archetypes).get();
      expect(stored, hasLength(1));
      expect(stored.single.key, 'renamed');
    },
  );

  test('dayFor hands back the day mandatory action, hydrated', () async {
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
    await repo.refresh();

    final action = (await repo.dayFor('campaign-1', 2))?.mandatory;
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
      await repo.refresh();

      final action = (await repo.dayFor('campaign-1', 1))?.mandatory;
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
      await repo.refresh();

      final action = (await repo.dayFor('campaign-1', 1))?.mandatory;
      expect(action?.archetypeWeights, isEmpty);
    },
  );

  test('a refresh covers every content table', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);

    await repo.refresh();

    expect(api.fetched.toSet(), {
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

  test('a row deleted on the server disappears from the cache', () async {
    final api = FakeContentApi({
      'archetypes': [
        archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z'),
        archetypeRow('arch-2', 'psycho', '2026-06-01T09:00:00Z'),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();
    expect(await db.select(db.archetypes).get(), hasLength(2));

    // The reason this repository stopped merging. A deleted row carries no newer
    // `updated_at`, so the incremental pull this replaced could never see it go:
    // the row sat below the watermark and survived until the app was reinstalled.
    api.rows['archetypes'] = [
      archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z'),
    ];
    api.version = 2;
    await repo.refresh();

    final stored = await db.select(db.archetypes).get();
    expect(stored, hasLength(1));
    expect(stored.single.id, 'arch-1');
  });

  test('a fetch that fails part way through leaves the cache intact', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
      'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    // A throw is "we did not find out", never "the library is empty" (ADR-0025).
    // Deleting first and fetching second would have emptied the app instead.
    api.rows['archetypes'] = [
      archetypeRow('arch-1', 'renamed', '2026-06-02T09:00:00Z'),
    ];
    api.version = 2;
    api.failTable['actions'] = const SocketException('offline');

    await expectLater(repo.refresh(), throwsA(isA<SocketException>()));

    final stored = await db.select(db.archetypes).get();
    expect(stored.single.key, 'killer', reason: 'the old cache survives');
    expect(await db.select(db.days).get(), hasLength(1));
    expect(
      await repo.cachedVersion(),
      1,
      reason: 'a version recorded here would skip the refetch still owed',
    );
  });

  test('a server with no library at all leaves the cache alone', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    // Distinct from a deletion: every table empty is an empty server, not a
    // library that lost a row. Wiping the bundled snapshot on that answer would
    // leave a fresh install with nothing to show.
    api.rows.clear();
    api.version = 2;
    expect(await repo.refresh(), isFalse);
    expect(await db.select(db.archetypes).get(), hasLength(1));
  });

  test('both body tables are fetched whole, never incrementally', () async {
    final api = FakeContentApi({
      'archetypes': [archetypeRow('arch-1', 'killer', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);

    await repo.refresh();

    // What the watermark-priming trap used to be about: a mark taken from the
    // free pack's bodies sat above every paid body's timestamp, so a purchase
    // delivered nothing (ADR-0025, ADR-0034). A whole-table fetch has no mark to
    // get wrong, and row-level security decides what comes back.
    expect(api.fetched, contains('action_bodies'));
    expect(api.fetched, contains('day_bodies'));
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
    await repo.refresh();

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
          'archetype_id': 'arch-trickster',
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
    await repo.refresh();

    final questions = await repo.diagnosticQuestions();
    expect(questions, hasLength(1));
    expect(questions.single.options.map((o) => o.archetypeId), [
      'arch-trickster',
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
    await repo.refresh();

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
      await repo.refresh();

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
    await repo.refresh();

    final rows = await db.select(db.actions).get();
    expect(rows.map((r) => (r.id, r.dayId)), [('action-1', 'day-2')]);
  });

  /// A day is the second table carrying both a uuid and a natural key, so it
  /// inherits the failure `_byIdOrNaturalKey` was written for: an authoring edit
  /// re-issues the id, the row arrives as an insert, UNIQUE(campaign_id,
  /// day_index) refuses it, and the whole pull dies there -- taking `actions`
  /// and everything after it with it, silently, for as long as the app is
  /// installed.
  test(
    'a day re-issued under a new id replaces the row it identifies',
    () async {
      final seeded = ContentRepository(db: db, api: FakeContentApi(const {}));
      await seeded.applyRows({
        'days': [
          dayRow('bundled-day', 'campaign-1', 1, '2026-06-01T09:00:00Z'),
        ],
      });

      final repo = ContentRepository(
        db: db,
        api: FakeContentApi({
          'days': [
            dayRow('server-day', 'campaign-1', 1, '2026-06-02T09:00:00Z'),
          ],
        }),
      );
      await repo.refresh();

      final rows = await db.select(db.days).get();
      expect(
        rows.map((r) => r.id),
        ['server-day'],
        reason: 'one day of one campaign is one row, whatever it is called',
      );
    },
  );

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
    await repo.refresh();

    final rows = await db.select(db.days).get();
    expect(rows.map((r) => (r.id, r.dayIndex)), [('day-1', 2)]);
  });

  test('dayFor returns the day with its actions, mandatory first', () async {
    final api = FakeContentApi({
      'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
      'day_bodies': [
        {
          'day_id': 'day-1',
          'body_md': 'what today asks',
          'updated_at': '2026-06-01T09:00:00Z',
        },
      ],
      'actions': [
        // Two optionals, authored out of `sort` order and arriving before the
        // mandatory action, so neither ordering term can pass by accident of
        // arrival order.
        actionRow(
          'a-optional-2',
          'day-1',
          '2026-06-01T09:00:00Z',
          isOptional: true,
          sort: 2,
        ),
        actionRow(
          'a-optional-1',
          'day-1',
          '2026-06-01T09:00:00Z',
          isOptional: true,
          sort: 1,
        ),
        actionRow('a-mandatory', 'day-1', '2026-06-01T09:00:00Z'),
      ],
      'action_archetypes': [
        actionArchetypeRow('a-mandatory', 'arch-1', '2026-06-01T09:00:00Z'),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    final day = await repo.dayFor('campaign-1', 1);
    expect(day?.title, 'Day 1');
    expect(day?.kind, DayKind.standard);
    expect(day?.bodyMd, 'what today asks');
    expect(
      day?.actions.map((a) => a.id),
      ['a-mandatory', 'a-optional-1', 'a-optional-2'],
      reason: 'mandatory first, then by sort -- never by arrival order',
    );
    expect(day?.mandatory?.id, 'a-mandatory');
    expect(day?.optionals.map((a) => a.id), ['a-optional-1', 'a-optional-2']);
  });

  test(
    'dayFor returns null rather than throwing for an uncached day',
    () async {
      // The surface must degrade to a recoverable "content unavailable" state.
      final repo = ContentRepository(db: db, api: FakeContentApi(const {}));
      await repo.refresh();
      expect(await repo.dayFor('campaign-1', 1), isNull);
    },
  );

  test('a day whose body has not arrived is a day, not a failure', () async {
    // A locked pack, or an owned pack mid-pull. Exactly the state ActionSpec
    // already models with a null bodyMd (ADR-0025).
    final api = FakeContentApi({
      'days': [dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    final day = await repo.dayFor('campaign-1', 1);
    expect(day, isNotNull);
    expect(day?.bodyMd, isNull);
    expect(day?.actions, isEmpty);
    expect(day?.mandatory, isNull);
  });

  test('a rest day reads as a rest day', () async {
    final api = FakeContentApi({
      'days': [
        dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z', kind: 'rest'),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    expect((await repo.dayFor('campaign-1', 1))?.kind, DayKind.rest);
  });

  test('an unknown kind degrades to standard rather than throwing', () async {
    // Content authored against a newer app than this one. The surface loses a
    // presentation nuance; it does not lose the day.
    final api = FakeContentApi({
      'days': [
        dayRow(
          'day-1',
          'campaign-1',
          1,
          '2026-06-01T09:00:00Z',
          kind: 'bridge',
        ),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    expect((await repo.dayFor('campaign-1', 1))?.kind, DayKind.standard);
  });

  test('daysFor returns the campaign in day order', () async {
    final api = FakeContentApi({
      'days': [
        dayRow('day-2', 'campaign-1', 2, '2026-06-01T09:00:00Z'),
        dayRow('day-1', 'campaign-1', 1, '2026-06-01T09:00:00Z'),
        dayRow('other', 'campaign-2', 1, '2026-06-01T09:00:00Z'),
      ],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

    expect(
      (await repo.daysFor('campaign-1')).map((d) => d.dayIndex),
      [1, 2],
      reason: 'ordered by day_index, not by arrival',
    );
  });

  /// Content can lag itself after a partial sync, and `days` is now the table
  /// `actions` depends on. Drift declares no foreign keys locally, so this must
  /// degrade to an absent day rather than an exception.
  test('an action whose day has not synced reads as an absent day', () async {
    final api = FakeContentApi({
      'actions': [actionRow('action-1', 'day-1', '2026-06-01T09:00:00Z')],
    });
    final repo = ContentRepository(db: db, api: api);
    await repo.refresh();

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
