import 'dart:async';

import 'package:feral/src/core/clock.dart';
import 'package:feral/src/domain/sync_status.dart';
import 'package:feral/src/engine/backoff.dart';
import 'package:feral/src/sync/sync_scheduler.dart';
import 'package:test/test.dart';

import '../support/fake_sync.dart';

void main() {
  late FakeSync sync;
  late FakeGate gate;
  late SyncScheduler scheduler;

  setUp(() {
    sync = FakeSync();
    gate = FakeGate();
    scheduler = SyncScheduler(
      runner: sync,
      gate: gate,
      clock: FixedClock(DateTime.utc(2026, 6, 10, 9)),
      backoff: const Backoff(
        base: Duration(milliseconds: 1),
        max: Duration(milliseconds: 8),
      ),
    );
  });
  tearDown(() {
    scheduler.dispose();
    gate.dispose();
  });

  test('a successful sync ends idle', () async {
    await scheduler.syncNow(userId: 'user-1');

    expect(sync.calls, 1);
    expect(scheduler.status, SyncStatus.idle);
  });

  test('offline does not attempt a sync at all', () async {
    gate.goOffline();

    await scheduler.syncNow(userId: 'user-1');

    expect(sync.calls, 0, reason: 'no point burning a request with no route');
    expect(scheduler.status, SyncStatus.offline);
  });

  test('regaining connectivity triggers a sync', () async {
    gate.goOffline();
    scheduler.start('user-1');
    await Future<void>.delayed(Duration.zero);
    expect(sync.calls, 0);

    gate.goOnline();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(sync.calls, greaterThanOrEqualTo(1));
  });

  test('starting again re-targets the scheduler at the new session', () async {
    scheduler.start('anon-user');
    await Future<void>.delayed(const Duration(milliseconds: 20));

    // Signing in replaces the session, and the app boots again against it.
    scheduler.start('existing-user');
    // Both start-up syncs are allowed to finish before the count is taken, so
    // what follows measures the listeners rather than coalescing.
    await Future<void>.delayed(const Duration(milliseconds: 20));
    sync.userIds.clear();

    gate.goOnline();
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(
      sync.userIds.toSet(),
      {'existing-user'},
      reason:
          'a listener left over from the previous session keeps syncing the '
          'account this device is no longer authenticated as, and every one of '
          'those requests is refused by row-level security',
    );
  });

  // ---------------------------------------------------------------- restore
  //
  // ADR-0024. Signing in clears this device's user tables and then has to pull
  // the account's record back. Until that pull lands the local store answers
  // "nothing here" to every question the router asks it, so the router is not
  // allowed to ask. These are the three things it needs from the scheduler to
  // wait honestly: an answer, a truthful failure, and an answer about the right
  // account.

  test('restoring an account waits for its pull and says it worked', () async {
    final restored = await scheduler.restore('existing-user');

    expect(restored, isTrue);
    expect(sync.userIds, ['existing-user']);
  });

  test(
    'a restore the server refuses reports failure rather than success',
    () async {
      sync.succeed = false;

      expect(
        await scheduler.restore('existing-user'),
        isFalse,
        reason:
            'a restore that reports success it did not have sends the user on to '
            'a screen chosen against an empty store, which is the whole bug',
      );
    },
  );

  test('a restore with no connection reports failure', () async {
    gate.goOffline();

    expect(await scheduler.restore('existing-user'), isFalse);
    expect(sync.calls, 0);
  });

  test('a restore never coalesces onto the previous session\'s sync', () async {
    sync.delay = const Duration(milliseconds: 40);
    unawaited(scheduler.syncNow(userId: 'anon-user'));
    await Future<void>.delayed(const Duration(milliseconds: 5));

    sync.delay = Duration.zero;
    final restored = await scheduler.restore('existing-user');

    expect(restored, isTrue);
    expect(
      sync.userIds.last,
      'existing-user',
      reason:
          'handing back the old session\'s future would let the router proceed '
          'on a pull that fetched the account the user just left',
    );
  });

  test(
    'a restore re-targets the scheduler at the account it restored',
    () async {
      scheduler.start('anon-user');
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await scheduler.restore('existing-user');
      sync.userIds.clear();

      gate.goOnline();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(sync.userIds.toSet(), {'existing-user'});
    },
  );

  test('a failure retries and stays quiet at first', () async {
    sync.succeed = false;

    await scheduler.syncNow(userId: 'user-1');

    expect(
      scheduler.status,
      SyncStatus.retrying,
      reason: 'one failure is not worth telling the user about',
    );
  });

  test('enough consecutive failures escalate to failing', () async {
    sync.succeed = false;

    for (var i = 0; i < SyncScheduler.failuresBeforeNotice; i++) {
      await scheduler.syncNow(userId: 'user-1');
    }

    expect(scheduler.status, SyncStatus.failing);
  });

  test('one success clears the failure count', () async {
    sync.succeed = false;
    for (var i = 0; i < SyncScheduler.failuresBeforeNotice; i++) {
      await scheduler.syncNow(userId: 'user-1');
    }
    expect(scheduler.status, SyncStatus.failing);

    sync.succeed = true;
    await scheduler.syncNow(userId: 'user-1');

    expect(scheduler.status, SyncStatus.idle);
  });

  test('overlapping calls do not run two syncs at once', () async {
    await Future.wait([
      scheduler.syncNow(userId: 'user-1'),
      scheduler.syncNow(userId: 'user-1'),
      scheduler.syncNow(userId: 'user-1'),
    ]);

    expect(
      sync.calls,
      1,
      reason: 'the second and third coalesce into the first',
    );
  });

  test('status changes are published on the stream', () async {
    final seen = <SyncStatus>[];
    final sub = scheduler.statusStream.listen(seen.add);

    await scheduler.syncNow(userId: 'user-1');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(seen, containsAllInOrder([SyncStatus.syncing, SyncStatus.idle]));
  });

  test(
    'the persistent-failure notice is emitted once, not every retry',
    () async {
      sync.succeed = false;
      final seen = <SyncNotice>[];
      final sub = scheduler.noticeStream.listen(seen.add);

      for (var i = 0; i < SyncScheduler.failuresBeforeNotice + 3; i++) {
        await scheduler.syncNow(userId: 'user-1');
      }
      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(
        seen.where((n) => n.kind == SyncNoticeKind.persistentFailure),
        hasLength(1),
      );
    },
  );
}
