import 'dart:async';

import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:feral/src/domain/sync_status.dart';
import 'package:feral/src/sync/sync_scheduler.dart';

/// A [SyncRunner] that records what it was asked to do and can be told to fail.
///
/// Lives here rather than beside one test because the scheduler's collaborators
/// are needed by every test that boots the app: the wiring test, both sign-in
/// tests, and the unlock test all drive a real [SyncScheduler] over fakes.
class FakeSync implements SyncRunner {
  int calls = 0;
  bool succeed = true;
  final List<SyncNotice> notices = [];

  /// Who each sync was for. The count alone cannot tell a sync of the account
  /// the user just signed into from one of the account they left.
  final List<String> userIds = [];

  /// How long a round trip takes. Zero everywhere except where a test needs a
  /// sync to still be in flight while something else happens.
  Duration delay = Duration.zero;

  @override
  Future<SyncOutcome> sync(String userId) async {
    calls++;
    userIds.add(userId);
    if (delay > Duration.zero) await Future<void>.delayed(delay);
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

/// Connectivity the test drives by hand.
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
