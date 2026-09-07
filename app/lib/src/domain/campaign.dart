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
}

/// One day's assignment within a campaign. Carries exactly one archetype.
class ActionSpec {
  const ActionSpec({
    required this.id,
    required this.campaignId,
    required this.dayIndex,
    required this.title,
    required this.bodyMd,
    required this.archetypeId,
    this.whyDoctrineId,
    this.effort = 1,
  });

  final String id;
  final String campaignId;

  /// 1-based. Contiguous from 1 to the campaign's lengthDays.
  final int dayIndex;
  final String title;
  final String bodyMd;
  final String archetypeId;
  final String? whyDoctrineId;
  final int effort;
}
