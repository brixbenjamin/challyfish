import 'package:drift/drift.dart';

/// User state. Note what is absent: no currentDay, no missCount, no live grade.
/// Those are derived by RunEngine every time they are needed.
@DataClassName('CampaignRunRow')
class CampaignRuns extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get campaignId => text()();
  TextColumn get status => text()();
  BoolColumn get isHardened => boolean().withDefault(const Constant(false))();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  /// Materialized once at completion only. Null while the run is active.
  TextColumn get grade => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  /// Written locally and not yet pushed. The push worker is Plan 3.
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DayLogRow')
class DayLogs extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get runId => text()();
  IntColumn get dayIndex => integer()();
  TextColumn get actionId => text()();
  DateTimeColumn get committedAt => dateTime().nullable()();
  TextColumn get outcome => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// Mirrors the Postgres unique constraint. This is what makes every future
  /// sync merge an upsert rather than a duplicate.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {runId, dayIndex},
  ];
}

/// The outcome of one sitting of the diagnostic. Kept as a history rather than
/// overwritten, so a retake does not destroy the original reading.
///
/// Note what is absent: the individual picks. Only the four scores are stored
/// (ADR-0009) — the answers themselves are a record of self-assessment that
/// nothing in the product ever reads again.
@DataClassName('DiagnosticResultRow')
class DiagnosticResults extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  DateTimeColumn get takenAt => dateTime()();

  /// JSON: archetype key to relative score, 0 to 1.
  TextColumn get scores => text()();
  TextColumn get weakestArchetypeId => text()();
  TextColumn get recommendedCampaignId => text()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One row per account, mirroring `public.profiles`.
///
/// `displayName` is carried because the server column exists; nothing in v1
/// surfaces it (there is no social layer).
@DataClassName('ProfileRow')
class Profiles extends Table {
  TextColumn get userId => text()();
  TextColumn get displayName => text().nullable()();
  DateTimeColumn get onboardedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {userId};
}
