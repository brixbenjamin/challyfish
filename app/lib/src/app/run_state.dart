import 'package:timezone/timezone.dart' as tz;

import '../domain/campaign.dart';
import '../domain/day.dart';
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
    required this.storyPosition,
    required this.missCount,
    this.absentDates = const [],
    required this.missAllowance,
    required this.grade,
    required this.logs,
    this.today,
    this.actionsById = const {},
    this.engine = const RunEngine(),
  });

  factory RunState.derive({
    required CampaignRun run,
    required Campaign campaign,
    required List<DayLog> logs,
    required tz.Location zone,
    required DateTime now,

    /// Today's day, whole. The screen reads its title and body as well as its
    /// actions, so it is not unwrapped on the way in.
    DaySpec? today,

    /// Every action of the run, not only today's: [runPoints] sums across
    /// every day the user has logged.
    Map<String, ActionSpec> actionsById = const {},
    RunEngine engine = const RunEngine(),
  }) {
    // Two pointers since ADR-0040, doing different jobs. The story position is
    // where the *content* stands and advances only when a day is resolved; the
    // calendar is what absence is counted in. Conflating them is what used to
    // let an absence skip a day of the campaign.
    final todayDate = engine.localDateOf(instant: now, zone: zone);
    final position = engine.dayOnScreen(
      logs: logs,
      lengthDays: campaign.lengthDays,
      today: todayDate,
    );
    final absence = engine.absence(
      startedOn: engine.localDateOf(instant: run.startedAt, zone: zone),
      today: todayDate,
      logs: logs,
    );

    return RunState(
      run: run,
      campaign: campaign,
      storyPosition: position,
      absentDates: absence.absences,
      missCount: engine.missCount(logs: logs, absences: absence.absences),
      missAllowance: engine.missAllowance(campaign.lengthDays),
      grade: engine.grade(
        missCount: engine.missCount(logs: logs, absences: absence.absences),
        lengthDays: campaign.lengthDays,
      ),
      logs: logs,
      today: today,
      actionsById: actionsById,
      engine: engine,
    );
  }

  final CampaignRun run;
  final Campaign campaign;

  /// The 1-based day of *content* the run stands on — the next unresolved day,
  /// not the number of days since it started (ADR-0040).
  ///
  /// A day resolved today holds this for the rest of that day, so reporting
  /// does not hand the user tomorrow's day the same evening.
  final int storyPosition;

  /// The local dates the run was live and the user resolved nothing. The
  /// calendar half of the record, and what the miss count is drawn from.
  final List<DateTime> absentDates;
  final int missCount;

  /// How many misses this campaign tolerates before Broken. Differs per
  /// campaign (ADR-0012), so it belongs on screen rather than in a help article.
  final int missAllowance;

  /// Where the run stands right now. Only becomes permanent at completion.
  final Grade grade;
  final List<DayLog> logs;

  /// Today's day: its title, its framing copy and its actions, mandatory first
  /// then optionals by `sort`. Null when the content is not cached — the UI
  /// shows the existing recoverable "content unavailable" state and the run is
  /// not lost.
  ///
  /// The mandatory-first ordering is the repository's, done in SQL
  /// (`content_repository.dart` `_hydrateDays`). The defensive re-sort that
  /// used to live here only ever normalised what was already normalised, and
  /// [DaySpec.mandatory] finds the action by its flag rather than by its
  /// index — so a content mistake still cannot bury the action the grade
  /// depends on.
  final DaySpec? today;

  /// Every action of this campaign, by id. Used for the run total, which spans
  /// days whose actions are not on screen.
  final Map<String, ActionSpec> actionsById;

  final RunEngine engine;

  int get lengthDays => campaign.lengthDays;

  DayLog? get todayLog {
    for (final log in logs) {
      if (log.dayIndex == storyPosition) return log;
    }
    return null;
  }

  /// The one action the grade depends on. Null when content is not cached.
  ActionSpec? get mandatoryToday => today?.mandatory;

  List<ActionSpec> get optionalsToday => today?.optionals ?? const [];

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
  int get todayPoints {
    final actions = today?.actions ?? const <ActionSpec>[];
    return engine.pointsFor(
      completedActionIds: completedActionIdsToday,
      actionsById: {for (final a in actions) a.id: a},
    );
  }

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

  bool get isFinalDay => storyPosition >= lengthDays;

  /// The final day has both arrived and been resolved, so the run is ready to
  /// be completed and graded. Elapsing alone is not enough — the user still has
  /// the final day until they report it or rollover resolves it.
  bool get isFinished => isFinalDay && isReportedToday;
}
