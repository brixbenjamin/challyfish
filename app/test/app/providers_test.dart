import 'package:feral/src/app/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test/test.dart';

import '../data/identity_repository_test.dart' show FakeAuthGateway;

void main() {
  test('the user id is read from the session, not from launch', () {
    final auth = FakeAuthGateway();
    final container = ProviderContainer.test(
      overrides: [authGatewayProvider.overrideWithValue(auth)],
    );

    expect(container.read(userIdProvider), 'anon-user');

    // Signing in replaces the session, and everything downstream reads rows by
    // user id: a value captured at launch would query the account the user just
    // left and write rows the server would refuse.
    auth.userId = 'existing-user';
    container.invalidate(userIdProvider);

    expect(container.read(userIdProvider), 'existing-user');
  });
}
