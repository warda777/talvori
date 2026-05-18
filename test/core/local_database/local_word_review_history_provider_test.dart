import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/local_review_visual_feedback.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
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
    final container = ProviderContainer(
      overrides: [
        localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
      final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
      await databaseFactoryFfi.deleteDatabase(databasePath);
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    return container;
  }

  test(
    'localWordReviewHistoryProvider filters_by_word_category_and_mode',
    () async {
      final container = await createContainer(
        'talvori_local_word_review_history_provider_test_',
      );
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repository = bootstrap.repositoryFactory.reviewHistoryRepository;
      final now = DateTime(2026, 1, 1, 10);

      await repository.insertReviewEvent(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        answer: ReviewAnswer.correct,
        reviewedAt: now,
        oldStage: SrsStage.s0,
        newStage: SrsStage.s1,
        oldPassCount: 0,
        newPassCount: 0,
        createdAt: now,
      );
      await repository.insertReviewEvent(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.all,
        answer: ReviewAnswer.wrong,
        reviewedAt: now.add(const Duration(minutes: 1)),
        oldStage: SrsStage.s1,
        newStage: SrsStage.s1,
        oldPassCount: 1,
        newPassCount: 0,
        createdAt: now,
      );
      await repository.insertReviewEvent(
        wordId: 'seed-travel-ticket',
        categoryId: 'seed-category-travel',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        answer: ReviewAnswer.correct,
        reviewedAt: now.add(const Duration(minutes: 2)),
        oldStage: SrsStage.s0,
        newStage: SrsStage.s1,
        oldPassCount: 0,
        newPassCount: 0,
        createdAt: now,
      );
      await repository.insertReviewEvent(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        answer: ReviewAnswer.correct,
        reviewedAt: now.add(const Duration(minutes: 3)),
        oldStage: SrsStage.s1,
        newStage: SrsStage.s1,
        oldPassCount: 0,
        newPassCount: 1,
        createdAt: now,
      );

      final history = await container.read(
        localWordReviewHistoryProvider(
          const LocalWordReviewHistoryRequest(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
          ),
        ).future,
      );

      expect(history, hasLength(2));
      expect(history.first.description, 'Wiederholung 1 in S1');
      expect(
        history.first.outcomeType,
        LocalReviewOutcomeType.repeatedSameStage,
      );
      expect(history.first.colorValue, 0xFF5DDCFF);
      expect(history.last.description, 'Richtig: S0 -> S1');
      expect(history.last.outcomeType, LocalReviewOutcomeType.promoted);
      expect(history.last.colorValue, 0xFF36F58A);
    },
  );

  test(
    'localWordReviewHistoryProvider maps_wrong_events_to_red_feedback',
    () async {
      final container = await createContainer(
        'talvori_local_word_review_history_provider_wrong_test_',
      );
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repository = bootstrap.repositoryFactory.reviewHistoryRepository;
      final now = DateTime(2026, 1, 1, 10);

      await repository.insertReviewEvent(
        wordId: 'seed-basics-hello',
        categoryId: 'seed-category-basics',
        mode: LearningMode.adaptive,
        trainingArea: TrainingArea.all,
        answer: ReviewAnswer.wrong,
        reviewedAt: now,
        oldStage: SrsStage.s3,
        newStage: SrsStage.s2,
        oldPassCount: 2,
        newPassCount: 0,
        createdAt: now,
      );

      final history = await container.read(
        localWordReviewHistoryProvider(
          const LocalWordReviewHistoryRequest(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
          ),
        ).future,
      );

      expect(history, hasLength(1));
      expect(history.single.description, 'Falsch: S3 -> S2');
      expect(history.single.outcomeType, LocalReviewOutcomeType.demoted);
      expect(history.single.colorValue, 0xFFFF4B6E);
    },
  );
}
