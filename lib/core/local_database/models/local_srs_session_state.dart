import '../../srs/models/learning_mode.dart';
import '../../srs/models/training_area.dart';

class LocalSrsSessionState {
  const LocalSrsSessionState({
    required this.sessionId,
    required this.categoryId,
    required this.mode,
    required this.trainingArea,
    required this.status,
    required this.sessionSize,
    required this.currentPosition,
    required this.totalItems,
    required this.answeredCount,
    required this.remainingCount,
    required this.canCompleteSession,
    this.currentWordId,
  });

  final String sessionId;
  final String categoryId;
  final LearningMode mode;
  final TrainingArea trainingArea;
  final String status;
  final int sessionSize;
  final int currentPosition;
  final int totalItems;
  final int answeredCount;
  final int remainingCount;
  final String? currentWordId;
  final bool canCompleteSession;
}
