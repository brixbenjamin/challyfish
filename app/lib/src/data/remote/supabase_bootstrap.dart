import 'package:supabase_flutter/supabase_flutter.dart';

/// Only the URL and the publishable anon key may exist in the client. Both are
/// safe to ship, because row-level security is what actually protects data. The
/// service role key never leaves the server.
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

Future<void> initializeSupabase() async {
  // `anonKey` is the brief's parameter name but is a deprecated alias for
  // `publishableKey` as of supabase_flutter 2.17; using `publishableKey` here
  // keeps `flutter analyze` clean without changing any value later tasks
  // depend on (the env var names and the supabaseAnonKey constant stay as
  // specified).
  await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseAnonKey);
}

/// Returns the current user id, creating an anonymous session if there is none.
///
/// No account screen, no prompt: nothing stands between install and the first
/// screen (ADR-0007). Losing the device before linking an identity loses the
/// progress — that is a known, accepted edge (Q7), and the reason the linking
/// prompt exists in Plan 3.
///
/// This is the one genuinely blocking failure in the product — the app cannot
/// proceed without a local user id (docs/design/user-flows.md, "Anonymous
/// session creation fails") — so a failed attempt retries with backoff instead
/// of throwing. Nothing in this task's scope hands back a give-up state, so the
/// retry does not stop on its own; it keeps trying, with the delay between
/// attempts capped, until a session is created or the process is killed. There
/// is deliberately no attempt cap and no distinction between failure causes —
/// the brief specifies retry-not-crash but not a schedule, and adding either
/// would be inventing policy the brief doesn't ask for.
Future<String> ensureAnonymousSession() async {
  final auth = Supabase.instance.client.auth;

  final existing = auth.currentUser;
  if (existing != null) return existing.id;

  var attempt = 0;
  while (true) {
    try {
      final response = await auth.signInAnonymously();
      final user = response.user;
      if (user == null) {
        throw StateError('Anonymous sign-in returned no user');
      }
      return user.id;
    } catch (_) {
      attempt++;
      await Future<void>.delayed(_retryDelay(attempt));
    }
  }
}

/// Exponential backoff between anonymous sign-in attempts, capped at 30s so a
/// long outage still retries at a steady, bounded interval rather than sleeping
/// for hours.
Duration _retryDelay(int attempt) {
  final seconds = 1 << attempt.clamp(0, 5);
  return Duration(seconds: seconds.clamp(1, 30));
}
