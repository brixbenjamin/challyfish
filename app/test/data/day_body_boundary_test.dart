import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:test/test.dart';

class EmptyContentApi implements ContentApi {
  @override
  Future<List<Map<String, dynamic>>> fetchAll(String table) async => const [];

  @override
  Future<int> fetchVersion() async => 1;
}

/// day_bodies is the second table whose visible rows depend on who is asking
/// (ADR-0025, ADR-0034). Every device-side rule that exists because of
/// action_bodies has to cover it too, or the boundary holds on the server and
/// leaks on the device.
void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  /// A core pack and a paid pack, one campaign each, one day each with a body,
  /// and one mandatory action each with a body.
  Future<void> seed() async {
    await db.batch((b) {
      b.insertAll(db.packs, [
        PacksCompanion.insert(
          id: 'pack-core',
          key: 'core',
          title: 'Core',
          description: 'd',
          isCore: const Value(true),
          sort: 1,
          updatedAt: DateTime.utc(2026, 9, 14),
        ),
        PacksCompanion.insert(
          id: 'pack-paid',
          key: 'paid',
          title: 'Paid',
          description: 'd',
          sort: 2,
          updatedAt: DateTime.utc(2026, 9, 14),
        ),
      ]);
      b.insertAll(db.campaigns, [
        for (final (id, packId) in const [
          ('camp-core', 'pack-core'),
          ('camp-paid', 'pack-paid'),
        ])
          CampaignsCompanion.insert(
            id: id,
            packId: packId,
            key: id,
            title: id,
            introMd: 'i',
            lengthDays: 1,
            sort: 1,
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
      ]);
      b.insertAll(db.days, [
        for (final (id, campaignId) in const [
          ('day-core', 'camp-core'),
          ('day-paid', 'camp-paid'),
        ])
          DaysCompanion.insert(
            id: id,
            campaignId: campaignId,
            dayIndex: 1,
            title: 'Day one',
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
      ]);
      b.insertAll(db.dayBodies, [
        for (final id in const ['day-core', 'day-paid'])
          DayBodiesCompanion.insert(
            dayId: id,
            bodyMd: 'framing',
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
      ]);
      b.insertAll(db.actions, [
        for (final (id, dayId) in const [
          ('act-core', 'day-core'),
          ('act-paid', 'day-paid'),
        ])
          ActionsCompanion.insert(
            id: id,
            dayId: dayId,
            title: 'Do it',
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
      ]);
      b.insertAll(db.actionBodies, [
        for (final id in const ['act-core', 'act-paid'])
          ActionBodiesCompanion.insert(
            actionId: id,
            bodyMd: 'copy',
            updatedAt: DateTime.utc(2026, 9, 14),
          ),
      ]);
    });
  }

  test('a sign-in drops the cached content version', () async {
    // This is what re-filters both body tables for whoever is now signed in.
    // The library did not change, so a version-gated refresh would decide there
    // was nothing to fetch and the new account would go on reading the old
    // account's paid copy. The wipe itself no longer deletes body rows — the
    // refresh replaces them with what row-level security returns (ADR-0025,
    // ADR-0034).
    await seed();
    final content = ContentRepository(db: db, api: EmptyContentApi());
    await content.primeVersion(7);

    await replaceLocalUserState(db);

    expect(await content.cachedVersion(), isNull);
  });

  test('a sign-in clears what this device still owed', () async {
    await seed();
    await db
        .into(db.outbox)
        .insert(
          OutboxCompanion.insert(
            remoteTable: 'day_logs',
            rowKey: 'run-1:1',
            payload: '{}',
            queuedAt: DateTime.utc(2026, 9, 9),
          ),
        );

    await replaceLocalUserState(db);

    expect(await db.select(db.outbox).get(), isEmpty);
  });

  test('hasBodyForFirstDay is false with no day body', () async {
    await seed();
    await (db.delete(
      db.dayBodies,
    )..where((b) => b.dayId.equals('day-paid'))).go();

    final repo = ContentRepository(db: db, api: EmptyContentApi());
    expect(await repo.hasBodyForFirstDay('pack-paid'), isFalse);
    expect(await repo.hasBodyForFirstDay('pack-core'), isTrue);
  });

  test('hasBodyForFirstDay is false with no action body', () async {
    // The case the check already existed for, and it must keep holding.
    await seed();
    await (db.delete(
      db.actionBodies,
    )..where((b) => b.actionId.equals('act-paid'))).go();

    final repo = ContentRepository(db: db, api: EmptyContentApi());
    expect(await repo.hasBodyForFirstDay('pack-paid'), isFalse);
  });
}
