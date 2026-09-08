import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';

/// The opening framing. Skippable in one tap: a user who wants to get on with
/// it should be able to, and the doctrine section is always there afterwards.
class DoctrineIntroScreen extends StatelessWidget {
  const DoctrineIntroScreen({required this.onContinue, super.key});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              Text(
                context.l10n.doctrineIntroTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(context.l10n.doctrineIntroBody),
              const SizedBox(height: 24),
              Text(context.l10n.doctrineIntroPromise),
              const Spacer(),
              FilledButton(
                onPressed: onContinue,
                child: Text(context.l10n.continueButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
