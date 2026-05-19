import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local_favorites_repository.dart';

enum LocalFavoriteAddResult { ok, duplicate, invalid }

class LocalFavoritesState {
  const LocalFavoritesState({required this.wordIds, this.isLoading = false});

  const LocalFavoritesState.initial() : wordIds = const [], isLoading = true;

  final List<String> wordIds;
  final bool isLoading;

  bool contains(String wordId) => wordIds.contains(wordId.trim());

  LocalFavoritesState copyWith({List<String>? wordIds, bool? isLoading}) {
    return LocalFavoritesState(
      wordIds: wordIds ?? this.wordIds,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class LocalFavoritesController extends StateNotifier<LocalFavoritesState> {
  LocalFavoritesController({required LocalFavoritesRepository repository})
    : _repository = repository,
      super(const LocalFavoritesState.initial());

  final LocalFavoritesRepository _repository;

  Future<void> load() async {
    final wordIds = await _repository.loadWordIds();
    state = state.copyWith(wordIds: wordIds, isLoading: false);
  }

  Future<LocalFavoriteAddResult> addWordId(String wordId) async {
    await _ensureLoaded();
    final normalized = wordId.trim();
    if (normalized.isEmpty) return LocalFavoriteAddResult.invalid;
    if (state.contains(normalized)) return LocalFavoriteAddResult.duplicate;

    final next = [...state.wordIds, normalized];
    state = state.copyWith(wordIds: next, isLoading: false);
    await _repository.saveWordIds(next);
    return LocalFavoriteAddResult.ok;
  }

  Future<void> _ensureLoaded() async {
    if (!state.isLoading) return;
    await load();
  }
}
