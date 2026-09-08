import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();

  late FeralDatabase db;
  final berlin = tz.getLocation('Europe/Berlin');

  ProgressRepository repoAt(DateTime now) =>
      ProgressRepository(db: db, clock: FixedClock(now), zone: berlin);

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  final day1 = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();

  test('starting a run creates an active run, dirty for later sync', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    expect(run.status, RunStatus.active);
    expect(run.startedAt, day1);

    final stored = await db.select(db.campaignRuns).getSingle();
    expect(stored.dirty, isTrue);
    expect(stored.grade, isNull, reason: 'an active run carries no grade');
  });

  test('activeRun returns the run; abandoning it clears the slot', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    expect((await repo.activeRun('user-1'))?.id, run.id);

    await repo.abandonRun(run.id);
    expect(await repo.activeRun('user-1'), isNull);

    // Abandoning never deletes. The record survives (ADR-0003).
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
  });

  test('committing records a timestamp without an outcome', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    await repo.commitToday(run: run, dayIndex: 1, actionId: 'action-1');

    final logs = await repo.logsFor(run.id);
    expect(logs.single.committedAt, day1);
    expect(logs.single.outcome, isNull);
  });

  test('reporting without committing is allowed', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    await repo.report(
      run: run,
      dayIndex: 1,
      actionId: 'action-1',
      outcome: Outcome.done,
      note: 'said it',
    );

    final log = (await repo.logsFor(run.id)).single;
    expect(log.outcome, Outcome.done);
    expect(log.committedAt, isNull);
    expect(log.note, 'said it');
  });

  test('reporting after committing keeps the commit timestamp', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    await repo.commitToday(run: run, dayIndex: 1, actionId: 'action-1');
    await repo.report(
      run: run,
      dayIndex: 1,
      actionId: 'action-1',
      outcome: Outcome.done,
    );

    final log = (await repo.logsFor(run.id)).single;
    expect(log.committedAt, day1);
    expect(log.outcome, Outcome.done);
    expect(
      await db.select(db.dayLogs).get(),
      hasLength(1),
      reason: 'upserted on (run_id, day_index), not duplicated',
    );
  });

  test('a freshly committed day log is dirty for later sync', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    await repo.commitToday(run: run, dayIndex: 1, actionId: 'action-1');

    final stored = await db.select(db.dayLogs).getSingle();
    expect(stored.dirty, isTrue);
  });

  test('reporting after committing keeps the day log dirty', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    await repo.commitToday(run: run, dayIndex: 1, actionId: 'action-1');
    await repo.report(
      run: run,
      dayIndex: 1,
      actionId: 'action-1',
      outcome: Outcome.done,
    );

    final stored = await db.select(db.dayLogs).getSingle();
    expect(stored.dirty, isTrue);
  });

  test(
    'rollover writes missed for elapsed unreported days and is idempotent',
    () async {
      final startRepo = repoAt(day1);
      final run = await startRepo.startRun(
        userId: 'user-1',
        campaignId: 'campaign-1',
        isUnlocked: true,
      );
      await startRepo.report(
        run: run,
        dayIndex: 1,
        actionId: 'action-1',
        outcome: Outcome.done,
      );

      // The user returns on day 5.
      final day5 = tz.TZDateTime(berlin, 2026, 6, 5, 9).toUtc();
      final later = repoAt(day5);

      await later.applyRollover(
        run: run,
        lengthDays: 7,
        actionIdForDay: (d) => 'action-$d',
      );

      final logs = await later.logsFor(run.id);
      final missed = logs
          .where((l) => l.outcome == Outcome.missed)
          .map((l) => l.dayIndex);
      expect(missed, [2, 3, 4]);
      expect(
        logs.any((l) => l.dayIndex == 5),
        isFalse,
        reason: 'today is never auto-missed',
      );

      await later.applyRollover(
        run: run,
        lengthDays: 7,
        actionIdForDay: (d) => 'action-$d',
      );
      expect(
        await later.logsFor(run.id),
        hasLength(4),
        reason: 'rollover is idempotent',
      );
    },
  );

  test('rollover never overwrites a reported day', () async {
    final startRepo = repoAt(day1);
    final run = await startRepo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );
    await startRepo.report(
      run: run,
      dayIndex: 1,
      actionId: 'action-1',
      outcome: Outcome.skipped,
    );

    final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
    await repoAt(day3).applyRollover(
      run: run,
      lengthDays: 7,
      actionIdForDay: (d) => 'action-$d',
    );

    final logs = await repoAt(day3).logsFor(run.id);
    expect(logs.firstWhere((l) => l.dayIndex == 1).outcome, Outcome.skipped);
  });
}
