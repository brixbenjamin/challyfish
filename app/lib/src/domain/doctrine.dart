class DoctrineGroup {
  const DoctrineGroup({
    required this.id,
    required this.title,
    required this.sort,
    this.blurb,
  });

  final String id;
  final String title;
  final String? blurb;
  final int sort;
}

class DoctrineEntry {
  const DoctrineEntry({
    required this.id,
    required this.groupId,
    required this.title,
    required this.bodyMd,
    required this.sort,
    this.relatedArchetypeId,
  });

  final String id;
  final String groupId;
  final String title;
  final String bodyMd;
  final String? relatedArchetypeId;
  final int sort;
}
