import 'dart:ui' show ImageFilter;

import 'package:cached_network_image/cached_network_image.dart';
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
  /// intro. Paced the same whether [isUnlocked] or not: most days beyond the
  /// reveal window fog their title behind a blur rather than spell it out
  /// (ADR-0037, amending the glossary's Teaser), and the day's own body and
  /// its actions stay behind the commit regardless.
  final List<DaySpec> days;

  /// Resolves the archetype ids in [DaySpec.archetypeWeights] to the
  /// [Archetype]s a day's preview tag is drawn from. A day carries only ids.
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
            if (campaign.coverPath != null)
              CachedNetworkImage(imageUrl: campaign.coverPath!),
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
                style: theme.textTheme.titleMedium?.copyWith(color: tokens.ink),
              ),
              SizedBox(height: tokens.sp8),
              _DayPreviewList(days: days, archetypesById: archetypesById),
            ],
            SizedBox(height: tokens.sp32),
            if (!isUnlocked)
              FilledButton(onPressed: onUnlock, child: Text(l10n.unlockButton))
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

/// The day-by-day preview strip, fogged past a point rather than run in full
/// (ADR-0037). A 30-day campaign spoiling all 30 titles up front both reads
/// as a wall of text and gives away the whole arc; instead the first
/// [_revealWindow] days stay sharp, every [_landmarkEvery]th day past that
/// stays sharp as a waypoint, and everything else blurs — collapsed behind a
/// tap until the user asks to see the fog itself.
class _DayPreviewList extends StatefulWidget {
  const _DayPreviewList({required this.days, required this.archetypesById});

  final List<DaySpec> days;
  final Map<String, Archetype> archetypesById;

  static const _revealWindow = 5;
  static const _landmarkEvery = 5;

  static bool _isRevealed(int dayIndex) =>
      dayIndex <= _revealWindow || dayIndex % _landmarkEvery == 0;

  @override
  State<_DayPreviewList> createState() => _DayPreviewListState();
}

class _DayPreviewListState extends State<_DayPreviewList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;

    final days = widget.days;
    final shown = _expanded || days.length <= _DayPreviewList._revealWindow
        ? days
        : days.take(_DayPreviewList._revealWindow).toList();
    final remaining = days.length - shown.length;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.r4),
      child: ColoredBox(
        color: tokens.surface1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final day in shown)
              _DayRow(
                day: day,
                archetypes: [
                  // In the order `archetypeWeights` folds them: heaviest drive
                  // first. An id with no archetype cached is skipped rather
                  // than shown as a blank -- the same partial-sync degradation
                  // an uncached action already gets.
                  for (final id in day.archetypeWeights.keys)
                    ?widget.archetypesById[id],
                ],
                isLast: remaining == 0 && day == shown.last,
                isRevealed: _DayPreviewList._isRevealed(day.dayIndex),
              ),
            if (remaining > 0)
              _ExpandRow(
                label: l10n.campaignDaysRemainingCta(remaining),
                onTap: () => setState(() => _expanded = true),
              ),
          ],
        ),
      ),
    );
  }
}

/// One row of the day preview: position, title, and the day's drives as a
/// single dot-and-label tag naming each of them (the Named-Drive Rule). A day
/// wears every drive its actions carry, heaviest first — nothing picks one
/// and nothing caps the count (ADR-0041).
///
/// A day with no tag is one with nothing to name: its actions have not been
/// cached yet. That is the only silence here, so a rest day now reads like any
/// other day of its drive — the campaign's rhythm no longer shows through gaps
/// in the dots, and a real rest-day treatment is owed by the brief.
///
/// When [isRevealed] is false, the day is fogged (ADR-0037): the number
/// stays sharp — the countdown itself isn't the mystery — but the title is
/// rendered through a real blur and the drive tag is withheld. Screen readers
/// get a stand-in label naming the day without ever speaking the blurred title.
class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.archetypes,
    required this.isLast,
    required this.isRevealed,
  });

  final DaySpec day;
  final List<Archetype> archetypes;
  final bool isLast;
  final bool isRevealed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    final title = Text(
      day.title,
      style: theme.textTheme.bodyLarge?.copyWith(color: tokens.ink),
    );

    final row = Row(
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
          child: isRevealed
              ? title
              : ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: title,
                ),
        ),
        if (isRevealed && archetypes.isNotEmpty) ...[
          SizedBox(width: tokens.sp12),
          ArchetypeTag(archetypes: archetypes),
        ],
      ],
    );

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
        child: isRevealed
            ? row
            : Semantics(
                label: l10n.dayNotYetRevealedLabel(day.dayIndex),
                excludeSemantics: true,
                child: row,
              ),
      ),
    );
  }
}

/// The tail-collapsing tap target: replaces every fogged day beyond the
/// reveal window until tapped, so a long campaign's list stays a fixed,
/// reasonable height (ADR-0037) instead of growing with the campaign.
class _ExpandRow extends StatelessWidget {
  const _ExpandRow({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.sp16,
          vertical: tokens.sp12,
        ),
        child: Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: tokens.mutedInk),
        ),
      ),
    );
  }
}
