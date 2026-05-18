import '../models/review_answer.dart';
import '../models/srs_stage.dart';
import '../models/stage_transition_result.dart';
import '../models/training_area.dart';
import '../models/word_progress.dart';

class StageTransitionService {
  const StageTransitionService();

  StageTransitionResult applyStageTransition({
    required WordProgress progress,
    required ReviewAnswer answer,
    required TrainingArea trainingArea,
    bool preventPromotionFromS1 = false,
  }) {
    if (trainingArea == TrainingArea.focused) {
      return _result(progress: progress, oldProgress: progress);
    }

    final updatedProgress = switch (answer) {
      ReviewAnswer.correct => _applyCorrectAnswer(
        progress,
        preventPromotionFromS1: preventPromotionFromS1,
      ),
      ReviewAnswer.wrong => _applyWrongAnswer(progress),
    };

    return _result(progress: updatedProgress, oldProgress: progress);
  }

  WordProgress _applyCorrectAnswer(
    WordProgress progress, {
    required bool preventPromotionFromS1,
  }) {
    final requiredPasses = _requiredPassesForPromotion(progress.stage);

    if (requiredPasses == null) {
      return progress;
    }

    final nextPassCount = progress.passCount + 1;
    if (preventPromotionFromS1 && progress.stage == SrsStage.s1) {
      return progress.copyWith(
        passCount: _min(nextPassCount, requiredPasses - 1),
      );
    }

    if (nextPassCount < requiredPasses) {
      return progress.copyWith(passCount: nextPassCount);
    }

    return progress.copyWith(stage: _nextStage(progress.stage), passCount: 0);
  }

  int _min(int left, int right) => left < right ? left : right;

  WordProgress _applyWrongAnswer(WordProgress progress) {
    return progress.copyWith(
      stage: _fallbackStage(progress.stage),
      passCount: 0,
      wrongCount: progress.wrongCount + 1,
    );
  }

  int? _requiredPassesForPromotion(SrsStage stage) {
    return switch (stage) {
      SrsStage.s0 => 1,
      SrsStage.s1 => 2,
      SrsStage.s2 => 2,
      SrsStage.s3 => 3,
      SrsStage.s4 => 3,
      SrsStage.s5 => null,
    };
  }

  SrsStage _nextStage(SrsStage stage) {
    return switch (stage) {
      SrsStage.s0 => SrsStage.s1,
      SrsStage.s1 => SrsStage.s2,
      SrsStage.s2 => SrsStage.s3,
      SrsStage.s3 => SrsStage.s4,
      SrsStage.s4 => SrsStage.s5,
      SrsStage.s5 => SrsStage.s5,
    };
  }

  SrsStage _fallbackStage(SrsStage stage) {
    return switch (stage) {
      SrsStage.s0 => SrsStage.s0,
      SrsStage.s1 => SrsStage.s1,
      SrsStage.s2 => SrsStage.s1,
      SrsStage.s3 => SrsStage.s2,
      SrsStage.s4 => SrsStage.s3,
      SrsStage.s5 => SrsStage.s3,
    };
  }

  StageTransitionResult _result({
    required WordProgress progress,
    required WordProgress oldProgress,
  }) {
    return StageTransitionResult(
      progress: progress,
      oldStage: oldProgress.stage,
      newStage: progress.stage,
      oldPassCount: oldProgress.passCount,
      newPassCount: progress.passCount,
    );
  }
}
