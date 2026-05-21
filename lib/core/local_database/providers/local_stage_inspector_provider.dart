import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/review_answer.dart';
import '../../srs/models/srs_stage.dart';
import '../models/local_learning_source.dart';
import '../models/local_review_visual_feedback.dart';
import '../models/local_stage_inspector_item.dart';
import 'local_bootstrap_provider.dart';
import 'local_words_for_source_provider.dart';

final localStageInspectorProvider =
    FutureProvider.family<
      List<LocalStageInspectorItem>,
      LocalStageInspectorRequest
    >((ref, request) async {
      if (request.categoryId.trim().isEmpty) {
        return const <LocalStageInspectorItem>[];
      }

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final source = LocalLearningSource.fromId(request.categoryId);
      if (source == null) {
        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: request.categoryId,
              mode: request.mode,
              now: DateTime.now(),
            );
      }

      final words = source == null
          ? await repositories.wordRepository.loadWordsForCategory(
              categoryId: request.categoryId,
            )
          : await ref.watch(localWordsForSourceProvider(source).future);
      final items = <LocalStageInspectorItem>[];

      for (final word in words) {
        final progressCategoryId = source == null
            ? request.categoryId
            : word.categoryId;
        final progress = await repositories.wordProgressRepository.loadProgress(
          wordId: word.id,
          categoryId: progressCategoryId,
          mode: request.mode,
        );
        if (progress == null || progress.stage != request.stage) {
          continue;
        }

        final matchingHistory = await repositories.reviewHistoryRepository
            .loadHistoryForWordInContext(
              wordId: word.id,
              categoryId: progressCategoryId,
              mode: request.mode,
            );
        final lastEvent = matchingHistory.isEmpty ? null : matchingHistory.last;

        items.add(
          LocalStageInspectorItem(
            wordId: word.id,
            term: word.term,
            translation: word.translation,
            categoryId: word.categoryId,
            mode: request.mode,
            currentStage: progress.stage,
            passCount: progress.passCount,
            wrongCount: progress.wrongCount,
            nextDueAt: progress.nextDueAt,
            lastReviewedAt: progress.lastReviewedAt,
            lastFeedback: lastEvent == null
                ? null
                : LocalReviewVisualFeedback(
                    wordId: word.id,
                    sourceStage: lastEvent.oldStage,
                    targetStage: lastEvent.newStage,
                    outcomeType: _outcomeTypeFor(
                      answer: lastEvent.answer,
                      oldStage: lastEvent.oldStage,
                      newStage: lastEvent.newStage,
                    ),
                    repeatIndex: lastEvent.oldStage == lastEvent.newStage
                        ? lastEvent.newPassCount
                        : 0,
                    wasPromoted:
                        lastEvent.newStage.index > lastEvent.oldStage.index,
                    wasDemoted:
                        lastEvent.newStage.index < lastEvent.oldStage.index,
                    timestamp: lastEvent.reviewedAt,
                  ),
          ),
        );
      }

      items.sort((a, b) => a.term.compareTo(b.term));
      return items;
    });

LocalReviewOutcomeType _outcomeTypeFor({
  required ReviewAnswer answer,
  required SrsStage oldStage,
  required SrsStage newStage,
}) {
  if (newStage.index > oldStage.index) {
    return LocalReviewOutcomeType.promoted;
  }
  if (newStage.index < oldStage.index) {
    return LocalReviewOutcomeType.demoted;
  }
  if (answer == ReviewAnswer.wrong) {
    return LocalReviewOutcomeType.unchangedWrong;
  }
  return LocalReviewOutcomeType.repeatedSameStage;
}
