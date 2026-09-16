import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/repositories/progress_repository.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/outcome.dart';
import 'package:feral/src/domain/run.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// One user, two devices: two independent local databases over one server
/// account, exactly as two phones would be.
class Device {
  Device(
    this.name,
    this.client, {
    required DateTime now,
    required tz.Location zone,
  }) : db = FeralDatabase(NativeDatabase.memory()) {
    api = SupabaseProgressApi(client);
    sync = SyncRepository(db: db, api: api, clock: FixedClock(now));
    progress = ProgressRepository(db: db, clock: FixedClock(now), zone: zone);
  }

  final String name;
  final SupabaseClient client;
  final FeralDatabase db;
  late final SupabaseProgressApi api;
  late final SyncRepository sync;
  late final ProgressRepository progress;

  /// The day's mandatory action, which ProgressRepository.report requires.
  ///
  /// Two hops, because an action no longer carries a campaign or a day index: it
  /// hangs off `day_id` and the day owns both (ADR-0034). This helper queried the
  /// dropped columns until now, which nothing noticed because CI has never had a
  /// device to run these tests on.
  Future<String> actionIdFor(String campaignId, int dayIndex) async {
    final days = await client
        .from('days')
        .select('id')
        .eq('campaign_id', campaignId)
        .eq('day_index', dayIndex)
        .limit(1);
    final rows = await client
        .from('actions')
        .select('id')
        .eq('day_id', days.first['id'] as String)
        .eq('is_optional', false)
        .limit(1);
    return rows.first['id'] as String;
  }

  Future<void> close() => db.close();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Two databases at once is the entire point here — they are two devices,
  // each with its own executor.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  late SupabaseClient client;
  late String userId;
  late String campaignId;
  late tz.Location zone;
  late Device a;
  late Device b;

  setUpAll(() async {
    tzdata.initializeTimeZones();
    zone = tz.getLocation('Europe/Berlin');

    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'http://127.0.0.1:54321',
      ),
      // publishableKey, not the deprecated anonKey alias — same as the app's
      // own bootstrap (supabase_flutter 2.17).
      publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    client = Supabase.instance.client;
    await client.auth.signInAnonymously();
    userId = client.auth.currentUser!.id;

    final campaigns = await client.from('campaigns').select('id').limit(1);
    campaignId = campaigns.first['id'] as String;
  });

  setUp(() {
    final now = DateTime.utc(2026, 6, 10, 9);
    a = Device('A', client, now: now, zone: zone);
    b = Device('B', client, now: now, zone: zone);
  });

  tearDown(() async {
    await a.close();
    await b.close();
    await client.from('day_logs').delete().eq('user_id', userId);
    await client.from('campaign_runs').delete().eq('user_id', userId);
  });

  Future<void> report(
    Device device,
    CampaignRun run,
    int dayIndex,
    Outcome outcome, {
    String? note,
  }) async {
    await device.progress.report(
      run: run,
      dayIndex: dayIndex,
      mandatoryActionId: await device.actionIdFor(run.campaignId, dayIndex),
      outcome: outcome,
      note: note,
    );
  }

  /// Force an earlier start so the reconciliation rule has a definite winner
  /// rather than depending on how fast the two startRun calls ran.
  Future<void> backdate(Device device, String runId, DateTime at) =>
      (device.db.update(device.db.campaignRuns)
            ..where((r) => r.id.equals(runId)))
          .write(CampaignRunsCompanion(startedAt: Value(at)));

  testWidgets('a day reported on A appears on B', (tester) async {
    final run = await a.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );
    await report(a, run, 1, Outcome.done, note: 'did it');
    await a.sync.sync(userId);

    await b.sync.sync(userId);

    final logs = await b.db.select(b.db.dayLogs).get();
    expect(logs, hasLength(1));
    expect(logs.single.outcome, 'done');
    expect(logs.single.note, 'did it');

    // Nothing is owed any more: the flush removed the entry when the server
    // acknowledged it, and the refresh brought back the server's own row.
    expect(await b.db.select(b.db.outbox).get(), isEmpty);
  });

  testWidgets('the later of two conflicting reports wins on both devices', (
    tester,
  ) async {
    final run = await a.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );
    await a.sync.sync(userId);
    await b.sync.sync(userId);

    // Both offline, both report day 1 differently. B reports later.
    await report(a, run, 1, Outcome.partial);
    await report(b, run, 1, Outcome.done);
    await (b.db.update(b.db.dayLogs)..where((l) => l.dayIndex.equals(1))).write(
      DayLogsCompanion(updatedAt: Value(DateTime.utc(2026, 6, 10, 21))),
    );

    await a.sync.sync(userId);
    await b.sync.sync(userId);
    await a.sync.sync(userId);

    expect((await a.db.select(a.db.dayLogs).getSingle()).outcome, 'done');
    expect((await b.db.select(b.db.dayLogs).getSingle()).outcome, 'done');
  });

  testWidgets(
    'the same day reported on both devices produces one row, not two',
    (tester) async {
      final run = await a.progress.startRun(
        userId: userId,
        campaignId: campaignId,
        isUnlocked: true,
      );
      await a.sync.sync(userId);
      await b.sync.sync(userId);

      // Different uuids for the same (run_id, day_index) — the trap.
      await report(a, run, 2, Outcome.done);
      await report(b, run, 2, Outcome.skipped);

      await a.sync.sync(userId);
      await b.sync.sync(userId);
      await a.sync.sync(userId);

      expect(await a.db.select(a.db.dayLogs).get(), hasLength(1));
      expect(await b.db.select(b.db.dayLogs).get(), hasLength(1));

      final server = await client
          .from('day_logs')
          .select()
          .eq('user_id', userId)
          .eq('day_index', 2);
      expect(server, hasLength(1));
    },
  );

  testWidgets('two offline starts converge on whichever reached the server', (
    tester,
  ) async {
    // A is deliberately the *earlier* run, and B is deliberately the one that
    // syncs first. The old rule kept the earlier `started_at` and needed two
    // devices that cannot talk to agree on it; the rule now is simply that the
    // run already on the server keeps the slot. This is the case where the two
    // answers differ, which is what makes it worth asserting.
    final runA = await a.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );
    await backdate(a, runA.id, DateTime.utc(2026, 6, 10, 8));
    final runB = await b.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );

    await b.sync.sync(userId);
    final outcome = await a.sync.sync(userId);

    // The rejection is expected and is resolved, not failed.
    expect(outcome.push.succeeded, isTrue);

    final aRuns = await a.db.select(a.db.campaignRuns).get();
    expect(
      aRuns.firstWhere((r) => r.id == runA.id).status,
      'abandoned',
      reason: 'started earlier, but arrived second',
    );
    expect(aRuns.where((r) => r.status == 'active').single.id, runB.id);

    // And the device that lost the slot told the user.
    expect(a.sync.pendingNotices, isNotEmpty);
  });

  testWidgets("neither device loses the abandoned run's day logs", (
    tester,
  ) async {
    final runA = await a.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );
    await backdate(a, runA.id, DateTime.utc(2026, 6, 10, 8));
    final runB = await b.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );
    await report(b, runB, 1, Outcome.done);

    await a.sync.sync(userId);
    await b.sync.sync(userId);
    await b.sync.sync(userId);

    // The abandoned run is closed, but its honest record survives. Nothing in
    // this product deletes a day the user reported (ADR-0003) -- and the queue
    // is what carries that: B's rejected run is rewritten as abandoned rather
    // than dropped, so the run and its day log both still reach the server.
    final logs = await b.db.select(b.db.dayLogs).get();
    expect(logs.where((l) => l.runId == runB.id), hasLength(1));

    final onServer = await client
        .from('day_logs')
        .select('run_id')
        .eq('user_id', userId)
        .eq('run_id', runB.id);
    expect(
      onServer,
      hasLength(1),
      reason: "the losing run's effort reaches the server too",
    );
  });

  testWidgets('a pull after a reinstall rebuilds the record from nothing', (
    tester,
  ) async {
    final run = await a.progress.startRun(
      userId: userId,
      campaignId: campaignId,
      isUnlocked: true,
    );
    for (var day = 1; day <= 3; day++) {
      await report(a, run, day, Outcome.done);
    }
    await a.sync.sync(userId);

    // A brand new device: empty database, same account.
    final fresh = Device(
      'C',
      client,
      now: DateTime.utc(2026, 6, 13, 9),
      zone: zone,
    );
    await fresh.sync.sync(userId);

    expect(await fresh.db.select(fresh.db.campaignRuns).get(), hasLength(1));
    expect(await fresh.db.select(fresh.db.dayLogs).get(), hasLength(3));
    await fresh.close();
  });
}
