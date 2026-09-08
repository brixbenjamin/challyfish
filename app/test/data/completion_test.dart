import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/domain/campaign.dart';
import 'package:feral/src/domain/grade.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  tzdata.initializeTimeZones();

  late FeralDatabase db;
  final berlin = tz.getLocation('Europe/Berlin');

  const campaign = Campaign(
    id: 'c-1',
    packId: 'p-1',
    key: 'first',
    title: 'The First Week',
    introMd: 'i',
    lengthDays: 7,
  );

  final day1 = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
  DateTime dayN(int n) => tz.TZDateTime(berlin, 2026, 6, n, 20).toUtc();

  ProgressRepository repoAt(DateTime now) =>
      ProgressRepository(db: db, clock: FixedClock(now), zone: berlin);

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<CampaignRun> runAllDays({required int misses}) async {
    final repo = repoAt(day1);
    final run = await repo.startRun(userId: 'u', campaignId: 'c-1');
    for (var day = 1; day <= 7; day++) {
      await repoAt(dayN(day)).report(
        run: run,
        dayIndex: day,
        actionId: 'a-$day',
        outcome: day <= misses ? Outcome.skipped : Outcome.done,
      );
    }
    return run;
  }

  test('a clean 7-day run completes as Sovereign', () async {
    final run = await runAllDays(misses: 0);
    final grade = await repoAt(
      dayN(7),
    ).completeRunIfFinished(run: run, campaign: campaign);

    expect(grade, Grade.sovereign);
    final stored = await db.select(db.campaignRuns).getSingle();
    expect(stored.status, 'completed');
    expect(stored.grade, 'sovereign');
    expect(stored.completedAt, isNotNull);
  });

  test('one miss in a 7-day run is Passed, because it allows one', () async {
    final run = await runAllDays(misses: 1);
    expect(
      await repoAt(dayN(7)).completeRunIfFinished(run: run, campaign: campaign),
      Grade.passed,
    );
  });

  test('two misses break a 7-day run', () async {
    final run = await runAllDays(misses: 2);
    expect(
      await repoAt(dayN(7)).completeRunIfFinished(run: run, campaign: campaign),
      Grade.broken,
    );
  });

  test('a run mid-way does not complete', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(userId: 'u', campaignId: 'c-1');
    await repo.report(
      run: run,
      dayIndex: 1,
      actionId: 'a-1',
      outcome: Outcome.done,
    );

    expect(
      await repoAt(dayN(3)).completeRunIfFinished(run: run, campaign: campaign),
      isNull,
    );
    expect((await db.select(db.campaignRuns).getSingle()).status, 'active');
  });

  test('the final day elapsing is not enough — it must be resolved', () async {
    final repo = repoAt(day1);
    final run = await repo.startRun(userId: 'u', campaignId: 'c-1');
    for (var day = 1; day <= 6; day++) {
      await repoAt(dayN(day)).report(
        run: run,
        dayIndex: day,
        actionId: 'a-$day',
        outcome: Outcome.done,
      );
    }

    // Day 7 has arrived but is unreported: the user still has the day.
    expect(
      await repoAt(dayN(7)).completeRunIfFinished(run: run, campaign: campaign),
      isNull,
    );
  });

  test('completing is idempotent and never regrades', () async {
    final run = await runAllDays(misses: 0);
    final later = repoAt(dayN(9));

    final first = await later.completeRunIfFinished(
      run: run,
      campaign: campaign,
    );
    final second = await later.completeRunIfFinished(
      run: run,
      campaign: campaign,
    );

    expect(first, Grade.sovereign);
    expect(second, isNull, reason: 'already completed');
    expect((await db.select(db.campaignRuns).getSingle()).grade, 'sovereign');
  });

  test(
    'a broken run keeps every day log — nothing is deleted or reset',
    () async {
      final run = await runAllDays(misses: 4);
      await repoAt(dayN(7)).completeRunIfFinished(run: run, campaign: campaign);

      expect(await db.select(db.dayLogs).get(), hasLength(7));
      expect(await db.select(db.campaignRuns).get(), hasLength(1));
    },
  );

  test('completing frees the active slot for a new run', () async {
    final run = await runAllDays(misses: 0);
    final repo = repoAt(dayN(8));
    await repo.completeRunIfFinished(run: run, campaign: campaign);

    expect(await repo.activeRun('u'), isNull);
    await repo.startRun(userId: 'u', campaignId: 'c-2');
    expect((await repo.activeRun('u'))?.campaignId, 'c-2');
  });

  test('the stored grade is read back onto the run', () async {
    // The grade is materialized once, but RunEngine remains the definition —
    // a run read back must carry what was written.
    final run = await runAllDays(misses: 1);
    final repo = repoAt(dayN(8));
    await repo.completeRunIfFinished(run: run, campaign: campaign);

    final all = await repo.allRuns('u');
    expect(all.single.grade, Grade.passed);
    expect(all.single.status, RunStatus.completed);
  });
}
