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
