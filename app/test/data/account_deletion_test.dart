import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/account_api.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:test/test.dart';

import 'identity_repository_test.dart' show FakeAuthGateway;

class FakeAccountApi implements AccountApi {
  bool succeed = true;
  int calls = 0;

  @override
  Future<void> deleteAccount() async {
    calls++;
    if (!succeed) throw const AccountDeletionFailed('500');
  }
}

void main() {
  late FeralDatabase db;
  late FakeAuthGateway auth;
  late FakeAccountApi api;
  late IdentityRepository identity;

  setUp(() async {
    db = FeralDatabase(NativeDatabase.memory());
    auth = FakeAuthGateway();
    api = FakeAccountApi();
    identity = IdentityRepository(db: db, auth: auth);
    await db
        .into(db.campaignRuns)
        .insert(
          CampaignRunsCompanion.insert(
            id: 'run-1',
            userId: 'anon-user',
            campaignId: 'campaign-1',
            status: 'active',
            startedAt: DateTime.utc(2026, 6, 1),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
  });
  tearDown(() => db.close());

  test(
    'a successful delete wipes local rows and starts a fresh anonymous session',
    () async {
      await api.deleteAccount();
      await identity.resetToFreshAnonymous();

      expect(await db.select(db.campaignRuns).get(), isEmpty);
      expect(auth.calls, contains('anon'));
      expect(auth.currentUserId, 'fresh-anon');
    },
  );

  test(
    'a failed server delete leaves the local record completely intact',
    () async {
      api.succeed = false;

      await expectLater(
        api.deleteAccount(),
        throwsA(isA<AccountDeletionFailed>()),
      );

      expect(
        await db.select(db.campaignRuns).get(),
        hasLength(1),
        reason: 'the wipe is only reached after the server confirms',
      );
      expect(auth.currentUserId, 'anon-user');
    },
  );
}
