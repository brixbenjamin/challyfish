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
    _ContentTable(
      'actions',
      (row) => db
          .into(db.actions)
          .insertOnConflictUpdate(
            ActionsCompanion.insert(
              id: row['id'] as String,
              campaignId: row['campaign_id'] as String,
              dayIndex: row['day_index'] as int,
              title: row['title'] as String,
              bodyMd: row['body_md'] as String,
              archetypeId: row['archetype_id'] as String,
              whyDoctrineId: Value(row['why_doctrine_id'] as String?),
              effort: Value(row['effort'] as int? ?? 1),
              updatedAt: _at(row),
            ),
          ),
    ),
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
    _ContentTable(
      'diagnostic_options',
      (row) => db
          .into(db.diagnosticOptions)
          .insertOnConflictUpdate(
            DiagnosticOptionsCompanion.insert(
              id: row['id'] as String,
              questionId: row['question_id'] as String,
              label: row['label'] as String,
              archetypeId: row['archetype_id'] as String,
              sort: row['sort'] as int,
              updatedAt: _at(row),
            ),
          ),
    ),
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

  Future<List<Campaign>> campaigns() async {
    final rows = await (db.select(
      db.campaigns,
    )..orderBy([(c) => OrderingTerm(expression: c.sort)])).get();
    return rows.map(toCampaign).toList();
  }

  Future<List<ActionSpec>> actionsFor(String campaignId) async {
    final rows =
        await (db.select(db.actions)
              ..where((a) => a.campaignId.equals(campaignId))
              ..orderBy([(a) => OrderingTerm(expression: a.dayIndex)]))
            .get();
    return rows.map(toAction).toList();
  }

  /// Null when the action is not cached. Callers must degrade to a recoverable
  /// "content unavailable" state — the run is never lost.
  Future<ActionSpec?> actionFor(String campaignId, int dayIndex) async {
    final row =
        await (db.select(db.actions)..where(
              (a) =>
                  a.campaignId.equals(campaignId) & a.dayIndex.equals(dayIndex),
            ))
            .getSingleOrNull();
    return row == null ? null : toAction(row);
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

class _ContentTable {
  _ContentTable(this.name, this.upsert);

  final String name;
  final Future<void> Function(Map<String, dynamic> row) upsert;
}
