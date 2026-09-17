import 'dart:io';

import 'package:drift/native.dart';
import 'package:feral/src/app/run_state.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  // `berlin` below is resolved at declaration time, before any setUpAll
  // callback runs — so the database must be loaded synchronously here.
  tzdata.initializeTimeZones();

  late Directory dir;
  late File dbFile;
  final berlin = tz.getLocation('Europe/Berlin');

  const campaign = Campaign(
    id: 'campaign-1',
    packId: 'pack-1',
    key: 'first-week',
    title: 'The First Week',
    introMd: 'i',
    lengthDays: 7,
  );

  setUp(() {
    dir = Directory.systemTemp.createTempSync('feral_restart');
    dbFile = File('${dir.path}/feral.sqlite');
  });
  tearDown(() => dir.deleteSync(recursive: true));

  FeralDatabase open() => FeralDatabase(NativeDatabase(dbFile));

  test(
    'a run and its day logs survive closing and reopening the database',
    () async {
      final day1 = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();

      // Session one: start, commit, report.
      var db = open();
      var repo = ProgressRepository(
        db: db,
        clock: FixedClock(day1),
        zone: berlin,
      );
      final run = await repo.startRun(
        userId: 'user-1',
        campaignId: 'campaign-1',
        isUnlocked: true,
      );
      await repo.commitToday(run: run, dayIndex: 1, actionId: 'action-1');
      await repo.report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        outcome: Outcome.done,
      );
      await db.close();

      // Session two: two days later, as if the app were relaunched.
      final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
      db = open();
      repo = ProgressRepository(db: db, clock: FixedClock(day3), zone: berlin);

      final restored = await repo.activeRun('user-1');
      expect(restored, isNotNull);
      expect(restored!.id, run.id);
      expect(restored.startedAt, day1);

      await repo.applyRollover(
        run: restored,
        lengthDays: campaign.lengthDays,
        mandatoryActionIdForDay: (d) => 'action-$d',
      );

      final logs = await repo.logsFor(restored.id);
      final state = RunState.derive(
        run: restored,
        campaign: campaign,
        logs: logs,
        zone: berlin,
        now: day3,
      );

      expect(
        state.storyPosition,
        2,
        reason: 'day 2 was never resolved, so the story still stands on it',
      );
      expect(
        state.logs.firstWhere((l) => l.dayIndex == 1).outcome,
        Outcome.done,
      );
      expect(
        state.logs.where((l) => l.dayIndex == 2),
        isEmpty,
        reason: 'an absent day leaves no row — it is a gap (ADR-0040)',
      );
      expect(
        state.absentDates,
        [DateTime.utc(2026, 6, 2)],
        reason: 'the 2nd is where the miss actually lives now',
      );
      expect(state.missCount, 1);
      expect(state.grade, Grade.passed);

      await db.close();
    },
  );
}
