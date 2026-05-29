import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/features/favorites/application/local_favorites_provider.dart';

final localWordsForSourceProvider =
    FutureProvider.family<List<LocalWord>, LocalLearningSource>((
      ref,
      source,
    ) async {
      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final wordRepository = bootstrap.repositoryFactory.wordRepository;

      switch (source) {
        case LocalLearningSource.allWords:
          return wordRepository.loadAllWords();
        case LocalLearningSource.myWords:
          return wordRepository.loadWordsForCategory(categoryId: source.id);
        case LocalLearningSource.favorites:
          return _loadFavoriteWords(ref);
        case LocalLearningSource.knownWords:
          return _loadKnownWords(ref);
        case LocalLearningSource.myMix:
          return _loadMyMixWords(ref);
      }
    });

Future<List<LocalWord>> _loadFavoriteWords(Ref ref) async {
  final favoriteWordIds = await ref
      .watch(localFavoritesRepositoryProvider)
      .loadWordIds();
  if (favoriteWordIds.isEmpty) return const <LocalWord>[];

  final bootstrap = await ref.watch(localBootstrapProvider.future);
  final wordRepository = bootstrap.repositoryFactory.wordRepository;
  final words = <LocalWord>[];
  final seen = <String>{};

  for (final wordId in favoriteWordIds) {
    final normalized = wordId.trim();
    if (normalized.isEmpty || !seen.add(normalized)) continue;
    final word = await wordRepository.loadWordById(normalized);
    if (word == null || word.isArchived) continue;
    words.add(word);
  }

  return List<LocalWord>.unmodifiable(words);
}

Future<List<LocalWord>> _loadKnownWords(Ref ref) async {
  final bootstrap = await ref.watch(localBootstrapProvider.future);
  final words = await bootstrap.repositoryFactory.wordRepository
      .loadKnownWords();
  return List<LocalWord>.unmodifiable(words);
}

Future<List<LocalWord>> _loadMyMixWords(Ref ref) async {
  final favorites = await _loadFavoriteWords(ref);
  final known = await _loadKnownWords(ref);
  final knownIds = known.map((word) => word.id).toSet();
  final bootstrap = await ref.watch(localBootstrapProvider.future);
  final allWords = await bootstrap.repositoryFactory.wordRepository
      .loadAllWords();

  final result = <LocalWord>[];
  final seen = <String>{};

  for (final word in favorites.take(8)) {
    if (seen.add(word.id)) result.add(word);
  }

  final recentPracticeCandidates =
      allWords.where((word) => !knownIds.contains(word.id)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  for (final word in recentPracticeCandidates.take(5)) {
    if (seen.add(word.id)) result.add(word);
  }

  return List<LocalWord>.unmodifiable(result);
}
