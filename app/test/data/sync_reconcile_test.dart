import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/sync_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show PostgrestException;
import 'package:test/test.dart';

import 'sync_push_test.dart' show FakeProgressApi;

void main() {
  late FeralDatabase db;
  late FakeProgressApi api;
  late SyncRepository sync;

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    api = FakeProgressApi();
    sync = SyncRepository(
      db: db,
      api: api,
      clock: FixedClock(DateTime.utc(2026, 6, 10, 9)),
    );
  });
  tearDown(() => db.close());

  Future<void> insertLocalActiveRun(String id, DateTime startedAt) => db
      .into(db.campaignRuns)
      .insert(
        CampaignRunsCompanion.insert(
          id: id,
          userId: 'user-1',
          campaignId: 'campaign-1',
          status: 'active',
          startedAt: startedAt,
          updatedAt: startedAt,
        ),
      );

  Map<String, dynamic> remoteRun(String id, DateTime startedAt) => {
    'id': id,
    'user_id': 'user-1',
    'campaign_id': 'campaign-2',
    'status': 'active',
    'is_hardened': false,
    'started_at': startedAt.toUtc().toIso8601String(),
    'completed_at': null,
    'grade': null,
    'updated_at': startedAt.toUtc().toIso8601String(),
  };

  void rejectRunPush() {
    api.throwOnUpsertForTable['campaign_runs'] = const PostgrestException(
      message: 'duplicate key value violates unique constraint',
      code: '23505',
    );
  }

  test('a rejected active-run push abandons the later run locally', () async {
    await insertLocalActiveRun('local-run', DateTime.utc(2026, 6, 5));
    rejectRunPush();
    api.remote['campaign_runs'] = [
      remoteRun('server-run', DateTime.utc(2026, 6, 1)),
    ];

    await sync.sync('user-1');

    final runs = await db.select(db.campaignRuns).get();
    final local = runs.firstWhere((r) => r.id == 'local-run');
    expect(local.status, 'abandoned');
    expect(
      local.dirty,
      isTrue,
      reason: 'the abandonment must reach the server',
    );
  });

  test(
    'the surviving run is the earlier one, and it is present locally',
    () async {
      await insertLocalActiveRun('local-run', DateTime.utc(2026, 6, 5));
      rejectRunPush();
      api.remote['campaign_runs'] = [
        remoteRun('server-run', DateTime.utc(2026, 6, 1)),
      ];

      await sync.sync('user-1');

      final runs = await db.select(db.campaignRuns).get();
      final survivor = runs.firstWhere((r) => r.status == 'active');
      expect(survivor.id, 'server-run');
    },
  );

  test('the user is told, exactly once, and it is not an error', () async {
    await insertLocalActiveRun('local-run', DateTime.utc(2026, 6, 5));
    rejectRunPush();
    api.remote['campaign_runs'] = [
      remoteRun('server-run', DateTime.utc(2026, 6, 1)),
    ];

    await sync.sync('user-1');

    final notices = sync.consumeNotices();
    expect(notices, hasLength(1));
    expect(notices.single.kind, SyncNoticeKind.runReconciled);
    expect(sync.consumeNotices(), isEmpty, reason: 'consumed, not repeated');
  });

  test('a 23505 collision does not mark the whole sync failed', () async {
    await insertLocalActiveRun('local-run', DateTime.utc(2026, 6, 5));
    rejectRunPush();
    api.remote['campaign_runs'] = [
      remoteRun('server-run', DateTime.utc(2026, 6, 1)),
    ];

    final outcome = await sync.sync('user-1');

    expect(
      outcome.push.succeeded,
      isTrue,
      reason: 'an expected rejection is a resolution, not a failure',
    );
  });

  test(
    'a non-23505 error is a real failure and is not reconciled away',
    () async {
      await insertLocalActiveRun('local-run', DateTime.utc(2026, 6, 5));
      api.throwOnUpsertForTable['campaign_runs'] = const PostgrestException(
        message: 'permission denied',
        code: '42501',
      );

      final outcome = await sync.sync('user-1');

      expect(outcome.push.succeeded, isFalse);
      expect((await db.select(db.campaignRuns).get()).single.status, 'active');
    },
  );
}
