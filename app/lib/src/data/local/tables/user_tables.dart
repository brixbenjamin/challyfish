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

/// Which actions the user ticked on a given day.
///
/// Identified by (runId, dayIndex, actionId) rather than by a day log's id:
/// the sync merge adopts the server's uuid for a day log by deleting and
/// reinserting that row, and a child keyed on the surrogate id would not
/// survive it.
///
/// `completed` is a flag, never row presence. Nothing in this sync design
/// carries tombstones, so a deleted tick would never reach a second device and
/// the next pull would resurrect it.
@DataClassName('DayLogActionRow')
class DayLogActions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get runId => text()();
  IntColumn get dayIndex => integer()();
  TextColumn get actionId => text()();
  BoolColumn get completed => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// Mirrors the Postgres unique constraint, and is the identity every sync
  /// merge keys on.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {runId, dayIndex, actionId},
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

/// A local copy of `public.entitlements`, which the client may read and never
/// write (ADR-0017). Pulled read-only; there is deliberately no `dirty` column,
/// because nothing here is ever pushed.
@DataClassName('EntitlementRow')
class Entitlements extends Table {
  TextColumn get userId => text()();
  TextColumn get packId => text()();
  TextColumn get source => text()();
  DateTimeColumn get acquiredAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  /// True for an optimistic row written the moment a purchase completed, before
  /// the webhook's row has been pulled. It unlocks the pack exactly as a server
  /// row does; the flag exists so a wipe can tell them apart and so nothing
  /// mistakes it for the server agreeing.
  BoolColumn get local => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {userId, packId};
}
