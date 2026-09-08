import 'package:timezone/timezone.dart' as tz;

import '../domain/archetype.dart';
import '../domain/campaign.dart';
import '../domain/day_log.dart';
import '../domain/run.dart';
import '../engine/balance.dart';
import '../engine/marks.dart';

/// What the radar draws: a decaying picture of recent behaviour, beside a
/// permanent record of what was finished.
///
/// Both are derived on read. Nothing here is ever persisted — the balance
/// depends on when it is computed, so storing it would be a bug (ADR-0010).
class BalanceState {
  const BalanceState({
    required this.balance,
    required this.marks,
    required this.archetypes,
    required this.maxValue,
  });

  factory BalanceState.load({
    required List<CampaignRun> runs,
    required List<DayLog> logs,
    required Map<String, ActionSpec> actionsById,
    required List<Archetype> archetypes,
    required Map<String, List<String>> archetypeIdsByCampaign,
    required tz.Location zone,
    required DateTime now,
    BalanceCalculator calculator = const BalanceCalculator(),
    MarkCalculator markCalculator = const MarkCalculator(),
    BalanceWeights weights = BalanceWeights.standard,
  }) {
    final balance = calculator.compute(
      logs: logs,
      actionsById: actionsById,
      runStartedAt: {for (final run in runs) run.id: run.startedAt},
      zone: zone,
      now: now,
      weights: weights,
    );

    final highest = balance.values.isEmpty
        ? 0.0
        : balance.values.reduce((a, b) => a > b ? a : b);

    return BalanceState(
      balance: balance,
      marks: markCalculator.earned(
        runs: runs,
        archetypeIdsByCampaign: archetypeIdsByCampaign,
      ),
      archetypes: archetypes,
      // Floored at one so a nearly-empty radar does not draw a single day as a
      // full axis, which would flatter the user with a shape they did not earn.
      maxValue: highest < 1 ? 1 : highest,
    );
  }

  final Map<String, double> balance;

  /// Permanent. Marks never decay (ADR-0010).
  final Map<String, int> marks;

  /// All four, in `sort` order. The radar has fixed axes.
  final List<Archetype> archetypes;

  final double maxValue;

  /// Zero rather than null for an archetype the user has never acted in — a
  /// missing key would collapse one of the radar's fixed axes.
  double valueFor(String archetypeId) => balance[archetypeId] ?? 0;

  int marksFor(String archetypeId) => marks[archetypeId] ?? 0;

  /// 0 to 1, for drawing. Never used for comparison or storage.
  double normalizedFor(String archetypeId) => valueFor(archetypeId) / maxValue;
}
