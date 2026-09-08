import '../domain/diagnostic.dart';

/// The result of one sitting of the diagnostic.
class DiagnosticOutcome {
  const DiagnosticOutcome({
    required this.scores,
    required this.weakestArchetypeId,
  });

  /// Archetype id to relative score: wins over appearances, 0 to 1.
  ///
  /// Relative, never absolute. It says which drive loses when it competes, not
  /// how developed anyone is — copy must never claim a level (ADR-0009).
  final Map<String, double> scores;

  final String weakestArchetypeId;
}

/// Scores the forced-choice instrument.
///
/// Pure: no I/O, no clock, no randomness anywhere. The absence of randomness is
/// load-bearing — a retake with the same answers must always produce the same
/// recommendation.
class DiagnosticScorer {
  const DiagnosticScorer();

  DiagnosticOutcome score({
    required List<DiagnosticQuestion> questions,
    required List<DiagnosticPick> picks,
    required List<String> archetypeOrder,
  }) {
    if (questions.isEmpty) {
      throw ArgumentError.value(
        questions,
        'questions',
        'The instrument is empty',
      );
    }

    final byId = {for (final q in questions) q.id: q};

    // The archetype the user chose on each answered question. Picks that name
    // an unknown question, or an option that is not on that question, are
    // dropped — the UI should prevent both, and neither should corrupt a score.
    final chosen = <String, String>{};
    for (final pick in picks) {
      final question = byId[pick.questionId];
      if (question == null) continue;
      for (final option in question.options) {
        if (option.id == pick.optionId) {
          chosen[question.id] = option.archetypeId;
          break;
        }
      }
    }

    final appearances = <String, int>{};
    final wins = <String, int>{};
    for (final question in questions) {
      for (final option in question.options) {
        appearances.update(option.archetypeId, (n) => n + 1, ifAbsent: () => 1);
        wins.putIfAbsent(option.archetypeId, () => 0);
      }
    }
    for (final archetypeId in chosen.values) {
      wins.update(archetypeId, (n) => n + 1, ifAbsent: () => 1);
    }

    final scores = <String, double>{
      for (final entry in appearances.entries)
        entry.key: entry.value == 0 ? 0 : wins[entry.key]! / entry.value,
    };

    return DiagnosticOutcome(
      scores: scores,
      weakestArchetypeId: _weakest(
        scores: scores,
        questions: questions,
        chosen: chosen,
        archetypeOrder: archetypeOrder,
      ),
    );
  }

  String _weakest({
    required Map<String, double> scores,
    required List<DiagnosticQuestion> questions,
    required Map<String, String> chosen,
    required List<String> archetypeOrder,
  }) {
    final lowest = scores.values.reduce((a, b) => a < b ? a : b);
    var candidates = scores.entries
        .where((e) => (e.value - lowest).abs() < 1e-9)
        .map((e) => e.key)
        .toList();

    if (candidates.length == 1) return candidates.first;

    // Tie-break 1: head-to-head. Among the tied archetypes, the one that lost
    // most often when it met another tied archetype is the weaker.
    final tied = candidates.toSet();
    final losses = {for (final id in candidates) id: 0};
    for (final question in questions) {
      final contenders = question.options.map((o) => o.archetypeId).toSet();
      if (!tied.containsAll(contenders) || contenders.length < 2) continue;

      final winner = chosen[question.id];
      if (winner == null) continue;
      for (final id in contenders) {
        if (id != winner) losses[id] = losses[id]! + 1;
      }
    }

    final mostLosses = losses.values.reduce((a, b) => a > b ? a : b);
    candidates = candidates.where((id) => losses[id] == mostLosses).toList();
    if (candidates.length == 1) return candidates.first;

    // Tie-break 2: the archetypes' fixed order. Deterministic by construction,
    // and never the map's iteration order.
    for (final id in archetypeOrder) {
      if (candidates.contains(id)) return id;
    }
    candidates.sort();
    return candidates.first;
  }
}
