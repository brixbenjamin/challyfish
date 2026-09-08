import 'package:drift/drift.dart';

import 'tables/content_tables.dart';
import 'tables/user_tables.dart';

part 'database.g.dart';

/// The runtime source of truth. Supabase is the durable store behind it, but
/// every read the UI performs comes from here — which is what makes the daily
/// loop independent of the network.
@DriftDatabase(
  tables: [
    Archetypes,
    Packs,
    Campaigns,
    CampaignArchetypes,
    Actions,
    DoctrineGroups,
    DoctrineEntries,
    DiagnosticQuestions,
    DiagnosticOptions,
    CampaignRuns,
    DayLogs,
    DiagnosticResults,
  ],
)
class FeralDatabase extends _$FeralDatabase {
  FeralDatabase(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Additive only. campaign_runs and day_logs are never touched:
        // losing a user's honest record to a schema bump is the worst
        // possible bug in this product.
        await m.createTable(campaignArchetypes);
        await m.createTable(doctrineGroups);
        await m.createTable(doctrineEntries);
        await m.createTable(diagnosticQuestions);
        await m.createTable(diagnosticOptions);
        await m.createTable(diagnosticResults);
      }
    },
  );
}
