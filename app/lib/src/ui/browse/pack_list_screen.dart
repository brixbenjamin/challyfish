import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/campaign.dart';
import '../../domain/pack.dart';

class PackView {
  const PackView({
    required this.pack,
    required this.campaigns,
    required this.isUnlocked,
  });

  final Pack pack;
  final List<Campaign> campaigns;
  final bool isUnlocked;
}

/// Browse. Locked packs are shown in full as teasers — title, campaigns and
/// lengths — because that is what a user needs to judge whether to buy them
/// (ADR-0008). Hiding them would make the paywall a wall.
class PackListScreen extends StatelessWidget {
  const PackListScreen({required this.packs, required this.onOpen, super.key});

  final List<PackView> packs;
  final void Function(Campaign campaign) onOpen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.campaignsTitle)),
      body: ListView(
        children: [
          for (final view in packs) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      view.pack.title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (!view.isUnlocked) Text(context.l10n.lockedBadge),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(view.pack.description),
            ),
            for (final campaign in view.campaigns)
              ListTile(
                title: Text(campaign.title),
                subtitle: Text(context.l10n.lengthInDays(campaign.lengthDays)),
                onTap: () => onOpen(campaign),
              ),
          ],
        ],
      ),
    );
  }
}
