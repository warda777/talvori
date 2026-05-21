import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';

final localFavoriteWordsProvider = FutureProvider<List<LocalWord>>((ref) async {
  return ref.watch(
    localWordsForSourceProvider(LocalLearningSource.favorites).future,
  );
});
