import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_practice_cards_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_counts_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'category_word_suggestion.dart';
import 'category_word_suggestion_service.dart';

class CategoryVocabularyState {
  const CategoryVocabularyState({
    this.isSaving = false,
    this.isLoadingSuggestions = false,
    this.suggestions = const <CategoryWordSuggestion>[],
    this.errorMessage,
  });

  final bool isSaving;
  final bool isLoadingSuggestions;
  final List<CategoryWordSuggestion> suggestions;
  final String? errorMessage;

  CategoryVocabularyState copyWith({
    bool? isSaving,
    bool? isLoadingSuggestions,
    List<CategoryWordSuggestion>? suggestions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryVocabularyState(
      isSaving: isSaving ?? this.isSaving,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      suggestions: suggestions ?? this.suggestions,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final categoryVocabularyControllerProvider =
    NotifierProvider<CategoryVocabularyController, CategoryVocabularyState>(
      CategoryVocabularyController.new,
    );

class CategoryVocabularyController extends Notifier<CategoryVocabularyState> {
  @override
  CategoryVocabularyState build() => const CategoryVocabularyState();

  Future<CategoryVocabularyAddResult> addManualWord({
    required String categoryId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? notes,
  }) async {
    final normalizedTerm = _normalize(term);
    if (normalizedTerm.isEmpty || translation.trim().isEmpty) {
      return CategoryVocabularyAddResult.invalid;
    }

    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final bootstrap = await ref.read(localBootstrapProvider.future);
      final repository = bootstrap.repositoryFactory.wordRepository;
      final existingCategoryWords = await repository.loadWordsForWordWorld(
        categoryId: categoryId,
        includeDisabled: true,
      );
      if (existingCategoryWords.any(
        (word) => _normalize(word.term) == normalizedTerm,
      )) {
        state = state.copyWith(isSaving: false);
        return CategoryVocabularyAddResult.duplicateInCategory;
      }

      final existingGlobal = await repository.findWordByTerm(term);
      await repository.addOrLinkWordToWordWorld(
        categoryId: categoryId,
        term: term,
        translation: translation,
        exampleSentence: exampleSentence,
        notes: notes,
      );
      _invalidateCategory(categoryId);
      state = state.copyWith(isSaving: false, clearError: true);
      return existingGlobal == null
          ? CategoryVocabularyAddResult.created
          : CategoryVocabularyAddResult.linkedExisting;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return CategoryVocabularyAddResult.failed;
    }
  }

  Future<void> loadSuggestions({
    required String categoryId,
    required String categoryName,
  }) async {
    state = state.copyWith(
      isLoadingSuggestions: true,
      suggestions: const <CategoryWordSuggestion>[],
      clearError: true,
    );
    try {
      final bootstrap = await ref.read(localBootstrapProvider.future);
      final words = await bootstrap.repositoryFactory.wordRepository
          .loadWordsForWordWorld(categoryId: categoryId, includeDisabled: true);
      final suggestions = await ref
          .read(categoryWordSuggestionServiceProvider)
          .suggestWords(categoryName: categoryName, existingWords: words);
      state = state.copyWith(
        isLoadingSuggestions: false,
        suggestions: suggestions,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingSuggestions: false,
        errorMessage: 'KI-Vorschläge sind gerade nicht verfügbar.',
      );
    }
  }

  void toggleSuggestion(String term, bool selected) {
    state = state.copyWith(
      suggestions: [
        for (final suggestion in state.suggestions)
          suggestion.term == term
              ? suggestion.copyWith(selected: selected)
              : suggestion,
      ],
    );
  }

  Future<int> addSelectedSuggestions({required String categoryId}) async {
    final selected = state.suggestions
        .where((suggestion) => suggestion.selected)
        .toList(growable: false);
    if (selected.isEmpty) return 0;
    state = state.copyWith(isSaving: true, clearError: true);
    var added = 0;
    try {
      for (final suggestion in selected) {
        final result = await addManualWord(
          categoryId: categoryId,
          term: suggestion.term,
          translation: suggestion.translation,
          exampleSentence: suggestion.exampleSentence,
        );
        if (result == CategoryVocabularyAddResult.created ||
            result == CategoryVocabularyAddResult.linkedExisting) {
          added += 1;
        }
      }
      state = state.copyWith(
        isSaving: false,
        suggestions: const <CategoryWordSuggestion>[],
        clearError: true,
      );
      _invalidateCategory(categoryId);
      return added;
    } catch (error) {
      state = state.copyWith(isSaving: false, errorMessage: error.toString());
      return added;
    }
  }

  Future<void> setDisabled({
    required String categoryId,
    required LocalWord word,
    required bool disabled,
  }) async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.wordRepository
        .setWordWorldMembershipDisabled(
          wordId: word.id,
          categoryId: categoryId,
          disabled: disabled,
        );
    _invalidateCategory(categoryId);
  }

  Future<void> markKnown({
    required String categoryId,
    required LocalWord word,
  }) async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.wordRepository
        .setWordWorldMembershipKnown(
          wordId: word.id,
          categoryId: categoryId,
          known: true,
        );
    _invalidateCategory(categoryId);
  }

  Future<void> restoreKnown({
    required String categoryId,
    required LocalWord word,
  }) async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.wordRepository.restoreKnownWord(
      wordId: word.id,
      categoryId: categoryId,
    );
    _invalidateCategory(categoryId);
  }

  void _invalidateCategory(String categoryId) {
    ref
      ..invalidate(localWordsForCategoryProvider(categoryId))
      ..invalidate(
        localWordsForCategoryProvider(LocalLearningSource.knownWords.id),
      )
      ..invalidate(localWordsForSourceProvider(LocalLearningSource.knownWords))
      ..invalidate(localWordCountProvider(categoryId))
      ..invalidate(localWordCountProvider(LocalLearningSource.knownWords.id))
      ..invalidate(localStageCountsProvider)
      ..invalidate(localStageInspectorProvider)
      ..invalidate(localPracticeCardsProvider);
  }

  String _normalize(String value) {
    return value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
  }
}

enum CategoryVocabularyAddResult {
  created,
  linkedExisting,
  duplicateInCategory,
  invalid,
  failed,
}
