import 'package:flutter/material.dart';

import '../../app/purchase_state.dart';
import '../../core/l10n_ext.dart';
import '../../domain/campaign.dart';
import '../../domain/pack.dart';
import 'purchase_problem_text.dart';

/// What is in the pack, what it costs, one button.
///
/// It opens when the user taps Unlock and at no other moment. It must never
/// become a countdown, a discount, a limited offer, a "most popular" badge, a
/// count of other buyers, or a reminder that the free campaigns are running out
/// (design principle 5). The one unsolicited prompt in this product is the link
/// prompt (ADR-0013), and this is not it.
class UnlockSheet extends StatelessWidget {
  const UnlockSheet({
    required this.pack,
    required this.campaigns,
    required this.priceLabel,
    required this.state,
    required this.onBuy,
    required this.onRestore,
    required this.onClose,
    super.key,
  });

  // The six keys below are widget identifiers, not user-facing copy, so each
  // is exempted from the no-string-literals rule on its own line (ADR-0022).
  // Kept short deliberately: dart format reflows a longer trailing comment onto
  // its own line, and the guard reads one line at a time.
  static const buyKey = Key('unlock-buy'); // niche:allow key
  static const restoreKey = Key('unlock-restore'); // niche:allow key
  static const priceKey = Key('unlock-price'); // niche:allow key
  static const waitingKey = Key('unlock-waiting'); // niche:allow key
  static const problemKey = Key('unlock-problem'); // niche:allow key
  static const closeKey = Key('unlock-close'); // niche:allow key

  final Pack pack;
  final List<Campaign> campaigns;

  /// The store's own localized string, or null when the store could not be
  /// reached. Never a number of our own (ADR-0019).
  final String? priceLabel;

  final PurchaseUiState state;
  final VoidCallback onBuy;
  final VoidCallback onRestore;
  final VoidCallback onClose;

  bool get _busy => state is PurchaseInProgress;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text(pack.title, style: text.headlineSmall)),
                IconButton(
                  key: closeKey,
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  tooltip: context.l10n.closeTooltip,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(pack.description),
            const SizedBox(height: 24),

            Text(context.l10n.packContentsLead, style: text.labelLarge),
            const SizedBox(height: 8),
            for (final campaign in campaigns)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(campaign.title, style: text.titleMedium),
                    Text(context.l10n.lengthInDays(campaign.lengthDays)),
                  ],
                ),
              ),

            const SizedBox(height: 24),
            if (priceLabel != null)
              Text(priceLabel!, key: priceKey, style: text.headlineSmall),
            const SizedBox(height: 4),
            // ADR-0008's promise, made where the money is asked for.
            Text(context.l10n.oneTimePurchaseNote),

            if (state case PurchaseWaiting())
              Padding(
                key: waitingKey,
                padding: const EdgeInsets.only(top: 16),
                child: Text(context.l10n.purchasePendingNote),
              ),

            if (state case PurchaseProblem(
              reason: final reason,
              storeMessage: final storeMessage,
            ))
              Padding(
                key: problemKey,
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  purchaseProblemText(context.l10n, reason, storeMessage),
                ),
              ),

            const SizedBox(height: 24),
            FilledButton(
              key: buyKey,
              // A second tap while the store is working is a second charge.
              onPressed: _busy ? null : onBuy,
              child: Text(
                _busy ? context.l10n.workingButton : context.l10n.unlockButton,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              key: restoreKey,
              onPressed: _busy ? null : onRestore,
              // "I already bought this" is a thought people have in front of a
              // buy button, not in settings (US26).
              child: Text(context.l10n.alreadyBoughtButton),
            ),
          ],
        ),
      ),
    );
  }
}
