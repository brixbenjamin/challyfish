import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:test/test.dart';

void main() {
  test('a body survives being read back through its own table', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db
        .into(db.actions)
        .insert(
          ActionsCompanion.insert(
            id: 'a1',
            campaignId: 'c1',
            dayIndex: 1,
            title: 'Day 1',
            archetypeId: 'x1',
            updatedAt: DateTime.utc(2026, 9, 9),
          ),
        );
    await db
        .into(db.actionBodies)
        .insert(
          ActionBodiesCompanion.insert(
            actionId: 'a1',
            bodyMd: 'the copy',
            updatedAt: DateTime.utc(2026, 9, 9),
          ),
        );

    final body = await (db.select(
      db.actionBodies,
    )..where((b) => b.actionId.equals('a1'))).getSingleOrNull();
    expect(body?.bodyMd, 'the copy');
  });

  test('an action without a body is a readable row, not an error', () async {
    final db = FeralDatabase(NativeDatabase.memory());
    addTearDown(db.close);

    await db
        .into(db.actions)
        .insert(
          ActionsCompanion.insert(
            id: 'a2',
            campaignId: 'c1',
            dayIndex: 2,
            title: 'Day 2',
            archetypeId: 'x1',
            updatedAt: DateTime.utc(2026, 9, 9),
          ),
        );

    final row = await (db.select(
      db.actions,
    )..where((a) => a.id.equals('a2'))).getSingleOrNull();
    expect(row, isNotNull, reason: 'a locked action is still a row');

    final body = await (db.select(
      db.actionBodies,
    )..where((b) => b.actionId.equals('a2'))).getSingleOrNull();
    expect(body, isNull);
  });
}
