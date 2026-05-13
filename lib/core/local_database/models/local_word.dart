class LocalWord {
  const LocalWord({
    required this.id,
    required this.categoryId,
    required this.term,
    required this.translation,
    required this.sortOrder,
    required this.isArchived,
    required this.createdAt,
    required this.updatedAt,
    this.exampleSentence,
    this.notes,
  });

  final String id;
  final String categoryId;
  final String term;
  final String translation;
  final String? exampleSentence;
  final String? notes;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
}
