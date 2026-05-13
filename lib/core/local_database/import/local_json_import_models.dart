class LocalJsonImportCategory {
  const LocalJsonImportCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isArchived,
    required this.words,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final int sortOrder;
  final bool isArchived;
  final List<LocalJsonImportWord> words;

  factory LocalJsonImportCategory.fromJson(Map<String, Object?> json) {
    return LocalJsonImportCategory(
      id: _requiredString(json, 'id'),
      name: _requiredString(json, 'name'),
      description: json['description'] as String?,
      sortOrder: _requiredInt(json, 'sort_order'),
      isArchived: _optionalBool(json, 'is_archived') ?? false,
      words: _requiredList(json, 'words')
          .map(
            (word) => LocalJsonImportWord.fromJson(
              _requiredMap(word, 'words item'),
            ),
          )
          .toList(growable: false),
    );
  }
}

class LocalJsonImportWord {
  const LocalJsonImportWord({
    required this.id,
    required this.term,
    required this.translation,
    required this.sortOrder,
    required this.isArchived,
    this.exampleSentence,
    this.notes,
  });

  final String id;
  final String term;
  final String translation;
  final String? exampleSentence;
  final String? notes;
  final int sortOrder;
  final bool isArchived;

  factory LocalJsonImportWord.fromJson(Map<String, Object?> json) {
    return LocalJsonImportWord(
      id: _requiredString(json, 'id'),
      term: _requiredString(json, 'term'),
      translation: _requiredString(json, 'translation'),
      exampleSentence: json['example_sentence'] as String?,
      notes: json['notes'] as String?,
      sortOrder: _requiredInt(json, 'sort_order'),
      isArchived: _optionalBool(json, 'is_archived') ?? false,
    );
  }
}

String _requiredString(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Expected non-empty string for "$key".');
  }
  return value;
}

int _requiredInt(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('Expected int for "$key".');
  }
  return value;
}

bool? _optionalBool(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value == null) {
    return null;
  }
  if (value is! bool) {
    throw FormatException('Expected bool for "$key".');
  }
  return value;
}

List<Object?> _requiredList(Map<String, Object?> json, String key) {
  final value = json[key];
  if (value is! List<Object?>) {
    throw FormatException('Expected list for "$key".');
  }
  return value;
}

Map<String, Object?> _requiredMap(Object? value, String context) {
  if (value is! Map<String, Object?>) {
    throw FormatException('Expected object for "$context".');
  }
  return value;
}
