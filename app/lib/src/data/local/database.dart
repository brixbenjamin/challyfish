import 'package:drift/drift.dart';

import 'tables/content_tables.dart';
import 'tables/user_tables.dart';

part 'database.g.dart';

/// The runtime source of truth. Supabase is the durable store behind it, but
/// every read the UI performs comes from here — which is what makes the daily
/// loop independent of the network.
@DriftDatabase(
  tables: [Archetypes, Packs, Campaigns, Actions, CampaignRuns, DayLogs],
)
class FeralDatabase extends _$FeralDatabase {
  FeralDatabase(super.executor);

  @override
  int get schemaVersion => 1;
}
