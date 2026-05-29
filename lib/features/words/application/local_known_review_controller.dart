import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/words/application/category_vocabulary/category_vocabulary_controller.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/word_world_display_names.dart';

final localKnownReviewControllerProvider =
    AutoDisposeAsyncNotifierProvider<
      LocalKnownReviewController,
      LocalKnownReviewState
    >(LocalKnownReviewController.new);

class LocalKnownReviewCategory {
  const LocalKnownReviewCategory({
    required this.id,
    required this.name,
    required this.remainingCount,
    this.reviewedCount = 0,
    this.knownCount = 0,
    this.totalCount = 0,
  });

  final String id;
  final String name;
  final int remainingCount;
  final int reviewedCount;
  final int knownCount;
  final int totalCount;

  bool get isCompleted => totalCount > 0 && remainingCount == 0;
}

enum LocalKnownReviewSource { wordWorlds, learningLevels, languageTools }

extension LocalKnownReviewSourceLabel on LocalKnownReviewSource {
  String get label => switch (this) {
    LocalKnownReviewSource.wordWorlds => 'Wortwelten',
    LocalKnownReviewSource.learningLevels => 'Lernlevel',
    LocalKnownReviewSource.languageTools => 'Sprachwerkzeuge',
  };
}

class LocalKnownReviewState {
  const LocalKnownReviewState({
    required this.categories,
    required this.words,
    required this.currentIndex,
    this.source = LocalKnownReviewSource.wordWorlds,
    this.selectedCategoryId,
    this.selectedCategoryName,
    this.knownCount = 0,
    this.keepLearningCount = 0,
    this.undoDepth = 0,
    this.isProcessing = false,
  });

  factory LocalKnownReviewState.empty({
    required List<LocalKnownReviewCategory> categories,
  }) {
    return LocalKnownReviewState(
      categories: List.unmodifiable(categories),
      words: const <LocalWord>[],
      currentIndex: 0,
    );
  }

  final LocalKnownReviewSource source;
  final List<LocalKnownReviewCategory> categories;
  final String? selectedCategoryId;
  final String? selectedCategoryName;
  final List<LocalWord> words;
  final int currentIndex;
  final int knownCount;
  final int keepLearningCount;
  final int undoDepth;
  final bool isProcessing;

  LocalWord? get currentWord {
    if (currentIndex < 0 || currentIndex >= words.length) return null;
    return words[currentIndex];
  }

  LocalKnownReviewCategory? get selectedCategory {
    final id = selectedCategoryId;
    if (id == null) return null;
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  bool get hasSelectedCategory => selectedCategoryId != null;
  bool get isCompleted => hasSelectedCategory && currentWord == null;
  bool get canUndo => undoDepth > 0;
  int get totalCount => words.length;
  int get remainingUnreviewedCountForCurrentCategory =>
      selectedCategory?.remainingCount ?? words.length;
  int get progressIndex =>
      totalCount == 0 ? 0 : currentIndex.clamp(0, totalCount - 1).toInt() + 1;

  LocalKnownReviewState copyWith({
    LocalKnownReviewSource? source,
    List<LocalKnownReviewCategory>? categories,
    Object? selectedCategoryId = _sentinel,
    Object? selectedCategoryName = _sentinel,
    List<LocalWord>? words,
    int? currentIndex,
    int? knownCount,
    int? keepLearningCount,
    int? undoDepth,
    bool? isProcessing,
  }) {
    return LocalKnownReviewState(
      source: source ?? this.source,
      categories: List.unmodifiable(categories ?? this.categories),
      selectedCategoryId: selectedCategoryId == _sentinel
          ? this.selectedCategoryId
          : selectedCategoryId as String?,
      selectedCategoryName: selectedCategoryName == _sentinel
          ? this.selectedCategoryName
          : selectedCategoryName as String?,
      words: List.unmodifiable(words ?? this.words),
      currentIndex: currentIndex ?? this.currentIndex,
      knownCount: knownCount ?? this.knownCount,
      keepLearningCount: keepLearningCount ?? this.keepLearningCount,
      undoDepth: undoDepth ?? this.undoDepth,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  static const Object _sentinel = Object();
}

class LocalKnownReviewController
    extends AutoDisposeAsyncNotifier<LocalKnownReviewState> {
  static const _lastCategoryIdKey =
      'talvori_local_known_review_last_category_id_v1';

  final List<_KnownUndoAction> _undoStack = [];
  final Set<String> _knownIds = {};
  final Set<String> _keepLearningIds = {};
  final Set<String> _aboveLineIds = {};
  final Set<String> _reviewedTouchedInSession = {};

  @override
  Future<LocalKnownReviewState> build() async {
    final categories = await _loadReviewCategories();
    final counters = await _loadPersistentCounters();
    if (categories.isNotEmpty) {
      final savedCategoryId = await _loadLastCategoryId();
      final selectedCategory = categories.firstWhere(
        (category) => category.id == savedCategoryId,
        orElse: () => categories.first,
      );
      final words = await _loadWords(selectedCategory.id);
      return LocalKnownReviewState(
        categories: categories,
        selectedCategoryId: selectedCategory.id,
        selectedCategoryName: selectedCategory.name,
        words: List.unmodifiable(words),
        currentIndex: 0,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
      );
    }
    return LocalKnownReviewState.empty(categories: categories).copyWith(
      knownCount: counters.knownCount,
      keepLearningCount: counters.keepLearningCount,
    );
  }

  Future<void> selectCategory(LocalKnownReviewCategory category) async {
    _clearSessionState();
    await _saveLastCategoryId(category.id);
    final words = await _loadWords(category.id);
    final categories = await _loadReviewCategories();
    final counters = await _loadPersistentCounters();
    state = AsyncData(
      LocalKnownReviewState(
        categories: categories,
        selectedCategoryId: category.id,
        selectedCategoryName: category.name,
        words: List.unmodifiable(words),
        currentIndex: 0,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
      ),
    );
  }

  Future<void> setReviewSource(LocalKnownReviewSource source) async {
    _clearSessionState();
    final counters = await _loadPersistentCounters();
    if (source != LocalKnownReviewSource.wordWorlds) {
      state = AsyncData(
        LocalKnownReviewState(
          source: source,
          categories: const <LocalKnownReviewCategory>[],
          words: const <LocalWord>[],
          currentIndex: 0,
          knownCount: counters.knownCount,
          keepLearningCount: counters.keepLearningCount,
        ),
      );
      return;
    }

    final categories = await _loadReviewCategories();
    if (categories.isEmpty) {
      state = AsyncData(
        LocalKnownReviewState.empty(categories: categories).copyWith(
          source: source,
          knownCount: counters.knownCount,
          keepLearningCount: counters.keepLearningCount,
        ),
      );
      return;
    }

    final savedCategoryId = await _loadLastCategoryId();
    final selectedCategory = categories.firstWhere(
      (category) => category.id == savedCategoryId,
      orElse: () => categories.first,
    );
    final words = await _loadWords(selectedCategory.id);
    state = AsyncData(
      LocalKnownReviewState(
        source: source,
        categories: categories,
        selectedCategoryId: selectedCategory.id,
        selectedCategoryName: selectedCategory.name,
        words: List.unmodifiable(words),
        currentIndex: 0,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
      ),
    );
  }

  Future<LocalWord?> markCurrentKnown() async {
    final currentState = state.valueOrNull;
    final categoryId = currentState?.selectedCategoryId;
    final word = currentState?.currentWord;
    if (currentState == null || categoryId == null || word == null) {
      return null;
    }

    state = AsyncData(currentState.copyWith(isProcessing: true));
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final wasReviewedForLearning = await bootstrap
        .repositoryFactory
        .wordRepository
        .isReviewedForLearning(wordId: word.id, categoryId: categoryId);
    await ref
        .read(categoryVocabularyControllerProvider.notifier)
        .markKnown(categoryId: categoryId, word: word);
    final wasAboveLine = _aboveLineIds.contains(word.id);
    _undoStack.add(
      _KnownUndoAction(
        categoryId: categoryId,
        word: word,
        wasAboveLine: wasAboveLine,
        restoreReviewedOnUndo: wasReviewedForLearning || wasAboveLine,
      ),
    );
    _knownIds.add(word.id);
    _keepLearningIds.remove(word.id);
    _aboveLineIds.remove(word.id);
    _reviewedTouchedInSession.remove(word.id);
    final categories = await _loadReviewCategories();
    final counters = await _loadPersistentCounters();
    final words = currentState.words
        .where((item) => item.id != word.id)
        .toList(growable: false);
    final nextIndex = currentState.currentIndex
        .clamp(0, (words.length - 1).clamp(0, 1 << 30))
        .toInt();
    state = AsyncData(
      currentState.copyWith(
        categories: categories,
        words: words,
        currentIndex: nextIndex,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
        undoDepth: _undoStack.length,
        isProcessing: false,
      ),
    );
    return word;
  }

  Future<void> markKeepLearning(LocalWord word) async {
    final currentState = state.valueOrNull;
    final categoryId = currentState?.selectedCategoryId;
    if (currentState == null ||
        categoryId == null ||
        !currentState.words.any((w) => w.id == word.id)) {
      return;
    }
    _aboveLineIds.add(word.id);
    if (_knownIds.contains(word.id)) return;
    if (!_keepLearningIds.add(word.id)) return;
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final wasAlreadyReviewed = await bootstrap.repositoryFactory.wordRepository
        .isReviewedForLearning(wordId: word.id, categoryId: categoryId);
    await bootstrap.repositoryFactory.wordRepository.markReviewedForLearning(
      wordId: word.id,
      categoryId: categoryId,
    );
    ref
      ..invalidate(
        localWordsForSourceProvider(LocalLearningSource.reviewedForLearning),
      )
      ..invalidate(
        localWordCountProvider(LocalLearningSource.reviewedForLearning.id),
      );
    if (!wasAlreadyReviewed) {
      _reviewedTouchedInSession.add(word.id);
    }
    final categories = await _loadReviewCategories();
    final counters = await _loadPersistentCounters();
    final latestState = state.valueOrNull;
    if (latestState == null) return;
    state = AsyncData(
      latestState.copyWith(
        categories: categories,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
      ),
    );
  }

  Future<void> unmarkKeepLearning(LocalWord word) async {
    final currentState = state.valueOrNull;
    final categoryId = currentState?.selectedCategoryId;
    if (currentState == null || categoryId == null) return;
    _aboveLineIds.remove(word.id);
    if (!_keepLearningIds.remove(word.id)) return;
    if (_reviewedTouchedInSession.remove(word.id)) {
      final bootstrap = await ref.read(localBootstrapProvider.future);
      await bootstrap.repositoryFactory.wordRepository
          .restoreReviewedForLearning(wordId: word.id, categoryId: categoryId);
      ref
        ..invalidate(
          localWordsForSourceProvider(LocalLearningSource.reviewedForLearning),
        )
        ..invalidate(
          localWordCountProvider(LocalLearningSource.reviewedForLearning.id),
        );
    }
    final categories = await _loadReviewCategories();
    final counters = await _loadPersistentCounters();
    final latestState = state.valueOrNull;
    if (latestState == null) return;
    state = AsyncData(
      latestState.copyWith(
        categories: categories,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
      ),
    );
  }

  void setCurrentWord(LocalWord word) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    final index = currentState.words.indexWhere((item) => item.id == word.id);
    if (index == -1 || index == currentState.currentIndex) return;
    state = AsyncData(currentState.copyWith(currentIndex: index));
  }

  void completeCurrentCategoryReview() {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.words.isEmpty) return;
    if (currentState.currentIndex == currentState.words.length) return;
    state = AsyncData(
      currentState.copyWith(currentIndex: currentState.words.length),
    );
  }

  Future<void> resetSelectedCategoryReview() async {
    final currentState = state.valueOrNull;
    final categoryId = currentState?.selectedCategoryId;
    if (currentState == null || categoryId == null) return;
    final bootstrap = await ref.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.wordRepository.resetCategoryReview(
      categoryId: categoryId,
    );
    _clearSessionState();
    await _reloadSelectedCategory(
      currentState,
      categoryId: categoryId,
      currentIndex: 0,
    );
  }

  Future<void> refreshCurrentCategory() async {
    final currentState = state.valueOrNull;
    final categoryId = currentState?.selectedCategoryId;
    if (currentState == null || categoryId == null) return;
    await _reloadSelectedCategory(
      currentState,
      categoryId: categoryId,
      currentIndex: currentState.currentIndex,
    );
  }

  Future<void> restoreKnown({
    required String categoryId,
    required LocalWord word,
  }) async {
    await ref
        .read(categoryVocabularyControllerProvider.notifier)
        .restoreKnown(categoryId: categoryId, word: word);
    final currentState = state.valueOrNull;
    if (currentState?.selectedCategoryId == categoryId) {
      final categories = await _loadReviewCategories();
      final words = await _loadWords(categoryId);
      final counters = await _loadPersistentCounters();
      state = AsyncData(
        currentState!.copyWith(
          categories: categories,
          words: words,
          currentIndex: 0,
          knownCount: counters.knownCount,
          keepLearningCount: counters.keepLearningCount,
          isProcessing: false,
        ),
      );
    }
  }

  Future<void> undoLastKnown() async {
    if (_undoStack.isEmpty) return;
    final action = _undoStack.removeLast();
    await ref
        .read(categoryVocabularyControllerProvider.notifier)
        .restoreKnown(categoryId: action.categoryId, word: action.word);

    final currentState = state.valueOrNull;
    if (currentState == null) return;

    if (currentState.selectedCategoryId != action.categoryId) {
      _knownIds.remove(action.word.id);
      if (action.wasAboveLine) {
        _aboveLineIds.add(action.word.id);
        _keepLearningIds.add(action.word.id);
      }
      if (action.restoreReviewedOnUndo) {
        await _restoreReviewedForAction(action);
      }
      final counters = await _loadPersistentCounters();
      state = AsyncData(
        currentState.copyWith(
          knownCount: counters.knownCount,
          keepLearningCount: counters.keepLearningCount,
          undoDepth: _undoStack.length,
          isProcessing: false,
        ),
      );
      return;
    }

    final nextWords = [...currentState.words];
    final insertIndex = currentState.currentIndex
        .clamp(0, nextWords.length)
        .toInt();
    nextWords.insert(insertIndex, action.word);
    _knownIds.remove(action.word.id);
    if (action.wasAboveLine) {
      _aboveLineIds.add(action.word.id);
      _keepLearningIds.add(action.word.id);
    }
    if (action.restoreReviewedOnUndo) {
      await _restoreReviewedForAction(action);
    }
    final counters = await _loadPersistentCounters();
    state = AsyncData(
      currentState.copyWith(
        words: nextWords,
        currentIndex: insertIndex,
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
        undoDepth: _undoStack.length,
        isProcessing: false,
      ),
    );
  }

  Future<List<LocalKnownReviewCategory>> _loadReviewCategories() async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final categories = await repositories.categoryRepository.loadCategories();
    final categoryByKey = <String, LocalCategory>{
      for (final category in categories) ...{
        _categoryKey(category.id): category,
        _categoryKey(category.name): category,
        _categoryKey(_displayCategoryName(category)): category,
      },
    };
    final reviewCategories = <LocalKnownReviewCategory>[];

    for (final section in wordWorldHubSections) {
      for (final subcat in section.subcats) {
        final category = _resolveWordWorldCategory(subcat, categoryByKey);
        if (category == null || _isExcludedReviewCategory(category)) continue;
        if (reviewCategories.any((item) => item.id == category.id)) continue;

        await repositories.wordRepository.ensureWordWorldMembershipsForCategory(
          categoryId: category.id,
        );
        final stats = await repositories.wordRepository
            .loadWordWorldReviewStats(categoryId: category.id);
        if (stats.totalCount == 0) continue;

        reviewCategories.add(
          LocalKnownReviewCategory(
            id: category.id,
            name: wordHubItemDisplayName(
              subcat.key,
              fallbackName: subcat.label,
              nativeLanguage: 'de',
            ),
            remainingCount: stats.unknownCount,
            reviewedCount: stats.reviewedCount,
            knownCount: stats.knownCount,
            totalCount: stats.totalCount,
          ),
        );
      }
    }

    return List.unmodifiable(reviewCategories);
  }

  Future<String?> _loadLastCategoryId() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_lastCategoryIdKey)?.trim();
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> _saveLastCategoryId(String categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastCategoryIdKey, categoryId);
  }

  LocalCategory? _resolveWordWorldCategory(
    HubSubcat subcat,
    Map<String, LocalCategory> categoryByKey,
  ) {
    final candidateKeys = <String>{
      subcat.key,
      subcat.label,
      wordHubItemDisplayName(
        subcat.key,
        fallbackName: subcat.label,
        nativeLanguage: 'de',
      ),
      'seed-category-${subcat.key.replaceAll('_', '-')}',
    };

    for (final key in candidateKeys) {
      final category = categoryByKey[_categoryKey(key)];
      if (category != null) return category;
    }

    return null;
  }

  Future<List<LocalWord>> _loadWords(String categoryId) async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final repository = bootstrap.repositoryFactory.wordRepository;
    await repository.ensureWordWorldMembershipsForCategory(
      categoryId: categoryId,
    );
    return repository.loadUnknownWordsForReview(categoryId: categoryId);
  }

  bool _isExcludedReviewCategory(LocalCategory category) {
    return category.id == LocalLearningSource.knownWords.id ||
        category.id == LocalLearningSource.reviewedForLearning.id;
  }

  void _clearSessionState() {
    _undoStack.clear();
    _knownIds.clear();
    _keepLearningIds.clear();
    _aboveLineIds.clear();
    _reviewedTouchedInSession.clear();
  }

  Future<_PersistentReviewCounters> _loadPersistentCounters() async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    final repository = bootstrap.repositoryFactory.wordRepository;
    final knownCount = await repository.countKnownWords();
    final keepLearningCount = await repository.countReviewedForLearningWords();
    return _PersistentReviewCounters(
      knownCount: knownCount,
      keepLearningCount: keepLearningCount,
    );
  }

  Future<void> _restoreReviewedForAction(_KnownUndoAction action) async {
    final bootstrap = await ref.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.wordRepository.markReviewedForLearning(
      wordId: action.word.id,
      categoryId: action.categoryId,
    );
    _reviewedTouchedInSession.add(action.word.id);
  }

  Future<void> _reloadSelectedCategory(
    LocalKnownReviewState currentState, {
    required String categoryId,
    required int currentIndex,
  }) async {
    final categories = await _loadReviewCategories();
    LocalKnownReviewCategory? category;
    for (final item in categories) {
      if (item.id == categoryId) {
        category = item;
        break;
      }
    }
    final words = await _loadWords(categoryId);
    final counters = await _loadPersistentCounters();
    state = AsyncData(
      currentState.copyWith(
        categories: categories,
        selectedCategoryName:
            category?.name ?? currentState.selectedCategoryName,
        words: words,
        currentIndex: currentIndex.clamp(0, words.length).toInt(),
        knownCount: counters.knownCount,
        keepLearningCount: counters.keepLearningCount,
        undoDepth: _undoStack.length,
        isProcessing: false,
      ),
    );
  }

  String _displayCategoryName(LocalCategory category) {
    return wordHubItemDisplayName(
      category.id,
      fallbackName: category.name,
      nativeLanguage: 'de',
    );
  }

  String _categoryKey(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('&', 'and')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');
  }
}

class _PersistentReviewCounters {
  const _PersistentReviewCounters({
    required this.knownCount,
    required this.keepLearningCount,
  });

  final int knownCount;
  final int keepLearningCount;
}

class _KnownUndoAction {
  const _KnownUndoAction({
    required this.categoryId,
    required this.word,
    required this.wasAboveLine,
    required this.restoreReviewedOnUndo,
  });

  final String categoryId;
  final LocalWord word;
  final bool wasAboveLine;
  final bool restoreReviewedOnUndo;
}
