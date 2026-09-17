/// The result recorded for one day of a run.
///
/// All three are **derived from the user's ticks** (ADR-0030) and produced only
/// by a day the user was actually present for. There is no outcome the product
/// writes on their behalf: ADR-0040 removed `missed`, because an absent
/// calendar day no longer maps to a day of content at all. Absence lives in the
/// gaps between the dates a day was resolved on.
///
/// See docs/product/glossary.md.
enum Outcome {
  done('done'),
  partial('partial'),
  skipped('skipped');

  const Outcome(this.key);

  /// The value stored in Postgres and SQLite. Never change these strings.
  final String key;

  /// Whether this outcome counts against the grade.
  ///
  /// Only `skipped` does: the user turned up and did nothing. It costs the same
  /// as an absent day — the difference is honesty, not consequence — but it can
  /// never end a run, because showing up is not absence (ADR-0040).
  bool get isMiss => this == Outcome.skipped;

  static Outcome fromKey(String key) {
    for (final outcome in Outcome.values) {
      if (outcome.key == key) return outcome;
    }
    throw ArgumentError.value(key, 'key', 'Unknown outcome');
  }
}
