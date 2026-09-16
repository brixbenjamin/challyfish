import 'package:feral/src/data/remote/auth_gateway.dart';
import 'package:feral/src/domain/identity.dart';

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
