/// One side of a forced-choice pair. Choosing it is a win for its archetype.
class DiagnosticOption {
  const DiagnosticOption({
    required this.id,
    required this.questionId,
    required this.label,
    required this.archetypeId,
    required this.sort,
  });

  final String id;
  final String questionId;
  final String label;
  final String archetypeId;
  final int sort;
}

/// One forced-choice pair: two options, on two different archetypes, with no
/// neutral answer (ADR-0009).
class DiagnosticQuestion {
  const DiagnosticQuestion({
    required this.id,
    required this.prompt,
    required this.sort,
    required this.options,
  });

  final String id;
  final String prompt;
  final int sort;

  /// Exactly two, ordered by `sort`. Enforced by content validation.
  final List<DiagnosticOption> options;

  Iterable<String> get archetypeIds => options.map((o) => o.archetypeId);
}

/// What the user chose on one question.
class DiagnosticPick {
  const DiagnosticPick({required this.questionId, required this.optionId});

  final String questionId;
  final String optionId;
}
