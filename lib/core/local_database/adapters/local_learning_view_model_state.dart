import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import '../../srs/models/training_area.dart';
import '../controllers/local_learning_controller.dart';
import '../models/local_review_visual_feedback.dart';

class LocalLearningViewModelState {
  const LocalLearningViewModelState({
    required this.isLoading,
    required this.hasSession,
    required this.currentPosition,
    required this.totalItems,
    required this.answeredCount,
    required this.remainingCount,
    this.stageCounts = const [0, 0, 0, 0, 0, 0],
    required this.canSubmitAnswer,
    required this.canCompleteSession,
    required this.lastAction,
    this.errorMessage,
    this.sessionId,
    this.categoryId,
    this.mode,
    this.trainingArea,
    this.status,
    this.currentWordId,
    this.term,
    this.translation,
    this.exampleSentence,
    this.notes,
    this.currentStage,
    this.nextAvailableAt,
    this.lastReviewFeedback,
  });

  final bool isLoading;
  final String? errorMessage;
  final bool hasSession;
  final String? sessionId;
  final String? categoryId;
  final LearningMode? mode;
  final TrainingArea? trainingArea;
  final String? status;
  final String? currentWordId;
  final String? term;
  final String? translation;
  final String? exampleSentence;
  final String? notes;
  final SrsStage? currentStage;
  final DateTime? nextAvailableAt;
  final LocalReviewVisualFeedback? lastReviewFeedback;
  final int currentPosition;
  final int totalItems;
  final int answeredCount;
  final int remainingCount;
  final List<int> stageCounts;
  final bool canSubmitAnswer;
  final bool canCompleteSession;
  final LocalLearningControllerAction lastAction;
}
