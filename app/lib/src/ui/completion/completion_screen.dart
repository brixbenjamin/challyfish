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
    required this.showLinkPrompt,
    required this.onLink,
    required this.onDismissLinkPrompt,
    required this.onBrowse,
    super.key,
  });

  final Grade grade;
  final Campaign campaign;
  final int missCount;
  final int missAllowance;
  final List<Archetype> marksEarned;

  /// The single answer, computed by the caller: unlinked AND never asked
  /// before. Two booleans where one answer is wanted is how a screen ends up
  /// prompting in a state nobody intended (ADR-0013).
  final bool showLinkPrompt;
  final VoidCallback onLink;
  final VoidCallback onDismissLinkPrompt;
  final VoidCallback onBrowse;

  // The prompt sits below the grade, and the test proves it — which needs both
  // to be findable.
  static const gradeKey = Key('completion-grade'); // niche:allow widget key
  static const linkPromptKey = Key('completion-link-prompt'); // niche:allow key
  static const linkPromptTextKey = Key(
    'completion-link-prompt-text', // niche:allow widget key
  );
  static const linkDismissKey = Key(
    'completion-link-dismiss', // niche:allow widget key
  );

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
                key: gradeKey,
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
              if (showLinkPrompt) ...[
                Card(
                  key: linkPromptKey,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // States the consequence. It does not sell a feature,
                        // and it is the only time the product will ask
                        // (ADR-0013).
                        Text(l10n.linkPromptBody, key: linkPromptTextKey),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: onLink,
                                child: Text(l10n.linkIdentityButton),
                              ),
                            ),
                            const SizedBox(width: 8),
                            TextButton(
                              key: linkDismissKey,
                              onPressed: onDismissLinkPrompt,
                              child: Text(l10n.notNowButton),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
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
