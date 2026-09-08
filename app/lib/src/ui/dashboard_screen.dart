import 'package:flutter/material.dart';

import '../app/run_state.dart';
import '../core/l10n_ext.dart';
import '../domain/outcome.dart';
import 'outcome_label.dart';

/// Answers one question: what is today's action, and have I dealt with it.
///
/// Holds no rules. Every number on this screen comes from RunState.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.state,
    required this.onCommit,
    required this.onReport,
    super.key,
  });

  final RunState state;
  final VoidCallback onCommit;
  final void Function(Outcome outcome, String? note) onReport;

  @override
  Widget build(BuildContext context) {
    final action = state.todayAction;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(state.campaign.title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.dayOfLength(state.currentDay, state.lengthDays)),
            const SizedBox(height: 4),
            // Stated plainly, never as a warning and never as a countdown.
            Text(l10n.missesUsed(state.missCount, state.missAllowance)),
            const SizedBox(height: 32),
            if (action == null)
              Text(l10n.contentUnavailable)
            else ...[
              Text(
                action.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(action.bodyMd),
              const Spacer(),
              if (state.isReportedToday)
                Text(
                  l10n.reportedOutcome(
                    outcomeLabel(l10n, state.todayLog!.outcome!),
                  ),
                )
              else ...[
                if (!state.isCommittedToday)
                  FilledButton(
                    onPressed: onCommit,
                    child: Text(l10n.commitButton),
                  ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    for (final outcome in const [
                      Outcome.done,
                      Outcome.partial,
                      Outcome.skipped,
                    ])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: OutlinedButton(
                          onPressed: () => onReport(outcome, null),
                          child: Text(outcomeLabel(l10n, outcome)),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
