import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/training_area.dart';
import 'local_bootstrap_provider.dart';

class LocalCategoryProgressResetRequest {
  const LocalCategoryProgressResetRequest({
    required this.categoryId,
    required this.mode,
  });

  final String categoryId;
  final LearningMode mode;
}

abstract class LocalCategoryProgressResetService {
  Future<void> resetToS0(LocalCategoryProgressResetRequest request);
}

class LocalCategoryProgressResetServiceImpl
    implements LocalCategoryProgressResetService {
  const LocalCategoryProgressResetServiceImpl(this.ref);

  final Ref ref;

  @override
  Future<void> resetToS0(LocalCategoryProgressResetRequest request) async {
    if (request.categoryId.trim().isEmpty) return;

    final bootstrap = await ref.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final now = DateTime.now();

    await repositories.progressInitializationService
        .initializeProgressForCategoryAndMode(
          categoryId: request.categoryId,
          mode: request.mode,
          now: now,
        );

    for (final trainingArea in TrainingArea.values) {
      final session = await repositories.learningSessionRepository
          .findActiveSession(
            categoryId: request.categoryId,
            mode: request.mode,
            trainingArea: trainingArea,
          );
      if (session != null) {
        await repositories.learningSessionRepository.completeSession(
          sessionId: session.id,
          completedAt: now,
        );
      }
    }

    await repositories.wordProgressRepository.resetCategoryProgressToS0(
      categoryId: request.categoryId,
      mode: request.mode,
      updatedAt: now,
    );
  }
}

final localCategoryProgressResetServiceProvider =
    Provider<LocalCategoryProgressResetService>(
      (ref) => LocalCategoryProgressResetServiceImpl(ref),
    );
