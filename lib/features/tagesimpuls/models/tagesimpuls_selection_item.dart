class TagesimpulsSelectionItem {
  const TagesimpulsSelectionItem({
    required this.wordId,
    required this.text,
    this.translation,
    this.categoryId,
    required this.addedAt,
  });

  final String wordId;
  final String text;
  final String? translation;
  final String? categoryId;
  final DateTime addedAt;

  String get normalizedText => normalizeText(text);

  bool get hasWordId => wordId.trim().isNotEmpty;

  Map<String, dynamic> toJson() {
    return {
      'wordId': wordId,
      'text': text,
      'translation': translation,
      'categoryId': categoryId,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory TagesimpulsSelectionItem.fromJson(Map<String, dynamic> json) {
    return TagesimpulsSelectionItem(
      wordId: (json['wordId'] as String?)?.trim() ?? '',
      text: (json['text'] as String?)?.trim() ?? '',
      translation: (json['translation'] as String?)?.trim(),
      categoryId: (json['categoryId'] as String?)?.trim(),
      addedAt:
          DateTime.tryParse((json['addedAt'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static String normalizeText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
  }
}
