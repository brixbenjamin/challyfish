/// The result recorded for one day of a run.
///
/// `missed` is written only by day rollover; the other three are user-reported.
/// See docs/product/glossary.md.
enum Outcome {
  done('done'),
  partial('partial'),
  skipped('skipped'),
  missed('missed');

  const Outcome(this.key);

  /// The value stored in Postgres and SQLite. Never change these strings.
  final String key;

  /// A miss counts toward the grade. Whether the user skipped deliberately or
  /// simply let the day roll over is a difference of honesty, not consequence.
  bool get isMiss => this == Outcome.skipped || this == Outcome.missed;

  static Outcome fromKey(String key) {
    for (final outcome in Outcome.values) {
      if (outcome.key == key) return outcome;
    }
    throw ArgumentError.value(key, 'key', 'Unknown outcome');
  }
}
