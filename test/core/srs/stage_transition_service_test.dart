import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/core/srs/services/stage_transition_service.dart';

void main() {
  const service = StageTransitionService();

  WordProgress progress({
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
    bool isMastered = false,
  }) {
    return WordProgress(
      wordId: 'word-1',
      categoryId: 'category-1',
      mode: LearningMode.adaptive,
      stage: stage,
      passCount: passCount,
      wrongCount: wrongCount,
      nextDueAt: nextDueAt,
      isMastered: isMastered,
    );
  }

  group('StageTransitionService', () {
    test('s0_correct_moves_to_s1_and_resets_pass_count', () {
      final result = service.applyStageTransition(
        progress: progress(stage: SrsStage.s0),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(result.progress.stage, SrsStage.s1);
      expect(result.progress.passCount, 0);
      expect(result.stageChanged, isTrue);
    });

    test('s1_requires_two_correct_answers_before_moving_to_s2', () {
      final firstCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s1),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(firstCorrect.progress.stage, SrsStage.s1);
      expect(firstCorrect.progress.passCount, 1);

      final secondCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s1, passCount: 1),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(secondCorrect.progress.stage, SrsStage.s2);
      expect(secondCorrect.progress.passCount, 0);
    });

    test('s2_requires_two_correct_answers_before_moving_to_s3', () {
      final firstCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s2),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(firstCorrect.progress.stage, SrsStage.s2);
      expect(firstCorrect.progress.passCount, 1);

      final secondCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s2, passCount: 1),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(secondCorrect.progress.stage, SrsStage.s3);
      expect(secondCorrect.progress.passCount, 0);
    });

    test('s3_requires_three_correct_answers_before_moving_to_s4', () {
      final firstCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s3),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(firstCorrect.progress.stage, SrsStage.s3);
      expect(firstCorrect.progress.passCount, 1);

      final secondCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s3, passCount: 1),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(secondCorrect.progress.stage, SrsStage.s3);
      expect(secondCorrect.progress.passCount, 2);

      final thirdCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s3, passCount: 2),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(thirdCorrect.progress.stage, SrsStage.s4);
      expect(thirdCorrect.progress.passCount, 0);
    });

    test('s4_requires_three_correct_answers_before_moving_to_s5', () {
      final firstCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s4),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(firstCorrect.progress.stage, SrsStage.s4);
      expect(firstCorrect.progress.passCount, 1);

      final secondCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s4, passCount: 1),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(secondCorrect.progress.stage, SrsStage.s4);
      expect(secondCorrect.progress.passCount, 2);

      final thirdCorrect = service.applyStageTransition(
        progress: progress(stage: SrsStage.s4, passCount: 2),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(thirdCorrect.progress.stage, SrsStage.s5);
      expect(thirdCorrect.progress.passCount, 0);
    });

    test('s5_wrong_falls_back_to_s3', () {
      final result = service.applyStageTransition(
        progress: progress(stage: SrsStage.s5),
        answer: ReviewAnswer.wrong,
        trainingArea: TrainingArea.all,
      );

      expect(result.progress.stage, SrsStage.s3);
      expect(result.progress.passCount, 0);
    });

    test('wrong_answer_resets_pass_count', () {
      final result = service.applyStageTransition(
        progress: progress(stage: SrsStage.s4, passCount: 2),
        answer: ReviewAnswer.wrong,
        trainingArea: TrainingArea.all,
      );

      expect(result.progress.stage, SrsStage.s3);
      expect(result.progress.passCount, 0);
      expect(result.progress.wrongCount, 1);
    });

    test('focused_training_does_not_change_srs_progress', () {
      final nextDueAt = DateTime(2026, 5, 20);
      final currentProgress = progress(
        stage: SrsStage.s3,
        passCount: 2,
        wrongCount: 4,
        nextDueAt: nextDueAt,
      );

      final result = service.applyStageTransition(
        progress: currentProgress,
        answer: ReviewAnswer.wrong,
        trainingArea: TrainingArea.focused,
      );

      expect(result.progress.stage, currentProgress.stage);
      expect(result.progress.passCount, currentProgress.passCount);
      expect(result.progress.wrongCount, currentProgress.wrongCount);
      expect(result.progress.nextDueAt, currentProgress.nextDueAt);
      expect(result.stageChanged, isFalse);
    });

    test('is_mastered_does_not_affect_stage_transition', () {
      final notMastered = service.applyStageTransition(
        progress: progress(stage: SrsStage.s0),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );
      final mastered = service.applyStageTransition(
        progress: progress(stage: SrsStage.s0, isMastered: true),
        answer: ReviewAnswer.correct,
        trainingArea: TrainingArea.all,
      );

      expect(mastered.progress.stage, notMastered.progress.stage);
      expect(mastered.progress.passCount, notMastered.progress.passCount);
    });
  });
}
