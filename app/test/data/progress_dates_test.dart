import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// The repository half of ADR-0040: stamping the dates a day happened on,
/// resolving a worked-on day at its close rather than writing `missed`, and
/// ending a run that has gone three consecutive days untouched.
void main() {
  tzdata.initializeTimeZones();

  late FeralDatabase db;
  final berlin = tz.getLocation('Europe/Berlin');

  ProgressRepository repoAt(DateTime now) =>
      ProgressRepository(db: db, clock: FixedClock(now), zone: berlin);

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// 09:00 local on the given June day.
  DateTime at(int day) => tz.TZDateTime(berlin, 2026, 6, day, 9).toUtc();
  DateTime date(int day) => DateTime.utc(2026, 6, day);

  const campaign = Campaign(
    id: 'campaign-1',
    packId: 'pack-1',
    key: 'campaign-1',
    title: 'A campaign',
    introMd: 'intro',
    lengthDays: 5,
  );

  Future<CampaignRun> startOn(int day) async {
    final repo = repoAt(at(day));
    return repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );
  }

  group('stamping the dates', () {
    test('reporting stamps both the worked-on and resolved-on dates', () async {
      final run = await startOn(1);
      await repoAt(at(1)).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.workedOn?.toUtc(), date(1));
      expect(log.resolvedOn?.toUtc(), date(1));
    });

    test('committing stamps worked-on but leaves the day unresolved', () async {
      final run = await startOn(1);
      await repoAt(at(1)).commitToday(run: run, dayIndex: 1, actionId: 'act-1');

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.workedOn?.toUtc(), date(1));
      expect(log.resolvedOn, isNull);
      expect(log.outcome, isNull);
    });

    test('the worked-on date never moves once set', () async {
      // Committed on the 1st, reported on the 2nd. The day was the 1st's.
      final run = await startOn(1);
      await repoAt(at(1)).commitToday(run: run, dayIndex: 1, actionId: 'act-1');
      await repoAt(at(2)).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.workedOn?.toUtc(), date(1));
    });

    test('the stamped date is local, not the UTC instant', () async {
      // 01:00 on the 2nd in Berlin is 23:00 UTC on the 1st. The user's day is
      // the 2nd, and that is what has to be recorded.
      final run = await startOn(1);
      final justAfterMidnight = tz.TZDateTime(berlin, 2026, 6, 2, 1).toUtc();
      await repoAt(justAfterMidnight).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );

      expect(
        (await db.select(db.dayLogs).getSingle()).workedOn?.toUtc(),
        date(2),
      );
    });
  });

  group('rollover', () {
    test('a day worked on but never reported resolves at its close', () async {
      final run = await startOn(1);
      await repoAt(at(1)).setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        actionId: 'act-1',
        completed: true,
      );

      await repoAt(at(3)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.outcome, Outcome.done.key);
      expect(
        log.resolvedOn?.toUtc(),
        date(1),
        reason: 'resolved at the close of the day it was worked, not today',
      );
    });

    test('a day nobody touched gets no log at all', () async {
      // This is what replaced `missed`. An absence is a gap in the calendar,
      // not an outcome written on the user's behalf.
      final run = await startOn(1);
      await repoAt(at(4)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      expect(await db.select(db.dayLogs).get(), isEmpty);
    });

    test('rollover is idempotent', () async {
      final run = await startOn(1);
      await repoAt(at(1)).setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        actionId: 'act-1',
        completed: true,
      );

      final repo = repoAt(at(2));
      await repo.applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );
      final first = await db.select(db.dayLogs).getSingle();
      await repo.applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );
      final second = await db.select(db.dayLogs).getSingle();

      expect(second.outcome, first.outcome);
      expect(second.resolvedOn, first.resolvedOn);
    });

    test('a day with uncached content is still resolved', () async {
      // The old rollover skipped it, because action_id could not be null.
      // A skipped day silently became an absence and could end a run.
      final run = await startOn(1);
      await repoAt(at(1)).commitToday(run: run, dayIndex: 1, actionId: 'act-1');

      await repoAt(at(2)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => null,
      );

      final log = await db.select(db.dayLogs).getSingle();
      expect(log.outcome, Outcome.skipped.key);
      expect(log.resolvedOn?.toUtc(), date(1));
    });
  });

  group('abandonment', () {
    test('two consecutive absent days leave the run active', () async {
      final run = await startOn(1);
      await repoAt(at(1)).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );

      await repoAt(at(4)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      final stored = await db.select(db.campaignRuns).getSingle();
      expect(stored.status, RunStatus.active.key);
      expect(stored.abandonedOn, isNull);
    });

    test(
      'the third consecutive absent day ends the run, dated to it',
      () async {
        final run = await startOn(1);
        await repoAt(at(1)).report(
          run: run,
          dayIndex: 1,
          mandatoryActionId: 'act-1',
          outcome: Outcome.done,
        );

        await repoAt(at(5)).applyRollover(
          run: run,
          lengthDays: 5,
          mandatoryActionIdForDay: (_) => 'act-1',
        );

        final stored = await db.select(db.campaignRuns).getSingle();
        expect(stored.status, RunStatus.abandoned.key);
        expect(stored.abandonedOn?.toUtc(), date(4));
        expect(stored.grade, isNull, reason: 'abandoned is not a grade');
      },
    );

    test('an abandoned run keeps every day it logged', () async {
      final run = await startOn(1);
      await repoAt(at(1)).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );
      await repoAt(at(9)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      expect(await db.select(db.dayLogs).get(), hasLength(1));
    });

    test('abandonment is queued for the server', () async {
      final run = await startOn(1);
      await repoAt(at(9)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      final queued = await db.select(db.outbox).get();
      expect(
        queued.where((q) => q.rowKey == run.id),
        isNotEmpty,
        reason: 'the run row must reach the server',
      );
    });

    test('showing up on the third day saves the run', () async {
      final run = await startOn(1);
      await repoAt(at(1)).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );
      // Absent the 2nd and 3rd; reports on the 4th.
      await repoAt(at(4)).report(
        run: run,
        dayIndex: 2,
        mandatoryActionId: 'act-2',
        outcome: Outcome.done,
      );
      await repoAt(at(5)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      final stored = await db.select(db.campaignRuns).getSingle();
      expect(stored.status, RunStatus.active.key);
    });

    test('reporting skipped three days running never ends the run', () async {
      final run = await startOn(1);
      for (var day = 1; day <= 3; day++) {
        await repoAt(at(day)).report(
          run: run,
          dayIndex: day,
          mandatoryActionId: 'act-$day',
          outcome: Outcome.skipped,
        );
      }
      await repoAt(at(4)).applyRollover(
        run: run,
        lengthDays: 5,
        mandatoryActionIdForDay: (_) => 'act-1',
      );

      final stored = await db.select(db.campaignRuns).getSingle();
      expect(
        stored.status,
        RunStatus.active.key,
        reason: 'honesty keeps the run alive, even at the cost of the grade',
      );
    });
  });

  group('completion', () {
    test(
      'a run completes when its last day is resolved, however late',
      () async {
        final run = await startOn(1);
        // Five days of content spread across nine calendar days, never three
        // absent in a row.
        const days = [1, 2, 4, 5, 7];
        for (var i = 0; i < days.length; i++) {
          await repoAt(at(days[i])).report(
            run: run,
            dayIndex: i + 1,
            mandatoryActionId: 'act-${i + 1}',
            outcome: Outcome.done,
          );
        }

        final grade = await repoAt(
          at(7),
        ).completeRunIfFinished(run: run, campaign: campaign);

        expect(grade, isNotNull);
        final stored = await db.select(db.campaignRuns).getSingle();
        expect(stored.status, RunStatus.completed.key);
      },
    );

    test('elapsed calendar time alone does not complete a run', () async {
      final run = await startOn(1);
      await repoAt(at(1)).report(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'act-1',
        outcome: Outcome.done,
      );

      final grade = await repoAt(
        at(30),
      ).completeRunIfFinished(run: run, campaign: campaign);

      expect(grade, isNull);
    });
  });
}
