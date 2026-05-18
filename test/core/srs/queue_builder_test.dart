import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/new_card_policy.dart';
import 'package:talvori/core/srs/models/queue_build_input.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/session_config.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/core/srs/services/queue_builder.dart';

void main() {
  const builder = QueueBuilder();
  final now = DateTime(2026, 5, 13, 10);

  WordProgress progress({
    required int id,
    required LearningMode mode,
    required SrsStage stage,
  }) {
    return WordProgress(
      wordId: 'word-$id',
      categoryId: 'category-1',
      mode: mode,
      stage: stage,
      passCount: 0,
      wrongCount: 0,
    );
  }

  List<WordProgress> reviews(int count, LearningMode mode) {
    return [
      for (var index = 0; index < count; index++)
        progress(id: index, mode: mode, stage: SrsStage.s2),
    ];
  }

  List<WordProgress> newCards(int count, LearningMode mode) {
    return [
      for (var index = 0; index < count; index++)
        progress(id: 100 + index, mode: mode, stage: SrsStage.s0),
    ];
  }

  QueueBuildInput input({
    required LearningMode mode,
    TrainingArea trainingArea = TrainingArea.all,
    int sessionSize = 20,
    int reviewCount = 0,
    int newCount = 0,
    List<ReviewAnswer> recentAnswers = const [],
    bool allowExpandedTimeNewCards = false,
  }) {
    return QueueBuildInput(
      config: SessionConfig(
        mode: mode,
        trainingArea: trainingArea,
        now: now,
        sessionSize: sessionSize,
        allowExpandedTimeNewCards: allowExpandedTimeNewCards,
      ),
      dueReviewProgresses: reviews(reviewCount, mode),
      newProgresses: newCards(newCount, mode),
      recentAnswers: recentAnswers,
    );
  }

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

  group('QueueBuilder', () {
    test('queue_never_exceeds_session_size_twenty', () {
      final result = builder.buildSessionQueue(
        input(mode: LearningMode.time, reviewCount: 30, newCount: 30),
      );

      expect(result.items, hasLength(20));
      expect(result.reviewsIncluded, 20);
      expect(result.newCardsIncluded, 0);
    });

    test('review_only_contains_no_new_s0_cards', () {
      final result = builder.buildSessionQueue(
        input(
          mode: LearningMode.time,
          trainingArea: TrainingArea.reviewOnly,
          reviewCount: 4,
          newCount: 10,
        ),
      );

      expect(result.items, hasLength(4));
      expect(result.newCardsIncluded, 0);
      expect(result.items.any((item) => item.isNewCard), isFalse);
      expect(result.newCardPolicy, NewCardPolicy.blockedByTrainingArea);
    });

    test('time_mode_includes_max_five_new_s0_cards', () {
      final result = builder.buildSessionQueue(
        input(mode: LearningMode.time, reviewCount: 10, newCount: 20),
      );

      expect(result.items, hasLength(15));
      expect(result.reviewsIncluded, 10);
      expect(result.newCardsIncluded, 5);
    });

    test('time_mode_initial_session_can_include_twenty_new_s0_cards', () {
      final result = builder.buildSessionQueue(
        input(
          mode: LearningMode.time,
          reviewCount: 0,
          newCount: 30,
          allowExpandedTimeNewCards: true,
        ),
      );

      expect(result.items, hasLength(20));
      expect(result.reviewsIncluded, 0);
      expect(result.newCardsIncluded, 20);
    });

    test('time_mode_initial_session_keeps_due_reviews_first', () {
      final result = builder.buildSessionQueue(
        input(
          mode: LearningMode.time,
          reviewCount: 6,
          newCount: 30,
          allowExpandedTimeNewCards: true,
        ),
      );

      expect(result.items, hasLength(20));
      expect(result.reviewsIncluded, 6);
      expect(result.newCardsIncluded, 14);
      expect(result.items.take(6).every((item) => !item.isNewCard), isTrue);
    });

    test('hybrid_mode_includes_max_eight_new_s0_cards', () {
      final result = builder.buildSessionQueue(
        input(mode: LearningMode.hybrid, reviewCount: 10, newCount: 20),
      );

      expect(result.items, hasLength(18));
      expect(result.reviewsIncluded, 10);
      expect(result.newCardsIncluded, 8);
    });

    test('adaptive_without_reviews_can_include_twenty_new_s0_cards', () {
      final result = builder.buildSessionQueue(
        input(mode: LearningMode.adaptive, reviewCount: 0, newCount: 30),
      );

      expect(result.items, hasLength(20));
      expect(result.reviewsIncluded, 0);
      expect(result.newCardsIncluded, 20);
      expect(result.items.every((item) => item.isNewCard), isTrue);
    });

    test('adaptive_without_reviews_can_use_larger_local_session_size', () {
      final result = builder.buildSessionQueue(
        input(
          mode: LearningMode.adaptive,
          reviewCount: 0,
          newCount: 25,
          sessionSize: 25,
        ),
      );

      expect(result.items, hasLength(25));
      expect(result.reviewsIncluded, 0);
      expect(result.newCardsIncluded, 25);
      expect(result.items.every((item) => item.isNewCard), isTrue);
    });

    test('adaptive_mixes_two_reviews_then_one_new_card', () {
      final result = builder.buildSessionQueue(
        input(mode: LearningMode.adaptive, reviewCount: 12, newCount: 12),
      );

      expect(result.items.take(6).map((item) => item.isNewCard), [
        false,
        false,
        true,
        false,
        false,
        true,
      ]);
      expect(result.items, hasLength(20));
    });

    test(
      'adaptive_fills_remaining_slots_with_new_cards_when_reviews_are_insufficient',
      () {
        final result = builder.buildSessionQueue(
          input(mode: LearningMode.adaptive, reviewCount: 3, newCount: 30),
        );

        expect(result.items, hasLength(20));
        expect(result.reviewsIncluded, 3);
        expect(result.newCardsIncluded, 17);
      },
    );

    test('three_wrong_answers_block_new_cards_in_time_and_hybrid', () {
      final timeResult = builder.buildSessionQueue(
        input(
          mode: LearningMode.time,
          reviewCount: 5,
          newCount: 20,
          recentAnswers: threeWrongAnswersInLastTen,
        ),
      );
      final hybridResult = builder.buildSessionQueue(
        input(
          mode: LearningMode.hybrid,
          reviewCount: 5,
          newCount: 20,
          recentAnswers: threeWrongAnswersInLastTen,
        ),
      );

      expect(timeResult.reviewsIncluded, 5);
      expect(timeResult.newCardsIncluded, 0);
      expect(timeResult.newCardPolicy, NewCardPolicy.blockedByErrorRate);
      expect(hybridResult.reviewsIncluded, 5);
      expect(hybridResult.newCardsIncluded, 0);
      expect(hybridResult.newCardPolicy, NewCardPolicy.blockedByErrorRate);
    });

    test(
      'three_wrong_answers_stop_adaptive_auto_new_cards_but_keep_reviews',
      () {
        final result = builder.buildSessionQueue(
          input(
            mode: LearningMode.adaptive,
            reviewCount: 12,
            newCount: 20,
            recentAnswers: threeWrongAnswersInLastTen,
          ),
        );

        expect(result.items, hasLength(12));
        expect(result.reviewsIncluded, 12);
        expect(result.newCardsIncluded, 0);
        expect(result.newCardPolicy, NewCardPolicy.blockedByErrorRate);
      },
    );
  });
}
