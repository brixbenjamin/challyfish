import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/outcome.dart';

/// Collects the one-line note after an outcome is chosen.
///
/// No confirmation step and no discouraging copy, whichever outcome was picked.
/// Reporting `skipped` is as cheap as reporting `done` by design (R6).
class ReportSheet extends StatefulWidget {
  const ReportSheet({required this.outcome, super.key});

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
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: context.l10n.notePlaceholder,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () {
              final note = _controller.text.trim();
              Navigator.of(
                context,
              ).pop((widget.outcome, note.isEmpty ? null : note));
            },
            child: Text(context.l10n.recordButton),
          ),
        ],
      ),
    );
  }
}
