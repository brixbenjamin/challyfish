import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/progress_api.dart';
import 'package:feral/src/data/repositories/sync_repository.dart';
import 'package:test/test.dart';

/// Serves rows per table, and records what was asked for.
class FakeProgressApi implements ProgressApi {
  FakeProgressApi(this.rows);

  final Map<String, List<Map<String, dynamic>>> rows;
  final List<String> fetched = [];
  final List<String> upserted = [];

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async {
    fetched.add(table);
    return rows[table] ?? const [];
  }

  @override
  Future<void> upsert(String table, List<Map<String, dynamic>> rows) async {
    upserted.add(table);
  }
}

Map<String, dynamic> entitlementRow({
  String packId = 'pack-edge',
  String source = 'store',
  String updatedAt = '2026-06-01T10:00:00Z',
}) => {
  'user_id': 'user-1',
  'pack_id': packId,
  'source': source,
  'acquired_at': '2026-06-01T09:00:00Z',
  'updated_at': updatedAt,
};

void main() {
  late FeralDatabase db;

  setUp(() => db = FeralDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  SyncRepository repoWith(FakeProgressApi api) => SyncRepository(
    db: db,
    api: api,
    clock: FixedClock(DateTime.utc(2026, 6, 1, 12)),
  );

  test('entitlements are pulled', () async {
    final api = FakeProgressApi({
      'entitlements': [entitlementRow()],
    });
    final result = await repoWith(api).pull('user-1');

    expect(result.succeeded, isTrue);
    expect(api.fetched, contains('entitlements'));

    final row = await db.select(db.entitlements).getSingle();
    expect(row.packId, 'pack-edge');
    expect(row.local, isFalse);
  });

  test('a pulled row replaces the optimistic local one', () async {
    await db
        .into(db.entitlements)
        .insert(
          EntitlementsCompanion.insert(
            userId: 'user-1',
            packId: 'pack-edge',
            source: 'store',
            acquiredAt: DateTime.utc(2026, 6, 1, 9),
            updatedAt: DateTime.utc(2026, 6, 1, 9),
            local: const Value(true),
          ),
        );

    final api = FakeProgressApi({
      'entitlements': [entitlementRow()],
    });
    await repoWith(api).pull('user-1');

    final rows = await db.select(db.entitlements).get();
    expect(rows, hasLength(1), reason: 'keyed on (user_id, pack_id)');
    expect(
      rows.single.local,
      isFalse,
      reason: 'the server has now confirmed what the client guessed',
    );
  });

  test(
    'an older server row still wins, because a refund looks like that',
    () async {
      await db
          .into(db.entitlements)
          .insert(
            EntitlementsCompanion.insert(
              userId: 'user-1',
              packId: 'pack-edge',
              source: 'store',
              acquiredAt: DateTime.utc(2026, 6, 1),
              updatedAt: DateTime.utc(2026, 7, 1), // newer than the server's
              local: const Value(true),
            ),
          );

      final api = FakeProgressApi({
        'entitlements': [entitlementRow(source: 'grant')],
      });
      await repoWith(api).pull('user-1');

      final row = await db.select(db.entitlements).getSingle();
      expect(
        row.source,
        'grant',
        reason: 'the client has no write here to protect, so it never wins',
      );
    },
  );

  test('the watermark advances so a second pull asks for less', () async {
    final api = FakeProgressApi({
      'entitlements': [entitlementRow()],
    });
    await repoWith(api).pull('user-1');

    expect(await db.watermarkFor('entitlements'), DateTime.utc(2026, 6, 1, 10));
  });

  test('entitlements are never pushed', () async {
    final api = FakeProgressApi(const {});
    await repoWith(api).push('user-1');

    expect(
      api.upserted,
      isNot(contains('entitlements')),
      reason: 'the client cannot write this table; RLS would reject it',
    );
    expect(SyncRepository.pushOrder, isNot(contains('entitlements')));
  });

  test('entitlements are pulled last', () async {
    final api = FakeProgressApi(const {});
    await repoWith(api).pull('user-1');

    // Foreign keys: a row referencing a run must arrive after the run. Nothing
    // references an entitlement, so it costs nothing to put it at the end and
    // it keeps the ordering rule uniform.
    expect(SyncRepository.pullOrder.last, 'entitlements');
  });
}
