/// The only source of "now" in the application.
///
/// Calling DateTime.now() anywhere else makes day rollover and grading
/// untestable — you cannot write "the user did not open the app for four days"
/// against a clock you do not control.
abstract class Clock {
  DateTime nowUtc();

  /// Waits [duration]. On the clock rather than a bare `Future.delayed` for the
  /// same reason `nowUtc` is: a retry loop that sleeps for real is a loop no
  /// test exercises.
  Future<void> delay(Duration duration);
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  Future<void> delay(Duration duration) => Future<void>.delayed(duration);
}

class FixedClock implements Clock {
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  final DateTime _instant;

  @override
  DateTime nowUtc() => _instant;

  /// Returns immediately. A fixed clock does not advance, so waiting on one is
  /// only ever a way to make a test slow.
  @override
  Future<void> delay(Duration duration) async {}
}
