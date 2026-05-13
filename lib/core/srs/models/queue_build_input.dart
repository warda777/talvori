import 'review_answer.dart';
import 'session_config.dart';
import 'word_progress.dart';

class QueueBuildInput {
  const QueueBuildInput({
    required this.config,
    required this.dueReviewProgresses,
    required this.newProgresses,
    required this.recentAnswers,
  });

  final SessionConfig config;
  final List<WordProgress> dueReviewProgresses;
  final List<WordProgress> newProgresses;
  final List<ReviewAnswer> recentAnswers;
}
