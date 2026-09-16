import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/clock.dart';
import '../../domain/diagnostic.dart';
import '../../engine/diagnostic_scorer.dart';
import '../local/database.dart';
import 'outbox.dart';
import 'content_repository.dart';

class StoredDiagnostic {
  const StoredDiagnostic({
    required this.scores,
    required this.weakestArchetypeId,
    required this.recommendedCampaignId,
    required this.takenAt,
  });

  /// Archetype **key** to relative score, so the stored JSON stays readable and
  /// survives a content id changing.
  final Map<String, double> scores;
  final String weakestArchetypeId;
  final String recommendedCampaignId;
  final DateTime takenAt;
}

/// Reads the instrument, scores a sitting, and stores the result.
class DiagnosticRepository {
  // Fields are public (not `_db`/`_content`/`_clock`/`_scorer`) so the
  // constructor can use initializing formals — see ContentRepository for the
  // same reasoning.
  DiagnosticRepository({
    required this.db,
    required this.content,
    required this.clock,
    this.scorer = const DiagnosticScorer(),
  });

  final FeralDatabase db;
  final ContentRepository content;
  final Clock clock;
  final DiagnosticScorer scorer;
  final Uuid _uuid = const Uuid();

  Future<List<DiagnosticQuestion>> questions() => content.diagnosticQuestions();

  Future<bool> hasCompleted(String userId) async =>
      (await latestFor(userId)) != null;

  Future<StoredDiagnostic?> latestFor(String userId) async {
    final row =
        await (db.select(db.diagnosticResults)
              ..where((r) => r.userId.equals(userId))
              ..orderBy([
                (r) => OrderingTerm(
                  expression: r.takenAt,
                  mode: OrderingMode.desc,
                ),
              ])
              ..limit(1))
            .getSingleOrNull();
    if (row == null) return null;

    final decoded = (jsonDecode(row.scores) as Map<String, dynamic>).map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return StoredDiagnostic(
      scores: decoded,
      weakestArchetypeId: row.weakestArchetypeId,
      recommendedCampaignId: row.recommendedCampaignId,
      // Drift stores a DateTime as unix seconds and hands it back flagged
      // local. Same instant, but the repository's contract is UTC — as the
      // clock's is — so normalise here rather than leaving every caller to
      // remember.
      takenAt: row.takenAt.toUtc(),
    );
  }

  Future<StoredDiagnostic> submit({
    required String userId,
    required List<DiagnosticPick> picks,
  }) async {
    final questions = await this.questions();
    final archetypes = await content.archetypesById();

    // Ordered by `sort` — this is the final, deterministic tie-break.
    final order = archetypes.values.toList()
      ..sort((a, b) => a.sort.compareTo(b.sort));

    final outcome = scorer.score(
      questions: questions,
      picks: picks,
      archetypeOrder: order.map((a) => a.id).toList(),
    );

    final recommended = await _recommendFor(outcome.weakestArchetypeId);
    final now = clock.nowUtc();

    // Stored by archetype key rather than id: readable, and it survives a
    // content id changing under us.
    final byKey = {
      for (final entry in outcome.scores.entries)
        if (archetypes[entry.key] != null)
          archetypes[entry.key]!.key: entry.value,
    };

    final id = _uuid.v4();

    // Cache and queue together, as in ProgressRepository: a sitting stored
    // without being queued is a diagnostic the account never receives, and the
    // router routes a returning user on whether the account has one.
    await db.transaction(() async {
      await db
          .into(db.diagnosticResults)
          .insert(
            DiagnosticResultsCompanion.insert(
              id: id,
              userId: userId,
              takenAt: now,
              scores: jsonEncode(byKey),
              weakestArchetypeId: outcome.weakestArchetypeId,
              recommendedCampaignId: recommended,
              updatedAt: now,
            ),
          );

      final row = await (db.select(
        db.diagnosticResults,
      )..where((d) => d.id.equals(id))).getSingle();
      await OutboxQueue(
        db: db,
        clock: clock.nowUtc,
      ).add(entryForDiagnostic(row));
    });

    return StoredDiagnostic(
      scores: byKey,
      weakestArchetypeId: outcome.weakestArchetypeId,
      recommendedCampaignId: recommended,
      takenAt: now,
    );
  }

  /// The easiest core-pack campaign targeting the weak archetype.
  ///
  /// Falls back to any core campaign when nothing targets it: a library that
  /// does not yet cover all four archetypes must not produce a dead end on the
  /// most important screen in the product.
  Future<String> _recommendFor(String archetypeId) async {
    final packs = await content.packs();
    final core = packs.where((p) => p.isCore).toList();
    if (core.isEmpty) {
      throw StateError(
        'No core pack: the app cannot recommend a first campaign',
      );
    }

    final candidates = <_Candidate>[];
    final fallbacks = <_Candidate>[];

    for (final pack in core) {
      for (final campaign in await content.campaignsFor(pack.id)) {
        final targets = await content.archetypeIdsFor(campaign.id);
        final candidate = _Candidate(
          campaign.id,
          campaign.difficulty,
          campaign.sort,
        );
        (targets.contains(archetypeId) ? candidates : fallbacks).add(candidate);
      }
    }

    final pool = candidates.isNotEmpty ? candidates : fallbacks;
    if (pool.isEmpty) {
      throw StateError('The core pack contains no campaigns');
    }

    pool.sort((a, b) {
      final byDifficulty = a.difficulty.compareTo(b.difficulty);
      return byDifficulty != 0 ? byDifficulty : a.sort.compareTo(b.sort);
    });
    return pool.first.campaignId;
  }
}

class _Candidate {
  const _Candidate(this.campaignId, this.difficulty, this.sort);

  final String campaignId;
  final int difficulty;
  final int sort;
}
