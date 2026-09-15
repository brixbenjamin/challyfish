import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../theme/theme_context.dart';

/// The committed phase's way back to the day's framing copy.
///
/// Collapsed by default: the user read the body seconds ago and it is a
/// reference now, not the content. It is never parked open above today's
/// action — the mandatory action comes first, and anything competing with it
/// for the top of the screen is wrong.
///
/// It carries the day title, which appears nowhere else in this phase.
///
/// Deliberately not styled like a tick row: no panel fill, no tick control,
/// muted ink throughout. Anything that made this look like a checklist row
/// would make it read as item zero of the checklist.
///
/// Stateful because the expansion is the user's, not the run's. `_reloadHome()`
/// rebuilds the dashboard from a freshly derived state on every tick, and a
/// panel that closed itself each time would be unusable. The [State] survives
/// that rebuild as long as this widget keeps its type and its position in the
/// tree, which `dashboard_screen_test.dart`'s "the expansion survives a tick"
/// is there to defend.
class DayPanel extends StatefulWidget {
  const DayPanel({required this.title, required this.bodyMd, super.key});

  final String title;

  /// Null when the body is not available: a locked pack, or an owned pack
  /// whose bodies have not been pulled yet (ADR-0025). It degrades to the same
  /// recoverable wording a missing action body does, never to a blank.
  final String? bodyMd;

  @override
  State<DayPanel> createState() => _DayPanelState();
}

class _DayPanelState extends State<DayPanel> {
  bool _isExpanded = false;

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final theme = Theme.of(context);

    // This panel is one item in DashboardScreen's ListView. A scroll view
    // merges every semantics-bearing descendant of a single list item into
    // one announcement unless the item itself claims explicit child nodes —
    // without this, the collapsed/expanded label below and the body text
    // that appears beside it would be read as one run-on sentence instead of
    // the disclosure row and its content staying two distinct things.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            label: l10n.dayFramingSemantic(
              widget.title,
              _isExpanded
                  ? l10n.dayFramingStateShown
                  : l10n.dayFramingStateHidden,
            ),
            button: true,
            expanded: _isExpanded,
            // Carried on the node as well as on the InkWell: excludeSemantics
            // drops the child's own tap action, and a disclosure a screen
            // reader cannot activate is worse than no disclosure.
            onTap: _toggle,
            excludeSemantics: true,
            child: InkWell(
              onTap: _toggle,
              child: Container(
                // The whole row is the target, never just the chevron — this
                // is a one-handed, low-attention surface.
                constraints: BoxConstraints(
                  minHeight: tokens.sp48 - tokens.sp4,
                ),
                padding: EdgeInsets.symmetric(vertical: tokens.sp8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dayFraming,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: tokens.mutedInk,
                            ),
                          ),
                          SizedBox(height: tokens.sp2),
                          // Wraps rather than truncates. A half-read day
                          // title is worse than a tall row.
                          Text(
                            widget.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: tokens.mutedInk,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: tokens.sp12),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: tokens.mutedInk,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // A height and opacity reveal — the vocabulary the brief already
          // specifies for optional body copy, so no new motion is
          // introduced. Reduced motion collapses both to an instant cut,
          // which AnimationController does under
          // SemanticsBinding.disableAnimations.
          //
          // The collapsed body is not mounted at all rather than hidden: a
          // body still in the tree is still in the semantics tree, and
          // "hidden" would then be a claim that is not true.
          AnimatedSize(
            duration: tokens.stateChange,
            curve: tokens.stateCurve,
            alignment: Alignment.topLeft,
            child: _isExpanded
                ? TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: tokens.stateChange,
                    curve: tokens.stateCurve,
                    builder: (context, opacity, child) =>
                        Opacity(opacity: opacity, child: child),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: tokens.sp8),
                      child: Text(widget.bodyMd ?? l10n.contentUnavailable),
                    ),
                  )
                // Width held constant so the reveal is a height change, not
                // a horizontal wipe.
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}
