import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/archetype.dart';
import '../../domain/campaign.dart';
import '../../domain/day.dart';
import '../theme/archetype_tag.dart';
import '../theme/theme_context.dart';

/// What the user is agreeing to, before they agree to it.
class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({
    required this.campaign,
    required this.targets,
    required this.missAllowance,
    required this.days,
    required this.archetypesById,
    required this.isUnlocked,
    required this.hasActiveRun,
    required this.onStart,
    required this.onUnlock,
    super.key,
  });

  final Campaign campaign;
  final List<Archetype> targets;

  /// Differs per campaign (ADR-0012), so it is stated here rather than left to
  /// a help article the user will never read.
  final int missAllowance;

  /// The campaign's days in order, for the day-by-day preview strip below the
  /// intro. Shown the same whether [isUnlocked] or not — number, title and
  /// primary drive are exactly what the glossary's Teaser already permits for
  /// a locked pack; the day's own body and its actions stay behind the
  /// commit regardless.
  final List<DaySpec> days;

  /// Resolves a day's [DaySpec.primaryArchetypeId] to the [Archetype] its
  /// preview dot is drawn in. A day carries only the id.
  final Map<String, Archetype> archetypesById;

  final bool isUnlocked;
  final bool hasActiveRun;
  final VoidCallback onStart;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(campaign.title)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.sp24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (campaign.subtitle != null) ...[
              Text(
                campaign.subtitle!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: tokens.mutedInk,
                ),
              ),
              SizedBox(height: tokens.sp16),
            ],
            Row(
              children: [
                Text(
                  l10n.lengthInDays(campaign.lengthDays),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.mutedInk,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                if (targets.isNotEmpty) ...[
                  SizedBox(width: tokens.sp12),
                  ArchetypeTag(archetypes: targets),
                ],
              ],
            ),
            SizedBox(height: tokens.sp4),
            Text(
              l10n.missesAllowed(missAllowance),
              style: theme.textTheme.labelMedium?.copyWith(
                color: tokens.mutedInk,
              ),
            ),
            SizedBox(height: tokens.sp24),
            Text(
              campaign.introMd,
              style: theme.textTheme.bodyMedium?.copyWith(color: tokens.ink),
            ),
            if (days.isNotEmpty) ...[
              SizedBox(height: tokens.sp32),
              Text(
                l10n.campaignDaysHeading,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: tokens.ink,
                ),
              ),
              SizedBox(height: tokens.sp8),
              ClipRRect(
                borderRadius: BorderRadius.circular(tokens.r4),
                child: ColoredBox(
                  color: tokens.surface1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final day in days)
                        _DayRow(
                          day: day,
                          archetype: day.primaryArchetypeId == null
                              ? null
                              : archetypesById[day.primaryArchetypeId],
                          isLast: day == days.last,
                        ),
                    ],
                  ),
                ),
              ),
            ],
            SizedBox(height: tokens.sp32),
            if (!isUnlocked)
              FilledButton(
                onPressed: onUnlock,
                child: Text(l10n.unlockButton),
              )
            else ...[
              if (hasActiveRun)
                // Abandoning is the only destructive action in the product. Say
                // what it costs before the tap, not after.
                Padding(
                  padding: EdgeInsets.only(bottom: tokens.sp12),
                  child: Text(
                    l10n.abandonActiveRunWarning,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: tokens.mutedInk,
                    ),
                  ),
                ),
              FilledButton(
                onPressed: onStart,
                child: Text(
                  hasActiveRun ? l10n.abandonAndStartButton : l10n.startButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One row of the day preview: position, title, and — only when the day
/// names a drive — that drive's dot-and-label tag (the Named-Drive Rule). A
/// rest day carries no [DaySpec.primaryArchetypeId], so it shows no tag
/// rather than needing a separate "rest" glyph — the rhythm of the campaign
/// reads through where the dots fall, not through invented iconography.
class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.archetype, required this.isLast});

  final DaySpec day;
  final Archetype? archetype;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: tokens.hairline)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.sp16,
          vertical: tokens.sp12,
        ),
        child: Row(
          children: [
            Text(
              l10n.dayPreviewNumber(day.dayIndex),
              style: theme.textTheme.labelMedium?.copyWith(
                color: tokens.mutedInk,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            SizedBox(width: tokens.sp16),
            Expanded(
              child: Text(
                day.title,
                style: theme.textTheme.bodyLarge?.copyWith(color: tokens.ink),
              ),
            ),
            if (archetype != null) ...[
              SizedBox(width: tokens.sp12),
              ArchetypeTag(archetypes: [archetype!]),
            ],
          ],
        ),
      ),
    );
  }
}
