import 'package:drift/drift.dart';

import '../../domain/campaign.dart';
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

  /// The high-water mark per table, so a pull asks only for what changed.
  final Map<String, DateTime> _watermarks = {};

  Future<void> pull() async {
    await _pullArchetypes();
    await _pullPacks();
    await _pullCampaigns();
    await _pullActions();
  }

  DateTime _advanceWatermark(String table, List<Map<String, dynamic>> rows) {
    var high =
        _watermarks[table] ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    for (final row in rows) {
      final updated = DateTime.parse(row['updated_at'] as String);
      if (updated.isAfter(high)) high = updated;
    }
    _watermarks[table] = high;
    return high;
  }

  Future<void> _pullArchetypes() async {
    const table = 'archetypes';
    final rows = await api.fetchSince(table, _watermarks[table]);
    if (rows.isEmpty) return;

    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.archetypes,
          ArchetypesCompanion.insert(
            id: row['id'] as String,
            key: row['key'] as String,
            name: row['name'] as String,
            blurb: row['blurb'] as String,
            color: row['color'] as String,
            sort: row['sort'] as int,
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    _advanceWatermark(table, rows);
  }

  Future<void> _pullPacks() async {
    const table = 'packs';
    final rows = await api.fetchSince(table, _watermarks[table]);
    if (rows.isEmpty) return;

    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.packs,
          PacksCompanion.insert(
            id: row['id'] as String,
            key: row['key'] as String,
            title: row['title'] as String,
            description: row['description'] as String,
            isCore: Value(row['is_core'] as bool? ?? false),
            storeProductId: Value(row['store_product_id'] as String?),
            coverPath: Value(row['cover_path'] as String?),
            sort: row['sort'] as int,
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    _advanceWatermark(table, rows);
  }

  Future<void> _pullCampaigns() async {
    const table = 'campaigns';
    final rows = await api.fetchSince(table, _watermarks[table]);
    if (rows.isEmpty) return;

    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.campaigns,
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
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    _advanceWatermark(table, rows);
  }

  Future<void> _pullActions() async {
    const table = 'actions';
    final rows = await api.fetchSince(table, _watermarks[table]);
    if (rows.isEmpty) return;

    await db.batch((batch) {
      for (final row in rows) {
        batch.insert(
          db.actions,
          ActionsCompanion.insert(
            id: row['id'] as String,
            campaignId: row['campaign_id'] as String,
            dayIndex: row['day_index'] as int,
            title: row['title'] as String,
            bodyMd: row['body_md'] as String,
            archetypeId: row['archetype_id'] as String,
            whyDoctrineId: Value(row['why_doctrine_id'] as String?),
            effort: Value(row['effort'] as int? ?? 1),
            updatedAt: DateTime.parse(row['updated_at'] as String),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
    _advanceWatermark(table, rows);
  }

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
}
