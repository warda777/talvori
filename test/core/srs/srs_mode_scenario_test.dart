import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/queue_build_input.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/review_input.dart';
import 'package:talvori/core/srs/models/review_result.dart';
import 'package:talvori/core/srs/models/session_config.dart';
import 'package:talvori/core/srs/models/session_context.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/core/srs/services/srs_engine.dart';

void main() {
  const engine = SrsEngine();
  final start = DateTime(2026, 5, 13, 10);

  WordProgress progress({
    LearningMode mode = LearningMode.time,
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
    DateTime? lastReviewedAt,
    bool isMastered = false,
  }) {
    return WordProgress(
      wordId: 'word-1',
      categoryId: 'category-1',
      mode: mode,
      stage: stage,
      passCount: passCount,
      wrongCount: wrongCount,
      nextDueAt: nextDueAt,
      lastReviewedAt: lastReviewedAt,
      isMastered: isMastered,
    );
  }

  ReviewResult review(
    WordProgress current, {
    ReviewAnswer answer = ReviewAnswer.correct,
    DateTime? reviewedAt,
    TrainingArea trainingArea = TrainingArea.all,
  }) {
    return engine.reviewCard(
      ReviewInput(
        progress: current,
        answer: answer,
        trainingArea: trainingArea,
        reviewedAt: reviewedAt ?? start,
        sessionContext: const SessionContext(
          sessionId: 'session-1',
          currentPosition: 0,
          recentAnswers: [],
          sameSessionWrongCountsByWordId: {},
          remainingQueueSize: 20,
        ),
      ),
    );
  }

  group('SRS mode scenarios', () {
    test('time_srs_full_scenario_respects_same_day_and_due_dates', () {
      var current = progress(mode: LearningMode.time);

      final s0Correct = review(current, reviewedAt: start);
      current = s0Correct.updatedProgress;
      expect(current.stage, SrsStage.s1);
      expect(current.passCount, 0);
      expect(current.nextDueAt, start.add(const Duration(days: 1)));

      final sameDayS1 = review(
        current.copyWith(passCount: 1),
        reviewedAt: start.add(const Duration(hours: 2)),
      );
      current = sameDayS1.updatedProgress;
      expect(current.stage, SrsStage.s1);
      expect(current.passCount, 1);
      expect(current.nextDueAt, start.add(const Duration(hours: 2, days: 1)));

      final nextDayS1 = review(
        current,
        reviewedAt: start.add(const Duration(days: 1, hours: 3)),
      );
      current = nextDayS1.updatedProgress;
      expect(current.stage, SrsStage.s2);
      expect(current.passCount, 0);
      expect(current.nextDueAt, start.add(const Duration(days: 4, hours: 3)));

      final masteredS5 = progress(
        mode: LearningMode.time,
        stage: SrsStage.s5,
        nextDueAt: start,
        isMastered: true,
      );
      final s5Repeat = review(masteredS5, reviewedAt: start);
      expect(s5Repeat.updatedProgress.stage, SrsStage.s5);
      expect(s5Repeat.updatedProgress.isMastered, isTrue);
      expect(s5Repeat.nextDueAt, start.add(const Duration(days: 30)));
    });

    test('adaptive_srs_can_climb_to_s5_same_day_with_thresholds', () {
      var current = progress(mode: LearningMode.adaptive);
      final stagesAfterCorrect = <SrsStage>[];
      final passCountsAfterCorrect = <int>[];

      for (var index = 0; index < 11; index++) {
        final result = review(
          current,
          reviewedAt: start.add(Duration(minutes: index)),
        );
        current = result.updatedProgress;
        stagesAfterCorrect.add(current.stage);
        passCountsAfterCorrect.add(current.passCount);
        expect(current.nextDueAt, start.add(Duration(minutes: index)));
      }

      expect(stagesAfterCorrect, [
        SrsStage.s1,
        SrsStage.s1,
        SrsStage.s2,
        SrsStage.s2,
        SrsStage.s3,
        SrsStage.s3,
        SrsStage.s3,
        SrsStage.s4,
        SrsStage.s4,
        SrsStage.s4,
        SrsStage.s5,
      ]);
      expect(passCountsAfterCorrect, [0, 1, 0, 1, 0, 1, 2, 0, 1, 2, 0]);

      final wrongFromS5 = review(
        current,
        answer: ReviewAnswer.wrong,
        reviewedAt: start.add(const Duration(minutes: 12)),
      );
      expect(wrongFromS5.updatedProgress.stage, SrsStage.s3);
      expect(wrongFromS5.updatedProgress.passCount, 0);
      expect(wrongFromS5.updatedProgress.wrongCount, 1);
      expect(wrongFromS5.nextDueAt, start.add(const Duration(minutes: 12)));
    });

    test('hybrid_srs_uses_adaptive_early_stages_and_timed_later_stages', () {
      var current = progress(mode: LearningMode.hybrid);

      for (var index = 0; index < 5; index++) {
        final result = review(
          current,
          reviewedAt: start.add(Duration(minutes: index)),
        );
        current = result.updatedProgress;
      }

      expect(current.stage, SrsStage.s3);
      expect(current.passCount, 0);
      expect(current.nextDueAt, start.add(const Duration(days: 1, minutes: 4)));

      final s3FirstPass = review(
        current,
        reviewedAt: start.add(const Duration(days: 1, minutes: 5)),
      );
      current = s3FirstPass.updatedProgress;
      expect(current.stage, SrsStage.s3);
      expect(current.passCount, 1);
      expect(current.nextDueAt, start.add(const Duration(days: 2, minutes: 5)));

      final s4Promoted = review(
        current.copyWith(passCount: 2),
        reviewedAt: start.add(const Duration(days: 3)),
      );
      current = s4Promoted.updatedProgress;
      expect(current.stage, SrsStage.s4);
      expect(current.passCount, 0);
      expect(current.nextDueAt, start.add(const Duration(days: 6)));

      final s5Wrong = review(
        current.copyWith(stage: SrsStage.s5, passCount: 0),
        answer: ReviewAnswer.wrong,
        reviewedAt: start.add(const Duration(days: 10)),
      );
      expect(s5Wrong.updatedProgress.stage, SrsStage.s3);
      expect(s5Wrong.nextDueAt, start.add(const Duration(days: 11)));
    });

    test('focused_training_does_not_change_normal_progress', () {
      final dueAt = start.add(const Duration(days: 5));
      final current = progress(
        mode: LearningMode.hybrid,
        stage: SrsStage.s5,
        passCount: 2,
        wrongCount: 4,
        nextDueAt: dueAt,
        lastReviewedAt: start.subtract(const Duration(days: 1)),
        isMastered: true,
      );

      final result = review(
        current,
        answer: ReviewAnswer.wrong,
        trainingArea: TrainingArea.focused,
      );

      expect(result.updatedProgress.stage, current.stage);
      expect(result.updatedProgress.passCount, current.passCount);
      expect(result.updatedProgress.wrongCount, current.wrongCount);
      expect(result.updatedProgress.nextDueAt, dueAt);
      expect(result.updatedProgress.lastReviewedAt, current.lastReviewedAt);
      expect(result.updatedProgress.isMastered, isTrue);
      expect(result.requeueDecision, isNull);
    });

    test('error_rate_blocks_or_stops_new_s0_by_mode', () {
      const recentAnswers = [
        ReviewAnswer.correct,
        ReviewAnswer.wrong,
        ReviewAnswer.correct,
        ReviewAnswer.correct,
        ReviewAnswer.wrong,
        ReviewAnswer.correct,
        ReviewAnswer.correct,
        ReviewAnswer.wrong,
        ReviewAnswer.correct,
        ReviewAnswer.correct,
      ];

      QueueBuildInput input(LearningMode mode) {
        return QueueBuildInput(
          config: SessionConfig(
            mode: mode,
            trainingArea: TrainingArea.all,
            now: start,
          ),
          dueReviewProgresses: [
            for (var index = 0; index < 4; index++)
              progress(
                mode: mode,
                stage: SrsStage.s2,
              ).copyWith(wordId: 'review-$index'),
          ],
          newProgresses: [
            for (var index = 0; index < 10; index++)
              progress(mode: mode).copyWith(wordId: 'new-$index'),
          ],
          recentAnswers: recentAnswers,
        );
      }

      final time = engine.buildSessionQueue(input(LearningMode.time));
      final adaptive = engine.buildSessionQueue(input(LearningMode.adaptive));
      final hybrid = engine.buildSessionQueue(input(LearningMode.hybrid));

      expect(time.reviewsIncluded, 4);
      expect(time.newCardsIncluded, 0);
      expect(adaptive.reviewsIncluded, 4);
      expect(adaptive.newCardsIncluded, 0);
      expect(hybrid.reviewsIncluded, 4);
      expect(hybrid.newCardsIncluded, 0);
    });
  });
}
