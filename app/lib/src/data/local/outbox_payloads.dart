/// The payload shapes the server expects, built from primitives.
///
/// Primitives rather than drift row classes on purpose. The row classes are
/// generated as part of `database.dart`, so a module taking them has to import
/// it — and `database.dart` needs these builders itself, for the upgrade that
/// drains the old `dirty` flags into the queue. Taking primitives is what keeps
/// that from being an import cycle, which drift's generator resolves by emitting
/// nothing at all.
///
/// These are the same shapes the dirty-row push built. One definition, so the
/// write path and the upgrade cannot disagree.
abstract final class OutboxPayloads {
  static String? iso(DateTime? value) => value?.toUtc().toIso8601String();

  /// A bare local calendar date, for a Postgres `date` column (ADR-0040).
  ///
  /// Deliberately not [iso]: these carry no time and no offset, and sending
  /// them as instants would let a server-side cast move the date by a day for
  /// anyone east or west of UTC — which is the exact class of bug the stamped
  /// date exists to prevent.
  static String? date(DateTime? value) => value == null
      ? null
      : '${value.year.toString().padLeft(4, '0')}-'
            '${value.month.toString().padLeft(2, '0')}-'
            '${value.day.toString().padLeft(2, '0')}';

  static const profiles = 'profiles';
  static const campaignRuns = 'campaign_runs';
  static const dayLogs = 'day_logs';
  static const dayLogActions = 'day_log_actions';
  static const diagnosticResults = 'diagnostic_results';

  static Map<String, dynamic> profile({
    required String userId,
    String? displayName,
    DateTime? onboardedAt,
    required DateTime updatedAt,
  }) => {
    'user_id': userId,
    'display_name': displayName,
    'onboarded_at': iso(onboardedAt),
    'updated_at': iso(updatedAt),
  };

  static Map<String, dynamic> run({
    required String id,
    required String userId,
    required String campaignId,
    required String status,
    required bool isHardened,
    required DateTime startedAt,
    DateTime? completedAt,
    String? grade,
    DateTime? abandonedOn,
    required DateTime updatedAt,
  }) => {
    'id': id,
    'user_id': userId,
    'campaign_id': campaignId,
    'status': status,
    'is_hardened': isHardened,
    'started_at': iso(startedAt),
    'completed_at': iso(completedAt),
    'grade': grade,
    'abandoned_on': date(abandonedOn),
    'updated_at': iso(updatedAt),
  };

  static Map<String, dynamic> dayLog({
    required String id,
    required String userId,
    required String runId,
    required int dayIndex,
    String? actionId,
    DateTime? committedAt,
    String? outcome,
    String? note,
    DateTime? workedOn,
    DateTime? resolvedOn,
    required DateTime updatedAt,
  }) => {
    'id': id,
    'user_id': userId,
    'run_id': runId,
    'day_index': dayIndex,
    'action_id': actionId,
    'committed_at': iso(committedAt),
    'outcome': outcome,
    'note': note,
    'worked_on': date(workedOn),
    'resolved_on': date(resolvedOn),
    'updated_at': iso(updatedAt),
  };

  /// `id` is deliberately absent, as it was from the dirty-row push: the server
  /// upserts on `(run_id, day_index, action_id)` and assigns its own uuid, and
  /// sending ours would fight it for nothing.
  static Map<String, dynamic> tick({
    required String userId,
    required String runId,
    required int dayIndex,
    required String actionId,
    required bool completed,
    required DateTime updatedAt,
  }) => {
    'user_id': userId,
    'run_id': runId,
    'day_index': dayIndex,
    'action_id': actionId,
    // A flag, never an absence. Unticking is something the user did.
    'completed': completed,
    'updated_at': iso(updatedAt),
  };

  static Map<String, dynamic> diagnostic({
    required String id,
    required String userId,
    required DateTime takenAt,
    required String scores,
    required String weakestArchetypeId,
    required String recommendedCampaignId,
    required DateTime updatedAt,
  }) => {
    'id': id,
    'user_id': userId,
    'taken_at': iso(takenAt),
    'scores': scores,
    'weakest_archetype_id': weakestArchetypeId,
    'recommended_campaign_id': recommendedCampaignId,
    'updated_at': iso(updatedAt),
  };

  /// What identifies a row on the server, and the key its queue entry is filed
  /// under. For day logs and ticks this is the natural key: two devices writing
  /// the same day offline mint different uuids, so the uuid identifies nothing.
  static String keyForDayLog(String runId, int dayIndex) => '$runId:$dayIndex';

  static String keyForTick(String runId, int dayIndex, String actionId) =>
      '$runId:$dayIndex:$actionId';
}
