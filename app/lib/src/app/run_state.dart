import 'package:timezone/timezone.dart' as tz;

import '../domain/campaign.dart';
import '../domain/day_log.dart';
import '../domain/grade.dart';
import '../domain/run.dart';
import '../engine/run_engine.dart';

/// Everything the dashboard needs, all of it derived.
///
/// Nothing here is read from a column. Constructing this object is the only way
/// the UI learns what day it is or what grade the run stands at, which is what
/// keeps rules out of widgets.
class RunState {
  const RunState({
    required this.run,
    required this.campaign,
    required this.currentDay,
    required this.missCount,
    required this.missAllowance,
    required this.grade,
    required this.logs,
    this.todayAction,
  });

  factory RunState.derive({
    required CampaignRun run,
    required Campaign campaign,
    required List<DayLog> logs,
    required tz.Location zone,
    required DateTime now,
    ActionSpec? todayAction,
    RunEngine engine = const RunEngine(),
  }) {
    final day = engine.currentDay(
      startedAt: run.startedAt,
      zone: zone,
      now: now,
      lengthDays: campaign.lengthDays,
    );

    return RunState(
      run: run,
      campaign: campaign,
      currentDay: day,
      missCount: engine.missCount(logs),
      missAllowance: engine.missAllowance(campaign.lengthDays),
      grade: engine.grade(logs, lengthDays: campaign.lengthDays),
      logs: logs,
      todayAction: todayAction,
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

  /// Null when the action is not cached — the UI shows a recoverable
  /// "content unavailable" state and the run is not lost.
  final ActionSpec? todayAction;

  int get lengthDays => campaign.lengthDays;

  DayLog? get todayLog {
    for (final log in logs) {
      if (log.dayIndex == currentDay) return log;
    }
    return null;
  }

  bool get isCommittedToday => todayLog?.committedAt != null;

  bool get isReportedToday => todayLog?.isReported ?? false;

  bool get isFinalDay => currentDay >= lengthDays;

  /// The final day has both arrived and been resolved, so the run is ready to
  /// be completed and graded. Elapsing alone is not enough — the user still has
  /// the final day until they report it or rollover resolves it.
  bool get isFinished => isFinalDay && isReportedToday;
}
