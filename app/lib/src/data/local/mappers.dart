import '../../domain/campaign.dart';
import 'database.dart';

/// Maps between the Drift-generated row classes and the domain types the rest
/// of the app reads. Kept separate from `ContentRepository` so the repository
/// stays about the pull/read flow, not the shape translation.
///
/// `CampaignRow` and `ActionRow` are the Drift row classes, named by the
/// `@DataClassName` annotations on the content tables — distinct from the
/// domain types `Campaign` and `ActionSpec` below.
Campaign toCampaign(CampaignRow row) => Campaign(
  id: row.id,
  packId: row.packId,
  key: row.key,
  title: row.title,
  subtitle: row.subtitle,
  introMd: row.introMd,
  lengthDays: row.lengthDays,
  rampDays: row.rampDays,
  difficulty: row.difficulty,
  sort: row.sort,
);

ActionSpec toAction(ActionRow row) => ActionSpec(
  id: row.id,
  campaignId: row.campaignId,
  dayIndex: row.dayIndex,
  title: row.title,
  bodyMd: row.bodyMd,
  archetypeId: row.archetypeId,
  whyDoctrineId: row.whyDoctrineId,
  effort: row.effort,
);
