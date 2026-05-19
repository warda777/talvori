import 'translation_status.dart';

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
    this.translationStatus = TranslationStatus.translated,
    this.exampleSentence,
    this.notes,
    this.sourceLanguage,
    this.targetLanguage,
    this.translationError,
  });

  final String id;
  final String categoryId;
  final String term;
  final String translation;
  final TranslationStatus translationStatus;
  final String? sourceLanguage;
  final String? targetLanguage;
  final String? translationError;
  final String? exampleSentence;
  final String? notes;
  final int sortOrder;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
}
