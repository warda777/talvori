import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/new_card_policy.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/core/srs/services/new_card_policy_service.dart';

void main() {
  const service = NewCardPolicyService();

  const stableRecentAnswers = [
    ReviewAnswer.correct,
    ReviewAnswer.correct,
    ReviewAnswer.wrong,
    ReviewAnswer.correct,
    ReviewAnswer.correct,
  ];

  const threeWrongAnswersInLastTen = [
    ReviewAnswer.correct,
    ReviewAnswer.correct,
    ReviewAnswer.wrong,
    ReviewAnswer.correct,
    ReviewAnswer.wrong,
    ReviewAnswer.correct,
    ReviewAnswer.correct,
    ReviewAnswer.wrong,
    ReviewAnswer.correct,
    ReviewAnswer.correct,
  ];

  group('NewCardPolicyService', () {
    test('review_only_blocks_new_s0_cards', () {
      final result = service.evaluate(
        mode: LearningMode.time,
        trainingArea: TrainingArea.reviewOnly,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 20,
      );

      expect(result.policy, NewCardPolicy.blockedByTrainingArea);
      expect(result.allowedNewCardCount, 0);
      expect(result.allowsNewCards, isFalse);
      expect(result.stopsAutomaticRefill, isTrue);
      expect(result.isHardLearningBlock, isFalse);
    });

    test('focused_blocks_new_s0_cards_for_normal_progression', () {
      final result = service.evaluate(
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.focused,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 20,
      );

      expect(result.policy, NewCardPolicy.blockedByTrainingArea);
      expect(result.allowedNewCardCount, 0);
      expect(result.allowsNewCards, isFalse);
      expect(result.stopsAutomaticRefill, isTrue);
      expect(result.isHardLearningBlock, isFalse);
    });

    test('time_mode_allows_max_five_new_cards', () {
      final result = service.evaluate(
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 20,
      );

      expect(result.policy, NewCardPolicy.allowed);
      expect(result.maxNewCardsForMode, 5);
      expect(result.allowedNewCardCount, 5);
      expect(result.allowsNewCards, isTrue);
    });

    test('hybrid_mode_allows_max_eight_new_cards', () {
      final result = service.evaluate(
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.all,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 20,
      );

      expect(result.policy, NewCardPolicy.allowed);
      expect(result.maxNewCardsForMode, 8);
      expect(result.allowedNewCardCount, 8);
      expect(result.allowsNewCards, isTrue);
    });

    test(
      'adaptive_mode_allows_up_to_session_size_without_hard_daily_limit',
      () {
        final result = service.evaluate(
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          recentAnswers: stableRecentAnswers,
          remainingSessionSlots: 20,
        );

        expect(result.policy, NewCardPolicy.allowed);
        expect(result.maxNewCardsForMode, 20);
        expect(result.allowedNewCardCount, 20);
        expect(result.isHardLearningBlock, isFalse);
      },
    );

    test('adaptive_mode_can_use_more_than_twenty_session_slots', () {
      final result = service.evaluate(
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 25,
      );

      expect(result.policy, NewCardPolicy.allowed);
      expect(result.maxNewCardsForMode, 25);
      expect(result.allowedNewCardCount, 25);
    });

    test(
      'three_wrong_answers_in_last_ten_blocks_time_and_hybrid_new_cards',
      () {
        final timeResult = service.evaluate(
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          recentAnswers: threeWrongAnswersInLastTen,
          remainingSessionSlots: 20,
        );
        final hybridResult = service.evaluate(
          mode: LearningMode.hybrid,
          trainingArea: TrainingArea.all,
          recentAnswers: threeWrongAnswersInLastTen,
          remainingSessionSlots: 20,
        );

        expect(timeResult.policy, NewCardPolicy.blockedByErrorRate);
        expect(timeResult.allowedNewCardCount, 0);
        expect(timeResult.stopsAutomaticRefill, isTrue);
        expect(timeResult.isHardLearningBlock, isTrue);
        expect(hybridResult.policy, NewCardPolicy.blockedByErrorRate);
        expect(hybridResult.allowedNewCardCount, 0);
        expect(hybridResult.stopsAutomaticRefill, isTrue);
        expect(hybridResult.isHardLearningBlock, isTrue);
      },
    );

    test(
      'three_wrong_answers_in_last_ten_stops_adaptive_auto_refill_but_not_learning',
      () {
        final result = service.evaluate(
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          recentAnswers: threeWrongAnswersInLastTen,
          remainingSessionSlots: 20,
        );

        expect(result.policy, NewCardPolicy.blockedByErrorRate);
        expect(result.allowedNewCardCount, 0);
        expect(result.stopsAutomaticRefill, isTrue);
        expect(result.isHardLearningBlock, isFalse);
      },
    );

    test('new_cards_never_exceed_remaining_session_slots', () {
      final timeResult = service.evaluate(
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 3,
      );
      final hybridResult = service.evaluate(
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.all,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 6,
      );
      final adaptiveResult = service.evaluate(
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        recentAnswers: stableRecentAnswers,
        remainingSessionSlots: 12,
      );

      expect(timeResult.allowedNewCardCount, 3);
      expect(hybridResult.allowedNewCardCount, 6);
      expect(adaptiveResult.allowedNewCardCount, 12);
    });
  });
}
