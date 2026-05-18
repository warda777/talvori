import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import 'local_review_visual_feedback.dart';

class LocalStageInspectorRequest {
  const LocalStageInspectorRequest({
    required this.categoryId,
    required this.mode,
    required this.stage,
  });

  final String categoryId;
  final LearningMode mode;
  final SrsStage stage;

  @override
  bool operator ==(Object other) {
    return other is LocalStageInspectorRequest &&
        other.categoryId == categoryId &&
        other.mode == mode &&
        other.stage == stage;
  }

  @override
  int get hashCode => Object.hash(categoryId, mode, stage);
}

class LocalStageInspectorItem {
  const LocalStageInspectorItem({
    required this.wordId,
    required this.term,
    required this.translation,
    required this.categoryId,
    required this.mode,
    required this.currentStage,
    required this.passCount,
    required this.wrongCount,
    this.nextDueAt,
    this.lastReviewedAt,
    this.lastFeedback,
  });

  final String wordId;
  final String term;
  final String translation;
  final String categoryId;
  final LearningMode mode;
  final SrsStage currentStage;
  final int passCount;
  final int wrongCount;
  final DateTime? nextDueAt;
  final DateTime? lastReviewedAt;
  final LocalReviewVisualFeedback? lastFeedback;
}
