import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';
import '../../data/repositories/diagnostic_repository.dart';
import '../../domain/archetype.dart';
import '../../domain/campaign.dart';

/// Names the user's weakest drive and offers one campaign for it.
///
/// The copy states a **relative** weakness and never a level: the instrument
/// cannot distinguish a user who is weak everywhere from one who is strong
/// everywhere, and claiming otherwise would be a lie the product cannot back up.
class DiagnosticResultScreen extends StatelessWidget {
  const DiagnosticResultScreen({
    required this.result,
    required this.weakest,
    required this.recommended,
    required this.onStart,
    required this.onBrowse,
    super.key,
  });

  final StoredDiagnostic result;
  final Archetype weakest;
  final Campaign recommended;
  final VoidCallback onStart;
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.diagnosticWeakestLead),
              const SizedBox(height: 12),
              Text(
                weakest.name,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(weakest.blurb),
              const SizedBox(height: 32),
              Text(context.l10n.diagnosticRecommendationLead),
              const SizedBox(height: 8),
              Text(
                recommended.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (recommended.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(recommended.subtitle!),
              ],
              const SizedBox(height: 8),
              Text(context.l10n.lengthInDays(recommended.lengthDays)),
              const Spacer(),
              FilledButton(
                onPressed: onStart,
                child: Text(context.l10n.startButton),
              ),
              const SizedBox(height: 8),
              // The recommendation is a default, never a gate.
              TextButton(
                onPressed: onBrowse,
                child: Text(context.l10n.browseInsteadButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
