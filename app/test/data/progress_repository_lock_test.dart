import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tzdata.initializeTimeZones);

  late FeralDatabase db;
  late ProgressRepository repo;

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    repo = ProgressRepository(
      db: db,
      clock: FixedClock(DateTime.utc(2026, 6, 1, 9)),
      zone: tz.getLocation('Europe/Berlin'),
    );
  });
  tearDown(() => db.close());

  test('starting a locked campaign throws', () async {
    expect(
      () => repo.startRun(
        userId: 'user-1',
        campaignId: 'campaign-paid',
        isUnlocked: false,
      ),
      throwsA(isA<PackLocked>()),
    );
  });

  test('a refused start writes nothing at all', () async {
    try {
      await repo.startRun(
        userId: 'user-1',
        campaignId: 'campaign-paid',
        isUnlocked: false,
      );
    } on PackLocked {
      // expected
    }

    expect(await db.select(db.campaignRuns).get(), isEmpty);
    expect(await db.select(db.dayLogs).get(), isEmpty);
  });

  test('a refused start does not disturb an existing active run', () async {
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-free',
      isUnlocked: true,
    );

    try {
      await repo.startRun(
        userId: 'user-1',
        campaignId: 'campaign-paid',
        isUnlocked: false,
      );
    } on PackLocked {
      // expected
    }

    final active = await repo.activeRun('user-1');
    expect(active, isNotNull);
    expect(
      active!.id,
      run.id,
      reason: 'the refusal must not abandon what the user is running',
    );
  });

  test('an unlocked campaign starts normally', () async {
    final run = await repo.startRun(
      userId: 'user-1',
      campaignId: 'campaign-free',
      isUnlocked: true,
    );
    expect(run.campaignId, 'campaign-free');
  });
}
