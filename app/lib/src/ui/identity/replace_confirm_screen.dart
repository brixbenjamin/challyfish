import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/l10n_ext.dart';
import '../../domain/identity.dart';

/// The one screen standing between a user and losing a record.
///
/// ADR-0014 accepts that this loss can happen; what makes that acceptable
/// rather than negligent is that the user is told exactly what, in terms they
/// can weigh, and has to confirm it. "Local data will be removed" would not be.
class ReplaceConfirmScreen extends StatelessWidget {
  const ReplaceConfirmScreen({
    required this.summary,
    required this.accountLabel,
    required this.onConfirm,
    required this.onCancel,
    super.key,
  });

  final LocalProgressSummary summary;
  final String accountLabel;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  static const confirmKey = Key('replace-confirm'); // niche:allow widget key
  static const cancelKey = Key('replace-cancel'); // niche:allow widget key

  String _whatIsHere(AppLocalizations l10n) {
    final title = summary.campaignTitle;
    if (title == null) {
      return l10n.replaceSummaryUntitled;
    }
    return l10n.replaceSummary(title, summary.reportedDays, summary.totalDays);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: onCancel),
        title: Text(l10n.signInTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.replaceHeadline, style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            Text(_whatIsHere(l10n), style: theme.textTheme.bodyLarge),
            const SizedBox(height: 16),
            Text(
              l10n.replaceWarning(accountLabel),
              style: theme.textTheme.bodyMedium,
            ),
            const Spacer(),
            // Cancel first, deliberately.
            OutlinedButton(
              key: cancelKey,
              onPressed: onCancel,
              child: Text(l10n.keepThisRecordButton),
            ),
            const SizedBox(height: 8),
            FilledButton(
              key: confirmKey,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              onPressed: onConfirm,
              child: Text(l10n.replaceWithAccountButton),
            ),
          ],
        ),
      ),
    );
  }
}
