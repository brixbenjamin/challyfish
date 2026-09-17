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

  DateTime dateOf(DateTime instant, tz.Location zone) =>
      engine.localDateOf(instant: instant, zone: zone);

  test('an instant reduces to the local calendar date it falls on', () {
    final at9 = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
    expect(dateOf(at9, berlin), DateTime.utc(2026, 6, 1));
  });

  test('late evening is still the same date', () {
    final late = tz.TZDateTime(berlin, 2026, 6, 1, 23, 59).toUtc();
    expect(dateOf(late, berlin), DateTime.utc(2026, 6, 1));
  });

  test('one minute past local midnight is the next date', () {
    // Two hours after 22:00, but a day boundary is a calendar change rather
    // than 24 elapsed hours.
    final justAfter = tz.TZDateTime(berlin, 2026, 6, 2, 0, 1).toUtc();
    expect(dateOf(justAfter, berlin), DateTime.utc(2026, 6, 2));
  });

  test('spring forward: a 23-hour day is still exactly one date apart', () {
    // Europe/Berlin springs forward on 2026-03-29.
    final start = tz.TZDateTime(berlin, 2026, 3, 28, 12).toUtc();
    final next = tz.TZDateTime(berlin, 2026, 3, 29, 12).toUtc();
    expect(
      next.difference(start).inHours,
      23,
      reason: 'sanity: the DST gap exists',
    );
    expect(dateOf(next, berlin).difference(dateOf(start, berlin)).inDays, 1);
  });

  test('fall back: a 25-hour day is still exactly one date apart', () {
    // Europe/Berlin falls back on 2026-10-25.
    final start = tz.TZDateTime(berlin, 2026, 10, 24, 12).toUtc();
    final next = tz.TZDateTime(berlin, 2026, 10, 25, 12).toUtc();
    expect(
      next.difference(start).inHours,
      25,
      reason: 'sanity: the DST overlap exists',
    );
    expect(dateOf(next, berlin).difference(dateOf(start, berlin)).inDays, 1);
  });

  test('travelling west does not advance the date', () {
    // 09:00 in Berlin; nine hours later it is still 2026-06-01 in LA.
    final start = tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc();
    final later = start.add(const Duration(hours: 9));
    expect(dateOf(later, losAngeles), DateTime.utc(2026, 6, 1));
  });

  test('the date carries no time and no offset of its own', () {
    // Absence is counted by subtracting these, so anything below a day would
    // make two dates in different offsets compare unequal.
    final date = dateOf(tz.TZDateTime(berlin, 2026, 6, 1, 9).toUtc(), berlin);
    expect(date.isUtc, isTrue);
    expect(date.hour, 0);
    expect(date.minute, 0);
    expect(date.second, 0);
    expect(date.millisecond, 0);
    expect(date.microsecond, 0);
  });

  test('a date already stored survives a change of zone unchanged', () {
    // The promise in user-stories.md: travel never retroactively converts a
    // past day into a miss. A stamped date is a fact, not a recomputation.
    // 01:00 on the 2nd in Berlin is still the afternoon of the 1st in LA, so
    // the two zones genuinely disagree about which day this act happened on.
    final instant = tz.TZDateTime(berlin, 2026, 6, 2, 1).toUtc();
    final stamped = dateOf(instant, berlin);
    expect(stamped, DateTime.utc(2026, 6, 2));
    // Re-deriving it after a flight would move the user's day underneath them.
    // Stamping it once is what makes that impossible.
    expect(dateOf(instant, losAngeles), DateTime.utc(2026, 6, 1));
    expect(stamped, DateTime.utc(2026, 6, 2));
  });
}
