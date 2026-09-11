import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:test/test.dart';

/// Exercises the state `_replaceLocalUserState` leaves behind.
///
/// It is private and reached only through a real sign-in, so its body is
/// extracted to a package-private top-level function in the same library and
/// the method is a one-line call to it. That is the smallest seam that lets
/// this be asserted against a real database rather than a mock, which matters
/// here because the whole claim is about which rows remain.
void main() {
  test('signing in clears paid bodies and the body watermark', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.packs).insert(PacksCompanion.insert(
          id: 'core', key: 'core', title: 'Core', description: 'd',
          isCore: const Value(true), sort: 1,
          updatedAt: DateTime.utc(2026, 9, 9),
        ));
    await db.into(db.packs).insert(PacksCompanion.insert(
          id: 'paid', key: 'paid', title: 'Paid', description: 'd',
          isCore: const Value(false), storeProductId: const Value('pack.paid'),
          sort: 2, updatedAt: DateTime.utc(2026, 9, 9),
        ));
    await db.into(db.campaigns).insert(CampaignsCompanion.insert(
          id: 'cCore', packId: 'core', key: 'k1', title: 'Free', introMd: 'i',
          lengthDays: 1, sort: 1, updatedAt: DateTime.utc(2026, 9, 9),
        ));
    await db.into(db.campaigns).insert(CampaignsCompanion.insert(
          id: 'cPaid', packId: 'paid', key: 'k2', title: 'Paid', introMd: 'i',
          lengthDays: 1, sort: 2, updatedAt: DateTime.utc(2026, 9, 9),
        ));
    for (final (id, campaign) in [('aCore', 'cCore'), ('aPaid', 'cPaid')]) {
      await db.into(db.actions).insert(ActionsCompanion.insert(
            id: id, campaignId: campaign, dayIndex: 1, title: 't',
            archetypeId: 'x1', updatedAt: DateTime.utc(2026, 9, 9),
          ));
      await db.into(db.actionBodies).insert(ActionBodiesCompanion.insert(
            actionId: id, bodyMd: 'copy',
            updatedAt: DateTime.utc(2026, 9, 9),
          ));
    }
    await db.setWatermark('action_bodies', DateTime.utc(2026, 9, 9));

    await replaceLocalUserState(db);

    final remaining = await db.select(db.actionBodies).get();
    expect(
      remaining.map((b) => b.actionId),
      ['aCore'],
      reason: 'the free pack survives; the previous account\'s pack does not',
    );
    expect(
      await db.watermarkFor('action_bodies'),
      isNull,
      reason: 'the next pull must be able to see rows older than the old mark',
    );
  });

  test('signing in clears the previous account\'s ticks', () async {
    // A tick left behind would feed the previous account's acts into this
    // account's radar and points total. The wipe has to know about every user
    // table, and this is the one ADR-0030 added.
    final db = FeralDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db.into(db.campaignRuns).insert(
      CampaignRunsCompanion.insert(
        id: 'run-1',
        userId: 'user-1',
        campaignId: 'campaign-1',
        status: 'active',
        startedAt: DateTime.utc(2026, 6, 1),
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
    );
    await db.into(db.dayLogs).insert(
      DayLogsCompanion.insert(
        id: 'log-1',
        userId: 'user-1',
        runId: 'run-1',
        dayIndex: 1,
        actionId: 'action-1',
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
    );
    await db.into(db.dayLogActions).insert(
      DayLogActionsCompanion.insert(
        id: 'tick-1',
        userId: 'user-1',
        runId: 'run-1',
        dayIndex: 1,
        actionId: 'action-1',
        updatedAt: DateTime.utc(2026, 6, 1),
      ),
    );

    await replaceLocalUserState(db);

    expect(await db.select(db.dayLogActions).get(), isEmpty);
    expect(await db.select(db.dayLogs).get(), isEmpty);
  });
}
