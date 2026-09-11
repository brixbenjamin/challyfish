import 'package:drift/drift.dart';

import '../../domain/archetype.dart';
import '../../domain/campaign.dart';
import '../../domain/diagnostic.dart';
import '../../domain/doctrine.dart';
import '../../domain/pack.dart';
import '../local/database.dart';
import '../local/mappers.dart';
import '../remote/content_api.dart';

/// Pull-only sync of the content zone into the local store, plus reads over it.
///
/// User-agnostic: this repository knows nothing about accounts, sessions, or
/// entitlements. That boundary is why it can run before there is a user.
class ContentRepository {
  // Fields are public (not `_db`/`_api`) so the constructor can use
  // initializing formals for named parameters — `flutter analyze` flags the
  // manual-assignment form (`prefer_initializing_formals`) since the field
  // names would otherwise differ from the named parameters `db`/`api` that
  // Tasks 16-18 construct this repository with. The constructor signature and
  // every public method are unchanged.
  ContentRepository({required this.db, required this.api});

  final FeralDatabase db;
  final ContentApi api;

  /// Every content table, and how to turn one of its rows into a local insert.
  ///
  /// One list rather than nine near-identical methods: at four tables the
  /// duplication was tolerable, at nine it is nine places for the same bug.
  late final List<_ContentTable> _tables = [
    _ContentTable(
      'archetypes',
      (row) => db
          .into(db.archetypes)
          .insertOnConflictUpdate(
            ArchetypesCompanion.insert(
              id: row['id'] as String,
              key: row['key'] as String,
              name: row['name'] as String,
              blurb: row['blurb'] as String,
              color: row['color'] as String,
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable(
      'packs',
      (row) => db
          .into(db.packs)
          .insertOnConflictUpdate(
            PacksCompanion.insert(
              id: row['id'] as String,
              key: row['key'] as String,
              title: row['title'] as String,
              description: row['description'] as String,
              isCore: Value(row['is_core'] as bool? ?? false),
              storeProductId: Value(row['store_product_id'] as String?),
              coverPath: Value(row['cover_path'] as String?),
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable(
      'campaigns',
      (row) => db
          .into(db.campaigns)
          .insertOnConflictUpdate(
            CampaignsCompanion.insert(
              id: row['id'] as String,
              packId: row['pack_id'] as String,
              key: row['key'] as String,
              title: row['title'] as String,
              subtitle: Value(row['subtitle'] as String?),
              introMd: row['intro_md'] as String,
              lengthDays: row['length_days'] as int,
              rampDays: Value(row['ramp_days'] as int? ?? 0),
              difficulty: Value(row['difficulty'] as int? ?? 1),
              coverPath: Value(row['cover_path'] as String?),
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable(
      'campaign_archetypes',
      (row) => db
          .into(db.campaignArchetypes)
          .insertOnConflictUpdate(
            CampaignArchetypesCompanion.insert(
              campaignId: row['campaign_id'] as String,
              archetypeId: row['archetype_id'] as String,
              weight: Value((row['weight'] as num?)?.toDouble() ?? 1),
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable('actions', (row) {
      final action = ActionsCompanion.insert(
        id: row['id'] as String,
        campaignId: row['campaign_id'] as String,
        dayIndex: row['day_index'] as int,
        title: row['title'] as String,
        archetypeId: row['archetype_id'] as String,
        whyDoctrineId: Value(row['why_doctrine_id'] as String?),
        effort: Value(row['effort'] as int? ?? 1),
        isOptional: Value(row['is_optional'] as bool? ?? false),
        sort: Value(row['sort'] as int? ?? 0),
        updatedAt: _at(row),
      );
      return db
          .into(db.actions)
          .insert(
            action,
            // The natural key is the day *slot*, not the day: since ADR-0030 a
            // day holds a mandatory action and n optional ones, and `sort`
            // is what separates them. A conflict target that is not an actual
            // unique index is rejected by sqlite outright.
            onConflict: _byIdOrNaturalKey(action, [
              db.actions.campaignId,
              db.actions.dayIndex,
              db.actions.sort,
            ]),
          );
    }),
    _ContentTable('action_bodies', (row) {
      // Keyed on action_id, which is the primary key, so a re-pull of the same
      // body is an update rather than a duplicate. There is no natural-key
      // fallback here because there is no natural key: the action's id is it.
      return db
          .into(db.actionBodies)
          .insertOnConflictUpdate(
            ActionBodiesCompanion.insert(
              actionId: row['action_id'] as String,
              bodyMd: row['body_md'] as String,
              updatedAt: _at(row),
            ),
          );
    }),
    _ContentTable(
      'doctrine_groups',
      (row) => db
          .into(db.doctrineGroups)
          .insertOnConflictUpdate(
            DoctrineGroupsCompanion.insert(
              id: row['id'] as String,
              title: row['title'] as String,
              blurb: Value(row['blurb'] as String?),
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable(
      'doctrine_entries',
      (row) => db
          .into(db.doctrineEntries)
          .insertOnConflictUpdate(
            DoctrineEntriesCompanion.insert(
              id: row['id'] as String,
              groupId: row['group_id'] as String,
              title: row['title'] as String,
              bodyMd: row['body_md'] as String,
              relatedArchetypeId: Value(row['related_archetype_id'] as String?),
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable(
      'diagnostic_questions',
      (row) => db
          .into(db.diagnosticQuestions)
          .insertOnConflictUpdate(
            DiagnosticQuestionsCompanion.insert(
              id: row['id'] as String,
              prompt: row['prompt'] as String,
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable('diagnostic_options', (row) {
      final option = DiagnosticOptionsCompanion.insert(
        id: row['id'] as String,
        questionId: row['question_id'] as String,
        label: row['label'] as String,
        archetypeId: row['archetype_id'] as String,
        sort: row['sort'] as int,
        updatedAt: _at(row),
      );
      return db
          .into(db.diagnosticOptions)
          .insert(
            option,
            onConflict: _byIdOrNaturalKey(option, [
              db.diagnosticOptions.questionId,
              db.diagnosticOptions.sort,
            ]),
          );
    }),
  ];

  static DateTime _at(Map<String, dynamic> row) =>
      DateTime.parse(row['updated_at'] as String);

  Future<void> pull() async {
    for (final table in _tables) {
      final rows = await api.fetchSince(
        table.name,
        await _watermark(table.name),
      );
      if (rows.isEmpty) continue;

      await db.transaction(() async {
        for (final row in rows) {
          await table.upsert(row);
        }
      });

      // Advanced only after the rows are committed, so an interrupted pull is
      // retried rather than skipped.
      await _advanceWatermark(table.name, rows);
    }
  }

  /// Plan 2 kept these in a map on this object, which meant every cold start
  /// re-downloaded the whole library. They are database state now.
  Future<DateTime?> _watermark(String table) => db.watermarkFor(table);

  Future<void> _advanceWatermark(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    if (rows.isEmpty) return;
    var high =
        await db.watermarkFor(table) ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    for (final row in rows) {
      final updated = _at(row).toUtc();
      if (updated.isAfter(high)) high = updated;
    }
    await db.setWatermark(table, high);
  }

  /// Applies rows keyed by table name, using the same upserts as the network
  /// pull, so the bundled snapshot and the wire can never diverge. Unknown
  /// table names are ignored; a malformed row throws.
  Future<void> applyRows(Map<String, dynamic> rowsByTable) async {
    for (final table in _tables) {
      final rows = rowsByTable[table.name];
      if (rows == null) continue;
      for (final row in (rows as List).cast<Map<String, dynamic>>()) {
        await table.upsert(row);
      }
    }
  }

  /// Used by the seed snapshot loader to set the initial marks. Same storage
  /// as a pull's own advance — there is only one watermark per table.
  Future<void> primeWatermark(String table, DateTime value) =>
      db.setWatermark(table, value);

  /// Read-only view, for tests and diagnostics.
  Future<DateTime?> watermarkFor(String table) => db.watermarkFor(table);

  /// Drops a table's high-water mark so the next pull re-asks for everything the
  /// server is willing to give. Used when the answer to "who is asking" changes.
  Future<void> clearWatermark(String table) => db.clearWatermark(table);

  /// Whether day one of any campaign in [packId] has its body locally. The
  /// delivery check, chosen over a row count because a partial pull that has not
  /// reached day one is not a pack the user can start.
  Future<bool> hasBodyForFirstDay(String packId) async {
    final query =
        db.selectOnly(db.actions).join([
            innerJoin(
              db.campaigns,
              db.campaigns.id.equalsExp(db.actions.campaignId),
            ),
            innerJoin(
              db.actionBodies,
              db.actionBodies.actionId.equalsExp(db.actions.id),
            ),
          ])
          ..addColumns([db.actions.id])
          ..where(
            db.campaigns.packId.equals(packId) & db.actions.dayIndex.equals(1),
          )
          ..limit(1);
    return (await query.get()).isNotEmpty;
  }

  Future<List<Campaign>> campaigns() async {
    final rows = await (db.select(
      db.campaigns,
    )..orderBy([(c) => OrderingTerm(expression: c.sort)])).get();
    return rows.map(toCampaign).toList();
  }

  Future<List<ActionSpec>> actionsFor(String campaignId) async {
    final query =
        db.select(db.actions).join([
            leftOuterJoin(
              db.actionBodies,
              db.actionBodies.actionId.equalsExp(db.actions.id),
            ),
          ])
          ..where(db.actions.campaignId.equals(campaignId))
          ..orderBy([OrderingTerm(expression: db.actions.dayIndex)]);
    final rows = await query.get();
    return [
      for (final row in rows)
        toAction(
          row.readTable(db.actions),
          row.readTableOrNull(db.actionBodies),
        ),
    ];
  }

  /// Null when the action itself is not cached. An action that is cached without
  /// its body returns a spec with a null `bodyMd` — a locked pack, or one whose
  /// bodies have not arrived — and callers degrade to the same recoverable
  /// "content unavailable" state either way.
  /// Every action on one campaign day: the mandatory one and any optionals,
  /// ordered mandatory-first then by `sort` (ADR-0030).
  ///
  /// Empty when the day's content is not cached at all. A day whose optionals
  /// are cached but whose mandatory action is not is a partial-sync state the
  /// caller degrades on, not one this query papers over.
  Future<List<ActionSpec>> actionsForDay(
    String campaignId,
    int dayIndex,
  ) async {
    final query =
        db.select(db.actions).join([
            leftOuterJoin(
              db.actionBodies,
              db.actionBodies.actionId.equalsExp(db.actions.id),
            ),
          ])
          ..where(
            db.actions.campaignId.equals(campaignId) &
                db.actions.dayIndex.equals(dayIndex),
          )
          ..orderBy([
            OrderingTerm(expression: db.actions.isOptional),
            OrderingTerm(expression: db.actions.sort),
          ]);
    final rows = await query.get();
    return [
      for (final row in rows)
        toAction(
          row.readTable(db.actions),
          row.readTableOrNull(db.actionBodies),
        ),
    ];
  }

  Future<ActionSpec?> actionFor(String campaignId, int dayIndex) async {
    final query =
        db.select(db.actions).join([
          leftOuterJoin(
            db.actionBodies,
            db.actionBodies.actionId.equalsExp(db.actions.id),
          ),
        ])..where(
          db.actions.campaignId.equals(campaignId) &
              db.actions.dayIndex.equals(dayIndex) &
              // The day's *mandatory* action. Without this the query would
              // throw on any day that has optionals, since a day is no longer
              // one row (ADR-0030).
              db.actions.isOptional.equals(false),
        );
    final row = await query.getSingleOrNull();
    return row == null
        ? null
        : toAction(
            row.readTable(db.actions),
            row.readTableOrNull(db.actionBodies),
          );
  }

  Future<List<Pack>> packs() async {
    final rows = await (db.select(
      db.packs,
    )..orderBy([(p) => OrderingTerm(expression: p.sort)])).get();
    return [
      for (final row in rows)
        Pack(
          id: row.id,
          key: row.key,
          title: row.title,
          description: row.description,
          isCore: row.isCore,
          storeProductId: row.storeProductId,
          coverPath: row.coverPath,
          sort: row.sort,
        ),
    ];
  }

  Future<List<Campaign>> campaignsFor(String packId) async {
    final rows =
        await (db.select(db.campaigns)
              ..where((c) => c.packId.equals(packId))
              ..orderBy([(c) => OrderingTerm(expression: c.sort)]))
            .get();
    return rows.map(toCampaign).toList();
  }

  Future<Campaign?> campaignById(String id) async {
    final row = await (db.select(
      db.campaigns,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    return row == null ? null : toCampaign(row);
  }

  Future<List<String>> archetypeIdsFor(String campaignId) async {
    final rows = await (db.select(
      db.campaignArchetypes,
    )..where((ca) => ca.campaignId.equals(campaignId))).get();
    return rows.map((r) => r.archetypeId).toList()..sort();
  }

  Future<Map<String, Archetype>> archetypesById() async {
    final rows = await (db.select(
      db.archetypes,
    )..orderBy([(a) => OrderingTerm(expression: a.sort)])).get();
    return {
      for (final row in rows)
        row.id: Archetype(
          id: row.id,
          key: row.key,
          name: row.name,
          blurb: row.blurb,
          color: row.color,
          sort: row.sort,
        ),
    };
  }

  Future<List<DoctrineGroup>> doctrineGroups() async {
    final rows = await (db.select(
      db.doctrineGroups,
    )..orderBy([(g) => OrderingTerm(expression: g.sort)])).get();
    return [
      for (final row in rows)
        DoctrineGroup(
          id: row.id,
          title: row.title,
          blurb: row.blurb,
          sort: row.sort,
        ),
    ];
  }

  Future<List<DoctrineEntry>> doctrineEntriesFor(String groupId) async {
    final rows =
        await (db.select(db.doctrineEntries)
              ..where((e) => e.groupId.equals(groupId))
              ..orderBy([(e) => OrderingTerm(expression: e.sort)]))
            .get();
    return [for (final row in rows) _toDoctrineEntry(row)];
  }

  Future<DoctrineEntry?> doctrineEntryById(String id) async {
    final row = await (db.select(
      db.doctrineEntries,
    )..where((e) => e.id.equals(id))).getSingleOrNull();
    return row == null ? null : _toDoctrineEntry(row);
  }

  static DoctrineEntry _toDoctrineEntry(DoctrineEntryRow row) => DoctrineEntry(
    id: row.id,
    groupId: row.groupId,
    title: row.title,
    bodyMd: row.bodyMd,
    relatedArchetypeId: row.relatedArchetypeId,
    sort: row.sort,
  );

  /// The instrument, in order, each question carrying both its options.
  Future<List<DiagnosticQuestion>> diagnosticQuestions() async {
    final questions = await (db.select(
      db.diagnosticQuestions,
    )..orderBy([(q) => OrderingTerm(expression: q.sort)])).get();
    final options = await (db.select(
      db.diagnosticOptions,
    )..orderBy([(o) => OrderingTerm(expression: o.sort)])).get();

    final byQuestion = <String, List<DiagnosticOption>>{};
    for (final option in options) {
      byQuestion
          .putIfAbsent(option.questionId, () => [])
          .add(
            DiagnosticOption(
              id: option.id,
              questionId: option.questionId,
              label: option.label,
              archetypeId: option.archetypeId,
              sort: option.sort,
            ),
          );
    }

    return [
      for (final question in questions)
        DiagnosticQuestion(
          id: question.id,
          prompt: question.prompt,
          sort: question.sort,
          options: byQuestion[question.id] ?? const [],
        ),
    ];
  }
}

/// Upserts [row] on its primary key *or* on [naturalKey], whichever it collides
/// with.
///
/// Two content tables carry both an id and a separate unique index over the
/// thing that actually identifies the row — an action's (campaign, day), an
/// option's (question, position). Matching on the id alone is what made a
/// re-issued id fatal: the row arrives as an insert, the natural key refuses it,
/// and the whole pull throws on a content edit that is entirely legitimate.
/// Matching on either means an id change is an update, and so is a day change.
///
/// The id clause is second because a row that collides on both is the ordinary
/// case — the same row, pulled again — and either clause writes the same values.
UpsertClause<T, D> _byIdOrNaturalKey<T extends Table, D>(
  Insertable<D> row,
  List<Column<Object>> naturalKey,
) => UpsertMultiple([
  DoUpdate((_) => row, target: naturalKey),
  DoUpdate((_) => row),
]);

class _ContentTable {
  _ContentTable(this.name, this.upsert);

  final String name;
  final Future<void> Function(Map<String, dynamic> row) upsert;
}
