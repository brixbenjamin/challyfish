import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/l10n_ext.dart';
import '../../domain/archetype.dart';
import '../../domain/campaign.dart';
import '../../domain/grade.dart';
import '../outcome_label.dart';

/// The result of a finished run.
///
/// A Broken result is stated plainly: no consolation copy, no "better luck next
/// time", and no offer to retry. The honest record is the product (ADR-0003),
/// and softening it here would undo the whole argument.
class CompletionScreen extends StatelessWidget {
  const CompletionScreen({
    required this.grade,
    required this.campaign,
    required this.missCount,
    required this.missAllowance,
    required this.marksEarned,
    required this.isLinked,
    required this.onLink,
    required this.onBrowse,
    super.key,
  });

  final Grade grade;
  final Campaign campaign;
  final int missCount;
  final int missAllowance;
  final List<Archetype> marksEarned;

  /// Whether the user has attached an identity. Finishing a campaign is the
  /// moment they have the most to lose (ADR-0007).
  final bool isLinked;
  final VoidCallback onLink;
  final VoidCallback onBrowse;

  String _summary(AppLocalizations l10n) => switch (grade) {
    Grade.sovereign => l10n.gradeSummarySovereign(campaign.title),
    Grade.passed => l10n.gradeSummaryPassed(
      campaign.title,
      missCount,
      missAllowance,
    ),
    Grade.broken => l10n.gradeSummaryBroken(
      campaign.title,
      missCount,
      missAllowance,
    ),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                gradeName(l10n, grade),
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(_summary(l10n)),
              const SizedBox(height: 32),
              if (marksEarned.isNotEmpty) ...[
                Text(l10n.marksEarnedLead),
                const SizedBox(height: 8),
                for (final archetype in marksEarned) Text(archetype.name),
              ] else
                Text(l10n.noMarkNote),
              const Spacer(),
              if (!isLinked) ...[
                Text(l10n.linkPromptBody),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onLink,
                  child: Text(l10n.linkIdentityButton),
                ),
                const SizedBox(height: 8),
              ],
              TextButton(onPressed: onBrowse, child: Text(l10n.whatNextButton)),
            ],
          ),
        ),
      ),
    );
  }
}
