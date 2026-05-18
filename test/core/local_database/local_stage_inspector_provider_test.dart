import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/local_stage_inspector_item.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_adjustment_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_counts_provider.dart';
import 'package:talvori/core/local_database/providers/local_stage_inspector_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';

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
}
