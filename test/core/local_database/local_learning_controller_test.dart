import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LocalLearningController', () {
    test('local_learning_controller_start_loads_read_state', () async {
      final now = DateTime(2026, 5, 13, 10);
      const categoryId = 'controller-category-basics';
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_learning_controller_test_',
      );
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

      final bootstrapResult = await container.read(
        localBootstrapProvider.future,
      );
      await bootstrapResult.repositoryFactory.categoryRepository.upsertCategory(
        id: categoryId,
        name: 'Controller Basics',
        sortOrder: 1,
        now: now,
      );
      await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
        id: 'controller-word-hello',
        categoryId: categoryId,
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello there.',
        notes: 'Greeting',
        sortOrder: 1,
        now: now,
      );
      await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
        id: 'controller-word-water',
        categoryId: categoryId,
        term: 'water',
        translation: 'Wasser',
        exampleSentence: 'I drink water.',
        notes: 'Basic noun',
        sortOrder: 2,
        now: now,
      );

      final initialState = container.read(localLearningControllerProvider);

      expect(initialState.readState, isNull);
      expect(initialState.isLoading, isFalse);

      await container.read(localLearningControllerProvider.notifier).startOrResume(
            categoryId: categoryId,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );

      final state = container.read(localLearningControllerProvider);
      final readState = state.readState;

      expect(readState, isNotNull);
      expect(readState!.currentWordId, isNotNull);
      expect(readState.currentTerm, isNotNull);
      expect(readState.currentStage, SrsStage.s0);
      expect(readState.canSubmitAnswer, isTrue);
      expect(
        state.lastAction,
        LocalLearningControllerAction.startOrResume,
      );
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
    });

    test('local_learning_controller_submit_correct_updates_state', () async {
      final now = DateTime(2026, 5, 13, 10);
      const categoryId = 'controller-submit-correct-category';
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_learning_controller_correct_test_',
      );
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

      final bootstrapResult = await container.read(
        localBootstrapProvider.future,
      );
      await bootstrapResult.repositoryFactory.categoryRepository.upsertCategory(
        id: categoryId,
        name: 'Controller Submit Correct',
        sortOrder: 1,
        now: now,
      );
      await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
        id: 'controller-correct-word-hello',
        categoryId: categoryId,
        term: 'hello',
        translation: 'hallo',
        exampleSentence: 'Hello there.',
        notes: 'Greeting',
        sortOrder: 1,
        now: now,
      );
      await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
        id: 'controller-correct-word-water',
        categoryId: categoryId,
        term: 'water',
        translation: 'Wasser',
        exampleSentence: 'I drink water.',
        notes: 'Basic noun',
        sortOrder: 2,
        now: now,
      );

      await container.read(localLearningControllerProvider.notifier).startOrResume(
            categoryId: categoryId,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );

      final beforeState = container.read(localLearningControllerProvider);
      final beforeReadState = beforeState.readState!;

      await container.read(localLearningControllerProvider.notifier).submitCorrect(
            now: now.add(const Duration(minutes: 1)),
          );

      final state = container.read(localLearningControllerProvider);
      final readState = state.readState;
      final retryItems = await bootstrapResult.database.query(
        'session_items',
        where: 'status = ?',
        whereArgs: ['retryPending'],
      );

      expect(readState, isNotNull);
      expect(readState!.answeredCount, beforeReadState.answeredCount + 1);
      expect(readState.currentPosition, beforeReadState.currentPosition + 1);
      expect(
        state.lastAction,
        LocalLearningControllerAction.submitCorrect,
      );
      expect(state.errorMessage, isNull);
      expect(state.isLoading, isFalse);
      expect(retryItems, isEmpty);
    });

    test(
      'local_learning_controller_submit_wrong_updates_state_with_requeue',
      () async {
        final now = DateTime(2026, 5, 13, 10);
        const categoryId = 'controller-submit-wrong-category';
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_learning_controller_wrong_test_',
        );
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

        final bootstrapResult = await container.read(
          localBootstrapProvider.future,
        );
        await bootstrapResult.repositoryFactory.categoryRepository
            .upsertCategory(
              id: categoryId,
              name: 'Controller Submit Wrong',
              sortOrder: 1,
              now: now,
            );

        for (var index = 0; index < 12; index += 1) {
          await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
            id: 'controller-wrong-word-$index',
            categoryId: categoryId,
            term: 'term $index',
            translation: 'translation $index',
            exampleSentence: 'Example $index.',
            notes: 'Wrong test word',
            sortOrder: index,
            now: now,
          );
        }

        await container
            .read(localLearningControllerProvider.notifier)
            .startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now,
            );

        final beforeState = container.read(localLearningControllerProvider);
        final beforeReadState = beforeState.readState!;

        await container
            .read(localLearningControllerProvider.notifier)
            .submitWrong(now: now.add(const Duration(minutes: 1)));

        final state = container.read(localLearningControllerProvider);
        final readState = state.readState;
        final retryItems = await bootstrapResult.database.query(
          'session_items',
          where: 'status = ?',
          whereArgs: ['retryPending'],
        );

        expect(readState, isNotNull);
        expect(readState!.answeredCount, beforeReadState.answeredCount + 1);
        expect(readState.currentPosition, beforeReadState.currentPosition + 1);
        expect(
          state.lastAction,
          LocalLearningControllerAction.submitWrong,
        );
        expect(state.errorMessage, isNull);
        expect(state.isLoading, isFalse);
        expect(retryItems, hasLength(1));
      },
    );

    test(
      'local_learning_controller_complete_when_finished_updates_state',
      () async {
        final now = DateTime(2026, 5, 13, 10);
        const categoryId = 'controller-complete-category';
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_learning_controller_complete_test_',
        );
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

        final bootstrapResult = await container.read(
          localBootstrapProvider.future,
        );
        await bootstrapResult.repositoryFactory.categoryRepository
            .upsertCategory(
              id: categoryId,
              name: 'Controller Completion',
              sortOrder: 1,
              now: now,
            );
        await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
          id: 'controller-complete-word',
          categoryId: categoryId,
          term: 'finish',
          translation: 'beenden',
          exampleSentence: 'Finish the session.',
          notes: 'Completion test word',
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

        final startedState = container.read(localLearningControllerProvider);
        final sessionId = startedState.readState!.sessionId;
        final sessionsBefore = await bootstrapResult.database.query(
          'learning_sessions',
        );

        await bootstrapResult.database.update(
          'session_items',
          {
            'status': 'answered',
            'answered_at': now.add(const Duration(minutes: 1)).toIso8601String(),
            'updated_at': now.add(const Duration(minutes: 1)).toIso8601String(),
          },
          where: 'session_id = ?',
          whereArgs: [sessionId],
        );

        await container
            .read(localLearningControllerProvider.notifier)
            .completeIfFinished(now: now.add(const Duration(minutes: 1)));

        final state = container.read(localLearningControllerProvider);
        final readState = state.readState;
        final sessionsAfter = await bootstrapResult.database.query(
          'learning_sessions',
        );

        expect(readState, isNotNull);
        expect(readState!.status, 'completed');
        expect(readState.currentWordId, isNull);
        expect(readState.canSubmitAnswer, isFalse);
        expect(
          state.lastAction,
          LocalLearningControllerAction.completeIfFinished,
        );
        expect(state.errorMessage, isNull);
        expect(state.isLoading, isFalse);
        expect(sessionsAfter, hasLength(sessionsBefore.length));
      },
    );
  });
}
