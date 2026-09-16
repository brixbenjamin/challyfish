import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/diagnostic_repository.dart';
import 'package:feral/src/domain/diagnostic.dart';
import 'package:test/test.dart';

void main() {
  late FeralDatabase db;
  late DiagnosticRepository repo;
  final now = DateTime.utc(2026, 6, 1, 9);

  Future<void> seedArchetype(String id, String key, int sort) => db
      .into(db.archetypes)
      .insert(
        ArchetypesCompanion.insert(
          id: id,
          key: key,
          name: key,
          blurb: 'b',
          color: '#000',
          sort: sort,
          updatedAt: now,
        ),
      );

  Future<void> seedCampaign(
    String id,
    String archetypeId, {
    int difficulty = 1,
    int sort = 1,
    String packId = 'pack-core',
  }) async {
    await db
        .into(db.campaigns)
        .insert(
          CampaignsCompanion.insert(
            id: id,
            packId: packId,
            key: id,
            title: id,
            introMd: 'i',
            lengthDays: 7,
            difficulty: Value(difficulty),
            sort: sort,
            updatedAt: now,
          ),
        );
    await db
        .into(db.campaignArchetypes)
        .insert(
          CampaignArchetypesCompanion.insert(
            campaignId: id,
            archetypeId: archetypeId,
            updatedAt: now,
          ),
        );
  }

  Future<void> seedPair(int n, String a, String b) async {
    await db
        .into(db.diagnosticQuestions)
        .insert(
          DiagnosticQuestionsCompanion.insert(
            id: 'q$n',
            prompt: 'Closer to you?',
            sort: n,
            updatedAt: now,
          ),
        );
    await db
        .into(db.diagnosticOptions)
        .insert(
          DiagnosticOptionsCompanion.insert(
            id: 'q${n}a',
            questionId: 'q$n',
            label: a,
            archetypeId: a,
            sort: 0,
            updatedAt: now,
          ),
        );
    await db
        .into(db.diagnosticOptions)
        .insert(
          DiagnosticOptionsCompanion.insert(
            id: 'q${n}b',
            questionId: 'q$n',
            label: b,
            archetypeId: b,
            sort: 1,
            updatedAt: now,
          ),
        );
  }

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    repo = DiagnosticRepository(
      db: db,
      content: ContentRepository(db: db, api: _NoopApi()),
      clock: FixedClock(now),
    );

    await seedArchetype('a-psycho', 'psycho', 1);
    await seedArchetype('a-killer', 'killer', 2);
    await db
        .into(db.packs)
        .insert(
          PacksCompanion.insert(
            id: 'pack-core',
            key: 'core',
            title: 'Core',
            description: 'd',
            isCore: const Value(true),
            sort: 1,
            updatedAt: now,
          ),
        );
    await seedPair(1, 'a-psycho', 'a-killer');
    await seedPair(2, 'a-psycho', 'a-killer');
  });
  tearDown(() => db.close());

  test('questions come back in order with both options', () async {
    final questions = await repo.questions();
    expect(questions.map((q) => q.id), ['q1', 'q2']);
    expect(questions.first.options, hasLength(2));
  });

  test('submitting stores the scores and the weakest archetype', () async {
    await seedCampaign('c-psycho', 'a-psycho');

    final stored = await repo.submit(
      userId: 'user-1',
      picks: const [
        DiagnosticPick(questionId: 'q1', optionId: 'q1b'),
        DiagnosticPick(questionId: 'q2', optionId: 'q2b'),
      ],
    );

    expect(stored.weakestArchetypeId, 'a-psycho');
    expect(stored.recommendedCampaignId, 'c-psycho');
    expect(stored.takenAt, now);
  });

  test(
    'the stored row keeps only scores, never the individual picks',
    () async {
      await seedCampaign('c-psycho', 'a-psycho');
      await repo.submit(
        userId: 'user-1',
        picks: const [DiagnosticPick(questionId: 'q1', optionId: 'q1b')],
      );

      final row = await db.select(db.diagnosticResults).getSingle();
      expect(row.scores, contains('psycho'));
      expect(
        row.scores,
        isNot(contains('q1')),
        reason: 'answers are never stored (ADR-0009)',
      );
      final queued = await (db.select(
        db.outbox,
      )..where((o) => o.remoteTable.equals('diagnostic_results'))).getSingle();
      expect(queued.rowKey, row.id);
    },
  );

  test(
    'the recommendation prefers the easiest campaign for the weak archetype',
    () async {
      await seedCampaign('c-hard', 'a-psycho', difficulty: 3, sort: 1);
      await seedCampaign('c-easy', 'a-psycho', difficulty: 1, sort: 2);

      final stored = await repo.submit(
        userId: 'user-1',
        picks: const [
          DiagnosticPick(questionId: 'q1', optionId: 'q1b'),
          DiagnosticPick(questionId: 'q2', optionId: 'q2b'),
        ],
      );

      expect(stored.recommendedCampaignId, 'c-easy');
    },
  );

  test(
    'falls back to any core campaign when none targets the weak archetype',
    () async {
      // A library that does not yet cover all four archetypes must not produce a
      // dead end on the most important screen in the product.
      await seedCampaign('c-killer', 'a-killer');

      final stored = await repo.submit(
        userId: 'user-1',
        picks: const [
          DiagnosticPick(questionId: 'q1', optionId: 'q1b'),
          DiagnosticPick(questionId: 'q2', optionId: 'q2b'),
        ],
      );

      expect(stored.weakestArchetypeId, 'a-psycho');
      expect(stored.recommendedCampaignId, 'c-killer');
    },
  );

  test(
    'throws rather than recommending nothing when the library is empty',
    () async {
      expect(
        () => repo.submit(
          userId: 'user-1',
          picks: const [DiagnosticPick(questionId: 'q1', optionId: 'q1b')],
        ),
        throwsStateError,
      );
    },
  );

  test('a retake adds a row and latestFor returns the newest', () async {
    await seedCampaign('c-psycho', 'a-psycho');
    await repo.submit(
      userId: 'user-1',
      picks: const [DiagnosticPick(questionId: 'q1', optionId: 'q1b')],
    );

    final later = DiagnosticRepository(
      db: db,
      content: ContentRepository(db: db, api: _NoopApi()),
      clock: FixedClock(DateTime.utc(2026, 8, 1, 9)),
    );
    await later.submit(
      userId: 'user-1',
      picks: const [DiagnosticPick(questionId: 'q1', optionId: 'q1a')],
    );

    expect(
      await db.select(db.diagnosticResults).get(),
      hasLength(2),
      reason: 'a retake never destroys the original reading',
    );
    expect(
      (await later.latestFor('user-1'))!.takenAt,
      DateTime.utc(2026, 8, 1, 9),
    );
  });

  test('hasCompleted is false before and true after', () async {
    await seedCampaign('c-psycho', 'a-psycho');
    expect(await repo.hasCompleted('user-1'), isFalse);
    await repo.submit(
      userId: 'user-1',
      picks: const [DiagnosticPick(questionId: 'q1', optionId: 'q1b')],
    );
    expect(await repo.hasCompleted('user-1'), isTrue);
  });
}

class _NoopApi implements ContentApi {
  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async => [];

  @override
  Future<int> fetchVersion() async => 1;
}
