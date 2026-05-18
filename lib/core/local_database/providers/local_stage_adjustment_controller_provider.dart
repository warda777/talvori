import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import '../models/local_stage_inspector_item.dart';
import 'local_bootstrap_provider.dart';
import 'local_stage_counts_provider.dart';
import 'local_stage_inspector_provider.dart';

final localStageAdjustmentControllerProvider =
    Provider<LocalStageAdjustmentController>((ref) {
      return LocalStageAdjustmentController(ref);
    });

class LocalStageAdjustmentController {
  const LocalStageAdjustmentController(this._ref);

  final Ref _ref;

  Future<void> demoteWordOneStage({
    required String wordId,
    required String categoryId,
    required LearningMode mode,
    required DateTime now,
  }) async {
    final bootstrap = await _ref.read(localBootstrapProvider.future);
    final progress = await bootstrap.repositoryFactory.wordProgressRepository
        .loadProgress(wordId: wordId, categoryId: categoryId, mode: mode);
    if (progress == null) {
      return;
    }
    if (progress.stage == SrsStage.s0) {
      return;
    }
    final targetIndex = progress.stage.index - 1;
    await demoteWordToStage(
      wordId: wordId,
      categoryId: categoryId,
      mode: mode,
      targetStage: SrsStage.values[targetIndex],
      now: now,
    );
  }

  Future<void> demoteWordToStage({
    required String wordId,
    required String categoryId,
    required LearningMode mode,
    required SrsStage targetStage,
    required DateTime now,
  }) async {
    final bootstrap = await _ref.read(localBootstrapProvider.future);
    final repository = bootstrap.repositoryFactory.wordProgressRepository;
    final progress = await repository.loadProgress(
      wordId: wordId,
      categoryId: categoryId,
      mode: mode,
    );
    if (progress == null) {
      return;
    }
    if (targetStage.index >= progress.stage.index) {
      throw StateError('Manual stage adjustment only supports demotion.');
    }

    await repository.saveProgress(
      updatedProgress: progress.copyWith(
        stage: targetStage,
        passCount: 0,
        nextDueAt: null,
      ),
      updatedAt: now,
    );

    _ref.invalidate(
      localStageCountsProvider(
        LocalStageCountsRequest(categoryId: categoryId, mode: mode),
      ),
    );
    for (final stage in SrsStage.values) {
      _ref.invalidate(
        localStageInspectorProvider(
          LocalStageInspectorRequest(
            categoryId: categoryId,
            mode: mode,
            stage: stage,
          ),
        ),
      );
    }
  }
}
