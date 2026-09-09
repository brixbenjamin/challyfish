import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/clock.dart';
import '../data/repositories/sync_repository.dart';
import '../domain/sync_status.dart';
import '../engine/backoff.dart';

/// What the scheduler needs from the sync repository. Narrowed to an interface
/// so the scheduler's own rules can be tested without a database.
abstract class SyncRunner {
  Future<SyncOutcome> sync(String userId);
  List<SyncNotice> consumeNotices();
}

abstract class ConnectivityGate {
  Future<bool> isOnline();
  Stream<bool> get onlineChanges;
}

class ConnectivityPlusGate implements ConnectivityGate {
  ConnectivityPlusGate([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;

  static bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  @override
  Future<bool> isOnline() async =>
      _isOnline(await _connectivity.checkConnectivity());

  @override
  Stream<bool> get onlineChanges =>
      _connectivity.onConnectivityChanged.map(_isOnline).distinct();
}

/// Decides when a sync runs, and holds the status the UI reads.
///
/// It never polls. An idle app with nothing owed does no work: syncs fire on
/// start, on foreground, on connectivity regain, and after a local write.
class SyncScheduler {
  // Fields are public, as elsewhere in this codebase, so the constructor can
  // use initializing formals for its named parameters.
  SyncScheduler({
    required this.runner,
    required this.gate,
    required this.clock,
    this.backoff = Backoff.standard,
  });

  final SyncRunner runner;
  final ConnectivityGate gate;
  final Clock clock;
  final Backoff backoff;

  final _status = StreamController<SyncStatus>.broadcast();
  final _notices = StreamController<SyncNotice>.broadcast();

  StreamSubscription<bool>? _connectivitySub;
  Timer? _retryTimer;
  Future<bool>? _inFlight;
  int _consecutiveFailures = 0;

  /// How many consecutive failures before the user is told. Two failures is a
  /// blip, and reporting it would train the user to ignore the banner; this is
  /// the line between "retrying quietly" and "you should know".
  static const failuresBeforeNotice = 3;

  SyncStatus _current = SyncStatus.idle;
  SyncStatus get status => _current;
  Stream<SyncStatus> get statusStream => _status.stream;
  Stream<SyncNotice> get noticeStream => _notices.stream;

  void _setStatus(SyncStatus next) {
    if (_current == next) return;
    _current = next;
    _status.add(next);
  }

  /// Points the scheduler at [userId] and syncs immediately.
  ///
  /// Called again whenever the session changes — signing in and deleting an
  /// account both replace the user id. The previous subscription is dropped
  /// rather than added to: a listener left over from the old session would keep
  /// asking for syncs of an account this device is no longer authenticated as,
  /// and row-level security refuses every one of them.
  void start(String userId) {
    _target(userId);
    unawaited(syncNow(userId: userId));
  }

  /// Points the scheduler at the account that just signed in and **waits** for
  /// one round trip, reporting whether it succeeded.
  ///
  /// The one place in the product where a caller waits on a sync (ADR-0024).
  /// Signing in clears this device's user tables first, so until this pull
  /// lands the local store answers "nothing here" to every question the router
  /// asks — which is how a returning user was routed back through onboarding
  /// and invited to take a diagnostic their account already had.
  ///
  /// A sync of the *previous* session may still be in flight. It is waited out
  /// rather than coalesced onto: [syncNow] would hand back that future, and its
  /// success says nothing about whether this account's record has arrived.
  Future<bool> restore(String userId) async {
    final previous = _inFlight;
    if (previous != null) {
      try {
        await previous;
      } catch (_) {
        // Whatever the old session's sync did is not this account's business.
      }
    }
    _target(userId);
    return syncNow(userId: userId);
  }

  /// Drops the previous session's listener and listens for this one. A listener
  /// left over from the old session would keep asking for syncs of an account
  /// this device is no longer authenticated as, and row-level security refuses
  /// every one of them.
  void _target(String userId) {
    unawaited(_connectivitySub?.cancel());
    _retryTimer?.cancel();
    _connectivitySub = gate.onlineChanges.listen((online) {
      if (online) unawaited(syncNow(userId: userId));
    });
  }

  /// Coalescing matters: the dashboard, the report sheet and a foreground event
  /// can all ask within the same frame, and three concurrent pushes of the same
  /// dirty rows is how duplicate work becomes duplicate bugs.
  /// Returns whether the round trip succeeded, for the one caller that waits on
  /// the answer ([restore]). Everything else fires and forgets.
  Future<bool> syncNow({required String userId}) {
    final existing = _inFlight;
    if (existing != null) return existing;
    final run = _run(userId).whenComplete(() => _inFlight = null);
    _inFlight = run;
    return run;
  }

  Future<bool> _run(String userId) async {
    if (!await gate.isOnline()) {
      _setStatus(SyncStatus.offline);
      return false;
    }

    _setStatus(SyncStatus.syncing);
    final outcome = await runner.sync(userId);

    for (final notice in runner.consumeNotices()) {
      _notices.add(notice);
    }

    if (outcome.succeeded) {
      _consecutiveFailures = 0;
      _retryTimer?.cancel();
      _setStatus(SyncStatus.idle);
      return true;
    }

    _consecutiveFailures++;
    _setStatus(
      _consecutiveFailures >= failuresBeforeNotice
          ? SyncStatus.failing
          : SyncStatus.retrying,
    );

    // Exactly at the threshold, never above it: the notice is emitted once, not
    // on every subsequent retry.
    if (_consecutiveFailures == failuresBeforeNotice) {
      _notices.add(
        SyncNotice(
          kind: SyncNoticeKind.persistentFailure,
          message:
              'Your progress is saved on this phone but has not reached the '
              'server yet. It will keep trying.',
          occurredAt: clock.nowUtc(),
        ),
      );
    }

    _retryTimer?.cancel();
    _retryTimer = Timer(
      backoff.delayFor(_consecutiveFailures),
      () => unawaited(syncNow(userId: userId)),
    );
    return false;
  }

  void dispose() {
    _retryTimer?.cancel();
    unawaited(_connectivitySub?.cancel());
    unawaited(_status.close());
    unawaited(_notices.close());
  }
}
