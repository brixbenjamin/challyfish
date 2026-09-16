import 'package:drift/drift.dart' show OrderingTerm;
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
    expect(stored.grade, isNull, reason: 'an active run carries no grade');

    final queued = await db.select(db.outbox).getSingle();
    expect(queued.remoteTable, 'campaign_runs');
    expect(queued.rowKey, run.id);
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
      mandatoryActionId: 'action-1',
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
      mandatoryActionId: 'action-1',
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
    expect(stored.committedAt, isNotNull);

    // Queued under the natural key, not the uuid this device happened to mint.
    final queued = await (db.select(
      db.outbox,
    )..where((o) => o.remoteTable.equals('day_logs'))).getSingle();
    expect(queued.rowKey, '${run.id}:1');
  });

  test('reporting after committing leaves one entry, not two', () async {
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
      mandatoryActionId: 'action-1',
      outcome: Outcome.done,
    );

    final stored = await db.select(db.dayLogs).getSingle();
    expect(stored.outcome, Outcome.done.key);

    // Committing then reporting touches the same row twice. One entry carrying
    // the final state, not two carrying a sequence: the queue replaces a pending
    // entry for a row rather than appending beside it.
    final queued = await (db.select(
      db.outbox,
    )..where((o) => o.remoteTable.equals('day_logs'))).get();
    expect(queued, hasLength(1));
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
        mandatoryActionId: 'action-1',
        outcome: Outcome.done,
      );

      // The user returns on day 5.
      final day5 = tz.TZDateTime(berlin, 2026, 6, 5, 9).toUtc();
      final later = repoAt(day5);

      await later.applyRollover(
        run: run,
        lengthDays: 7,
        mandatoryActionIdForDay: (d) => 'action-$d',
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
        mandatoryActionIdForDay: (d) => 'action-$d',
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
      mandatoryActionId: 'action-1',
      outcome: Outcome.skipped,
    );

    final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
    await repoAt(day3).applyRollover(
      run: run,
      lengthDays: 7,
      mandatoryActionIdForDay: (d) => 'action-$d',
    );

    final logs = await repoAt(day3).logsFor(run.id);
    expect(logs.firstWhere((l) => l.dayIndex == 1).outcome, Outcome.skipped);
  });

  group('ticks', () {
    Future<CampaignRun> startRun(ProgressRepository repo) => repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );

    test('ticking before committing creates the day row', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: true,
      );

      final logs = await repo.logsFor(run.id);
      expect(logs, hasLength(1));
      expect(logs.single.completedActionIds, {'action-1'});
      expect(logs.single.committedAt, isNull);
      expect(logs.single.outcome, isNull);
    });

    test('an optional tick does not rewrite the assigned action', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'optional-1',
        completed: true,
      );

      final log = (await repo.logsFor(run.id)).single;
      expect(
        log.actionId,
        'action-1',
        reason: 'the day is still assigned its mandatory action',
      );
      expect(log.completedActionIds, {'optional-1'});
    });

    test('unticking flips the flag and never deletes the row', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: true,
      );
      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: false,
      );

      // The row must survive. Unticking is something the user did, so it has to
      // travel as a value the server can store; an absent row says nothing.
      final rows = await db.select(db.dayLogActions).get();
      expect(rows, hasLength(1));
      expect(rows.single.completed, isFalse);

      final logs = await repo.logsFor(run.id);
      expect(logs.single.completedActionIds, isEmpty);
    });

    test('a fresh tick is queued for the server', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: true,
      );

      final queued = await (db.select(
        db.outbox,
      )..where((o) => o.remoteTable.equals('day_log_actions'))).getSingle();
      expect(queued.rowKey, '${run.id}:1:action-1');
    });

    test('a run is queued before the ticks under it', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: true,
      );

      // Ascending id is the only push order there is, and the server's foreign
      // keys depend on it: a day log sent before its run is rejected, and the
      // retry is rejected identically forever.
      final queued = await (db.select(
        db.outbox,
      )..orderBy([(o) => OrderingTerm.asc(o.id)])).get();
      expect(queued.map((q) => q.remoteTable), [
        'campaign_runs',
        'day_logs',
        'day_log_actions',
      ]);
    });

    test('several ticks on one day all come back on the log', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      for (final id in ['action-1', 'optional-1', 'optional-2']) {
        await repo.setActionCompleted(
          run: run,
          dayIndex: 1,
          mandatoryActionId: 'action-1',
          actionId: id,
          completed: true,
        );
      }

      final log = (await repo.logsFor(run.id)).single;
      expect(log.completedActionIds, {'action-1', 'optional-1', 'optional-2'});
      expect(
        await db.select(db.dayLogs).get(),
        hasLength(1),
        reason: 'still one day log, however many actions it holds',
      );
    });

    test(
      'rollover writes the derived outcome for a day that was acted on',
      () async {
        // Day 1 was ticked but never reported, and the run has moved on.
        final repo = repoAt(day1);
        final run = await startRun(repo);
        await repo.setActionCompleted(
          run: run,
          dayIndex: 1,
          mandatoryActionId: 'action-1',
          actionId: 'optional-1',
          completed: true,
        );

        final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
        await repoAt(day3).applyRollover(
          run: run,
          lengthDays: 30,
          mandatoryActionIdForDay: (_) => 'action-1',
        );

        final logs = await repoAt(day3).logsFor(run.id);
        final day1Log = logs.firstWhere((l) => l.dayIndex == 1);
        expect(
          day1Log.outcome,
          Outcome.partial,
          reason: 'writing missed over a day the user acted on is dishonest',
        );
      },
    );

    test('rollover writes done when the mandatory action was ticked', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);
      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: true,
      );

      final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
      await repoAt(day3).applyRollover(
        run: run,
        lengthDays: 30,
        mandatoryActionIdForDay: (_) => 'action-1',
      );

      final logs = await repoAt(day3).logsFor(run.id);
      expect(logs.firstWhere((l) => l.dayIndex == 1).outcome, Outcome.done);
    });

    test('rollover still writes missed for a day with no ticks', () async {
      final repo = repoAt(day1);
      final run = await startRun(repo);

      final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
      await repoAt(day3).applyRollover(
        run: run,
        lengthDays: 30,
        mandatoryActionIdForDay: (_) => 'action-1',
      );

      final logs = await repoAt(day3).logsFor(run.id);
      expect(logs.firstWhere((l) => l.dayIndex == 1).outcome, Outcome.missed);
    });

    test('an unticked tick row does not rescue a day from missed', () async {
      // The row exists but says the user did not do it. That is a miss.
      final repo = repoAt(day1);
      final run = await startRun(repo);
      await repo.setActionCompleted(
        run: run,
        dayIndex: 1,
        mandatoryActionId: 'action-1',
        actionId: 'action-1',
        completed: false,
      );

      final day3 = tz.TZDateTime(berlin, 2026, 6, 3, 9).toUtc();
      await repoAt(day3).applyRollover(
        run: run,
        lengthDays: 30,
        mandatoryActionIdForDay: (_) => 'action-1',
      );

      final logs = await repoAt(day3).logsFor(run.id);
      expect(logs.firstWhere((l) => l.dayIndex == 1).outcome, Outcome.missed);
    });
  });
}
