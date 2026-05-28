import 'package:flutter/foundation.dart';

@immutable
class CategoryWordSuggestion {
  const CategoryWordSuggestion({
    required this.term,
    required this.translation,
    this.exampleSentence,
    this.selected = true,
  });

  final String term;
  final String translation;
  final String? exampleSentence;
  final bool selected;

  CategoryWordSuggestion copyWith({bool? selected}) {
    return CategoryWordSuggestion(
      term: term,
      translation: translation,
      exampleSentence: exampleSentence,
      selected: selected ?? this.selected,
    );
  }
}
