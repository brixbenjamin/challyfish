import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/outcome.dart';
import '../outcome_label.dart';
import '../theme/theme_context.dart';

/// States what the day is about to record, and collects the one-line note.
///
/// The outcome is derived from what the user ticked, not chosen here — the
/// three buttons are gone. That strengthens design principle 10 rather than
/// weakening it: `skipped` no longer has a control of its own to feel exposed
/// by, so it cannot read as a confession.
class ReportSheet extends StatefulWidget {
  const ReportSheet({required this.outcome, super.key});

  /// Already derived by the engine. This sheet displays it and never decides
  /// it — a widget that computed an outcome would be a defect even if the
  /// answer happened to be right (principle 7).
  final Outcome outcome;

  @override
  State<ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tokens = context.tokens;
    final willRecord = l10n.willRecord(outcomeLabel(l10n, widget.outcome));

    return Padding(
      padding: EdgeInsets.only(
        left: tokens.sp24,
        right: tokens.sp24,
        top: tokens.sp24,
        bottom: MediaQuery.of(context).viewInsets.bottom + tokens.sp24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Stated before the control that commits it, and announced first, so
          // a non-sighted user knows what they are about to record. This is
          // the accessibility equivalent of a confirm step.
          Semantics(
            liveRegion: true,
            child: Text(
              willRecord,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          SizedBox(height: tokens.sp16),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 1,
            decoration: InputDecoration(labelText: l10n.notePlaceholder),
          ),
          SizedBox(height: tokens.sp16),
          FilledButton(
            onPressed: () {
              final note = _controller.text.trim();
              Navigator.of(context).pop((note: note.isEmpty ? null : note));
            },
            child: Text(l10n.recordButton),
          ),
        ],
      ),
    );
  }
}

/// What the sheet returns when the user confirms.
///
/// A record rather than a bare `String?` so that "confirmed with no note" and
/// "dismissed the sheet" are different values: the sheet pops this, and a
/// dismissal pops null. Dismissing must not record the day, and a nullable
/// string alone cannot carry that difference.
typedef ReportResult = ({String? note});
