import 'package:drift/drift.dart';

/// Content mirrors the Postgres content zone one-for-one. Client-read-only:
/// nothing in the app ever writes these outside the content sync.
///
/// Drift names each generated row class after the singular of the table, which
/// would collide with the domain types Campaign and ActionSpec. @DataClassName
/// resolves that here, once, rather than at every call site later.
@DataClassName('ArchetypeRow')
class Archetypes extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get name => text()();
  TextColumn get blurb => text()();
  TextColumn get color => text()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('PackRow')
class Packs extends Table {
  TextColumn get id => text()();
  TextColumn get key => text().unique()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  BoolColumn get isCore => boolean().withDefault(const Constant(false))();
  TextColumn get storeProductId => text().nullable()();
  TextColumn get coverPath => text().nullable()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('CampaignRow')
class Campaigns extends Table {
  TextColumn get id => text()();
  TextColumn get packId => text()();
  TextColumn get key => text().unique()();
  TextColumn get title => text()();
  TextColumn get subtitle => text().nullable()();
  TextColumn get introMd => text()();
  IntColumn get lengthDays => integer()();
  IntColumn get rampDays => integer().withDefault(const Constant(0))();
  IntColumn get difficulty => integer().withDefault(const Constant(1))();
  TextColumn get coverPath => text().nullable()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ActionRow')
class Actions extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text()();
  IntColumn get dayIndex => integer()();
  TextColumn get title => text()();

  /// Exactly one archetype per action (ADR-0004). Not nullable.
  TextColumn get archetypeId => text()();
  TextColumn get whyDoctrineId => text().nullable()();
  IntColumn get effort => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {campaignId, dayIndex},
  ];
}

/// The authored copy, kept apart from the action so the server can withhold it
/// for a pack the user does not own (ADR-0025). Locally this is a plain cache
/// like every other content table; the boundary is enforced in Postgres, and a
/// row's presence here means only that the server was once willing to send it.
@DataClassName('ActionBodyRow')
class ActionBodies extends Table {
  TextColumn get actionId => text()();
  TextColumn get bodyMd => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {actionId};
}

@DataClassName('CampaignArchetypeRow')
class CampaignArchetypes extends Table {
  TextColumn get campaignId => text()();
  TextColumn get archetypeId => text()();
  RealColumn get weight => real().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {campaignId, archetypeId};
}

@DataClassName('DoctrineGroupRow')
class DoctrineGroups extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get blurb => text().nullable()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('DoctrineEntryRow')
class DoctrineEntries extends Table {
  TextColumn get id => text()();
  TextColumn get groupId => text()();
  TextColumn get title => text()();
  TextColumn get bodyMd => text()();
  TextColumn get relatedArchetypeId => text().nullable()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One forced-choice pair (ADR-0009).
@DataClassName('DiagnosticQuestionRow')
class DiagnosticQuestions extends Table {
  TextColumn get id => text()();
  TextColumn get prompt => text()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// One side of a pair. Exactly two per question, on different archetypes.
@DataClassName('DiagnosticOptionRow')
class DiagnosticOptions extends Table {
  TextColumn get id => text()();
  TextColumn get questionId => text()();
  TextColumn get label => text()();
  TextColumn get archetypeId => text()();
  IntColumn get sort => integer()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {questionId, sort},
  ];
}
