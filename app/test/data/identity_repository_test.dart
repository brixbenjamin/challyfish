import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/remote/auth_gateway.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:test/test.dart';

import '../support/fake_purchase_gateway.dart';

class FakeAuthGateway implements AuthGateway {
  String? userId = 'anon-user';
  LinkedIdentity? identity;
  bool identityTaken = false;
  final List<String> calls = [];

  @override
  String? get currentUserId => userId;

  @override
  LinkedIdentity? get linkedIdentity => identity;

  @override
  Future<void> linkIdentity(AuthProvider provider, Object credential) async {
    calls.add('link:${provider.name}');
    if (identityTaken) {
      throw const IdentityAlreadyAttached(
        'that identity belongs to another account',
      );
    }
    identity = LinkedIdentity(provider: provider, label: 'you@example.com');
  }

  @override
  Future<String> signIn(AuthProvider provider, Object credential) async {
    calls.add('signIn:${provider.name}');
    userId = 'existing-user';
    identity = LinkedIdentity(provider: provider, label: 'you@example.com');
    return userId!;
  }

  /// The address belongs to another account. Only the linking branch can see
  /// this, exactly as GoTrue only refuses an email *change* to a taken address.
  bool addressTaken = false;
  bool codeIsWrong = false;

  @override
  Future<void> sendEmailCode(String email, {required bool link}) async {
    calls.add('sendCode:$email:link=$link');
    if (link && addressTaken) {
      throw const IdentityAlreadyAttached(
        'that address belongs to another account',
      );
    }
  }

  @override
  Future<String> verifyEmailCode({
    required String email,
    required String code,
    required bool link,
  }) async {
    calls.add('verify:$code:link=$link');
    if (codeIsWrong) throw Exception('token has expired or is invalid');
    identity = LinkedIdentity(provider: AuthProvider.email, label: email);
    if (!link) userId = 'existing-user';
    return userId!;
  }

  @override
  Future<void> signInAnonymously() async {
    calls.add('anon');
    userId = 'fresh-anon';
    identity = null;
  }
}

void main() {
  late FeralDatabase db;
  late FakeAuthGateway auth;
  late IdentityRepository identity;
  late FakePurchaseGateway purchases;

  Future<void> seedLocalProgress() async {
    await db
        .into(db.campaigns)
        .insert(
          CampaignsCompanion.insert(
            id: 'campaign-1',
            packId: 'pack-1',
            key: 'cold-approach',
            title: 'Cold Approach',
            introMd: 'intro',
            lengthDays: 7,
            sort: 1,
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
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
    for (var day = 1; day <= 4; day++) {
      await db
          .into(db.dayLogs)
          .insert(
            DayLogsCompanion.insert(
              id: 'log-$day',
              userId: 'anon-user',
              runId: 'run-1',
              dayIndex: day,
              actionId: 'action-$day',
              outcome: const Value('done'),
              updatedAt: DateTime.utc(2026, 6, day),
            ),
          );
    }
  }

  setUp(() {
    db = FeralDatabase(NativeDatabase.memory());
    auth = FakeAuthGateway();
    purchases = FakePurchaseGateway();
    identity = IdentityRepository(
      db: db,
      auth: auth,
      entitlements: EntitlementRepository(
        db: db,
        gateway: purchases,
        clock: FixedClock(DateTime.utc(2026, 6, 1)),
      ),
      purchases: purchases,
    );
  });
  tearDown(() => db.close());

  test('an unattached identity links, and nothing is destroyed', () async {
    await seedLocalProgress();

    final outcome = await identity.attach(
      provider: AuthProvider.apple,
      credential: 'apple-token',
    );

    expect(outcome, isA<Linked>());
    expect(auth.calls, ['link:apple']);
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
    expect(auth.currentUserId, 'anon-user', reason: 'the user id is preserved');
  });

  test(
    'an already-attached identity asks for confirmation and signs in to nothing yet',
    () async {
      await seedLocalProgress();
      auth.identityTaken = true;

      final outcome = await identity.attach(
        provider: AuthProvider.google,
        credential: 'google-token',
      );

      expect(outcome, isA<NeedsReplaceConfirmation>());
      expect(auth.calls, [
        'link:google',
      ], reason: 'sign-in has NOT been attempted');
      expect(
        await db.select(db.campaignRuns).get(),
        hasLength(1),
        reason: 'nothing is destroyed before the user confirms',
      );
    },
  );

  test(
    'the confirmation carries the campaign title and the reported-day count',
    () async {
      await seedLocalProgress();
      auth.identityTaken = true;

      final outcome =
          await identity.attach(
                provider: AuthProvider.google,
                credential: 'google-token',
              )
              as NeedsReplaceConfirmation;

      expect(outcome.summary.campaignTitle, 'Cold Approach');
      expect(outcome.summary.reportedDays, 4);
      expect(outcome.summary.totalDays, 7);
      expect(outcome.summary.hasProgress, isTrue);
    },
  );

  test('with no local progress there is nothing to confirm', () async {
    auth.identityTaken = true;

    final outcome = await identity.attach(
      provider: AuthProvider.google,
      credential: 'google-token',
    );

    expect(
      outcome,
      isA<SignedIn>(),
      reason: 'the reinstall case is silent and immediate',
    );
    expect(auth.calls, ['link:google', 'signIn:google']);
  });

  test('completing a sign-in clears user rows but never content', () async {
    await seedLocalProgress();
    auth.identityTaken = true;
    await identity.attach(provider: AuthProvider.google, credential: 'g');

    await identity.completeSignIn(
      provider: AuthProvider.google,
      credential: 'g',
    );

    expect(await db.select(db.campaignRuns).get(), isEmpty);
    expect(await db.select(db.dayLogs).get(), isEmpty);
    expect(
      await db.select(db.campaigns).get(),
      hasLength(1),
      reason: 'content is user-agnostic; re-downloading it would be pointless',
    );
  });

  test(
    'a sign-in resets the user watermarks but not the content ones',
    () async {
      await seedLocalProgress();
      await db.setWatermark('day_logs', DateTime.utc(2026, 6, 4));
      await db.setWatermark('campaigns', DateTime.utc(2026, 6, 1));
      auth.identityTaken = true;
      await identity.attach(provider: AuthProvider.google, credential: 'g');

      await identity.completeSignIn(
        provider: AuthProvider.google,
        credential: 'g',
      );

      expect(
        await db.watermarkFor('day_logs'),
        isNull,
        reason: 'the new account must pull its record in full',
      );
      expect(
        await db.watermarkFor('campaigns'),
        DateTime.utc(2026, 6, 1),
        reason: "the library is not the new account's business to re-download",
      );
    },
  );

  test('the rows are gone before any sync could pick them up', () async {
    await seedLocalProgress();
    auth.identityTaken = true;
    await identity.attach(provider: AuthProvider.google, credential: 'g');

    await identity.completeSignIn(
      provider: AuthProvider.google,
      credential: 'g',
    );

    // Nothing is left dirty, because nothing is left. Uploading records the
    // user just agreed to discard would be worse than discarding them, and the
    // only way to guarantee that is for the wipe to leave no queue behind.
    final dirtyRuns = await (db.select(
      db.campaignRuns,
    )..where((r) => r.dirty.equals(true))).get();
    final dirtyLogs = await (db.select(
      db.dayLogs,
    )..where((l) => l.dirty.equals(true))).get();
    expect(dirtyRuns, isEmpty);
    expect(dirtyLogs, isEmpty);
  });

  test('a cancelled link leaves the anonymous session untouched', () async {
    await seedLocalProgress();

    final outcome = await identity.attach(
      provider: AuthProvider.apple,
      credential: null,
    );

    expect(outcome, isA<Cancelled>());
    expect(auth.linkedIdentity, isNull);
    expect(auth.calls, isEmpty);
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
  });

  // ------------------------------------------------------------------- email

  test('a free address attaches to the record already on this phone', () async {
    await seedLocalProgress();

    final sent = await identity.sendEmailCode('you@example.com');
    expect(sent, isA<CodeSent>());
    expect((sent as CodeSent).link, isTrue);

    final outcome = await identity.verifyEmailCode(
      email: 'you@example.com',
      code: '123456',
      link: true,
    );

    expect(outcome, isA<Linked>());
    expect(auth.currentUserId, 'anon-user', reason: 'the record does not move');
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
  });

  test('an address with an account asks before it sends anything', () async {
    await seedLocalProgress();
    auth.addressTaken = true;

    final outcome = await identity.sendEmailCode('you@example.com');

    expect(outcome, isA<NeedsReplaceConfirmation>());
    expect(auth.calls, [
      'sendCode:you@example.com:link=true',
    ], reason: 'no sign-in code was sent to an address we may not use');
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
  });

  test('the confirmation carries what an email sign-in would cost', () async {
    await seedLocalProgress();
    auth.addressTaken = true;

    final outcome =
        await identity.sendEmailCode('you@example.com')
            as NeedsReplaceConfirmation;

    expect(outcome.summary.campaignTitle, 'Cold Approach');
    expect(outcome.summary.reportedDays, 4);
  });

  test('with nothing to lose the sign-in code goes straight out', () async {
    auth.addressTaken = true;

    final outcome = await identity.sendEmailCode('you@example.com');

    expect(outcome, isA<CodeSent>());
    expect(
      (outcome as CodeSent).link,
      isFalse,
      reason: 'the code that follows verifies as a sign-in, not a link',
    );
    expect(auth.calls, [
      'sendCode:you@example.com:link=true',
      'sendCode:you@example.com:link=false',
    ]);
  });

  test('confirming the replacement is what sends the sign-in code', () async {
    await seedLocalProgress();
    auth.addressTaken = true;
    await identity.sendEmailCode('you@example.com');

    final outcome = await identity.confirmEmailReplacement('you@example.com');

    expect(outcome, isA<CodeSent>());
    expect((outcome as CodeSent).link, isFalse);
    expect(auth.calls.last, 'sendCode:you@example.com:link=false');
    expect(
      await db.select(db.campaignRuns).get(),
      hasLength(1),
      reason: 'consent sends a code; it does not destroy anything yet',
    );
  });

  test('an email sign-in clears user rows but never content', () async {
    await seedLocalProgress();

    final outcome = await identity.verifyEmailCode(
      email: 'you@example.com',
      code: '123456',
      link: false,
    );

    expect(outcome, isA<SignedIn>());
    expect((outcome as SignedIn).userId, 'existing-user');
    expect(await db.select(db.campaignRuns).get(), isEmpty);
    expect(await db.select(db.dayLogs).get(), isEmpty);
    expect(await db.select(db.campaigns).get(), hasLength(1));
  });

  test('a rejected code changes nothing at all', () async {
    await seedLocalProgress();
    auth.codeIsWrong = true;

    final outcome = await identity.verifyEmailCode(
      email: 'you@example.com',
      code: '000000',
      link: false,
    );

    expect(outcome, isA<Failed>());
    expect(
      await db.select(db.campaignRuns).get(),
      hasLength(1),
      reason: 'a typo must not cost the user their record',
    );
    expect(auth.linkedIdentity, isNull);
  });
}
