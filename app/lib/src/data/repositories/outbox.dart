import 'dart:convert';

import 'package:drift/drift.dart';

import '../local/database.dart';
import '../local/outbox_payloads.dart';

/// Turns a stored row into the payload the server expects, and says what key
/// identifies it.
///
/// Serialising from the row rather than from the arguments a write was called
/// with is deliberate: what gets queued is then, by construction, what got
/// stored. These are the same payload shapes the dirty-row push built, moved
/// here so the write path and the upgrade that drains the old `dirty` flags
/// cannot disagree about them.
/// Adapts a stored row into a queue entry.
///
/// Serialising from the row rather than from the arguments a write was called
/// with is deliberate: what gets queued is then, by construction, what got
/// stored. The shapes themselves live in [OutboxPayloads], which takes
/// primitives so `database.dart` can use them during an upgrade without
/// importing this file back.
typedef OutboxEntry = ({
  String table,
  String key,
  Map<String, dynamic> payload,
});

OutboxEntry entryForProfile(ProfileRow row) => (
  table: OutboxPayloads.profiles,
  key: row.userId,
  payload: OutboxPayloads.profile(
    userId: row.userId,
    displayName: row.displayName,
    onboardedAt: row.onboardedAt,
    updatedAt: row.updatedAt,
  ),
);

OutboxEntry entryForRun(CampaignRunRow row) => (
  table: OutboxPayloads.campaignRuns,
  key: row.id,
  payload: OutboxPayloads.run(
    id: row.id,
    userId: row.userId,
    campaignId: row.campaignId,
    status: row.status,
    isHardened: row.isHardened,
    startedAt: row.startedAt,
    completedAt: row.completedAt,
    grade: row.grade,
    updatedAt: row.updatedAt,
  ),
);

OutboxEntry entryForDayLog(DayLogRow row) => (
  table: OutboxPayloads.dayLogs,
  key: OutboxPayloads.keyForDayLog(row.runId, row.dayIndex),
  payload: OutboxPayloads.dayLog(
    id: row.id,
    userId: row.userId,
    runId: row.runId,
    dayIndex: row.dayIndex,
    actionId: row.actionId,
    committedAt: row.committedAt,
    outcome: row.outcome,
    note: row.note,
    updatedAt: row.updatedAt,
  ),
);

OutboxEntry entryForTick(DayLogActionRow row) => (
  table: OutboxPayloads.dayLogActions,
  key: OutboxPayloads.keyForTick(row.runId, row.dayIndex, row.actionId),
  payload: OutboxPayloads.tick(
    userId: row.userId,
    runId: row.runId,
    dayIndex: row.dayIndex,
    actionId: row.actionId,
    completed: row.completed,
    updatedAt: row.updatedAt,
  ),
);

OutboxEntry entryForDiagnostic(DiagnosticResultRow row) => (
  table: OutboxPayloads.diagnosticResults,
  key: row.id,
  payload: OutboxPayloads.diagnostic(
    id: row.id,
    userId: row.userId,
    takenAt: row.takenAt,
    scores: row.scores,
    weakestArchetypeId: row.weakestArchetypeId,
    recommendedCampaignId: row.recommendedCampaignId,
    updatedAt: row.updatedAt,
  ),
);

/// The queue of writes this device owes the server.
///
/// Reads and writes only the `outbox` table. It is a class rather than loose
/// functions so the write path can be handed one thing to enqueue with, and so
/// the flush has one place to drain from.
class OutboxQueue {
  OutboxQueue({required this.db, required this.clock});

  final FeralDatabase db;
  final DateTime Function() clock;

  /// Queues [entry], replacing any pending entry for the same row.
  ///
  /// Replacing keeps the original `id`, so a row edited twice before a sync
  /// keeps the position it first took. That is what preserves foreign-key order:
  /// a run queued before its day logs stays before them however often either is
  /// rewritten.
  Future<void> add(OutboxEntry entry) async {
    final existing =
        await (db.select(db.outbox)..where(
              (o) =>
                  o.remoteTable.equals(entry.table) &
                  o.rowKey.equals(entry.key),
            ))
            .getSingleOrNull();

    if (existing != null) {
      await (db.update(db.outbox)..where((o) => o.id.equals(existing.id)))
          .write(OutboxCompanion(payload: Value(jsonEncode(entry.payload))));
      return;
    }

    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            remoteTable: entry.table,
            rowKey: entry.key,
            payload: jsonEncode(entry.payload),
            queuedAt: clock(),
          ),
        );
  }

  /// Everything owed, oldest first. Ascending `id` is the foreign-key order.
  Future<List<OutboxRow>> pending() =>
      (db.select(db.outbox)..orderBy([(o) => OrderingTerm.asc(o.id)])).get();

  /// The row keys still owed for [table], so a refresh can leave them alone.
  Future<Set<String>> pendingKeysFor(String table) async {
    final rows = await (db.select(
      db.outbox,
    )..where((o) => o.remoteTable.equals(table))).get();
    return rows.map((r) => r.rowKey).toSet();
  }

  Future<void> remove(int id) =>
      (db.delete(db.outbox)..where((o) => o.id.equals(id))).go();

  /// Rewrites one entry's payload in place, keeping its position.
  Future<void> rewrite(int id, Map<String, dynamic> payload) =>
      (db.update(db.outbox)..where((o) => o.id.equals(id))).write(
        OutboxCompanion(payload: Value(jsonEncode(payload))),
      );

  /// Drops everything owed. Used when this device changes account: a write
  /// belonging to the account the user just left must never be sent as the one
  /// they just joined.
  Future<void> clear() => db.delete(db.outbox).go();

  static Map<String, dynamic> decode(OutboxRow row) =>
      jsonDecode(row.payload) as Map<String, dynamic>;
}
