import '../models/learning_mode.dart';
import '../models/new_card_policy.dart';
import '../models/new_card_policy_result.dart';
import '../models/review_answer.dart';
import '../models/training_area.dart';

class NewCardPolicyService {
  const NewCardPolicyService();

  static const int v1SessionSize = 20;
  static const int timeModeMaxNewCards = 5;
  static const int hybridModeMaxNewCards = 8;

  NewCardPolicyResult evaluate({
    required LearningMode mode,
    required TrainingArea trainingArea,
    required List<ReviewAnswer> recentAnswers,
    required int remainingSessionSlots,
    bool allowExpandedTimeNewCards = false,
  }) {
    assert(remainingSessionSlots >= 0);

    final maxNewCardsForMode = _maxNewCardsForMode(
      mode,
      remainingSessionSlots: remainingSessionSlots,
      allowExpandedTimeNewCards: allowExpandedTimeNewCards,
    );

    if (trainingArea == TrainingArea.reviewOnly ||
        trainingArea == TrainingArea.focused) {
      return NewCardPolicyResult(
        policy: NewCardPolicy.blockedByTrainingArea,
        allowedNewCardCount: 0,
        maxNewCardsForMode: maxNewCardsForMode,
        stopsAutomaticRefill: true,
        isHardLearningBlock: false,
      );
    }

    if (_hasThreeWrongAnswersInLastTen(recentAnswers)) {
      return NewCardPolicyResult(
        policy: NewCardPolicy.blockedByErrorRate,
        allowedNewCardCount: 0,
        maxNewCardsForMode: maxNewCardsForMode,
        stopsAutomaticRefill: true,
        isHardLearningBlock: mode != LearningMode.adaptive,
      );
    }

    final allowedNewCardCount = _min(maxNewCardsForMode, remainingSessionSlots);

    return NewCardPolicyResult(
      policy: allowedNewCardCount == 0
          ? NewCardPolicy.blockedBySessionLimit
          : NewCardPolicy.allowed,
      allowedNewCardCount: allowedNewCardCount,
      maxNewCardsForMode: maxNewCardsForMode,
      stopsAutomaticRefill: false,
      isHardLearningBlock: false,
    );
  }

  int _maxNewCardsForMode(
    LearningMode mode, {
    required int remainingSessionSlots,
    required bool allowExpandedTimeNewCards,
  }) {
    return switch (mode) {
      LearningMode.time =>
        allowExpandedTimeNewCards ? v1SessionSize : timeModeMaxNewCards,
      LearningMode.hybrid => hybridModeMaxNewCards,
      LearningMode.adaptive => remainingSessionSlots,
    };
  }

  bool _hasThreeWrongAnswersInLastTen(List<ReviewAnswer> recentAnswers) {
    final lastTenAnswers = recentAnswers.length <= 10
        ? recentAnswers
        : recentAnswers.sublist(recentAnswers.length - 10);

    return lastTenAnswers
            .where((answer) => answer == ReviewAnswer.wrong)
            .length >=
        3;
  }

  int _min(int left, int right) => left < right ? left : right;
}
