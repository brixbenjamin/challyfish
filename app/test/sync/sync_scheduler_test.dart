import 'dart:async';

import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/sync_status.dart';
import 'package:feral/src/engine/backoff.dart';
import 'package:feral/src/sync/sync_scheduler.dart';
import 'package:test/test.dart';

class FakeSync implements SyncRunner {
  int calls = 0;
  bool succeed = true;
  final List<SyncNotice> notices = [];

  @override
  Future<SyncOutcome> sync(String userId) async {
    calls++;
    const ok = PushResult(succeeded: true);
    const bad = PushResult(succeeded: false, error: 'boom');
    return succeed
        ? const SyncOutcome(push: ok, pull: PullResult(succeeded: true))
        : const SyncOutcome(
            push: bad,
            pull: PullResult(succeeded: false, error: 'boom'),
          );
  }

  @override
  List<SyncNotice> consumeNotices() {
    final out = List<SyncNotice>.from(notices);
    notices.clear();
    return out;
  }
}

class FakeGate implements ConnectivityGate {
  bool online = true;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> isOnline() async => online;

  @override
  Stream<bool> get onlineChanges => _controller.stream;

  void goOnline() {
    online = true;
    _controller.add(true);
  }

  void goOffline() {
    online = false;
    _controller.add(false);
  }

  void dispose() => _controller.close();
}

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
