import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/local_review_visual_feedback.dart';
import 'package:talvori/core/local_database/models/local_stage_inspector_item.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_category_progress_reset_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_adjustment_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_counts_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_review_history_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<ProviderContainer> createContainer(String prefix) async {
    final tempDir = await Directory.systemTemp.createTemp(prefix);
    late final ProviderContainer container;

    addTearDown(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
      await databaseFactoryFfi.deleteDatabase(databasePath);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    container = ProviderContainer(
      overrides: [
        localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
      ],
    );
    return container;
  }

  group('localStageInspectorProvider', () {
    test('loads_words_and_progress_for_requested_stage', () async {
      final container = await createContainer('talvori_stage_inspector_');
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      await repositories.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            now: DateTime(2026, 1, 1),
          );

      final progress = await repositories.wordProgressRepository.loadProgress(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
      );
      await repositories.wordProgressRepository.saveProgress(
        updatedProgress: progress!.copyWith(
          stage: SrsStage.s2,
          passCount: 1,
          wrongCount: 2,
        ),
        updatedAt: DateTime(2026, 1, 2),
      );

      final items = await container.read(
        localStageInspectorProvider(
          const LocalStageInspectorRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            stage: SrsStage.s2,
          ),
        ).future,
      );

      expect(items.map((item) => item.wordId), contains('seed-basics-hello'));
      final hello = items.singleWhere(
        (item) => item.wordId == 'seed-basics-hello',
      );
      expect(hello.term, 'hello');
      expect(hello.translation, 'hallo');
      expect(hello.passCount, 1);
      expect(hello.wrongCount, 2);
    });

    test('returns_empty_list_when_no_words_are_in_stage', () async {
      final container = await createContainer('talvori_stage_inspector_empty_');

      final items = await container.read(
        localStageInspectorProvider(
          const LocalStageInspectorRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            stage: SrsStage.s4,
          ),
        ).future,
      );

      expect(items, isEmpty);
    });

    test('keeps_category_and_mode_separate', () async {
      final container = await createContainer(
        'talvori_stage_inspector_isolation_',
      );
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      for (final mode in [LearningMode.adaptive, LearningMode.time]) {
        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: 'seed-category-basics',
              mode: mode,
              now: DateTime(2026, 1, 1),
            );
      }

      final adaptiveProgress = await repositories.wordProgressRepository
          .loadProgress(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
          );
      await repositories.wordProgressRepository.saveProgress(
        updatedProgress: adaptiveProgress!.copyWith(stage: SrsStage.s3),
        updatedAt: DateTime(2026, 1, 2),
      );

      final adaptiveItems = await container.read(
        localStageInspectorProvider(
          const LocalStageInspectorRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            stage: SrsStage.s3,
          ),
        ).future,
      );
      final timeItems = await container.read(
        localStageInspectorProvider(
          const LocalStageInspectorRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.time,
            stage: SrsStage.s3,
          ),
        ).future,
      );

      expect(
        adaptiveItems.map((item) => item.wordId),
        contains('seed-basics-hello'),
      );
      expect(timeItems, isEmpty);
    });

    test(
      'submit_wrong_in_s1_keeps_word_in_s1_and_updates_wrong_feedback',
      () async {
        final container = await createContainer('talvori_stage_wrong_s1_');
        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final now = DateTime(2026, 1, 1);
        const categoryId = 'wrong-s1-category';
        const wordId = 'wrong-s1-word';
        const request = LocalStageInspectorRequest(
          categoryId: categoryId,
          mode: LearningMode.adaptive,
          stage: SrsStage.s1,
        );

        await repositories.categoryRepository.upsertCategory(
          id: categoryId,
          name: 'Wrong S1',
          sortOrder: 1,
          now: now,
        );
        await repositories.wordRepository.upsertWord(
          id: wordId,
          categoryId: categoryId,
          term: 'checkup',
          translation: 'Kontrolle',
          exampleSentence: 'A quick checkup.',
          notes: 'Wrong S1 test word',
          sortOrder: 1,
          now: now,
        );
        await container
            .read(localLearningControllerProvider.notifier)
            .startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now,
            );
        expect(
          container
              .read(localLearningControllerProvider)
              .readState!
              .currentWordId,
          wordId,
        );
        await container
            .read(localLearningControllerProvider.notifier)
            .submitCorrect(now: now.add(const Duration(minutes: 1)));

        final beforeItems = await container.read(
          localStageInspectorProvider(request).future,
        );
        expect(beforeItems.single.wrongCount, 0);
        expect(
          beforeItems.single.lastFeedback!.outcomeType,
          LocalReviewOutcomeType.promoted,
        );

        await container
            .read(localLearningControllerProvider.notifier)
            .submitWrong(now: now.add(const Duration(minutes: 2)));

        final updatedProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: wordId,
              categoryId: categoryId,
              mode: LearningMode.adaptive,
            );
        final afterItems = await container.read(
          localStageInspectorProvider(request).future,
        );
        final history = await container.read(
          localWordReviewHistoryProvider(
            const LocalWordReviewHistoryRequest(
              wordId: wordId,
              categoryId: categoryId,
              mode: LearningMode.adaptive,
            ),
          ).future,
        );

        expect(updatedProgress!.stage, SrsStage.s1);
        expect(updatedProgress.wrongCount, 1);
        expect(afterItems.single.wordId, wordId);
        expect(afterItems.single.wrongCount, 1);
        expect(
          afterItems.single.lastFeedback!.outcomeType,
          LocalReviewOutcomeType.unchangedWrong,
        );
        expect(history.first.description, 'Falsch: bleibt S1');
      },
    );

    test(
      'submit_wrong_from_s3_moves_word_to_s2_inspector_and_preserves_other_contexts',
      () async {
        final container = await createContainer('talvori_stage_wrong_s3_');
        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final now = DateTime(2026, 1, 1);
        const categoryId = 'wrong-s3-category';
        const otherCategoryId = 'wrong-s3-other-category';
        const wordId = 'wrong-s3-word';
        const otherWordId = 'wrong-s3-other-word';

        await repositories.categoryRepository.upsertCategory(
          id: categoryId,
          name: 'Wrong S3',
          sortOrder: 1,
          now: now,
        );
        await repositories.categoryRepository.upsertCategory(
          id: otherCategoryId,
          name: 'Wrong S3 Other',
          sortOrder: 2,
          now: now,
        );
        await repositories.wordRepository.upsertWord(
          id: wordId,
          categoryId: categoryId,
          term: 'strength',
          translation: 'Stärke',
          exampleSentence: 'Build strength.',
          notes: 'Wrong S3 test word',
          sortOrder: 1,
          now: now,
        );
        await repositories.wordRepository.upsertWord(
          id: otherWordId,
          categoryId: otherCategoryId,
          term: 'balance',
          translation: 'Gleichgewicht',
          exampleSentence: 'Keep balance.',
          notes: 'Other category word',
          sortOrder: 1,
          now: now,
        );

        for (final mode in [LearningMode.adaptive, LearningMode.time]) {
          await repositories.progressInitializationService
              .initializeProgressForCategoryAndMode(
                categoryId: categoryId,
                mode: mode,
                now: now,
              );
        }
        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: otherCategoryId,
              mode: LearningMode.adaptive,
              now: now,
            );

        final timeProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: wordId,
              categoryId: categoryId,
              mode: LearningMode.time,
            );
        final otherProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: otherWordId,
              categoryId: otherCategoryId,
              mode: LearningMode.adaptive,
            );

        await repositories.wordProgressRepository.saveProgress(
          updatedProgress: timeProgress!.copyWith(stage: SrsStage.s4),
          updatedAt: now,
        );
        await repositories.wordProgressRepository.saveProgress(
          updatedProgress: otherProgress!.copyWith(stage: SrsStage.s4),
          updatedAt: now,
        );

        await container
            .read(localLearningControllerProvider.notifier)
            .startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now,
            );
        for (var index = 0; index < 5; index += 1) {
          await container
              .read(localLearningControllerProvider.notifier)
              .submitCorrect(now: now.add(Duration(minutes: index + 1)));
        }

        final beforeS3Items = await container.read(
          localStageInspectorProvider(
            const LocalStageInspectorRequest(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              stage: SrsStage.s3,
            ),
          ).future,
        );
        expect(beforeS3Items.map((item) => item.wordId), contains(wordId));

        await container
            .read(localLearningControllerProvider.notifier)
            .submitWrong(now: now.add(const Duration(minutes: 6)));

        final updatedAdaptiveProgress = await repositories
            .wordProgressRepository
            .loadProgress(
              wordId: wordId,
              categoryId: categoryId,
              mode: LearningMode.adaptive,
            );
        final unchangedTimeProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: wordId,
              categoryId: categoryId,
              mode: LearningMode.time,
            );
        final unchangedOtherProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: otherWordId,
              categoryId: otherCategoryId,
              mode: LearningMode.adaptive,
            );
        final counts = await container.read(
          localStageCountsProvider(
            const LocalStageCountsRequest(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
            ),
          ).future,
        );
        final s2Items = await container.read(
          localStageInspectorProvider(
            const LocalStageInspectorRequest(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              stage: SrsStage.s2,
            ),
          ).future,
        );
        final s3Items = await container.read(
          localStageInspectorProvider(
            const LocalStageInspectorRequest(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              stage: SrsStage.s3,
            ),
          ).future,
        );

        expect(updatedAdaptiveProgress!.stage, SrsStage.s2);
        expect(updatedAdaptiveProgress.wrongCount, 1);
        expect(counts[SrsStage.s2.index], 1);
        expect(counts[SrsStage.s3.index], 0);
        expect(s2Items.map((item) => item.wordId), contains(wordId));
        expect(
          s2Items.single.lastFeedback!.outcomeType,
          LocalReviewOutcomeType.demoted,
        );
        expect(s3Items, isEmpty);
        expect(unchangedTimeProgress!.stage, SrsStage.s4);
        expect(unchangedOtherProgress!.stage, SrsStage.s4);
      },
    );
  });

  group('localStageAdjustmentControllerProvider', () {
    test('demotes_word_and_updates_stage_counts', () async {
      final container = await createContainer('talvori_stage_demote_');
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      await repositories.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            now: DateTime(2026, 1, 1),
          );
      final progress = await repositories.wordProgressRepository.loadProgress(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
      );
      await repositories.wordProgressRepository.saveProgress(
        updatedProgress: progress!.copyWith(
          stage: SrsStage.s4,
          passCount: 2,
          wrongCount: 3,
        ),
        updatedAt: DateTime(2026, 1, 2),
      );

      await container
          .read(localStageAdjustmentControllerProvider)
          .demoteWordToStage(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            targetStage: SrsStage.s0,
            now: DateTime(2026, 1, 3),
          );

      final updated = await repositories.wordProgressRepository.loadProgress(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
      );
      final counts = await container.read(
        localStageCountsProvider(
          const LocalStageCountsRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
          ),
        ).future,
      );

      expect(updated!.stage, SrsStage.s0);
      expect(updated.passCount, 0);
      expect(updated.wrongCount, 3);
      expect(updated.nextDueAt, isNull);
      expect(counts[SrsStage.s0.index], 25);
    });

    test('rejects_manual_promotion_and_preserves_other_modes', () async {
      final container = await createContainer('talvori_stage_demote_reject_');
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      for (final mode in [LearningMode.adaptive, LearningMode.time]) {
        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: 'seed-category-basics',
              mode: mode,
              now: DateTime(2026, 1, 1),
            );
      }
      final adaptiveProgress = await repositories.wordProgressRepository
          .loadProgress(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
          );
      final timeProgress = await repositories.wordProgressRepository
          .loadProgress(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.time,
          );
      await repositories.wordProgressRepository.saveProgress(
        updatedProgress: adaptiveProgress!.copyWith(stage: SrsStage.s2),
        updatedAt: DateTime(2026, 1, 2),
      );
      await repositories.wordProgressRepository.saveProgress(
        updatedProgress: timeProgress!.copyWith(stage: SrsStage.s4),
        updatedAt: DateTime(2026, 1, 2),
      );

      expect(
        () => container
            .read(localStageAdjustmentControllerProvider)
            .demoteWordToStage(
              wordId: 'seed-basics-hello',
              categoryId: 'seed-category-basics',
              mode: LearningMode.adaptive,
              targetStage: SrsStage.s3,
              now: DateTime(2026, 1, 3),
            ),
        throwsA(isA<StateError>()),
      );

      await container
          .read(localStageAdjustmentControllerProvider)
          .demoteWordToStage(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            targetStage: SrsStage.s1,
            now: DateTime(2026, 1, 3),
          );

      final adaptiveAfter = await repositories.wordProgressRepository
          .loadProgress(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
          );
      final timeAfter = await repositories.wordProgressRepository.loadProgress(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.time,
      );

      expect(adaptiveAfter!.stage, SrsStage.s1);
      expect(timeAfter!.stage, SrsStage.s4);
    });
  });

  group('localCategoryProgressResetServiceProvider', () {
    test(
      'reset_clears_review_history_and_stage_feedback_for_selected_context_only',
      () async {
        final container = await createContainer('talvori_stage_reset_history_');
        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final now = DateTime(2026, 1, 1);

        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: 'seed-category-basics',
              mode: LearningMode.adaptive,
              now: now,
            );
        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: 'seed-category-basics',
              mode: LearningMode.time,
              now: now,
            );
        await repositories.progressInitializationService
            .initializeProgressForCategoryAndMode(
              categoryId: 'seed-category-travel',
              mode: LearningMode.adaptive,
              now: now,
            );

        final adaptiveProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: 'seed-basics-hello',
              categoryId: 'seed-category-basics',
              mode: LearningMode.adaptive,
            );
        final timeProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: 'seed-basics-hello',
              categoryId: 'seed-category-basics',
              mode: LearningMode.time,
            );
        final travelProgress = await repositories.wordProgressRepository
            .loadProgress(
              wordId: 'seed-travel-ticket',
              categoryId: 'seed-category-travel',
              mode: LearningMode.adaptive,
            );

        await repositories.wordProgressRepository.saveProgress(
          updatedProgress: adaptiveProgress!.copyWith(
            stage: SrsStage.s2,
            passCount: 1,
          ),
          updatedAt: now,
        );
        await repositories.wordProgressRepository.saveProgress(
          updatedProgress: timeProgress!.copyWith(stage: SrsStage.s3),
          updatedAt: now,
        );
        await repositories.wordProgressRepository.saveProgress(
          updatedProgress: travelProgress!.copyWith(stage: SrsStage.s4),
          updatedAt: now,
        );

        await repositories.reviewHistoryRepository.insertReviewEvent(
          wordId: 'seed-basics-hello',
          categoryId: 'seed-category-basics',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          answer: ReviewAnswer.correct,
          reviewedAt: now,
          oldStage: SrsStage.s1,
          newStage: SrsStage.s2,
          oldPassCount: 1,
          newPassCount: 0,
          createdAt: now,
        );
        await repositories.reviewHistoryRepository.insertReviewEvent(
          wordId: 'seed-basics-hello',
          categoryId: 'seed-category-basics',
          mode: LearningMode.time,
          trainingArea: TrainingArea.all,
          answer: ReviewAnswer.correct,
          reviewedAt: now,
          oldStage: SrsStage.s2,
          newStage: SrsStage.s3,
          oldPassCount: 1,
          newPassCount: 0,
          createdAt: now,
        );
        await repositories.reviewHistoryRepository.insertReviewEvent(
          wordId: 'seed-travel-ticket',
          categoryId: 'seed-category-travel',
          mode: LearningMode.adaptive,
          trainingArea: TrainingArea.all,
          answer: ReviewAnswer.correct,
          reviewedAt: now,
          oldStage: SrsStage.s3,
          newStage: SrsStage.s4,
          oldPassCount: 1,
          newPassCount: 0,
          createdAt: now,
        );

        await container
            .read(localCategoryProgressResetServiceProvider)
            .resetToS0(
              const LocalCategoryProgressResetRequest(
                categoryId: 'seed-category-basics',
                mode: LearningMode.adaptive,
              ),
            );

        final resetHistory = await container.read(
          localWordReviewHistoryProvider(
            const LocalWordReviewHistoryRequest(
              wordId: 'seed-basics-hello',
              categoryId: 'seed-category-basics',
              mode: LearningMode.adaptive,
            ),
          ).future,
        );
        final timeHistory = await container.read(
          localWordReviewHistoryProvider(
            const LocalWordReviewHistoryRequest(
              wordId: 'seed-basics-hello',
              categoryId: 'seed-category-basics',
              mode: LearningMode.time,
            ),
          ).future,
        );
        final travelHistory = await container.read(
          localWordReviewHistoryProvider(
            const LocalWordReviewHistoryRequest(
              wordId: 'seed-travel-ticket',
              categoryId: 'seed-category-travel',
              mode: LearningMode.adaptive,
            ),
          ).future,
        );
        final s2Items = await container.read(
          localStageInspectorProvider(
            const LocalStageInspectorRequest(
              categoryId: 'seed-category-basics',
              mode: LearningMode.adaptive,
              stage: SrsStage.s2,
            ),
          ).future,
        );
        final s0Items = await container.read(
          localStageInspectorProvider(
            const LocalStageInspectorRequest(
              categoryId: 'seed-category-basics',
              mode: LearningMode.adaptive,
              stage: SrsStage.s0,
            ),
          ).future,
        );
        final hello = s0Items.singleWhere(
          (item) => item.wordId == 'seed-basics-hello',
        );

        expect(resetHistory, isEmpty);
        expect(timeHistory, hasLength(1));
        expect(travelHistory, hasLength(1));
        expect(s2Items, isEmpty);
        expect(hello.lastFeedback, isNull);
      },
    );
  });
}
