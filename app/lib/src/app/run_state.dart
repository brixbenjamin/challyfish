import 'package:timezone/timezone.dart' as tz;

import '../domain/campaign.dart';
import '../domain/day_log.dart';
import '../domain/grade.dart';
import '../domain/outcome.dart';
import '../domain/run.dart';
import '../engine/run_engine.dart';

/// Everything the dashboard needs, all of it derived.
///
/// Nothing here is read from a column. Constructing this object is the only way
/// the UI learns what day it is, what grade the run stands at, or what the day
/// would record if reported now — which is what keeps rules out of widgets.
class RunState {
  const RunState({
    required this.run,
    required this.campaign,
    required this.currentDay,
    required this.missCount,
    required this.missAllowance,
    required this.grade,
    required this.logs,
    this.todayActions = const [],
    this.actionsById = const {},
    this.engine = const RunEngine(),
  });

  factory RunState.derive({
    required CampaignRun run,
    required Campaign campaign,
    required List<DayLog> logs,
    required tz.Location zone,
    required DateTime now,
    List<ActionSpec> todayActions = const [],

    /// Every action of the run, not only today's: [runPoints] sums across
    /// every day the user has logged.
    Map<String, ActionSpec> actionsById = const {},
    RunEngine engine = const RunEngine(),
  }) {
    final day = engine.currentDay(
      startedAt: run.startedAt,
      zone: zone,
      now: now,
      lengthDays: campaign.lengthDays,
    );

    // The mandatory action leads regardless of the authored sort, so a content
    // mistake cannot bury the one action the grade depends on.
    final ordered = [...todayActions]
      ..sort(
        (a, b) => a.isOptional == b.isOptional
            ? a.sort.compareTo(b.sort)
            : (a.isOptional ? 1 : -1),
      );

    return RunState(
      run: run,
      campaign: campaign,
      currentDay: day,
      missCount: engine.missCount(logs),
      missAllowance: engine.missAllowance(campaign.lengthDays),
      grade: engine.grade(logs, lengthDays: campaign.lengthDays),
      logs: logs,
      todayActions: ordered,
      actionsById: actionsById,
      engine: engine,
    );
  }

  final CampaignRun run;
  final Campaign campaign;
  final int currentDay;
  final int missCount;

  /// How many misses this campaign tolerates before Broken. Differs per
  /// campaign (ADR-0012), so it belongs on screen rather than in a help article.
  final int missAllowance;

  /// Where the run stands right now. Only becomes permanent at completion.
  final Grade grade;
  final List<DayLog> logs;

  /// Today's actions, mandatory first then optionals by `sort`. Empty when the
  /// content is not cached — the UI shows the existing recoverable
  /// "content unavailable" state and the run is not lost.
  final List<ActionSpec> todayActions;

  /// Every action of this campaign, by id. Used for the run total, which spans
  /// days whose actions are not on screen.
  final Map<String, ActionSpec> actionsById;

  final RunEngine engine;

  int get lengthDays => campaign.lengthDays;

  DayLog? get todayLog {
    for (final log in logs) {
      if (log.dayIndex == currentDay) return log;
    }
    return null;
  }

  /// The one action the grade depends on. Null when content is not cached.
  ActionSpec? get mandatoryToday {
    for (final action in todayActions) {
      if (!action.isOptional) return action;
    }
    return null;
  }

  List<ActionSpec> get optionalsToday => [
    for (final action in todayActions)
      if (action.isOptional) action,
  ];

  Set<String> get completedActionIdsToday =>
      todayLog?.completedActionIds ?? const {};

  bool isCompletedToday(String actionId) =>
      completedActionIdsToday.contains(actionId);

  /// What Report would record right now. Null when the day's mandatory action
  /// is not cached, because the derivation has nothing to key on.
  Outcome? get derivedOutcomeToday {
    final mandatory = mandatoryToday;
    if (mandatory == null) return null;
    return engine.deriveOutcome(
      mandatoryActionId: mandatory.id,
      completedActionIds: completedActionIdsToday,
    );
  }

  /// Points earned today. A reading, never a score against a target.
  int get todayPoints => engine.pointsFor(
    completedActionIds: completedActionIdsToday,
    actionsById: {for (final a in todayActions) a.id: a},
  );

  /// Points earned so far in this run, across every day logged.
  int get runPoints {
    var total = 0;
    for (final log in logs) {
      total += engine.pointsFor(
        completedActionIds: log.completedActionIds,
        actionsById: actionsById,
      );
    }
    return total;
  }

  bool get isCommittedToday => todayLog?.committedAt != null;

  bool get isReportedToday => todayLog?.isReported ?? false;

  bool get isFinalDay => currentDay >= lengthDays;

  /// The final day has both arrived and been resolved, so the run is ready to
  /// be completed and graded. Elapsing alone is not enough — the user still has
  /// the final day until they report it or rollover resolves it.
  bool get isFinished => isFinalDay && isReportedToday;
}
