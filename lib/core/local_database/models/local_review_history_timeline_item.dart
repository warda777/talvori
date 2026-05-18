import '../../srs/models/review_answer.dart';
import '../../srs/models/srs_stage.dart';
import 'local_review_visual_feedback.dart';

class LocalReviewHistoryTimelineItem {
  const LocalReviewHistoryTimelineItem({
    required this.id,
    required this.wordId,
    required this.categoryId,
    required this.reviewedAt,
    required this.answer,
    required this.sourceStage,
    required this.targetStage,
    required this.outcomeType,
    required this.repeatIndex,
    required this.description,
    required this.colorValue,
  });

  final String id;
  final String wordId;
  final String categoryId;
  final DateTime reviewedAt;
  final ReviewAnswer answer;
  final SrsStage sourceStage;
  final SrsStage targetStage;
  final LocalReviewOutcomeType outcomeType;
  final int repeatIndex;
  final String description;
  final int colorValue;
}
