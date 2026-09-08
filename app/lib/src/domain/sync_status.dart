/// Where the background sync currently stands. The UI reads this and nothing
/// else — no screen inspects a repository to decide what to show.
enum SyncStatus {
  /// Nothing to do and nothing owed.
  idle,

  /// A push or pull is in flight.
  syncing,

  /// No connectivity. Expected, not an error — writes are queueing normally.
  offline,

  /// Attempts are failing and being retried. Still silent to the user.
  retrying,

  /// Retries have failed long enough that the user should be told. The only
  /// status that produces visible copy, and even then non-modally.
  failing,
}

enum SyncNoticeKind {
  /// Two devices each started a run; one was abandoned by the rule in
  /// RunReconciler. The user is told plainly what happened.
  runReconciled,

  /// Sync has failed for long enough to be worth surfacing.
  persistentFailure,
}

class SyncNotice {
  const SyncNotice({
    required this.kind,
    required this.message,
    required this.occurredAt,
  });

  final SyncNoticeKind kind;
  final String message;
  final DateTime occurredAt;
}
