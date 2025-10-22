import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/mock_word_repository.dart';
import 'package:talvori/features/words/domain/word.dart';

final wordRepositoryProvider = Provider<MockWordRepository>((ref) {
  return MockWordRepository();
});

final recentWordsProvider = FutureProvider<List<Word>>((ref) async {
  return ref.read(wordRepositoryProvider).fetchRecentWords();
});
