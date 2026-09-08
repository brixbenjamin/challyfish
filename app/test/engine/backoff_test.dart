import 'package:feral/src/engine/backoff.dart';
import 'package:test/test.dart';

void main() {
  const b = Backoff.standard;

  test('the first retry is quick', () {
    expect(b.delayFor(1), const Duration(seconds: 2));
  });

  test('each attempt doubles', () {
    expect(b.delayFor(2), const Duration(seconds: 4));
    expect(b.delayFor(3), const Duration(seconds: 8));
    expect(b.delayFor(4), const Duration(seconds: 16));
  });

  test('it stops doubling at the ceiling', () {
    expect(b.delayFor(20), const Duration(minutes: 5));
    expect(b.delayFor(1000), const Duration(minutes: 5));
  });

  test('attempt zero has no delay, because it is the first try', () {
    expect(b.delayFor(0), Duration.zero);
  });

  test(
    'a negative attempt is treated as the first try rather than throwing',
    () {
      expect(b.delayFor(-3), Duration.zero);
    },
  );

  test('the schedule is deterministic', () {
    expect(
      List.generate(6, b.delayFor),
      List.generate(6, b.delayFor),
      reason: 'no jitter — a test that is sometimes right is not a test',
    );
  });
}
