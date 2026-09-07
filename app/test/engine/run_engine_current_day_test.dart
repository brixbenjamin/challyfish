import 'package:feral/src/engine/run_engine.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

void main() {
  // `berlin`/`losAngeles` below are resolved at declaration time, before any
  // setUpAll callback runs — so the database must be loaded synchronously
  // here rather than deferred to setUpAll.
  tzdata.initializeTimeZones();

  const engine = RunEngine();
  final berlin = tz.getLocation('Europe/Berlin');
  final losAngeles = tz.getLocation('America/Los_Angeles');

  int dayFor(
    DateTime startedAt,
    DateTime now,
    tz.Location zone, {
    int length = 21,
  }) => engine.currentDay(
    startedAt: startedAt,
    zone: zone,
    now: now,
    lengthDays: length,
  );

  test('the day a run starts is day 1', () {
    final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
    expect(dayFor(start, start, berlin), 1);
  });

  test('later the same local day is still day 1', () {
    final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
    final later = tz.TZDateTime(berlin, 2026, 6, 1, 23, 59).toUtc();
    expect(dayFor(start, later, berlin), 1);
  });

  test(
    'one minute past local midnight is day 2, even though 2 hours elapsed',
    () {
      final start = tz.TZDateTime(berlin, 2026, 6, 1, 22).toUtc();
      final later = tz.TZDateTime(berlin, 2026, 6, 2, 0, 1).toUtc();
      expect(dayFor(start, later, berlin), 2);
    },
  );

  test('spring forward: a 23-hour day still counts as exactly one day', () {
    // Europe/Berlin springs forward on 2026-03-29.
    final start = tz.TZDateTime(berlin, 2026, 3, 28, 12).toUtc();
    final next = tz.TZDateTime(berlin, 2026, 3, 29, 12).toUtc();
    expect(
      next.difference(start).inHours,
      23,
      reason: 'sanity: the DST gap exists',
    );
    expect(dayFor(start, next, berlin), 2);
  });

  test('fall back: a 25-hour day still counts as exactly one day', () {
    // Europe/Berlin falls back on 2026-10-25.
    final start = tz.TZDateTime(berlin, 2026, 10, 24, 12).toUtc();
    final next = tz.TZDateTime(berlin, 2026, 10, 25, 12).toUtc();
    expect(
      next.difference(start).inHours,
      25,
      reason: 'sanity: the DST overlap exists',
    );
    expect(dayFor(start, next, berlin), 2);
  });

  test('travelling west does not retroactively advance the day', () {
    // Starts 09:00 in Berlin; nine hours later it is still 2026-06-01 in LA.
    final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
    final later = start.add(const Duration(hours: 9));
    expect(dayFor(start, later, losAngeles), 1);
  });

  test('the day index is capped at the campaign length', () {
    final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
    final wayLater = tz.TZDateTime(berlin, 2026, 12, 1, 9).toUtc();
    expect(dayFor(start, wayLater, berlin, length: 21), 21);
  });

  test(
    'a clock behind the start still yields day 1, never zero or negative',
    () {
      final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
      final before = tz.TZDateTime(berlin, 2026, 5, 30, 9).toUtc();
      expect(dayFor(start, before, berlin), 1);
    },
  );
}
