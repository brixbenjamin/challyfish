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

/// One day of a campaign, and the owner of its actions (ADR-0034). Before this
/// a day was an integer that several [Actions] rows happened to share, and
/// nothing could be said about a day that was not said about one of its actions.
@DataClassName('DayRow')
class Days extends Table {
  TextColumn get id => text()();
  TextColumn get campaignId => text()();

  /// 1-based. Contiguous from 1 to the campaign's lengthDays — enforced in
  /// Postgres by a pgTAP assertion over rows that now exist, and not mirrored
  /// here, because content is a read-only cache of a server that checks it.
  IntColumn get dayIndex => integer()();
  TextColumn get title => text()();

  /// `standard` or `rest`, stored as the server's own string. Text rather than
  /// a boolean because the taxonomy has a second member lurking — the bridge
  /// day — and parallel flags would permit a day that is both. Unknown values
  /// are not a failure: the domain reads an unrecognised kind as `standard`,
  /// so content authored against a newer app degrades rather than throws.
  TextColumn get kind => text().withDefault(const Constant('standard'))();

  /// No archetype column, deliberately: a day's drives are folded from its
  /// actions (ADR-0041). `primary_archetype_id` existed to name the one colour
  /// the One Drive Per Loop Rule allowed a day to wear, and a day may now wear
  /// every drive its actions carry — see `DaySpec.archetypeWeights`.
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// The day's natural key, and the reason a re-issued day id is an update
  /// rather than a failed pull — see `_byIdOrNaturalKey`.
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {campaignId, dayIndex},
  ];
}

/// The day's framing copy, read before the commit. Kept apart from the day so
/// the server can withhold it for a pack the user does not own (ADR-0025,
/// ADR-0034). Locally this is a plain cache like every other content table; the
/// boundary is enforced in Postgres, and a row's presence here means only that
/// the server was once willing to send it.
@DataClassName('DayBodyRow')
class DayBodies extends Table {
  TextColumn get dayId => text()();
  TextColumn get bodyMd => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {dayId};
}

@DataClassName('ActionRow')
class Actions extends Table {
  TextColumn get id => text()();

  /// The day this action belongs to. The action no longer knows its campaign
  /// or its day number — the day knows both, and a denormalized copy would be a
  /// second place for the truth to live and eventually disagree (ADR-0034).
  TextColumn get dayId => text()();
  TextColumn get title => text()();

  /// The archetypes an action serves live in [ActionArchetypes], not here. The
  /// column this replaced was `not null`, which guaranteed every action had one
  /// archetype; a join table cannot express that, so the guarantee moved to a
  /// deferred constraint trigger in Postgres. Locally there is nothing to
  /// enforce — content is a read-only cache of a server that already checks it.
  TextColumn get whyDoctrineId => text().nullable()();

  /// The points value. Authored and displayed as a whole number; the balance
  /// divides it by `pointsPerFullDay` before using it (ADR-0030, amending
  /// ADR-0010's "effort is not used"). Keeps its storage name because renaming
  /// would touch seeds, mappers and the domain type for no behavioural gain.
  IntColumn get effort => integer().withDefault(const Constant(1))();

  /// False for the day's one mandatory action, true for every extra the user
  /// may take on. Server-enforced: exactly one mandatory row per day. Not
  /// mirrored as a local constraint — content is a read-only cache of a server
  /// that already guarantees it, and drift's table DSL cannot express a partial
  /// unique index without custom SQL.
  BoolColumn get isOptional => boolean().withDefault(const Constant(false))();

  /// Display order within the day. The mandatory action sorts first.
  IntColumn get sort => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};

  /// The day slot, one level down from where ADR-0030 put it: a real foreign
  /// key rather than two columns kept consistent by authoring discipline
  /// (ADR-0034).
  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {dayId, sort},
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

/// How one action's effort divides across the drives it serves.
///
/// [share] is a ratio numerator, not a multiplier: the weight is
/// `share / sum(shares for the action)`, so an action contributes its own
/// `effort` and no more however many rows it has here. Authoring writes small
/// integers — 1 for a single drive, 1:1 for an even pair, 2:1 where there is a
/// clear primary — and cannot inflate an action by choosing bigger ones.
@DataClassName('ActionArchetypeRow')
class ActionArchetypes extends Table {
  TextColumn get actionId => text()();
  TextColumn get archetypeId => text()();
  IntColumn get share => integer().withDefault(const Constant(1))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {actionId, archetypeId};
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
