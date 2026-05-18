import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/review_answer.dart';
import '../models/local_review_history_timeline_item.dart';
import '../models/local_review_visual_feedback.dart';
import '../repositories/review_history_repository.dart';
import 'local_bootstrap_provider.dart';

class LocalWordReviewHistoryRequest {
  const LocalWordReviewHistoryRequest({
    required this.wordId,
    required this.categoryId,
    this.mode = LearningMode.adaptive,
  });

  final String wordId;
  final String categoryId;
  final LearningMode mode;

  @override
  bool operator ==(Object other) {
    return other is LocalWordReviewHistoryRequest &&
        other.wordId == wordId &&
        other.categoryId == categoryId &&
        other.mode == mode;
  }

  @override
  int get hashCode => Object.hash(wordId, categoryId, mode);
}

final localWordReviewHistoryProvider =
    FutureProvider.family<
      List<LocalReviewHistoryTimelineItem>,
      LocalWordReviewHistoryRequest
    >((ref, request) async {
      if (request.wordId.trim().isEmpty || request.categoryId.trim().isEmpty) {
        return const [];
      }

      final bootstrap = await ref.watch(localBootstrapProvider.future);
      final events = await bootstrap.repositoryFactory.reviewHistoryRepository
          .loadHistoryForWordInContext(
            wordId: request.wordId,
            categoryId: request.categoryId,
            mode: request.mode,
            descending: true,
          );

      return events.map(_mapTimelineItem).toList(growable: false);
    });

LocalReviewHistoryTimelineItem _mapTimelineItem(ReviewHistoryEvent event) {
  final wasPromoted = event.newStage.index > event.oldStage.index;
  final wasDemoted = event.newStage.index < event.oldStage.index;
  final outcomeType = wasPromoted
      ? LocalReviewOutcomeType.promoted
      : wasDemoted
      ? LocalReviewOutcomeType.demoted
      : event.answer == ReviewAnswer.wrong
      ? LocalReviewOutcomeType.unchangedWrong
      : LocalReviewOutcomeType.repeatedSameStage;
  final repeatIndex = outcomeType == LocalReviewOutcomeType.repeatedSameStage
      ? event.newPassCount.clamp(1, 3)
      : 0;

  return LocalReviewHistoryTimelineItem(
    id: event.id,
    wordId: event.wordId,
    categoryId: event.categoryId,
    reviewedAt: event.reviewedAt,
    answer: event.answer,
    sourceStage: event.oldStage,
    targetStage: event.newStage,
    outcomeType: outcomeType,
    repeatIndex: repeatIndex,
    description: _descriptionFor(
      outcomeType: outcomeType,
      sourceStage: event.oldStage.index,
      targetStage: event.newStage.index,
      repeatIndex: repeatIndex,
    ),
    colorValue: _colorValueFor(outcomeType, repeatIndex),
  );
}

String _descriptionFor({
  required LocalReviewOutcomeType outcomeType,
  required int sourceStage,
  required int targetStage,
  required int repeatIndex,
}) {
  return switch (outcomeType) {
    LocalReviewOutcomeType.promoted =>
      'Richtig: S$sourceStage -> S$targetStage',
    LocalReviewOutcomeType.demoted => 'Falsch: S$sourceStage -> S$targetStage',
    LocalReviewOutcomeType.unchangedWrong => 'Falsch: bleibt S$targetStage',
    LocalReviewOutcomeType.repeatedSameStage =>
      'Wiederholung $repeatIndex in S$targetStage',
  };
}

int _colorValueFor(LocalReviewOutcomeType outcomeType, int repeatIndex) {
  return switch (outcomeType) {
    LocalReviewOutcomeType.promoted => 0xFF36F58A,
    LocalReviewOutcomeType.demoted ||
    LocalReviewOutcomeType.unchangedWrong => 0xFFFF4B6E,
    LocalReviewOutcomeType.repeatedSameStage => switch (repeatIndex.clamp(
      1,
      3,
    )) {
      1 => 0xFF5DDCFF,
      2 => 0xFFB36BFF,
      _ => 0xFFFFB84A,
    },
  };
}
