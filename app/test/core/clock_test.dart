import 'package:feral/src/core/clock.dart';
import 'package:test/test.dart';

void main() {
  test('FixedClock returns exactly what it was given, in UTC', () {
    final instant = DateTime.utc(2026, 3, 29, 5, 30);
    final clock = FixedClock(instant);

    expect(clock.nowUtc(), instant);
    expect(clock.nowUtc().isUtc, isTrue);
  });

  test('FixedClock normalizes a local input to UTC', () {
    final clock = FixedClock(DateTime(2026, 3, 29, 5, 30));
    expect(clock.nowUtc().isUtc, isTrue);
  });

  test('SystemClock returns a UTC instant', () {
    expect(const SystemClock().nowUtc().isUtc, isTrue);
  });
}
