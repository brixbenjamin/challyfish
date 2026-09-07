/// One of exactly four fixed drives. Four, permanently — this is the
/// progression backbone, not a taxonomy that grows (ADR-0004).
///
/// `key` is a stored wire value; `name`, `blurb` and `color` are content and are
/// what a user sees. No code outside a seed file names a key literal, and the
/// engine's tests deliberately use invented keys, so that "the rules carry no
/// knowledge of this particular taxonomy" is a thing CI checks rather than a
/// thing a document claims (ADR-0021).
class Archetype {
  const Archetype({
    required this.id,
    required this.key,
    required this.name,
    required this.blurb,
    required this.color,
    required this.sort,
  });

  final String id;
  final String key;
  final String name;
  final String blurb;
  final String color;
  final int sort;
}
