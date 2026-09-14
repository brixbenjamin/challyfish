/// A designed arc of fixed length. Hand-authored; belongs to a pack.
class Campaign {
  const Campaign({
    required this.id,
    required this.packId,
    required this.key,
    required this.title,
    required this.introMd,
    required this.lengthDays,
    this.subtitle,
    this.rampDays = 0,
    this.difficulty = 1,
    this.sort = 0,
  });

  final String id;
  final String packId;
  final String key;
  final String title;
  final String? subtitle;
  final String introMd;
  final int lengthDays;
  final int rampDays;
  final int difficulty;

  /// Authoring order within the pack. Carried on the domain type because the
  /// recommendation ranks by (difficulty, sort) and must not depend on a
  /// query's incidental ordering.
  final int sort;
}

/// Turns the integer shares content authoring writes into the weights an
/// [ActionSpec] carries.
///
/// A share is a ratio numerator, not a multiplier: whatever the shares are, the
/// result sums to 1, so an action contributes exactly its own `effort` however
/// it is split. That is the property that makes splitting safe to add — see
/// ActionSpec.archetypeWeights.
///
/// An empty or non-positive input yields an empty map rather than throwing.
/// Content can lag progress after a partial sync, and an action whose archetype
/// rows have not arrived must degrade the same way an uncached action does.
Map<String, double> archetypeWeightsFromShares(Map<String, int> shares) {
  var total = 0;
  for (final share in shares.values) {
    if (share > 0) total += share;
  }
  if (total == 0) return const {};
  return {
    for (final entry in shares.entries)
      if (entry.value > 0) entry.key: entry.value / total,
  };
}

/// One action within a campaign day. A day holds one mandatory action and zero
/// or more optional ones (ADR-0030).
class ActionSpec {
  const ActionSpec({
    required this.id,
    required this.campaignId,
    required this.dayIndex,
    required this.title,
    this.bodyMd,
    required this.archetypeWeights,
    this.whyDoctrineId,
    this.effort = 1,
    this.isOptional = false,
    this.sort = 0,
  });

  final String id;
  final String campaignId;

  /// 1-based. Contiguous from 1 to the campaign's lengthDays.
  final int dayIndex;
  final String title;

  /// Null when the copy is not available: a locked pack, or an owned pack
  /// whose bodies have not been pulled yet (ADR-0025). Callers degrade to the
  /// existing "content unavailable" path rather than failing.
  final String? bodyMd;

  /// How this action's effort is apportioned across archetypes, as fractions
  /// that sum to 1 — never the raw authoring shares. An action that serves two
  /// drives splits its points between them rather than paying both in full,
  /// which is what keeps a multi-tagged action from being worth more than a
  /// single-tagged one of the same effort (amends ADR-0004's one tag per
  /// action).
  ///
  /// Usually one entry at weight 1.0, which is arithmetically identical to the
  /// single `archetypeId` this replaced. Empty is a real state, not a failure:
  /// an action whose archetype rows have not been pulled yet contributes
  /// nothing to the balance and its full effort to the points total, the same
  /// way an uncached action does.
  final Map<String, double> archetypeWeights;
  final String? whyDoctrineId;

  /// The action's points value, shown to the user as authored. The balance
  /// divides it by `pointsPerFullDay`; nothing else does (ADR-0030).
  final int effort;

  /// False for the day's one mandatory action — the one the grade depends on.
  final bool isOptional;

  /// Display order within the day. The mandatory action sorts first.
  final int sort;
}
