import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// A run that ends while the user is away has to be *discovered*, never found
/// already gone (ADR-0040). `activeRun` filters on status, so without this the
/// user opens the app and is simply dropped back to the shelf.
void main() {
  tzdata.initializeTimeZones();

  late FeralDatabase db;
  final berlin = tz.getLocation('Europe/Berlin');

  ProgressRepository repoAt(DateTime now) =>
      ProgressRepository(db: db, clock: FixedClock(now), zone: berlin);

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  DateTime at(int day) => tz.TZDateTime(berlin, 2026, 6, day, 9).toUtc();

  Future<String> abandonedRun() async {
    final run = await repoAt(at(1)).startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );
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
    return run.id;
  }

  test('an abandoned run is offered once', () async {
    final id = await abandonedRun();
    final repo = repoAt(at(5));

    final notice = await repo.unacknowledgedAbandonment('user-1');
    expect(notice, isNotNull);
    expect(notice!.id, id);
    expect(notice.abandonedOn?.toUtc(), DateTime.utc(2026, 6, 4));
  });

  test('acknowledging it stops it coming back', () async {
    final id = await abandonedRun();
    final repo = repoAt(at(5));

    await repo.acknowledgeAbandonment(id);
    expect(await repo.unacknowledgedAbandonment('user-1'), isNull);
  });

  test('a run the user abandoned themselves is never offered', () async {
    // They chose it and saw the warning. Telling them again is nagging.
    final run = await repoAt(at(1)).startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );
    await repoAt(at(1)).abandonRun(run.id);

    expect(await repoAt(at(2)).unacknowledgedAbandonment('user-1'), isNull);
  });

  test('an active run is never offered', () async {
    await repoAt(at(1)).startRun(
      userId: 'user-1',
      campaignId: 'campaign-1',
      isUnlocked: true,
    );
    expect(await repoAt(at(2)).unacknowledgedAbandonment('user-1'), isNull);
  });

  test('another user\'s abandoned run is not offered', () async {
    await abandonedRun();
    expect(await repoAt(at(5)).unacknowledgedAbandonment('user-2'), isNull);
  });
}
