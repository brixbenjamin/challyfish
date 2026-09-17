import 'package:flutter/material.dart';

import '../../app/balance_state.dart';
import '../../app/run_state.dart';
import '../../core/l10n_ext.dart';
import '../../domain/campaign.dart';
import '../outcome_label.dart';
import '../theme/theme_context.dart';
import 'archetype_radar.dart';
import 'day_panel.dart';
import 'report_sheet.dart';

/// One screen in two phases. Before the commit it answers "what is today, and
/// am I willing to take it on"; after the commit it answers "what is today's
/// action, and have I dealt with it".
///
/// The commit is what reveals the actions, and thereby gates ticking behind it.
/// That is a decision taken on information rather than a bare acknowledgement,
/// which is the whole point of putting the day's authored framing in front of
/// it (ADR-0034).
///
/// A day holds several actions, which makes the second question harder to keep
/// answered rather than easier. The mandatory action reads as *the* action and
/// the optionals are an appendix; equal-weight rows would be the failure mode.
///
/// Holds no rules. Every number on this screen comes from RunState or
/// BalanceState, and the phase switch reads one flag — a widget that computes a
/// grade, an outcome or a total is a defect even when the number happens to be
/// right.
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
                // The run's own line, and it reads the same in both phases:
                // which day this is, what it has cost, what it has earned.
                Text(
                  l10n.dayOfLength(state.storyPosition, state.lengthDays),
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
                SizedBox(height: tokens.sp8),
                // With the day line, where the brief always placed it, so it
                // survives both phases instead of being dropped from the
                // uncommitted one by accident.
                _PointsReading(
                  label: l10n.runPointsTotal,
                  points: state.runPoints,
                ),
                SizedBox(height: tokens.sp32),

                if (state.isCommittedToday)
                  ..._committed(context)
                else
                  ..._uncommitted(context),

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

  /// Before the commit, the screen is the day: its title, its framing copy,
  /// and the one control that accepts them.
  ///
  /// No action, no tick, no day total and no Report. A pre-commit Report could
  /// only ever derive `skipped` from zero ticks, which makes it a "give up on
  /// today" control sitting beside copy whose consequences the user has not
  /// been shown. Nothing real is lost: Commit costs nothing and immediately
  /// reveals the ticks.
  List<Widget> _uncommitted(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);
    final today = state.today;

    return [
      if (today == null)
        // With no day there is no title and no body either, so both rows
        // collapse into the one recoverable message. The day line above and
        // the radar below still render: the run is never lost, and the surface
        // must not imply that it is.
        Text(l10n.contentUnavailable)
      else ...[
        // The only element on this screen carrying weight.
        Text(today.title, style: theme.textTheme.headlineSmall),
        SizedBox(height: tokens.sp12),
        // Plain text, as doctrine_entry_screen.dart and _MandatoryAction
        // already render their copy — there is no markdown renderer yet. A
        // body can be absent while the day is present: a locked pack, or an
        // owned one whose bodies have not arrived (ADR-0025).
        Text(today.bodyMd ?? l10n.contentUnavailable),
      ],
      SizedBox(height: tokens.sp32),
      if (state.mandatoryToday != null)
        FilledButton(onPressed: onCommit, child: Text(l10n.commitButton))
      else
        // onCommit needs the mandatory action's id to write the log row, and
        // used to swallow the tap when there was none. With the actions hidden
        // the user would have no way to tell why nothing happened, so the
        // control is disabled and the reason travels with it.
        Semantics(
          label: l10n.commitUnavailable,
          button: true,
          enabled: false,
          excludeSemantics: true,
          child: FilledButton(onPressed: null, child: Text(l10n.commitButton)),
        ),
    ];
  }

  /// The commit is what reveals these: today's checklist as it stands now.
  List<Widget> _committed(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final today = state.today;
    final mandatory = today?.mandatory;

    // One missing-content path, not two: no day and no mandatory action read
    // the same way to the user, and there is nothing useful to say that
    // distinguishes them.
    if (today == null || mandatory == null) {
      return [Text(l10n.contentUnavailable)];
    }

    return [
      // The day title appears nowhere else in this phase, and the body is a
      // reference now rather than the content — so it opens collapsed, in
      // place, and never above today's action.
      DayPanel(title: today.title, bodyMd: today.bodyMd),
      SizedBox(height: tokens.sp24),

      // Today's action comes first. Anything competing with it for the top of
      // the screen is wrong.
      _MandatoryAction(
        action: mandatory,
        isCompleted: state.isCompletedToday(mandatory.id),
        // Ticks become a read-only record once the day is reported. Changing
        // the record after the fact is not a flow this product offers.
        onToggle: state.isReportedToday
            ? null
            : (value) => onToggleAction(mandatory.id, value),
      ),

      // A clear spacing step, not a divider: a rule here would read as two
      // equal sections rather than a thing and its appendix.
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
      _PointsReading(label: l10n.dayPointsTotal, points: state.todayPoints),

      SizedBox(height: tokens.sp24),
      if (state.isReportedToday)
        Text(l10n.reportedOutcome(outcomeLabel(l10n, state.todayLog!.outcome!)))
      else
        // The only control in this phase. Commit belongs to the phase before
        // it, and the two never render at once.
        FilledButton(
          onPressed: () => _report(context),
          child: Text(l10n.reportButton),
        ),
    ];
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

/// One optional action: tick, title, points. No body copy inline, and no
/// archetype colour — not because a rule forbids it any more (ADR-0041 retired
/// the One Drive Per Loop Rule) but because nothing has argued for it. The
/// checklist is carried by the neutral ramp, and whether an action row should
/// name its own drive is an open item in the multi-action-day brief, to be
/// decided against a real layout rather than taken because it is now allowed.
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
