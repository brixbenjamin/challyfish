/// The permanent result of a finished run. Derived from miss count; never
/// awarded, never revoked, never reset.
///
/// These keys are stored in Postgres and SQLite. They are wire values, not
/// display names — the words a user sees ("Sovereign", "Passed", "Broken") are
/// ARB keys and may be reworded freely, while renaming a key here would be a
/// data migration (ADR-0021, ADR-0022). Do not add a `label` getter to this
/// enum.
enum Grade {
  sovereign('sovereign'),
  passed('passed'),
  broken('broken');

  const Grade(this.key);

  final String key;

  /// Only Sovereign and Passed earn the campaign's archetype mark. A Broken run
  /// still contributes every done and partial day to the archetype balance —
  /// effort is never erased, only the mark is withheld (ADR-0003).
  bool get earnsMark => this != Grade.broken;

  static Grade fromKey(String key) {
    for (final grade in Grade.values) {
      if (grade.key == key) return grade;
    }
    throw ArgumentError.value(key, 'key', 'Unknown grade');
  }
}
