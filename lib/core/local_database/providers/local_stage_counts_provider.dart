import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import 'local_bootstrap_provider.dart';

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
      await repositories.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: request.categoryId,
            mode: request.mode,
            now: DateTime.now(),
          );

      return repositories.wordProgressRepository.countByStage(
        categoryId: request.categoryId,
        mode: request.mode,
      );
    });
