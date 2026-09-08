/// Exponential retry delays, with a ceiling.
///
/// Deliberately without jitter. Jitter matters when many clients retry against
/// one server at the same instant; Feral's sync is per-user and triggered by
/// that user's own app lifecycle, so there is no thundering herd to spread —
/// and a non-deterministic schedule would make this untestable.
class Backoff {
  const Backoff({
    this.base = const Duration(seconds: 1),
    this.max = const Duration(minutes: 5),
  });

  final Duration base;
  final Duration max;

  static const standard = Backoff();

  /// [attempt] is the number of failures so far: 0 for the first try.
  Duration delayFor(int attempt) {
    if (attempt <= 0) return Duration.zero;
    // Cap the exponent before shifting: 1 << 40 overflows into nonsense long
    // before the Duration comparison below would catch it.
    final exponent = attempt > 20 ? 20 : attempt;
    final scaled = base * (1 << exponent);
    return scaled > max ? max : scaled;
  }
}
