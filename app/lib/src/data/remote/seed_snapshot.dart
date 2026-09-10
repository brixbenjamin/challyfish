import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../local/database.dart';
import '../repositories/content_repository.dart';

/// Loads the bundled core content on a first launch.
///
/// A freshly installed app with an empty database and no signal would otherwise
/// show an empty campaign list, which violates design principle 4 — the daily
/// loop, and the path to starting one, never depends on the network.
class SeedSnapshotLoader {
  // Fields are public for the same reason ContentRepository's are: the
  // initializing-formal lint.
  SeedSnapshotLoader({
    required this.db,
    required this.content,
    Future<String> Function()? readSnapshot,
  }) : _readSnapshot =
           readSnapshot ??
           (() => rootBundle.loadString('assets/seed/core_content.json'));

  /// Tables the snapshot carries a deliberate subset of. Their rows are applied
  /// like any other, but they establish no high-water mark: a mark taken from
  /// the free pack's bodies sits above every paid body's timestamp, and the
  /// incremental pull would then filter out exactly what a purchase paid for
  /// (ADR-0025).
  static const _partialTables = {'action_bodies'};

  final FeralDatabase db;
  final ContentRepository content;
  final Future<String> Function() _readSnapshot;

  /// Returns whether it seeded. Safe to call on every launch.
  Future<bool> loadIfEmpty() async {
    final existing = await db.select(db.campaigns).get();
    if (existing.isNotEmpty) return false;

    final raw = jsonDecode(await _readSnapshot()) as Map<String, dynamic>;

    // One transaction: a half-seeded database is worse than an empty one,
    // because loadIfEmpty would then decline to fix it.
    await db.transaction(() async {
      await content.applyRows(raw);
    });

    for (final entry in raw.entries) {
      if (_partialTables.contains(entry.key)) continue;
      final rows = (entry.value as List).cast<Map<String, dynamic>>();
      DateTime? high;
      for (final row in rows) {
        final updated = DateTime.parse(row['updated_at'] as String);
        if (high == null || updated.isAfter(high)) high = updated;
      }
      if (high != null) await content.primeWatermark(entry.key, high);
    }

    return true;
  }
}
