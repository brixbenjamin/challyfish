import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:test/test.dart';

import '../support/fake_auth_gateway.dart';
import '../support/fake_purchase_gateway.dart';

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

  test('a sign-in drops the cached content version but keeps content', () async {
    await seedLocalProgress();
    auth.identityTaken = true;
    await identity.attach(provider: AuthProvider.google, credential: 'g');

    await identity.completeSignIn(
      provider: AuthProvider.google,
      credential: 'g',
    );

    // There are no per-table watermarks to reset any more: the record is fetched
    // as a complete set, and the library is fetched whole when its version moves.
    // Dropping the version is what forces the one refresh that matters here,
    // because it re-filters the body tables for whoever is now signed in.
    expect(await db.select(db.clientState).get(), isEmpty);
    expect(
      await db.select(db.campaigns).get(),
      isNotEmpty,
      reason: "the library is not the new account's business to re-download",
    );
  });

  test('the rows are gone before any sync could pick them up', () async {
    await seedLocalProgress();
    auth.identityTaken = true;
    await identity.attach(provider: AuthProvider.google, credential: 'g');

    await identity.completeSignIn(
      provider: AuthProvider.google,
      credential: 'g',
    );

    // Nothing is owed, because nothing is left. Uploading records the user just
    // agreed to discard would be worse than discarding them, and the only way to
    // guarantee that is for the wipe to leave no queue behind.
    expect(await db.select(db.campaignRuns).get(), isEmpty);
    expect(await db.select(db.dayLogs).get(), isEmpty);
    expect(
      await db.select(db.outbox).get(),
      isEmpty,
      reason: "a queued write would be sent as the account they just joined",
    );
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
