import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:feral/src/app/link_flow.dart';
import 'package:feral/src/data/local/database.dart';
import 'package:feral/src/data/repositories/entitlement_repository.dart';
import 'package:feral/src/core/clock.dart';
import 'package:feral/src/data/repositories/identity_repository.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:test/test.dart';

import '../support/fake_auth_gateway.dart';

import '../support/fake_purchase_gateway.dart';

/// The order of the questions, which is the part of linking a widget test can
/// only reach through three screens and a modal sheet.
///
/// What is asserted here is sequence, not navigation: that a confirmation is
/// asked exactly when there is something to lose, that declining costs nothing,
/// and that the code a user types is verified against the flow that mailed it.
void main() {
  late FeralDatabase db;
  late FakeAuthGateway auth;
  late IdentityRepository identity;
  late FakePurchaseGateway purchases;
  late LinkFlow flow;

  var confirmations = 0;
  var confirmAnswer = true;
  String? labelShown;

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
    await db
        .into(db.dayLogs)
        .insert(
          DayLogsCompanion.insert(
            id: 'log-1',
            userId: 'anon-user',
            runId: 'run-1',
            dayIndex: 1,
            actionId: 'action-1',
            outcome: const Value('done'),
            updatedAt: DateTime.utc(2026, 6, 1),
          ),
        );
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
    confirmations = 0;
    confirmAnswer = true;
    labelShown = null;
    flow = LinkFlow(
      identity: identity,
      confirmReplacement: (summary, label) async {
        confirmations++;
        labelShown = label;
        return confirmAnswer;
      },
    );
  });
  tearDown(() => db.close());

  test('a free identity is attached without asking anything', () async {
    await seedLocalProgress();

    final outcome = await flow.attach(
      provider: AuthProvider.apple,
      credential: 'apple-token',
      accountLabel: 'your Apple ID',
    );

    expect(outcome, isA<Linked>());
    expect(confirmations, 0, reason: 'there was nothing to weigh');
  });

  test('a taken identity is asked about once, and a yes signs in', () async {
    await seedLocalProgress();
    auth.identityTaken = true;

    final outcome = await flow.attach(
      provider: AuthProvider.google,
      credential: 'google-token',
      accountLabel: 'your Google account',
    );

    expect(outcome, isA<SignedIn>());
    expect(confirmations, 1);
    expect(labelShown, 'your Google account');
    expect(await db.select(db.campaignRuns).get(), isEmpty);
  });

  test('a no leaves the record exactly where it was', () async {
    await seedLocalProgress();
    auth.identityTaken = true;
    confirmAnswer = false;

    final outcome = await flow.attach(
      provider: AuthProvider.google,
      credential: 'google-token',
      accountLabel: 'your Google account',
    );

    expect(outcome, isA<Cancelled>());
    expect(auth.calls, ['link:google'], reason: 'no sign-in was attempted');
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
    expect(await db.select(db.dayLogs).get(), hasLength(1));
  });

  test('a taken address asks before any sign-in code is sent', () async {
    await seedLocalProgress();
    auth.addressTaken = true;

    final outcome = await flow.sendEmailCode('you@example.com');

    expect(outcome, isA<CodeSent>());
    expect((outcome as CodeSent).link, isFalse);
    expect(confirmations, 1);
    expect(
      labelShown,
      'you@example.com',
      reason: 'the user is told which account they would be signing in as',
    );
    expect(auth.calls, [
      'sendCode:you@example.com:link=true',
      'sendCode:you@example.com:link=false',
    ]);
  });

  test('declining an email replacement sends no code', () async {
    await seedLocalProgress();
    auth.addressTaken = true;
    confirmAnswer = false;

    final outcome = await flow.sendEmailCode('you@example.com');

    expect(outcome, isA<Cancelled>());
    expect(auth.calls, ['sendCode:you@example.com:link=true']);
    expect(await db.select(db.campaignRuns).get(), hasLength(1));
  });

  test('a code is verified against the flow that mailed it', () async {
    await seedLocalProgress();

    // Linking: the code came from an email change, and verifies as one.
    await flow.sendEmailCode('you@example.com');
    await flow.verifyEmailCode(email: 'you@example.com', code: '111111');
    expect(auth.calls.last, 'verify:111111:link=true');

    // Signing in: a different mail, and a different type. Verifying this one as
    // a link would reject six digits the user typed correctly.
    auth.addressTaken = true;
    await flow.sendEmailCode('other@example.com');
    await flow.verifyEmailCode(email: 'other@example.com', code: '222222');
    expect(auth.calls.last, 'verify:222222:link=false');
  });

  test('a cancelled provider sheet is not a failure', () async {
    final outcome = await flow.attach(
      provider: AuthProvider.apple,
      credential: null,
      accountLabel: 'your Apple ID',
    );

    expect(outcome, isA<Cancelled>());
    expect(auth.calls, isEmpty);
  });
}
