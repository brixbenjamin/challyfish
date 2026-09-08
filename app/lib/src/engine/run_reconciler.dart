import '../domain/run.dart';

/// Which of two colliding active runs survives.
class Reconciliation {
  const Reconciliation({
    required this.keep,
    required this.abandon,
    required this.localSurvived,
  });

  final CampaignRun keep;
  final CampaignRun abandon;

  /// True when the run this device started is the one that survives. Decides
  /// which message the user is shown.
  final bool localSurvived;
}

/// The one-active-run rule is enforced by a partial unique index in Postgres,
/// so a second offline start is rejected rather than accepted. This decides
/// what happens next.
///
/// Determinism is the requirement, not fairness: both devices run this
/// independently, with no communication, and must reach the same answer. Any
/// rule depending on arrival order, local clocks, or map iteration would leave
/// the two devices permanently disagreeing about which run is real.
abstract final class RunReconciler {
  static bool isConflict({
    required CampaignRun local,
    required CampaignRun remote,
  }) =>
      local.id != remote.id &&
      local.status == RunStatus.active &&
      remote.status == RunStatus.active;

  static Reconciliation resolve({
    required CampaignRun local,
    required CampaignRun remote,
  }) {
    final localFirst = switch (local.startedAt.compareTo(remote.startedAt)) {
      < 0 => true,
      > 0 => false,
      // Identical instants are possible on two devices with synced clocks.
      // Comparing ids gives both devices the same answer.
      _ => local.id.compareTo(remote.id) <= 0,
    };

    return localFirst
        ? Reconciliation(keep: local, abandon: remote, localSurvived: true)
        : Reconciliation(keep: remote, abandon: local, localSurvived: false);
  }
}
