import 'review_answer.dart';
import 'session_context.dart';
import 'training_area.dart';
import 'word_progress.dart';

class ReviewInput {
  const ReviewInput({
    required this.progress,
    required this.answer,
    required this.trainingArea,
    required this.reviewedAt,
    required this.sessionContext,
  });

  final WordProgress progress;
  final ReviewAnswer answer;
  final TrainingArea trainingArea;
  final DateTime reviewedAt;
  final SessionContext sessionContext;
}
