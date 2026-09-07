/// The only source of "now" in the application.
///
/// Calling DateTime.now() anywhere else makes day rollover and grading
/// untestable — you cannot write "the user did not open the app for four days"
/// against a clock you do not control.
abstract class Clock {
  DateTime nowUtc();
}

class SystemClock implements Clock {
  const SystemClock();

  @override
  DateTime nowUtc() => DateTime.now().toUtc();
}

class FixedClock implements Clock {
  FixedClock(DateTime instant) : _instant = instant.toUtc();

  final DateTime _instant;

  @override
  DateTime nowUtc() => _instant;
}
