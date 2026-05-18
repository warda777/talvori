import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/controllers/local_learning_controller.dart';
import 'package:talvori/core/local_database/local_app_bootstrap_result.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_learning_view_model_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/queue_item_status.dart';
import 'package:talvori/core/srs/models/requeue_reason.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final now = DateTime(2026, 5, 13, 10);

  ProviderContainer createContainer(String databasesPath) {
    return ProviderContainer(
      overrides: [
        localBootstrapDatabasesPathProvider.overrideWithValue(databasesPath),
      ],
    );
  }

  Future<void> disposeContainer(ProviderContainer container) async {
    container.dispose();
    await Future<void>.delayed(Duration.zero);
  }

  Future<void> insertCategoryAndWords(
    LocalAppBootstrapResult bootstrapResult, {
    required String categoryId,
    required int wordCount,
    DateTime? createdAt,
  }) async {
    final at = createdAt ?? now;
    await bootstrapResult.repositoryFactory.categoryRepository.upsertCategory(
      id: categoryId,
      name: categoryId,
      sortOrder: 1,
      now: at,
    );

    for (var index = 1; index <= wordCount; index++) {
      await bootstrapResult.repositoryFactory.wordRepository.upsertWord(
        id: '$categoryId-word-$index',
        categoryId: categoryId,
        term: 'term $index',
        translation: 'translation $index',
        exampleSentence: 'Example $index.',
        notes: 'Controller persistence test word',
        sortOrder: index,
        now: at,
      );
    }
  }

  Future<void> upsertProgress(
    LocalAppBootstrapResult bootstrapResult, {
    required String categoryId,
    required String wordId,
    required LearningMode mode,
    SrsStage stage = SrsStage.s0,
    int passCount = 0,
    int wrongCount = 0,
    DateTime? nextDueAt,
  }) async {
    await bootstrapResult.database.insert('word_progress', {
      'id': 'progress-$wordId-${mode.name}',
      'word_id': wordId,
      'category_id': categoryId,
      'mode_id': mode.name,
      'stage': stage.name,
      'pass_count': passCount,
      'wrong_count': wrongCount,
      'next_due_at': nextDueAt?.toIso8601String(),
      'last_reviewed_at': null,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> prepareDueTimeProgress(
    LocalAppBootstrapResult bootstrapResult, {
    required String categoryId,
    required int wordCount,
  }) async {
    for (var index = 1; index <= wordCount; index++) {
      await upsertProgress(
        bootstrapResult,
        categoryId: categoryId,
        wordId: '$categoryId-word-$index',
        mode: LearningMode.time,
        stage: SrsStage.s2,
        nextDueAt: now,
      );
    }
  }

  Future<List<Map<String, Object?>>> sessionRows(
    LocalAppBootstrapResult bootstrapResult,
  ) {
    return bootstrapResult.database.query(
      'learning_sessions',
      orderBy: 'created_at ASC',
    );
  }

  Future<List<Map<String, Object?>>> sessionItemRows(
    LocalAppBootstrapResult bootstrapResult,
    String sessionId,
  ) {
    return bootstrapResult.database.query(
      'session_items',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'position ASC',
    );
  }

  Future<Map<String, Object?>> progressRow(
    LocalAppBootstrapResult bootstrapResult, {
    required String categoryId,
    required String wordId,
    required LearningMode mode,
  }) async {
    return (await bootstrapResult.database.query(
      'word_progress',
      where: 'category_id = ? AND word_id = ? AND mode_id = ?',
      whereArgs: [categoryId, wordId, mode.name],
    )).single;
  }

  List<String> queueOrder(List<Map<String, Object?>> rows) {
    return rows
        .map((row) => '${row['position']}:${row['word_id']}:${row['status']}')
        .toList(growable: false);
  }

  group('LocalLearningController file persistence', () {
    test('start_or_resume_view_model_survives_provider_reopen', () async {
      const categoryId = 'controller-persist-start';
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_controller_persistence_start_',
      );
      final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var container = createContainer(tempDir.path);
      var bootstrapResult = await container.read(localBootstrapProvider.future);
      await insertCategoryAndWords(
        bootstrapResult,
        categoryId: categoryId,
        wordCount: 4,
      );
      await container
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: categoryId,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final firstViewModel = container.read(localLearningViewModelProvider);
      final sessionId = firstViewModel.sessionId!;
      final queueBeforeReopen = queueOrder(
        await sessionItemRows(bootstrapResult, sessionId),
      );

      expect(firstViewModel.hasSession, isTrue);
      expect(firstViewModel.currentWordId, isNotNull);
      expect(firstViewModel.stageCounts[SrsStage.s0.index], 4);

      await disposeContainer(container);

      container = createContainer(tempDir.path);
      addTearDown(() async => disposeContainer(container));
      bootstrapResult = await container.read(localBootstrapProvider.future);
      await container
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: categoryId,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 1)),
          );
      final resumedViewModel = container.read(localLearningViewModelProvider);

      expect(resumedViewModel.sessionId, sessionId);
      expect(resumedViewModel.currentWordId, firstViewModel.currentWordId);
      expect(resumedViewModel.currentPosition, firstViewModel.currentPosition);
      expect(
        queueOrder(await sessionItemRows(bootstrapResult, sessionId)),
        queueBeforeReopen,
      );
      expect(resumedViewModel.stageCounts, firstViewModel.stageCounts);
      expect(await sessionRows(bootstrapResult), hasLength(1));
    });

    test('submit_correct_persists_through_provider_reopen', () async {
      const categoryId = 'controller-persist-correct';
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_controller_persistence_correct_',
      );
      final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var container = createContainer(tempDir.path);
      var bootstrapResult = await container.read(localBootstrapProvider.future);
      await insertCategoryAndWords(
        bootstrapResult,
        categoryId: categoryId,
        wordCount: 3,
      );
      await container
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: categoryId,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final before = container.read(localLearningViewModelProvider);
      final answeredWordId = before.currentWordId!;
      await container
          .read(localLearningControllerProvider.notifier)
          .submitCorrect(now: now.add(const Duration(minutes: 1)));
      final after = container.read(localLearningViewModelProvider);
      final progressAfterSubmit = await progressRow(
        bootstrapResult,
        categoryId: categoryId,
        wordId: answeredWordId,
        mode: LearningMode.adaptive,
      );

      expect(after.sessionId, before.sessionId);
      expect(after.currentPosition, before.currentPosition + 1);
      expect(after.stageCounts[SrsStage.s0.index], 2);
      expect(after.stageCounts[SrsStage.s1.index], 1);
      expect(progressAfterSubmit['stage'], SrsStage.s1.name);

      await disposeContainer(container);

      container = createContainer(tempDir.path);
      addTearDown(() async => disposeContainer(container));
      bootstrapResult = await container.read(localBootstrapProvider.future);
      await container
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: categoryId,
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 2)),
          );
      final resumed = container.read(localLearningViewModelProvider);
      final progressAfterReopen = await progressRow(
        bootstrapResult,
        categoryId: categoryId,
        wordId: answeredWordId,
        mode: LearningMode.adaptive,
      );

      expect(resumed.sessionId, before.sessionId);
      expect(resumed.currentPosition, after.currentPosition);
      expect(resumed.currentWordId, after.currentWordId);
      expect(resumed.stageCounts, after.stageCounts);
      expect(progressAfterReopen['stage'], progressAfterSubmit['stage']);
      expect(await sessionRows(bootstrapResult), hasLength(1));
    });

    test('submit_wrong_requeue_persists_through_provider_reopen', () async {
      const categoryId = 'controller-persist-wrong';
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_controller_persistence_wrong_',
      );
      final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      var container = createContainer(tempDir.path);
      var bootstrapResult = await container.read(localBootstrapProvider.future);
      await insertCategoryAndWords(
        bootstrapResult,
        categoryId: categoryId,
        wordCount: 12,
      );
      await prepareDueTimeProgress(
        bootstrapResult,
        categoryId: categoryId,
        wordCount: 12,
      );
      await container
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: categoryId,
            mode: LearningMode.time,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final before = container.read(localLearningViewModelProvider);
      final wrongWordId = before.currentWordId!;
      await container
          .read(localLearningControllerProvider.notifier)
          .submitWrong(now: now.add(const Duration(minutes: 1)));
      final after = container.read(localLearningViewModelProvider);
      final requeueBeforeReopen = (await bootstrapResult.database.query(
        'session_items',
        where: 'session_id = ? AND word_id = ? AND requeue_reason = ?',
        whereArgs: [
          before.sessionId,
          wrongWordId,
          RequeueReason.wrongAnswer.name,
        ],
      )).single;

      await disposeContainer(container);

      container = createContainer(tempDir.path);
      addTearDown(() async => disposeContainer(container));
      bootstrapResult = await container.read(localBootstrapProvider.future);
      await container
          .read(localLearningControllerProvider.notifier)
          .startOrResume(
            categoryId: categoryId,
            mode: LearningMode.time,
            trainingArea: TrainingArea.all,
            now: now.add(const Duration(minutes: 2)),
          );
      final resumed = container.read(localLearningViewModelProvider);
      final requeueAfterReopen = (await bootstrapResult.database.query(
        'session_items',
        where: 'session_id = ? AND word_id = ? AND requeue_reason = ?',
        whereArgs: [
          before.sessionId,
          wrongWordId,
          RequeueReason.wrongAnswer.name,
        ],
      )).single;
      final openWrongWordItems = await bootstrapResult.database.query(
        'session_items',
        where: 'session_id = ? AND word_id = ? AND status IN (?, ?, ?, ?)',
        whereArgs: [
          before.sessionId,
          wrongWordId,
          QueueItemStatus.queued.name,
          QueueItemStatus.shown.name,
          QueueItemStatus.retryPending.name,
          QueueItemStatus.difficult.name,
        ],
      );

      expect(resumed.sessionId, before.sessionId);
      expect(resumed.currentPosition, after.currentPosition);
      expect(requeueAfterReopen['position'], requeueBeforeReopen['position']);
      expect(requeueAfterReopen['status'], requeueBeforeReopen['status']);
      expect(openWrongWordItems, hasLength(1));
      expect(resumed.remainingCount, greaterThan(0));
      expect(resumed.canCompleteSession, isFalse);
      expect(await sessionRows(bootstrapResult), hasLength(1));
    });

    test(
      'completed_state_and_explicit_reset_survive_provider_reopen',
      () async {
        const categoryId = 'controller-persist-completed';
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_controller_persistence_completed_',
        );
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        addTearDown(() async {
          await databaseFactoryFfi.deleteDatabase(databasePath);
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        var container = createContainer(tempDir.path);
        var bootstrapResult = await container.read(
          localBootstrapProvider.future,
        );
        await insertCategoryAndWords(
          bootstrapResult,
          categoryId: categoryId,
          wordCount: 1,
        );
        await container
            .read(localLearningControllerProvider.notifier)
            .startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now,
            );
        for (var index = 0; index < 11; index++) {
          await container
              .read(localLearningControllerProvider.notifier)
              .submitCorrect(now: now.add(Duration(minutes: index + 1)));
        }
        await container
            .read(localLearningControllerProvider.notifier)
            .startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now.add(const Duration(minutes: 20)),
            );
        final completed = container.read(localLearningViewModelProvider);

        expect(completed.status, 'completed');
        expect(completed.currentWordId, isNull);
        expect(completed.stageCounts[SrsStage.s5.index], 1);

        await disposeContainer(container);

        container = createContainer(tempDir.path);
        addTearDown(() async => disposeContainer(container));
        bootstrapResult = await container.read(localBootstrapProvider.future);
        await container
            .read(localLearningControllerProvider.notifier)
            .startOrResume(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now.add(const Duration(minutes: 21)),
            );
        final completedAfterReopen = container.read(
          localLearningViewModelProvider,
        );

        expect(completedAfterReopen.sessionId, completed.sessionId);
        expect(completedAfterReopen.status, 'completed');
        expect(completedAfterReopen.stageCounts[SrsStage.s5.index], 1);

        await container
            .read(localLearningControllerProvider.notifier)
            .resetAndStart(
              categoryId: categoryId,
              mode: LearningMode.adaptive,
              trainingArea: TrainingArea.all,
              now: now.add(const Duration(minutes: 22)),
            );
        final restarted = container.read(localLearningViewModelProvider);
        final progress = await progressRow(
          bootstrapResult,
          categoryId: categoryId,
          wordId: '$categoryId-word-1',
          mode: LearningMode.adaptive,
        );

        expect(restarted.sessionId, isNot(completed.sessionId));
        expect(restarted.status, 'active');
        expect(restarted.currentWordId, '$categoryId-word-1');
        expect(restarted.stageCounts[SrsStage.s0.index], 1);
        expect(progress['stage'], SrsStage.s0.name);
        expect(progress['pass_count'], 0);
        expect(progress['wrong_count'], 0);
        expect(await sessionRows(bootstrapResult), hasLength(2));
      },
    );
  });
}
