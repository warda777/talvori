import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:talvori/features/words/data/mock_word_repository.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

final wordRepositoryProvider = Provider<MockWordRepository>((ref) {
  return MockWordRepository();
});

final recentWordsProvider = FutureProvider<List<Word>>((ref) async {
  return ref.read(wordRepositoryProvider).fetchRecentWords();
});

// ---- Learn Mode Selektoren ----

/// Aktuelles Wort basierend auf Index und Queue
final currentWordProvider = Provider<WordUserView?>((ref) {
  final s = ref.watch(learnModeControllerProvider);
  if (s.shuffledWordIds.isEmpty || s.index >= s.shuffledWordIds.length) {
    print('🔍 currentWordProvider: shuffledWordIds.isEmpty=${s.shuffledWordIds.isEmpty}, index=${s.index}, shuffledWordIds.length=${s.shuffledWordIds.length}');
    return null;
  }
  final id = s.shuffledWordIds[s.index];
  print('🔍 currentWordProvider: Suche Wort mit id=$id (index=${s.index})');
  print('🔍 currentWordProvider: wordQueue.length=${s.wordQueue.length}');
  if (s.wordQueue.isNotEmpty) {
    print('🔍 currentWordProvider: Erste 3 IDs in wordQueue: ${s.wordQueue.take(3).map((w) => w.id).toList()}');
  }
  final w = s.wordQueue.where((e) => e.id == id);
  if (w.isEmpty) {
    print('⚠️ currentWordProvider: Wort mit id=$id nicht in wordQueue gefunden!');
    print('⚠️ currentWordProvider: shuffledWordIds[${s.index}]=$id');
    if (s.wordQueue.isNotEmpty) {
      print('⚠️ currentWordProvider: Verfügbare IDs in wordQueue: ${s.wordQueue.map((e) => e.id).toList()}');
    }
    return null;
  }
  final word = w.first;
  print('✅ currentWordProvider: Wort gefunden: ${word.text} (id=${word.id})');
  return word;
});

/// Stages für die Switches
/// Gibt die Stage-Counts aus dem aktuell geladenen Deck zurück (nur geladene Karten).
/// Verwendet deckStages statt stages (CategoryProgress), damit die UI nur Stages zeigt, die wirklich im Deck sind.
final stagesProvider = Provider<List<int>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.deckStages));
});

/// Anzahl der gelernten Wörter in Stage 5 (Streak >= 3) pro Kategorie.
/// Diese Wörter sind endgültig fertig und als "gelernt" markiert.
final learnedInStage5Provider = FutureProvider.family<int, String>((ref, categoryId) async {
  if (categoryId.isEmpty) return 0;

  final srsSystem = ref.watch(srsModeControllerProvider).mode;
  final repo = ref.read(supabaseWordRepositoryProvider);

  return repo.countLearnedInStage5(categoryId, srsSystem: srsSystem);
});

/// Timer-Status (aktiv und läuft)
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.timerActive && s.running));
});

/// Timer-Status (pausiert)
final isPausedProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.timerActive && s.timerPaused));
});

/// Verbleibende Zeit
final remainingTimeProvider = Provider<double>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.remainingMillis));
});

/// Karten in Session
final cardsSwipedProvider = Provider<int>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.cardsSwipedInSession));
});

/// Loading-Status
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.loading));
});

/// Kategorien
final categoriesProvider = Provider<List<CategoryInfo>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.categories));
});

/// Ausgewählte Kategorie
final selectedCategoryProvider = Provider<CategoryInfo?>((ref) {
  final s = ref.watch(learnModeControllerProvider);
  if (s.selectedCategoryIndex < 0 || s.selectedCategoryIndex >= s.categories.length) return null;
  return s.categories[s.selectedCategoryIndex];
});

// ===== WordHub (Liste/Suche/Pagination) =====

// WICHTIG: eigener Name, kollidiert nicht mit MockWordRepository oben.
final supabaseWordRepositoryProvider = Provider<SupabaseWordRepository>((ref) {
  return SupabaseWordRepository();
});

class WordHubState extends Equatable {
  final bool loading;
  final List<Word> items;
  final String? query;
  final String? categorySlug;
  final bool canLoadMore;

  const WordHubState({
    this.loading = false,
    this.items = const [],
    this.query,
    this.categorySlug,
    this.canLoadMore = true,
  });

  WordHubState copyWith({
    bool? loading,
    List<Word>? items,
    String? query,
    String? categorySlug,
    bool? canLoadMore,
  }) => WordHubState(
        loading: loading ?? this.loading,
        items: items ?? this.items,
        query: query ?? this.query,
        categorySlug: categorySlug ?? this.categorySlug,
        canLoadMore: canLoadMore ?? this.canLoadMore,
      );

  @override
  List<Object?> get props => [loading, items, query, categorySlug, canLoadMore];
}

class WordHubController extends Notifier<WordHubState> {
  static const _pageSize = 50;
  late final SupabaseWordRepository _repo;
  Timer? _debounce;

  @override
  WordHubState build() {
    _repo = ref.read(supabaseWordRepositoryProvider);
    ref.onDispose(() => _debounce?.cancel());
    return const WordHubState();
  }

  Future<void> init({String? categorySlug}) async {
    state = state.copyWith(loading: true, categorySlug: categorySlug);
    final data = await _repo.fetchRecentWords(limit: _pageSize);
    state = state.copyWith(
      loading: false,
      items: data,
      canLoadMore: data.length == _pageSize,
    );
  }

  Future<void> search(String? q) async {
    state = state.copyWith(query: q);
    await init(categorySlug: state.categorySlug);
  }

  Future<void> loadMore() async {
    if (!state.canLoadMore || state.loading) return;
    state = state.copyWith(loading: true);
    final more = await _repo.fetchRecentWords(limit: _pageSize);
    state = state.copyWith(
      loading: false,
      items: [...state.items, ...more],
      canLoadMore: more.length == _pageSize,
    );
  }

  // Exponiere Repo für bestehende Card-Stats (_CategoryCard nutzt derzeit Repo-Methoden)
  SupabaseWordRepository get repo => _repo;

  void searchDebounced(String q, {Duration delay = const Duration(milliseconds: 350)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, () => search(q));
  }
}

// Riverpod-Provider für Controller/State
final wordHubControllerProvider =
    NotifierProvider<WordHubController, WordHubState>(() => WordHubController());

// ===== Meine Wörter (Liste / Suche / Pagination) =====

// State
class MyWordsState extends Equatable {
  final bool loadingFirst;
  final bool loadingMore;
  final bool hasMore;
  final List<Word> items;
  final String query;
  final int offset;

  const MyWordsState({
    this.loadingFirst = false,
    this.loadingMore = false,
    this.hasMore = true,
    this.items = const [],
    this.query = '',
    this.offset = 0,
  });

  MyWordsState copyWith({
    bool? loadingFirst,
    bool? loadingMore,
    bool? hasMore,
    List<Word>? items,
    String? query,
    int? offset,
  }) => MyWordsState(
        loadingFirst: loadingFirst ?? this.loadingFirst,
        loadingMore: loadingMore ?? this.loadingMore,
        hasMore: hasMore ?? this.hasMore,
        items: items ?? this.items,
        query: query ?? this.query,
        offset: offset ?? this.offset,
      );

  @override
  List<Object?> get props => [loadingFirst, loadingMore, hasMore, items, query, offset];
}

// Controller
class MyWordsController extends Notifier<MyWordsState> {
  static const _pageSize = 50;
  late final SupabaseWordRepository _repo;
  Timer? _debounce;

  @override
  MyWordsState build() {
    _repo = ref.read(supabaseWordRepositoryProvider);
    ref.onDispose(() => _debounce?.cancel());
    return const MyWordsState();
  }

  Future<void> init() async {
    state = state.copyWith(loadingFirst: true, items: [], offset: 0, hasMore: true);
    final batch = await _repo.fetchMyWords(limit: _pageSize, offset: 0, query: state.query);
    state = state.copyWith(
      loadingFirst: false,
      items: batch,
      offset: batch.length,
      hasMore: batch.length == _pageSize,
    );
  }

  void setQuery(String q) {
    state = state.copyWith(query: q);
  }

  void searchDebounced(String q, {Duration delay = const Duration(milliseconds: 350)}) {
    setQuery(q);
    _debounce?.cancel();
    _debounce = Timer(delay, () => init());
  }

  Future<void> loadMore() async {
    if (state.loadingMore || !state.hasMore) return;
    state = state.copyWith(loadingMore: true);
    final batch = await _repo.fetchMyWords(limit: _pageSize, offset: state.offset, query: state.query);
    state = state.copyWith(
      loadingMore: false,
      items: [...state.items, ...batch],
      offset: state.offset + batch.length,
      hasMore: batch.length == _pageSize,
    );
  }

  Future<void> removeWord(String wordId) async {
    await _repo.removeFromMyWords(wordId);
    final next = [...state.items]..removeWhere((w) => w.id == wordId);
    state = state.copyWith(items: next, offset: next.length);
  }
}

// Provider
final myWordsControllerProvider =
    NotifierProvider<MyWordsController, MyWordsState>(() => MyWordsController());

