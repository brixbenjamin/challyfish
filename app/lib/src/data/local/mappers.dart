import '../../domain/campaign.dart';
import '../../domain/day.dart';
import 'database.dart';

/// Maps between the Drift-generated row classes and the domain types the rest
/// of the app reads. Kept separate from `ContentRepository` so the repository
/// stays about the pull/read flow, not the shape translation.
///
/// `CampaignRow`, `DayRow` and `ActionRow` are the Drift row classes, named by
/// the `@DataClassName` annotations on the content tables — distinct from the
/// domain types `Campaign`, `DaySpec` and `ActionSpec` below.
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

/// [shares] are the action's authored integer shares, keyed by archetype id,
/// normalised here into the weights the domain type carries. Empty is a real
/// state — an action cached ahead of its archetype rows — and the domain type
/// documents how it degrades.
///
/// A null [body] is a real state too, not a failure: a locked pack, or an owned
/// pack whose bodies have not been pulled yet. Callers degrade to the existing
/// "content unavailable" path (ADR-0025).
/// A null [body] is a real state, not a failure: a locked pack, or an owned
/// pack whose bodies have not been pulled yet (ADR-0025, ADR-0034).
///
/// [actions] arrive already ordered — mandatory first, then by `sort` — because
/// the ordering is the repository's query, not this function's arithmetic.
DaySpec toDay(DayRow row, List<ActionSpec> actions, [DayBodyRow? body]) =>
    DaySpec(
      id: row.id,
      campaignId: row.campaignId,
      dayIndex: row.dayIndex,
      title: row.title,
      kind: DayKind.fromKey(row.kind),
      primaryArchetypeId: row.primaryArchetypeId,
      bodyMd: body?.bodyMd,
      actions: actions,
    );

ActionSpec toAction(
  ActionRow row,
  Map<String, int> shares, [
  ActionBodyRow? body,
]) => ActionSpec(
  id: row.id,
  dayId: row.dayId,
  title: row.title,
  bodyMd: body?.bodyMd,
  archetypeWeights: archetypeWeightsFromShares(shares),
  whyDoctrineId: row.whyDoctrineId,
  effort: row.effort,
  isOptional: row.isOptional,
  sort: row.sort,
);
