import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';

import 'local_favorites_provider.dart';

final localFavoriteWordsProvider = FutureProvider<List<LocalWord>>((ref) async {
  final favoriteWordIds = await ref
      .watch(localFavoritesRepositoryProvider)
      .loadWordIds();
  if (favoriteWordIds.isEmpty) return const <LocalWord>[];

  final bootstrapResult = await ref.watch(localBootstrapProvider.future);
  final wordRepository = bootstrapResult.repositoryFactory.wordRepository;
  final words = <LocalWord>[];
  final seen = <String>{};

  for (final wordId in favoriteWordIds) {
    final normalized = wordId.trim();
    if (normalized.isEmpty || !seen.add(normalized)) continue;

    final word = await wordRepository.loadWordById(normalized);
    if (word == null || word.isArchived) continue;
    words.add(word);
  }

  return words;
});
