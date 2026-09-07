import 'grade.dart';

enum RunStatus {
  active('active'),
  completed('completed'),
  abandoned('abandoned');

  const RunStatus(this.key);

  final String key;

  static RunStatus fromKey(String key) {
    for (final status in RunStatus.values) {
      if (status.key == key) return status;
    }
    throw ArgumentError.value(key, 'key', 'Unknown run status');
  }
}

/// A user's instance of a campaign. Exactly one may be active at a time.
class CampaignRun {
  const CampaignRun({
    required this.id,
    required this.userId,
    required this.campaignId,
    required this.status,
    required this.startedAt,
    this.isHardened = false,
    this.completedAt,
    this.grade,
  });

  final String id;
  final String userId;
  final String campaignId;
  final RunStatus status;

  /// The anchor for all day arithmetic. A UTC instant.
  final DateTime startedAt;
  final bool isHardened;
  final DateTime? completedAt;

  /// Materialized once at completion for stable querying. Must always equal
  /// what RunEngine computes from the day logs.
  final Grade? grade;
}
