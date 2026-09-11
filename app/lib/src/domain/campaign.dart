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

/// One action within a campaign day. Carries exactly one archetype (ADR-0004).
/// A day holds one mandatory action and zero or more optional ones (ADR-0030).
class ActionSpec {
  const ActionSpec({
    required this.id,
    required this.campaignId,
    required this.dayIndex,
    required this.title,
    this.bodyMd,
    required this.archetypeId,
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
  final String archetypeId;
  final String? whyDoctrineId;

  /// The action's points value, shown to the user as authored. The balance
  /// divides it by `pointsPerFullDay`; nothing else does (ADR-0030).
  final int effort;

  /// False for the day's one mandatory action — the one the grade depends on.
  final bool isOptional;

  /// Display order within the day. The mandatory action sorts first.
  final int sort;
}
