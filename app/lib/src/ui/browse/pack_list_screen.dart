import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/archetype.dart';
import '../../domain/campaign.dart';
import '../../domain/pack.dart';
import '../theme/archetype_tag.dart';
import '../theme/theme_context.dart';

class PackView {
  const PackView({
    required this.pack,
    required this.campaigns,
    required this.isUnlocked,
    required this.priceLabel,
    required this.archetypesByCampaign,
  });

  final Pack pack;
  final List<Campaign> campaigns;
  final bool isUnlocked;

  /// The store's own localized string for a locked pack, or null while the
  /// store hasn't answered yet or can't be reached. Never a number of our own
  /// (ADR-0019). Meaningless — and left null — once [isUnlocked] is true.
  final String? priceLabel;

  /// Each campaign's target archetypes, keyed by campaign id. A campaign
  /// authored against more than one drive has no single accent to show (see
  /// _CampaignRow), the same restraint dashboard_screen.dart's optional
  /// actions already apply.
  final Map<String, List<Archetype>> archetypesByCampaign;
}

/// Browse. Locked packs are shown in full as teasers — title, campaigns and
/// lengths — because that is what a user needs to judge whether to buy them
/// (ADR-0008). Hiding them would make the paywall a wall.
///
/// This is the product's one store surface, so it carries the one job a store
/// screen has: make the case for a pack honestly. It sells through content and
/// clarity — the price stated plainly, each campaign's own drive named where
/// it's unambiguous — never through urgency, scarcity or a comparison table
/// (PRODUCT.md's dark-pattern store screen ban).
class PackListScreen extends StatelessWidget {
  const PackListScreen({
    required this.packs,
    required this.onOpen,
    required this.onPurchase,
    super.key,
  });

  final List<PackView> packs;
  final void Function(Campaign campaign) onOpen;
  final void Function(Pack pack) onPurchase;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.campaignsTitle)),
      body: ListView.separated(
        padding: EdgeInsets.all(tokens.sp24),
        itemCount: packs.length,
        separatorBuilder: (_, _) => SizedBox(height: tokens.sp32),
        itemBuilder: (context, index) => _PackBlock(
          view: packs[index],
          onOpen: onOpen,
          onPurchase: onPurchase,
        ),
      ),
    );
  }
}

/// One pack: an optional cover band, a header stating what it is and what it
/// costs, and its campaigns underneath. A single Surface-1 block — the
/// "grouped block within a scroll" DESIGN.md's neutral ramp defines — rather
/// than a card holding cards.
class _PackBlock extends StatelessWidget {
  const _PackBlock({
    required this.view,
    required this.onOpen,
    required this.onPurchase,
  });

  final PackView view;
  final void Function(Campaign campaign) onOpen;
  final void Function(Pack pack) onPurchase;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final coverPath = view.pack.coverPath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(tokens.r4),
      child: ColoredBox(
        color: tokens.surface1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Renders only once real cover art exists — every pack today has
            // no coverPath, so this is a future upgrade, not a placeholder to
            // design around now.
            if (coverPath != null)
              AspectRatio(
                aspectRatio: 2,
                child: Image.asset(
                  coverPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.sp16,
                tokens.sp16,
                tokens.sp16,
                tokens.sp12,
              ),
              child: _PackHeader(view: view),
            ),
            for (final campaign in view.campaigns)
              _CampaignRow(
                campaign: campaign,
                targets: view.archetypesByCampaign[campaign.id] ?? const [],
                isLast: campaign == view.campaigns.last,
                onTap: () => onOpen(campaign),
              ),
            // Only a pack the user hasn't yet unlocked needs a way to buy it —
            // core and owned packs already read "Included"/"Owned" up in the
            // header and would make a second CTA redundant here.
            if (!view.isUnlocked)
              Padding(
                padding: EdgeInsets.fromLTRB(
                  tokens.sp16,
                  tokens.sp12,
                  tokens.sp16,
                  tokens.sp16,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => onPurchase(view.pack),
                    child: Text(context.l10n.unlockButton),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PackHeader extends StatelessWidget {
  const _PackHeader({required this.view});

  final PackView view;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final pack = view.pack;

    // Always says something in the same slot — "Locked" until a price
    // arrives, then the price; "Included" or "Owned" once unlocked — so the
    // status reading never goes blank while the store is still answering
    // (design principle 10's spirit: one slot, the same weight, whatever
    // the word).
    final status = view.isUnlocked
        ? (pack.isCore ? l10n.includedLabel : l10n.ownedLabel)
        : (view.priceLabel ?? l10n.lockedBadge);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(pack.title, style: theme.textTheme.headlineSmall),
            ),
            SizedBox(width: tokens.sp12),
            Text(
              status,
              textAlign: TextAlign.end,
              style: theme.textTheme.labelLarge?.copyWith(
                color: tokens.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        SizedBox(height: tokens.sp4),
        Text(
          pack.description,
          style: theme.textTheme.bodyMedium?.copyWith(color: tokens.mutedInk),
        ),
      ],
    );
  }
}

/// One campaign within a pack: title, length, and — only when the campaign
/// targets exactly one archetype — that drive named as a small dot-and-label
/// tag (the Named-Drive Rule: colour appears only where a drive is literally
/// named, paired with text rather than hue alone). A campaign that trains
/// more than one drive shows no tag, the same restraint
/// dashboard_screen.dart's _OptionalAction already applies rather than
/// inventing a false "the one that matters most."
class _CampaignRow extends StatelessWidget {
  const _CampaignRow({
    required this.campaign,
    required this.targets,
    required this.isLast,
    required this.onTap,
  });

  final Campaign campaign;
  final List<Archetype> targets;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final tags = targets.isNotEmpty ? targets : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(bottom: BorderSide(color: tokens.hairline)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.sp16,
              vertical: tokens.sp12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(campaign.title, style: theme.textTheme.bodyLarge),
                      SizedBox(height: tokens.sp2),
                      Text(
                        l10n.lengthInDays(campaign.lengthDays),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: tokens.mutedInk,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ],
                  ),
                ),
                if (tags != null) ...[
                  SizedBox(width: tokens.sp12),
                  ArchetypeTag(archetypes: tags),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
