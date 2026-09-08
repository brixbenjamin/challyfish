import 'package:flutter/material.dart';

import '../../core/l10n_ext.dart';

/// Shown before the diagnostic, because the diagnostic is the first thing that
/// writes user data.
///
/// It must say plainly that an account already exists even though nothing was
/// asked for, and that an unlinked account cannot be recovered (Q7, R4). A user
/// discovering that after losing a phone is the outcome this screen exists to
/// prevent.
class PrivacyNoticeScreen extends StatelessWidget {
  const PrivacyNoticeScreen({required this.onAccept, super.key});

  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.privacyNoticeTitle,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Text(context.l10n.privacyNoticeAccount),
              const SizedBox(height: 12),
              Text(context.l10n.privacyNoticeStored),
              const SizedBox(height: 12),
              Text(context.l10n.privacyNoticeLoss),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: onAccept,
                child: Text(context.l10n.understoodButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
