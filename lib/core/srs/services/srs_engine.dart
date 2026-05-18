import '../models/learning_mode.dart';
import '../models/queue_build_input.dart';
import '../models/queue_build_result.dart';
import '../models/requeue_decision.dart';
import '../models/review_answer.dart';
import '../models/review_input.dart';
import '../models/review_result.dart';
import '../models/srs_stage.dart';
import '../models/training_area.dart';
import 'due_date_calculator.dart';
import 'queue_builder.dart';
import 'requeue_service.dart';
import 'stage_transition_service.dart';

class SrsEngine {
  const SrsEngine({
    StageTransitionService stageTransitionService =
        const StageTransitionService(),
    DueDateCalculator dueDateCalculator = const DueDateCalculator(),
    RequeueService requeueService = const RequeueService(),
    QueueBuilder queueBuilder = const QueueBuilder(),
  }) : _stageTransitionService = stageTransitionService,
       _dueDateCalculator = dueDateCalculator,
       _requeueService = requeueService,
       _queueBuilder = queueBuilder;

  final StageTransitionService _stageTransitionService;
  final DueDateCalculator _dueDateCalculator;
  final RequeueService _requeueService;
  final QueueBuilder _queueBuilder;

  ReviewResult reviewCard(ReviewInput input) {
    final stageTransition = _stageTransitionService.applyStageTransition(
      progress: input.progress,
      answer: input.answer,
      trainingArea: input.trainingArea,
      preventPromotionFromS1: _preventsSameDayTimePromotion(input),
    );

    if (input.trainingArea == TrainingArea.focused) {
      return ReviewResult(
        updatedProgress: stageTransition.progress,
        oldStage: stageTransition.oldStage,
        newStage: stageTransition.newStage,
        oldPassCount: stageTransition.oldPassCount,
        newPassCount: stageTransition.newPassCount,
        stageChanged: stageTransition.stageChanged,
        nextDueAt: stageTransition.progress.nextDueAt,
        requeueDecision: null,
      );
    }

    final nextDueAt = _dueDateCalculator.calculateNextDueAt(
      mode: stageTransition.progress.mode,
      stage: stageTransition.progress.stage,
      now: input.reviewedAt,
    );
    final updatedProgress = stageTransition.progress.copyWith(
      nextDueAt: nextDueAt,
      lastReviewedAt: input.reviewedAt,
    );

    final requeueDecision = _requeueDecisionFor(input);

    return ReviewResult(
      updatedProgress: updatedProgress,
      oldStage: stageTransition.oldStage,
      newStage: stageTransition.newStage,
      oldPassCount: stageTransition.oldPassCount,
      newPassCount: stageTransition.newPassCount,
      stageChanged: stageTransition.stageChanged,
      nextDueAt: nextDueAt,
      requeueDecision: requeueDecision,
    );
  }

  QueueBuildResult buildSessionQueue(QueueBuildInput input) {
    return _queueBuilder.buildSessionQueue(input);
  }

  RequeueDecision? _requeueDecisionFor(ReviewInput input) {
    if (input.answer != ReviewAnswer.wrong) {
      return null;
    }

    final sameSessionWrongCount =
        input.sessionContext.wrongCountForWord(input.progress.wordId) + 1;

    return _requeueService.applyRequeueForWrongAnswer(
      sameSessionWrongCount: sameSessionWrongCount,
      remainingQueueSize: input.sessionContext.remainingQueueSize,
    );
  }

  bool _preventsSameDayTimePromotion(ReviewInput input) {
    final lastReviewedAt = input.progress.lastReviewedAt;
    return input.progress.mode == LearningMode.time &&
        input.answer == ReviewAnswer.correct &&
        input.progress.stage == SrsStage.s1 &&
        lastReviewedAt != null &&
        _isSameDate(lastReviewedAt, input.reviewedAt);
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
