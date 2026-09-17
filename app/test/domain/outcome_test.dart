import 'package:feral/src/domain/outcome.dart';
import 'package:test/test.dart';

void main() {
  test('every outcome round-trips through its wire key', () {
    for (final outcome in Outcome.values) {
      expect(Outcome.fromKey(outcome.key), outcome);
    }
  });

  test('wire keys are exactly the three the schema allows', () {
    expect(Outcome.values.map((o) => o.key).toSet(), {
      'done',
      'partial',
      'skipped',
    });
  });

  test('skipped is the only outcome that is a miss', () {
    // ADR-0040 removed `missed`: an absent day has no outcome to carry,
    // because it has no day log at all.
    expect(Outcome.skipped.isMiss, isTrue);
    expect(Outcome.done.isMiss, isFalse);
    expect(Outcome.partial.isMiss, isFalse);
  });

  test('an unknown key throws rather than silently becoming a miss', () {
    expect(() => Outcome.fromKey('completed'), throwsArgumentError);
  });
}
