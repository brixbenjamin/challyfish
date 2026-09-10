import 'package:flutter/material.dart';

import '../../app/balance_state.dart';
import '../../app/run_state.dart';
import '../../core/l10n_ext.dart';
import '../../domain/outcome.dart';
import '../outcome_label.dart';
import 'archetype_radar.dart';
import 'report_sheet.dart';

/// Answers one question: what is today's action, and have I dealt with it.
///
/// Holds no rules. Every number on this screen comes from RunState or
/// BalanceState — a widget that computes a grade is a defect even when the
/// number happens to be right.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.state,
    required this.balance,
    required this.onCommit,
    required this.onReport,
    required this.onOpenDoctrine,
    required this.onOpenSettings,
    this.banner,
    super.key,
  });

  final RunState state;
  final BalanceState balance;
  final VoidCallback onCommit;
  final void Function(Outcome outcome, String? note) onReport;
  final VoidCallback onOpenDoctrine;
  final VoidCallback onOpenSettings;

  /// Chrome above today's action — the sync banner, when there is anything to
  /// say. Passed in rather than watched here: this screen holds no rules and
  /// reads no providers.
  final Widget? banner;

  Future<void> _report(BuildContext context, Outcome outcome) async {
    final result = await showModalBottomSheet<(Outcome, String?)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportSheet(outcome: outcome),
    );
    if (result != null) onReport(result.$1, result.$2);
  }

  @override
  Widget build(BuildContext context) {
    final action = state.todayAction;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(state.campaign.title),
        actions: [
          IconButton(
            onPressed: onOpenDoctrine,
            tooltip: l10n.openDoctrine,
            icon: const Icon(Icons.menu_book),
          ),
          IconButton(
            onPressed: onOpenSettings,
            tooltip: l10n.openSettings,
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          // Above the scroll view, so it never covers today's action and never
          // scrolls a message out from under the user mid-read.
          ?banner,
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Text(l10n.dayOfLength(state.currentDay, state.lengthDays)),
                const SizedBox(height: 4),
                // Stated plainly, never as a warning and never as a countdown.
                Text(l10n.missesUsed(state.missCount, state.missAllowance)),
                const SizedBox(height: 32),

                // Today's action comes first. Anything competing with it for the top
                // of the screen is wrong.
                if (action == null)
                  Text(l10n.contentUnavailable)
                else ...[
                  Text(
                    action.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  // The title is a public teaser and the copy is not, so the
                  // body can be absent while the action is present: a locked
                  // pack, or an owned one whose bodies have not arrived yet
                  // (ADR-0025). It degrades to the same recoverable "content
                  // unavailable" wording as a missing action, never to a blank.
                  Text(action.bodyMd ?? l10n.contentUnavailable),
                  const SizedBox(height: 24),
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
                    // Every outcome is offered the same way, at the same size. If
                    // skipping feels like a confession, users stop reporting instead
                    // of skipping and the honest record dies (R6).
                    Row(
                      children: [
                        for (final outcome in const [
                          Outcome.done,
                          Outcome.partial,
                          Outcome.skipped,
                        ])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: OutlinedButton(
                                onPressed: () => _report(context, outcome),
                                child: Text(outcomeLabel(l10n, outcome)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],

                const SizedBox(height: 48),
                ArchetypeRadar(state: balance),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
