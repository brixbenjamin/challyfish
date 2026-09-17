import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/l10n_ext.dart';
import '../../domain/campaign.dart';

/// A run that ended because the user stopped turning up (ADR-0040).
///
/// Shown once, on the first open after three consecutive days passed with
/// nothing reported, and never again. The run is already closed by the time
/// this appears — it is a notice, not a decision, and there is nothing here to
/// confirm or undo.
///
/// Deliberately not a second chance. No restart, no encouragement, no offer to
/// pick up where it left off: the single control leads to the shelf, the same
/// place every other "what now" in the product leads. Softening this would undo
/// the argument the consequence exists to make, exactly as consoling copy would
/// on [CompletionScreen] for a Broken run.
class AbandonedScreen extends StatelessWidget {
  const AbandonedScreen({
    required this.campaign,
    required this.abandonedOn,
    required this.daysReported,
    required this.onBrowse,
    super.key,
  });

  final Campaign campaign;

  /// The local date the run ended: the third consecutive day with nothing
  /// reported. A bare date, so it is formatted rather than localised as an
  /// instant.
  final DateTime abandonedOn;

  /// How many days of the campaign were resolved before it ended. They still
  /// count toward the archetype balance — effort is never erased (ADR-0003).
  final int daysReported;

  final VoidCallback onBrowse;

  static const headingKey = Key('abandoned-heading'); // niche:allow widget key

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.abandonedHeading,
                key: headingKey,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.abandonedSummary(
                  campaign.title,
                  DateFormat.yMMMMd(locale).format(abandonedOn),
                ),
              ),
              const SizedBox(height: 32),
              Text(l10n.abandonedDaysKept(daysReported)),
              const SizedBox(height: 8),
              // The same line a Broken run gets. An abandoned run earns no mark
              // for the same reason and says so in the same words.
              Text(l10n.noMarkNote),
              const Spacer(),
              TextButton(onPressed: onBrowse, child: Text(l10n.whatNextButton)),
            ],
          ),
        ),
      ),
    );
  }
}
