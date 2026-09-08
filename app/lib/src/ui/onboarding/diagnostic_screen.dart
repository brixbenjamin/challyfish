import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../domain/diagnostic.dart';

/// Eight forced-choice pairs. No neutral answer, no skip: picking one drive
/// necessarily declines another, which is the whole point of the instrument
/// (ADR-0009).
class DiagnosticScreen extends StatefulWidget {
  const DiagnosticScreen({
    required this.questions,
    required this.onComplete,
    super.key,
  });

  final List<DiagnosticQuestion> questions;
  final void Function(List<DiagnosticPick> picks) onComplete;

  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  int _index = 0;

  /// Keyed by question id, so going back and changing an answer replaces it
  /// rather than adding a second pick for the same question.
  final Map<String, String> _picks = {};

  void _choose(DiagnosticQuestion question, DiagnosticOption option) {
    _picks[question.id] = option.id;

    if (_index + 1 < widget.questions.length) {
      setState(() => _index++);
      return;
    }

    widget.onComplete([
      for (final q in widget.questions)
        if (_picks.containsKey(q.id))
          DiagnosticPick(questionId: q.id, optionId: _picks[q.id]!),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[_index];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.questionProgress(
                  _index + 1,
                  widget.questions.length,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                question.prompt,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              for (final option in question.options) ...[
                OutlinedButton(
                  onPressed: () => _choose(question, option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(option.label, textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              const Spacer(),
              // Changing your mind about an earlier pair is not dishonesty.
              if (_index > 0)
                TextButton(
                  onPressed: () => setState(() => _index--),
                  child: Text(context.l10n.backButton),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
