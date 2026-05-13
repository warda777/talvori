import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/queue_build_input.dart';
import 'package:talvori/core/srs/models/requeue_reason.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/review_input.dart';
import 'package:talvori/core/srs/models/session_config.dart';
import 'package:talvori/core/srs/models/session_context.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/core/srs/services/srs_engine.dart';

void main() {
  const engine = SrsEngine();
  final now = DateTime(2026, 5, 13, 10);

  WordProgress progress({
    String wordId = 'word-1',
    LearningMode mode = LearningMode.time,
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
  }) {
    return WordProgress(
      wordId: wordId,
      categoryId: 'category-1',
      mode: mode,
      stage: stage,
      passCount: passCount,
      wrongCount: wrongCount,
      nextDueAt: nextDueAt,
    );
  }

  SessionContext sessionContext({
    Map<String, int> wrongCounts = const {},
    int remainingQueueSize = 12,
  }) {
    return SessionContext(
      sessionId: 'session-1',
      currentPosition: 0,
      recentAnswers: const [],
      sameSessionWrongCountsByWordId: wrongCounts,
      remainingQueueSize: remainingQueueSize,
    );
  }

  ReviewInput reviewInput({
    required WordProgress progress,
    required ReviewAnswer answer,
    TrainingArea trainingArea = TrainingArea.all,
    SessionContext? context,
  }) {
    return ReviewInput(
      progress: progress,
      answer: answer,
      trainingArea: trainingArea,
      reviewedAt: now,
      sessionContext: context ?? sessionContext(),
    );
  }

  group('SrsEngine', () {
    test('review_card_correct_uses_stage_transition_and_due_date', () {
      final result = engine.reviewCard(
        reviewInput(
          progress: progress(stage: SrsStage.s0),
          answer: ReviewAnswer.correct,
        ),
      );

      expect(result.oldStage, SrsStage.s0);
      expect(result.newStage, SrsStage.s1);
      expect(result.stageChanged, isTrue);
      expect(result.updatedProgress.stage, SrsStage.s1);
      expect(result.updatedProgress.passCount, 0);
      expect(result.nextDueAt, now.add(const Duration(days: 1)));
      expect(result.updatedProgress.nextDueAt, result.nextDueAt);
      expect(result.updatedProgress.lastReviewedAt, now);
      expect(result.requeueDecision, isNull);
    });

    test('review_card_wrong_uses_stage_transition_and_requeue', () {
      final result = engine.reviewCard(
        reviewInput(
          progress: progress(stage: SrsStage.s5, passCount: 2),
          answer: ReviewAnswer.wrong,
          context: sessionContext(remainingQueueSize: 12),
        ),
      );

      expect(result.oldStage, SrsStage.s5);
      expect(result.newStage, SrsStage.s3);
      expect(result.updatedProgress.stage, SrsStage.s3);
      expect(result.updatedProgress.passCount, 0);
      expect(result.updatedProgress.wrongCount, 1);
      expect(result.nextDueAt, now.add(const Duration(days: 7)));
      expect(result.requeueDecision, isNotNull);
      expect(result.requeueDecision!.reason, RequeueReason.wrongAnswer);
      expect(result.requeueDecision!.targetOffset, 10);
      expect(result.requeueDecision!.shouldRequeue, isTrue);
    });

    test('focused_review_does_not_change_progress', () {
      final originalNextDueAt = DateTime(2026, 5, 20, 10);
      final currentProgress = progress(
        mode: LearningMode.hybrid,
        stage: SrsStage.s4,
        passCount: 2,
        wrongCount: 3,
        nextDueAt: originalNextDueAt,
      );

      final result = engine.reviewCard(
        reviewInput(
          progress: currentProgress,
          answer: ReviewAnswer.wrong,
          trainingArea: TrainingArea.focused,
        ),
      );

      expect(result.updatedProgress.stage, currentProgress.stage);
      expect(result.updatedProgress.passCount, currentProgress.passCount);
      expect(result.updatedProgress.wrongCount, currentProgress.wrongCount);
      expect(result.updatedProgress.nextDueAt, originalNextDueAt);
      expect(result.nextDueAt, originalNextDueAt);
      expect(result.requeueDecision, isNull);
      expect(result.stageChanged, isFalse);
    });

    test('build_session_queue_delegates_to_queue_builder', () {
      final result = engine.buildSessionQueue(
        QueueBuildInput(
          config: SessionConfig(
            mode: LearningMode.time,
            trainingArea: TrainingArea.all,
            now: now,
          ),
          dueReviewProgresses: [
            progress(wordId: 'review-1', stage: SrsStage.s2),
            progress(wordId: 'review-2', stage: SrsStage.s3),
          ],
          newProgresses: [
            for (var index = 0; index < 10; index++)
              progress(wordId: 'new-$index', stage: SrsStage.s0),
          ],
          recentAnswers: const [],
        ),
      );

      expect(result.items, hasLength(7));
      expect(result.reviewsIncluded, 2);
      expect(result.newCardsIncluded, 5);
      expect(result.items.take(2).every((item) => !item.isNewCard), isTrue);
    });

    test('srs_engine_does_not_require_sqlite_or_repository', () {
      const standaloneEngine = SrsEngine();

      final result = standaloneEngine.reviewCard(
        reviewInput(
          progress: progress(mode: LearningMode.adaptive, stage: SrsStage.s0),
          answer: ReviewAnswer.correct,
        ),
      );

      expect(result.updatedProgress.stage, SrsStage.s1);
      expect(result.nextDueAt, now);
    });
  });
}
