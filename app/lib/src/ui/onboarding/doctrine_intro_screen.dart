import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';

/// The opening framing. Skippable in one tap: a user who wants to get on with
/// it should be able to, and the doctrine section is always there afterwards.
///
/// [onSignIn] is the other way out. A returning user answered the diagnostic
/// long ago, on an account rather than on this phone, and without an offer here
/// the only route to it is to answer all eight again — which then writes a
/// second, contradictory result over the one they already had (ADR-0024). It is
/// deliberately the quieter of the two buttons: onboarding is still the path,
/// and nothing stands between install and the diagnostic (ADR-0007).
class DoctrineIntroScreen extends StatelessWidget {
  const DoctrineIntroScreen({
    required this.onContinue,
    required this.onSignIn,
    super.key,
  });

  final VoidCallback onContinue;
  final VoidCallback onSignIn;

  static const signInKey = Key('intro-sign-in'); // niche:allow widget key

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
              TextButton(
                key: signInKey,
                onPressed: onSignIn,
                child: Text(context.l10n.haveAccountButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
