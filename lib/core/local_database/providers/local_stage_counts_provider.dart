import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/local_learning_source.dart';
import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import 'local_bootstrap_provider.dart';
import 'local_words_for_source_provider.dart';

class LocalStageCountsRequest {
  const LocalStageCountsRequest({required this.categoryId, required this.mode});

  final String categoryId;
  final LearningMode mode;

  @override
  bool operator ==(Object other) {
    return other is LocalStageCountsRequest &&
        other.categoryId == categoryId &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(categoryId, mode);
}

final localStageCountsProvider =
    FutureProvider.family<List<int>, LocalStageCountsRequest>((
      ref,
      request,
    ) async {
      if (request.categoryId.trim().isEmpty) {
        return List<int>.filled(SrsStage.values.length, 0);
      }

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final source = LocalLearningSource.fromId(request.categoryId);
      if (source != null) {
        final counts = List<int>.filled(SrsStage.values.length, 0);
        final words = await ref.watch(
          localWordsForSourceProvider(source).future,
        );
        for (final word in words) {
          final progress = await repositories.wordProgressRepository
              .loadProgress(
                wordId: word.id,
                categoryId: word.categoryId,
                mode: request.mode,
              );
          if (progress == null) continue;
          counts[progress.stage.index] += 1;
        }
        return counts;
      }

      await repositories.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: request.categoryId,
            mode: request.mode,
            now: DateTime.now(),
          );

      final counts = List<int>.filled(SrsStage.values.length, 0);
      final words = await repositories.wordRepository.loadWordsForWordWorld(
        categoryId: request.categoryId,
      );
      for (final word in words) {
        final progress = await repositories.wordProgressRepository.loadProgress(
          wordId: word.id,
          categoryId: request.categoryId,
          mode: request.mode,
        );
        if (progress == null) continue;
        counts[progress.stage.index] += 1;
      }
      return counts;
    });
