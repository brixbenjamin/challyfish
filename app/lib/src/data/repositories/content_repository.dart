import 'package:drift/drift.dart';

import '../../domain/archetype.dart';
import '../../domain/campaign.dart';
import '../../domain/day.dart';
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
    // Before `actions`, and that ordering is load-bearing rather than
    // incidental now: an action's day_id points here (ADR-0034). Drift declares
    // no foreign keys locally, so an action that arrives first merely fails to
    // join and the day reads as absent -- a partial-sync state the caller
    // already degrades on, not a crash.
    _ContentTable('days', (row) {
      final day = DaysCompanion.insert(
        id: row['id'] as String,
        campaignId: row['campaign_id'] as String,
        dayIndex: row['day_index'] as int,
        title: row['title'] as String,
        kind: Value(row['kind'] as String? ?? 'standard'),
        primaryArchetypeId: Value(row['primary_archetype_id'] as String?),
        updatedAt: _at(row),
      );
      return db
          .into(db.days)
          .insert(
            day,
            // A re-issued id from an authoring edit must be an update, not a
            // fatal insert -- the same defect `_byIdOrNaturalKey` exists for.
            onConflict: _byIdOrNaturalKey(day, [
              db.days.campaignId,
              db.days.dayIndex,
            ]),
          );
    }),
    // After `days`, because a body is meaningless without the day it frames.
    // Keyed on day_id, which is the primary key, so a re-pull is an update
    // rather than a duplicate. There is no natural-key fallback here because
    // there is no natural key: the day's id is it.
    _ContentTable(
      'day_bodies',
      (row) => db
          .into(db.dayBodies)
          .insertOnConflictUpdate(
            DayBodiesCompanion.insert(
              dayId: row['day_id'] as String,
              bodyMd: row['body_md'] as String,
              updatedAt: _at(row),
            ),
          ),
    ),
    _ContentTable('actions', (row) {
      final action = ActionsCompanion.insert(
        id: row['id'] as String,
        dayId: row['day_id'] as String,
        title: row['title'] as String,
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
            // The natural key is the day *slot* -- since ADR-0030 a day holds a
            // mandatory action and n optional ones and `sort` separates them,
            // and since ADR-0034 the day is a real foreign key rather than two
            // columns. A conflict target that is not an actual unique index is
            // rejected by sqlite outright.
            onConflict: _byIdOrNaturalKey(action, [
              db.actions.dayId,
              db.actions.sort,
            ]),
          );
    }),
    // After `actions`, because a share is meaningless without the action it
    // divides. Keyed on (action_id, archetype_id), which is the primary key, so
    // a re-pull is an update rather than a duplicate — there is no natural-key
    // fallback to write because the key is natural already.
    _ContentTable(
      'action_archetypes',
      (row) => db
          .into(db.actionArchetypes)
          .insertOnConflictUpdate(
            ActionArchetypesCompanion.insert(
              actionId: row['action_id'] as String,
              archetypeId: row['archetype_id'] as String,
              share: Value(row['share'] as int? ?? 1),
              updatedAt: _at(row),
            ),
          ),
    ),
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

  /// Every cached content table, for the wholesale delete a refresh performs.
  ///
  /// Listed explicitly rather than derived from [_tables] so the compiler checks
  /// each one, and in reverse dependency order: drift declares no foreign keys
  /// locally, but an order that reads like the schema is one a reader can check.
  late final List<TableInfo<Table, dynamic>> _contentTables = [
    db.diagnosticOptions,
    db.diagnosticQuestions,
    db.doctrineEntries,
    db.doctrineGroups,
    db.actionBodies,
    db.actionArchetypes,
    db.actions,
    db.dayBodies,
    db.days,
    db.campaignArchetypes,
    db.campaigns,
    db.packs,
    db.archetypes,
  ];

  static const _versionKey = 'content_version';

  /// Replaces the cached library with what the server currently holds.
  ///
  /// Replace, not merge. The incremental pull this succeeds asked each table for
  /// rows newer than a per-device watermark, which structurally cannot observe a
  /// deletion: a deleted row carries no newer `updated_at`, so a campaign removed
  /// on the server stayed on the device until the app was reinstalled. Replacing
  /// the set makes a deletion ordinary — the row simply is not in the answer.
  ///
  /// Returns whether anything was applied. [force] skips the version gate, for
  /// the two cases where the *visible* rows change without the library changing:
  /// a purchase and a sign-in both move what row-level security will return for
  /// the body tables (ADR-0025, ADR-0034).
  Future<bool> refresh({bool force = false}) async {
    final remoteVersion = await api.fetchVersion();
    if (!force && remoteVersion == await cachedVersion()) return false;

    // Everything is fetched before anything local is touched, so a fetch that
    // fails half way through leaves the cache exactly as it was. A throw is "we
    // did not find out", never "the library is empty" — the same rule that keeps
    // a failed entitlement fetch from revoking a pack (ADR-0025).
    final fetched = <String, List<Map<String, dynamic>>>{};
    for (final table in _tables) {
      fetched[table.name] = await api.fetchAll(table.name);
    }

    // Nothing anywhere means the server holds no library yet. There is nothing
    // to apply and nothing to complain about, and applying it would empty a cache
    // the bundled snapshot may have filled.
    if (fetched.values.every((rows) => rows.isEmpty)) return false;

    await db.transaction(() async {
      for (final table in _contentTables) {
        await db.delete(table).go();
      }
      for (final table in _tables) {
        for (final row in fetched[table.name]!) {
          await table.upsert(row);
        }
      }
      // Inside the transaction: a version recorded for rows that were not
      // committed would make the next launch skip the refetch they need.
      await primeVersion(remoteVersion);
    });
    return true;
  }

  /// Applies rows keyed by table name, using the same upserts as the network
  /// refresh, so the bundled snapshot and the wire can never diverge. Unknown
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

  /// The content version this device has cached, or null if it has never
  /// refreshed. Null is what makes a bundled-snapshot install refetch once.
  Future<int?> cachedVersion() async {
    final row = await (db.select(
      db.clientState,
    )..where((r) => r.key.equals(_versionKey))).getSingleOrNull();
    final raw = row?.value;
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> primeVersion(int value) => db
      .into(db.clientState)
      .insertOnConflictUpdate(
        ClientStateRow(key: _versionKey, value: '$value'),
      );

  /// Whether day one of any campaign in [packId] is fully readable locally:
  /// its **day body** and its mandatory action's body.
  ///
  /// Both, because a day the user cannot read is not a day they can start — the
  /// commit is taken after reading the framing copy (ADR-0034) — and a day whose
  /// action body has not arrived is the case this check already existed for
  /// (ADR-0025). The delivery check, chosen over a row count because a partial
  /// pull that has not reached day one is not a pack the user can start.
  Future<bool> hasBodyForFirstDay(String packId) async {
    final query =
        db.selectOnly(db.days).join([
            innerJoin(
              db.campaigns,
              db.campaigns.id.equalsExp(db.days.campaignId),
            ),
            innerJoin(db.dayBodies, db.dayBodies.dayId.equalsExp(db.days.id)),
            innerJoin(db.actions, db.actions.dayId.equalsExp(db.days.id)),
            innerJoin(
              db.actionBodies,
              db.actionBodies.actionId.equalsExp(db.actions.id),
            ),
          ])
          ..addColumns([db.days.id])
          ..where(
            db.campaigns.packId.equals(packId) &
                db.days.dayIndex.equals(1) &
                db.actions.isOptional.equals(false),
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
            innerJoin(db.days, db.days.id.equalsExp(db.actions.dayId)),
            leftOuterJoin(
              db.actionBodies,
              db.actionBodies.actionId.equalsExp(db.actions.id),
            ),
          ])
          ..where(db.days.campaignId.equals(campaignId))
          ..orderBy([
            OrderingTerm(expression: db.days.dayIndex),
            OrderingTerm(expression: db.actions.sort),
          ]);
    return _toActions(await query.get());
  }

  /// Hydrates joined action rows, attaching each one's archetype shares.
  ///
  /// The shares come from a second query rather than a third join: an action
  /// has many archetypes, so joining them would multiply the rows the body join
  /// already produces and every caller would have to fold them back together.
  Future<List<ActionSpec>> _toActions(List<TypedResult> rows) async {
    final actions = [for (final row in rows) row.readTable(db.actions)];
    final shares = await _sharesFor([for (final a in actions) a.id]);
    return [
      for (var i = 0; i < rows.length; i++)
        toAction(
          actions[i],
          shares[actions[i].id] ?? const {},
          rows[i].readTableOrNull(db.actionBodies),
        ),
    ];
  }

  /// Authored shares per action, keyed by archetype id. Actions with no rows
  /// here are simply absent from the result; the mapper reads that as an empty
  /// split, which is how a partial content sync degrades.
  Future<Map<String, Map<String, int>>> _sharesFor(
    List<String> actionIds,
  ) async {
    if (actionIds.isEmpty) return const {};
    final rows = await (db.select(
      db.actionArchetypes,
    )..where((aa) => aa.actionId.isIn(actionIds))).get();

    final shares = <String, Map<String, int>>{};
    for (final row in rows) {
      (shares[row.actionId] ??= <String, int>{})[row.archetypeId] = row.share;
    }
    return shares;
  }

  /// One campaign day, with its actions already ordered mandatory-first then by
  /// `sort`, and its body attached.
  ///
  /// Null when the day itself is not cached. A cached day whose actions or body
  /// have not arrived comes back as a day with an empty action list or a null
  /// `bodyMd` — partial-sync states the caller degrades on, and the reason this
  /// replaced `actionFor`, whose single-row query would throw outright on any
  /// day that had optionals.
  Future<DaySpec?> dayFor(String campaignId, int dayIndex) async {
    final row =
        await (db.select(db.days)..where(
              (d) =>
                  d.campaignId.equals(campaignId) & d.dayIndex.equals(dayIndex),
            ))
            .getSingleOrNull();
    if (row == null) return null;
    return (await _hydrateDays([row])).single;
  }

  /// Every cached day of a campaign, in day order.
  Future<List<DaySpec>> daysFor(String campaignId) async {
    final rows =
        await (db.select(db.days)
              ..where((d) => d.campaignId.equals(campaignId))
              ..orderBy([(d) => OrderingTerm(expression: d.dayIndex)]))
            .get();
    return _hydrateDays(rows);
  }

  /// Attaches each day's actions and body.
  ///
  /// Two follow-up queries rather than two more joins: a day has many actions
  /// and an action has many archetypes, so joining either would multiply the
  /// rows and every caller would have to fold them back together.
  Future<List<DaySpec>> _hydrateDays(List<DayRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final row in rows) row.id];

    final actionRows =
        await (db.select(db.actions).join([
                leftOuterJoin(
                  db.actionBodies,
                  db.actionBodies.actionId.equalsExp(db.actions.id),
                ),
              ])
              ..where(db.actions.dayId.isIn(ids))
              ..orderBy([
                OrderingTerm(expression: db.actions.isOptional),
                OrderingTerm(expression: db.actions.sort),
              ]))
            .get();

    final byDay = <String, List<ActionSpec>>{};
    for (final action in await _toActions(actionRows)) {
      (byDay[action.dayId] ??= <ActionSpec>[]).add(action);
    }

    final bodies = await (db.select(
      db.dayBodies,
    )..where((b) => b.dayId.isIn(ids))).get();
    final bodyByDay = {for (final body in bodies) body.dayId: body};

    return [
      for (final row in rows)
        toDay(row, byDay[row.id] ?? const [], bodyByDay[row.id]),
    ];
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
