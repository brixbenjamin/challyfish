import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/archetype.dart';
import '../../domain/campaign.dart';

/// What the user is agreeing to, before they agree to it.
class CampaignDetailScreen extends StatelessWidget {
  const CampaignDetailScreen({
    required this.campaign,
    required this.targets,
    required this.missAllowance,
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
  final bool isUnlocked;
  final bool hasActiveRun;
  final VoidCallback onStart;
  final VoidCallback onUnlock;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(campaign.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (campaign.subtitle != null) ...[
              Text(campaign.subtitle!),
              const SizedBox(height: 16),
            ],
            Text(context.l10n.lengthInDays(campaign.lengthDays)),
            const SizedBox(height: 4),
            Text(context.l10n.missesAllowed(missAllowance)),
            const SizedBox(height: 16),
            for (final archetype in targets) Text(archetype.name),
            const SizedBox(height: 24),
            Text(campaign.introMd),
            const SizedBox(height: 32),
            if (!isUnlocked)
              FilledButton(
                onPressed: onUnlock,
                child: Text(context.l10n.unlockButton),
              )
            else ...[
              if (hasActiveRun)
                // Abandoning is the only destructive action in the product. Say
                // what it costs before the tap, not after.
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(context.l10n.abandonActiveRunWarning),
                ),
              FilledButton(
                onPressed: onStart,
                child: Text(
                  hasActiveRun
                      ? context.l10n.abandonAndStartButton
                      : context.l10n.startButton,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
