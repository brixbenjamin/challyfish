class Pack {
  const Pack({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.isCore,
    required this.sort,
    this.storeProductId,
    this.coverPath,
  });

  final String id;
  final String key;
  final String title;
  final String description;

  /// The free pack. Exactly one exists.
  final bool isCore;
  final String? storeProductId;
  final String? coverPath;
  final int sort;
}
