import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/word_progress.dart';
import '../models/local_word.dart';
import 'local_bootstrap_provider.dart';

class LocalWordDetailRequest {
  const LocalWordDetailRequest({
    required this.wordId,
    required this.categoryId,
    this.mode = LearningMode.adaptive,
  });

  final String wordId;
  final String categoryId;
  final LearningMode mode;

  @override
  bool operator ==(Object other) {
    return other is LocalWordDetailRequest &&
        other.wordId == wordId &&
        other.categoryId == categoryId &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(wordId, categoryId, mode);
}

class LocalWordDetailData {
  const LocalWordDetailData({required this.word, required this.progress});

  final LocalWord word;
  final WordProgress? progress;
}

final localWordDetailProvider =
    FutureProvider.family<LocalWordDetailData?, LocalWordDetailRequest>((
      ref,
      request,
    ) async {
      if (request.wordId.trim().isEmpty || request.categoryId.trim().isEmpty) {
        return null;
      }

      final bootstrapResult = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrapResult.repositoryFactory;
      final word = await repositories.wordRepository.loadWordById(
        request.wordId,
      );

      if (word == null || word.categoryId != request.categoryId) {
        return null;
      }

      final progress = await repositories.wordProgressRepository.loadProgress(
        wordId: request.wordId,
        categoryId: request.categoryId,
        mode: request.mode,
      );

      return LocalWordDetailData(word: word, progress: progress);
    });
