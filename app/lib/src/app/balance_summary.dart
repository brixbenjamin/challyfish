import '../../l10n/app_localizations.dart';
import 'balance_state.dart';

/// What a screen reader is told about the radar.
///
/// It lives here rather than in the widget because it is a reading of the
/// numbers, and no rule of this product is decided inside a widget
/// (PRODUCT.md principle 7). The bands below are presentation of the same
/// normalised value the figure draws, not a second rule about behaviour: the
/// figure and this sentence can never disagree.
///
/// Nothing here frames the decay as a loss (ADR-0010). The marks clause is
/// always present when there is anything to say, because a falling
/// distribution read beside a permanent record is the whole point.
String balanceSummary(BalanceState state, AppLocalizations l10n) {
  String bandFor(double normalized) {
    if (normalized <= 0) return l10n.radarBandNone;
    if (normalized < 0.34) return l10n.radarBandLow;
    if (normalized < 0.67) return l10n.radarBandMedium;
    return l10n.radarBandHigh;
  }

  final bands = <String>[
    for (final archetype in state.archetypes)
      bandFor(state.normalizedFor(archetype.id)),
  ];

  if (bands.every((band) => band == l10n.radarBandNone)) {
    return l10n.radarSummaryEmpty;
  }

  final distribution = <String>[
    for (var i = 0; i < state.archetypes.length; i++)
      l10n.radarAxisBand(state.archetypes[i].name, bands[i]),
  ].join(l10n.radarListSeparator);

  final earned = <String>[
    for (final archetype in state.archetypes)
      if (state.marksFor(archetype.id) > 0)
        l10n.radarMarkEntry(archetype.name, state.marksFor(archetype.id)),
  ];

  return l10n.radarSummary(
    distribution,
    l10n.radarMarks(earned.length, earned.join(l10n.radarListSeparator)),
  );
}
