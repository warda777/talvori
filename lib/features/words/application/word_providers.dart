import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';
import 'package:talvori/features/words/data/mock_word_repository.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/learn_mode_controller.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

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
  if (s.shuffledWordIds.isEmpty || s.index >= s.shuffledWordIds.length) return null;
  final id = s.shuffledWordIds[s.index];
  final w = s.wordQueue.where((e) => e.id == id);
  return w.isEmpty ? null : w.first;
});

/// Stages für die Switches
final stagesProvider = Provider<List<int>>((ref) {
  return ref.watch(learnModeControllerProvider.select((s) => s.stages));
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

  @override
  WordHubState build() {
    _repo = ref.read(supabaseWordRepositoryProvider);
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
}

// Riverpod-Provider für Controller/State
final wordHubControllerProvider =
    NotifierProvider<WordHubController, WordHubState>(() {
  return WordHubController();
});

