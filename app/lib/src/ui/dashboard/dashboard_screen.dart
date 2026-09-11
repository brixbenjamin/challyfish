import 'package:flutter/material.dart';

import '../../app/balance_state.dart';
import '../../app/run_state.dart';
import '../../core/l10n_ext.dart';
import '../../domain/campaign.dart';
import '../outcome_label.dart';
import '../theme/theme_context.dart';
import 'archetype_radar.dart';
import 'report_sheet.dart';

/// Answers one question: what is today's action, and have I dealt with it.
///
/// A day now holds several actions, which makes that question harder to keep
/// answered rather than easier. The mandatory action reads as *the* action and
/// the optionals are an appendix; equal-weight rows would be the failure mode.
///
/// Holds no rules. Every number on this screen comes from RunState or
/// BalanceState — a widget that computes a grade, an outcome or a points total
/// is a defect even when the number happens to be right.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.state,
    required this.balance,
    required this.onCommit,
    required this.onReport,
    required this.onToggleAction,
    required this.onOpenDoctrine,
    required this.onOpenSettings,
    this.banner,
    super.key,
  });

  final RunState state;
  final BalanceState balance;
  final VoidCallback onCommit;

  /// Takes only the note. The screen no longer chooses an outcome — it reads
  /// the one the engine derived.
  final void Function(String? note) onReport;
  final void Function(String actionId, bool completed) onToggleAction;
  final VoidCallback onOpenDoctrine;
  final VoidCallback onOpenSettings;

  /// Chrome above today's action — the sync banner, when there is anything to
  /// say. Passed in rather than watched here: this screen holds no rules and
  /// reads no providers.
  final Widget? banner;

  Future<void> _report(BuildContext context) async {
    final outcome = state.derivedOutcomeToday;
    if (outcome == null) return;

    final result = await showModalBottomSheet<ReportResult>(
      context: context,
      isScrollControlled: true,
      builder: (_) => ReportSheet(outcome: outcome),
    );
    // Null means the sheet was dismissed, which must not record the day. A
    // record with a null note means confirmed without writing one.
    if (result != null) onReport(result.note);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final mandatory = state.mandatoryToday;

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
              padding: EdgeInsets.all(tokens.sp24),
              children: [
                Text(
                  l10n.dayOfLength(state.currentDay, state.lengthDays),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.mutedInk,
                  ),
                ),
                SizedBox(height: tokens.sp4),
                // Stated plainly, never as a warning and never as a countdown.
                Text(
                  l10n.missesUsed(state.missCount, state.missAllowance),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: tokens.mutedInk,
                  ),
                ),
                SizedBox(height: tokens.sp32),

                // Today's action comes first. Anything competing with it for
                // the top of the screen is wrong.
                if (mandatory == null)
                  Text(l10n.contentUnavailable)
                else ...[
                  _MandatoryAction(
                    action: mandatory,
                    isCompleted: state.isCompletedToday(mandatory.id),
                    // Ticks become a read-only record once the day is
                    // reported. Changing the record after the fact is not a
                    // flow this product offers.
                    onToggle: state.isReportedToday
                        ? null
                        : (value) => onToggleAction(mandatory.id, value),
                  ),

                  // A clear spacing step, not a divider: a rule here would
                  // read as two equal sections rather than a thing and its
                  // appendix.
                  if (state.optionalsToday.isNotEmpty) ...[
                    SizedBox(height: tokens.sp32),
                    for (final optional in state.optionalsToday)
                      _OptionalAction(
                        action: optional,
                        isCompleted: state.isCompletedToday(optional.id),
                        onToggle: state.isReportedToday
                            ? null
                            : (value) => onToggleAction(optional.id, value),
                      ),
                  ],

                  SizedBox(height: tokens.sp24),
                  _PointsReading(
                    label: l10n.dayPointsTotal,
                    points: state.todayPoints,
                  ),
                  SizedBox(height: tokens.sp8),
                  _PointsReading(
                    label: l10n.runPointsTotal,
                    points: state.runPoints,
                  ),

                  SizedBox(height: tokens.sp24),
                  if (state.isReportedToday)
                    Text(
                      l10n.reportedOutcome(
                        outcomeLabel(l10n, state.todayLog!.outcome!),
                      ),
                    )
                  else ...[
                    // In the morning Commit is the one filled control and
                    // Report is present but clearly not yet the point. Once
                    // the day is committed, Report becomes the filled one.
                    if (!state.isCommittedToday) ...[
                      FilledButton(
                        onPressed: onCommit,
                        child: Text(l10n.commitButton),
                      ),
                      SizedBox(height: tokens.sp8),
                      OutlinedButton(
                        onPressed: () => _report(context),
                        child: Text(l10n.reportButton),
                      ),
                    ] else
                      FilledButton(
                        onPressed: () => _report(context),
                        child: Text(l10n.reportButton),
                      ),
                  ],
                ],

                SizedBox(height: tokens.sp48),
                ArchetypeRadar(state: balance),
                SizedBox(height: tokens.sp16),
                // Beside the permanent marks, where ADR-0010 already places
                // the undecayed record that keeps a falling radar from reading
                // as erasure.
                _PointsReading(
                  label: l10n.allTimePointsTotal,
                  points: balance.allTimePoints,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The day's one mandatory action, at full weight with its body copy inline.
class _MandatoryAction extends StatelessWidget {
  const _MandatoryAction({
    required this.action,
    required this.isCompleted,
    required this.onToggle,
  });

  final ActionSpec action;
  final bool isCompleted;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final points = l10n.actionPoints(action.effort);

    return _TickRow(
      isCompleted: isCompleted,
      onToggle: onToggle,
      semanticLabel: l10n.actionSemanticMandatory(
        action.title,
        points,
        isCompleted ? l10n.actionStateDone : l10n.actionStateNotDone,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(action.title, style: theme.textTheme.headlineSmall),
          SizedBox(height: tokens.sp4),
          Text(
            points,
            style: theme.textTheme.labelMedium?.copyWith(
              color: tokens.mutedInk,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          SizedBox(height: tokens.sp12),
          // The title is a public teaser and the copy is not, so the body can
          // be absent while the action is present: a locked pack, or an owned
          // one whose bodies have not arrived yet (ADR-0025). It degrades to
          // the same recoverable wording as a missing action, never to a blank.
          Text(action.bodyMd ?? l10n.contentUnavailable),
        ],
      ),
    );
  }
}

/// One optional action: tick, title, points. No body copy inline, and
/// deliberately no archetype colour — a day can hold four archetypes and the
/// One Drive Per Loop Rule allows the surface at most one.
class _OptionalAction extends StatelessWidget {
  const _OptionalAction({
    required this.action,
    required this.isCompleted,
    required this.onToggle,
  });

  final ActionSpec action;
  final bool isCompleted;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final points = l10n.actionPoints(action.effort);

    return Padding(
      padding: EdgeInsets.only(bottom: tokens.sp8),
      child: _TickRow(
        isCompleted: isCompleted,
        onToggle: onToggle,
        semanticLabel: l10n.actionSemanticOptional(
          action.title,
          points,
          isCompleted ? l10n.actionStateDone : l10n.actionStateNotDone,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.optionalAction,
              style: theme.textTheme.labelSmall?.copyWith(
                color: tokens.mutedInk,
              ),
            ),
            SizedBox(height: tokens.sp2),
            // Wraps rather than truncates. A half-read action is worse than a
            // tall row.
            Text(action.title, style: theme.textTheme.bodyLarge),
            SizedBox(height: tokens.sp2),
            Text(
              points,
              style: theme.textTheme.labelMedium?.copyWith(
                color: tokens.mutedInk,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The shared tick affordance: the whole row is the target, never just the
/// control, because this is a one-handed low-attention surface.
///
/// A completed row differs from an incomplete one in tone and mark, not hue.
/// Ticking earns no green, no colour shift and no flourish — the No
/// Celebration Colour Rule holds here as everywhere.
class _TickRow extends StatelessWidget {
  const _TickRow({
    required this.isCompleted,
    required this.onToggle,
    required this.semanticLabel,
    required this.child,
  });

  final bool isCompleted;
  final ValueChanged<bool>? onToggle;
  final String semanticLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;

    return Semantics(
      checked: isCompleted,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkWell(
        onTap: onToggle == null ? null : () => onToggle!(!isCompleted),
        child: AnimatedContainer(
          // Feedback, not celebration. Reduced motion is honoured by the
          // framework, which collapses this to an instant cut.
          duration: tokens.stateChange,
          curve: tokens.stateCurve,
          constraints: BoxConstraints(minHeight: tokens.sp48 - tokens.sp4),
          padding: EdgeInsets.all(tokens.sp8),
          decoration: BoxDecoration(
            color: isCompleted ? tokens.surface2 : tokens.panel,
            borderRadius: BorderRadius.circular(tokens.r2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                isCompleted
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
                color: isCompleted ? tokens.ink : tokens.mutedInk,
              ),
              SizedBox(width: tokens.sp12),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

/// A panel reading: a muted label and an ink value in tabular figures.
///
/// Never a bar, never a percentage, never a target. A number with a target
/// beside it is a score you can lose; a number on its own is a record, and
/// that distinction is the whole basis on which points were permitted at all
/// (ADR-0029). The value changes; it never counts up.
class _PointsReading extends StatelessWidget {
  const _PointsReading({required this.label, required this.points});

  final String label;
  final int points;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final value = context.l10n.actionPoints(points);

    return Semantics(
      label: label,
      value: value,
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: tokens.mutedInk,
              ),
            ),
          ),
          SizedBox(width: tokens.sp12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: tokens.ink,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
