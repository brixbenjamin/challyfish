import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/content_api.dart';
import 'package:feral/src/data/repositories/content_repository.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:test/test.dart';

class EmptyContentApi implements ContentApi {
  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
  ) async => const [];
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

  test('a sign-in wipes paid day bodies and keeps the core ones', () async {
    // The core pack is free to everyone, which also means a sign-in never
    // leaves the app with nothing to show.
    await seed();

    await replaceLocalUserState(db);

    final remaining = await db.select(db.dayBodies).get();
    expect(remaining.map((b) => b.dayId), ['day-core']);
  });

  test('a sign-in clears the day_bodies watermark', () async {
    // The mark is per device while the visible row set is per user. A stale
    // mark hides the newly signed-in account's own pack behind an
    // `updated_at >` filter it can never satisfy.
    await seed();
    await db.setWatermark('day_bodies', DateTime.utc(2026, 9, 9));
    await db.setWatermark('campaigns', DateTime.utc(2026, 9, 9));

    await replaceLocalUserState(db);

    expect(await db.watermarkFor('day_bodies'), isNull);
    expect(
      await db.watermarkFor('campaigns'),
      isNotNull,
      reason: 'every other content mark is left alone',
    );
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
