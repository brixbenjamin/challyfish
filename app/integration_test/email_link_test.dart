import 'dart:convert';
import 'dart:io';

import 'package:feral/src/data/remote/auth_gateway.dart';
import 'package:feral/src/domain/identity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Email identity against a real GoTrue, including the mailbox.
///
/// Everything here is a rule a fake gateway can assert but could never have
/// discovered: that attaching an address keeps the user id rather than moving
/// the record to a new one, that an address belonging to someone else is
/// refused before a single mail is sent, and — the one that rejects a perfectly
/// correct code — which OTP type each of the two flows verifies against.
///
/// Requires the local stack (`supabase start`). The code is read out of Mailpit
/// exactly as a user reads it out of their inbox; nothing here knows a token
/// the app would not have.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const mailpit = 'http://127.0.0.1:54324';

  late SupabaseClient client;
  late SupabaseAuthGateway gateway;

  /// A fresh address per run: these users persist in the local stack, and a
  /// reused address would make the second run test the first run's leftovers.
  String freshAddress(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}@example.com';

  Future<dynamic> mailpitJson(String path) async {
    final http = HttpClient();
    try {
      final request = await http.getUrl(Uri.parse('$mailpit$path'));
      final response = await request.close();
      return jsonDecode(await response.transform(utf8.decoder).join());
    } finally {
      http.close();
    }
  }

  Future<List<dynamic>> messagesTo(String address) async {
    final result = await mailpitJson(
      '/api/v1/search?query=${Uri.encodeQueryComponent('to:$address')}',
    );
    return (result as Map<String, dynamic>)['messages'] as List<dynamic>;
  }

  /// Polls the inbox the way a user refreshes it, then reads the six digits.
  Future<String> codeSentTo(String address) async {
    for (var attempt = 0; attempt < 20; attempt++) {
      final messages = await messagesTo(address);
      if (messages.isNotEmpty) {
        final id = (messages.first as Map<String, dynamic>)['ID'];
        final message =
            await mailpitJson('/api/v1/message/$id') as Map<String, dynamic>;
        final body = '${message['Text'] ?? ''}${message['HTML'] ?? ''}';
        final code = RegExp(r'\b\d{6}\b').firstMatch(body);
        if (code != null) return code.group(0)!;
        fail('the mail for $address carries no six-digit code:\n$body');
      }
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    fail('no mail arrived for $address');
  }

  setUpAll(() async {
    await Supabase.initialize(
      url: const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'http://127.0.0.1:54321',
      ),
      publishableKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
    );
    client = Supabase.instance.client;
    gateway = SupabaseAuthGateway(client);
  });

  setUp(() async {
    // Every case starts where a user starts: an anonymous record on a phone.
    await client.auth.signOut();
    await client.auth.signInAnonymously();
  });

  testWidgets('attaching a free address keeps the record it is attached to', (
    tester,
  ) async {
    final address = freshAddress('link');
    final anonymousId = gateway.currentUserId;

    await gateway.sendEmailCode(address, link: true);
    final userId = await gateway.verifyEmailCode(
      email: address,
      code: await codeSentTo(address),
      link: true,
    );

    expect(
      userId,
      anonymousId,
      reason: 'the record stays put; only its owner is now named',
    );
    expect(gateway.linkedIdentity, isNotNull);
    expect(gateway.linkedIdentity!.provider, AuthProvider.email);
    expect(gateway.linkedIdentity!.label, address);
  });

  testWidgets('an address that already has an account is refused, silently', (
    tester,
  ) async {
    final address = freshAddress('taken');
    await gateway.sendEmailCode(address, link: true);
    await gateway.verifyEmailCode(
      email: address,
      code: await codeSentTo(address),
      link: true,
    );
    final mailSoFar = (await messagesTo(address)).length;

    // A second phone, a second anonymous record, the same address.
    await client.auth.signOut();
    await client.auth.signInAnonymously();

    await expectLater(
      gateway.sendEmailCode(address, link: true),
      throwsA(isA<IdentityAlreadyAttached>()),
    );
    expect(
      (await messagesTo(address)).length,
      mailSoFar,
      reason: 'nothing was sent: the branch is decided before the mail is',
    );
  });

  testWidgets('the account that owns the address signs back in with a code', (
    tester,
  ) async {
    final address = freshAddress('signin');
    await gateway.sendEmailCode(address, link: true);
    final ownerId = await gateway.verifyEmailCode(
      email: address,
      code: await codeSentTo(address),
      link: true,
    );

    await client.auth.signOut();
    await client.auth.signInAnonymously();
    final strandedId = gateway.currentUserId;

    await gateway.sendEmailCode(address, link: false);
    final signedInId = await gateway.verifyEmailCode(
      email: address,
      code: await codeSentTo(address),
      link: false,
    );

    expect(signedInId, ownerId);
    expect(
      signedInId,
      isNot(strandedId),
      reason: 'this is the branch where the anonymous record is left behind',
    );
  });

  testWidgets('signing in to an address nobody owns creates no account', (
    tester,
  ) async {
    // Otherwise a typo on the sign-in branch would quietly strand the record
    // this device is holding in a brand new, empty account.
    final address = freshAddress('nobody');

    await expectLater(
      gateway.sendEmailCode(address, link: false),
      throwsA(anything),
    );
    expect(await messagesTo(address), isEmpty);
  });
}
