import 'package:drift/drift.dart' show Value;
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
  final List<DateTime?> fetchedSince = [];
  final List<String> upserted = [];

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String table,
    DateTime? since,
    String userId,
  ) async {
    fetched.add(table);
    fetchedSince.add(since);
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

  test('entitlements keep no watermark, because a refund has no timestamp',
      () async {
    // Deliberately not the incremental contract this test used to assert. A
    // refund deletes the server row, and a deleted row carries no newer
    // updated_at, so a watermark would make revocation unobservable forever
    // (ADR-0025). The set is fetched whole every time instead: one row per
    // owned pack, and a user owns one.
    final api = FakeProgressApi({
      'entitlements': [entitlementRow()],
    });
    await repoWith(api).pull('user-1');

    expect(await db.watermarkFor('entitlements'), isNull);
    expect(
      api.fetchedSince[api.fetched.indexOf('entitlements')],
      isNull,
      reason: 'a complete set is asked for unconditionally',
    );
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

  test('entitlements are pulled last, outside the incremental order', () async {
    final api = FakeProgressApi(const {});
    await repoWith(api).pull('user-1');

    // Still last -- nothing references an entitlement, and the purge it drives
    // must see the rest of the pull's result. But it is no longer a member of
    // pullOrder, which is the incremental path it cannot use (ADR-0025).
    expect(SyncRepository.pullOrder, isNot(contains('entitlements')));
    expect(api.fetched.last, 'entitlements');
  });
}
