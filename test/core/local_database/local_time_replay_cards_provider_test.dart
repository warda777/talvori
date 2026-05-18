import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_time_replay_cards_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/new_card_policy.dart';
import 'package:talvori/core/srs/models/queue_build_result.dart';
import 'package:talvori/core/srs/models/queue_item_status.dart';
import 'package:talvori/core/srs/models/session_item.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localTimeReplayCardsProvider', () {
    test(
      'loads_cards_from_last_time_session_with_items_after_empty_session',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_time_replay_cards_provider_test_',
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

        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final words = await repositories.wordRepository.loadWordsForCategory(
          categoryId: 'seed-category-basics',
        );
        final replayWords = words.take(2).toList(growable: false);
        final now = DateTime(2026, 5, 18, 10);

        final learnedSession = await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.time,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: QueueBuildResult(
                items: [
                  for (var index = 0; index < replayWords.length; index++)
                    SessionItem(
                      wordId: replayWords[index].id,
                      categoryId: 'seed-category-basics',
                      mode: LearningMode.time,
                      stageAtEnqueue: SrsStage.s0,
                      position: index,
                      status: QueueItemStatus.answered,
                      isNewCard: true,
                    ),
                ],
                newCardsIncluded: replayWords.length,
                reviewsIncluded: 0,
                newCardPolicy: NewCardPolicy.allowed,
              ),
              now: now,
            );
        await repositories.learningSessionRepository.completeSession(
          sessionId: learnedSession.id,
          completedAt: now.add(const Duration(minutes: 5)),
        );
        await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.time,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: const QueueBuildResult(
                items: [],
                newCardsIncluded: 0,
                reviewsIncluded: 0,
                newCardPolicy: NewCardPolicy.blockedBySessionLimit,
              ),
              now: now.add(const Duration(minutes: 10)),
            );

        final cards = await container.read(
          localTimeReplayCardsProvider('seed-category-basics').future,
        );

        expect(cards.map((card) => card.wordId), [
          replayWords[0].id,
          replayWords[1].id,
        ]);
        expect(cards.map((card) => card.term), [
          replayWords[0].term,
          replayWords[1].term,
        ]);
      },
    );

    test('returns_empty_list_without_previous_time_session', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_time_replay_cards_provider_empty_test_',
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

      final cards = await container.read(
        localTimeReplayCardsProvider('seed-category-basics').future,
      );

      expect(cards, isEmpty);
    });

    test(
      'general_replay_provider_loads_cards_from_last_hybrid_session_with_items',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_hybrid_replay_cards_provider_test_',
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

        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final words = await repositories.wordRepository.loadWordsForCategory(
          categoryId: 'seed-category-basics',
        );
        final replayWords = words.skip(2).take(2).toList(growable: false);
        final now = DateTime(2026, 5, 18, 10);

        final learnedSession = await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: QueueBuildResult(
                items: [
                  for (var index = 0; index < replayWords.length; index++)
                    SessionItem(
                      wordId: replayWords[index].id,
                      categoryId: 'seed-category-basics',
                      mode: LearningMode.hybrid,
                      stageAtEnqueue: SrsStage.s3,
                      position: index,
                      status: QueueItemStatus.answered,
                      isNewCard: false,
                    ),
                ],
                newCardsIncluded: 0,
                reviewsIncluded: replayWords.length,
                newCardPolicy: NewCardPolicy.allowed,
              ),
              now: now,
            );
        await repositories.learningSessionRepository.completeSession(
          sessionId: learnedSession.id,
          completedAt: now.add(const Duration(minutes: 5)),
        );
        await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: const QueueBuildResult(
                items: [],
                newCardsIncluded: 0,
                reviewsIncluded: 0,
                newCardPolicy: NewCardPolicy.blockedBySessionLimit,
              ),
              now: now.add(const Duration(minutes: 10)),
            );

        final cards = await container.read(
          localReplayCardsProvider(
            const LocalReplayCardsRequest(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
            ),
          ).future,
        );

        expect(cards.map((card) => card.wordId), [
          replayWords[0].id,
          replayWords[1].id,
        ]);
      },
    );

    test(
      'general_replay_provider_loads_all_unique_cards_from_latest_hybrid_day',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_hybrid_replay_cards_provider_multi_test_',
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

        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final words = await repositories.wordRepository.loadWordsForCategory(
          categoryId: 'seed-category-basics',
        );
        final replayWords = words.take(25).toList(growable: false);
        final now = DateTime(2026, 5, 18, 10);

        for (var chunk = 0; chunk < 3; chunk++) {
          final chunkWords = replayWords
              .skip(chunk * 8)
              .take(chunk == 2 ? 9 : 8)
              .toList(growable: false);
          final session = await repositories.learningSessionRepository
              .createSessionFromQueueResult(
                categoryId: 'seed-category-basics',
                mode: LearningMode.hybrid,
                trainingArea: TrainingArea.all,
                sessionSize: 20,
                queueBuildResult: QueueBuildResult(
                  items: [
                    for (var index = 0; index < chunkWords.length; index++)
                      SessionItem(
                        wordId: chunkWords[index].id,
                        categoryId: 'seed-category-basics',
                        mode: LearningMode.hybrid,
                        stageAtEnqueue: SrsStage.s3,
                        position: index,
                        status: QueueItemStatus.done,
                        isNewCard: false,
                      ),
                  ],
                  newCardsIncluded: 0,
                  reviewsIncluded: chunkWords.length,
                  newCardPolicy: NewCardPolicy.allowed,
                ),
                now: now.add(Duration(minutes: chunk * 10)),
              );
          await repositories.learningSessionRepository.completeSession(
            sessionId: session.id,
            completedAt: now.add(Duration(minutes: chunk * 10 + 5)),
          );
        }

        await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: const QueueBuildResult(
                items: [],
                newCardsIncluded: 0,
                reviewsIncluded: 0,
                newCardPolicy: NewCardPolicy.blockedBySessionLimit,
              ),
              now: now.add(const Duration(hours: 1)),
            );

        final cards = await container.read(
          localReplayCardsProvider(
            const LocalReplayCardsRequest(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
            ),
          ).future,
        );

        expect(cards, hasLength(25));
        expect(
          cards.map((card) => card.wordId),
          replayWords.map((word) => word.id),
        );
      },
    );

    test(
      'general_replay_provider_keeps_position_order_and_dedupes_words',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_replay_cards_provider_dedupe_test_',
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

        final bootstrap = await container.read(localBootstrapProvider.future);
        final repositories = bootstrap.repositoryFactory;
        final words = await repositories.wordRepository.loadWordsForCategory(
          categoryId: 'seed-category-basics',
        );
        final now = DateTime(2026, 5, 18, 10);

        final firstSession = await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: QueueBuildResult(
                items: [
                  SessionItem(
                    wordId: words[1].id,
                    categoryId: 'seed-category-basics',
                    mode: LearningMode.hybrid,
                    stageAtEnqueue: SrsStage.s3,
                    position: 1,
                    status: QueueItemStatus.answered,
                    isNewCard: false,
                  ),
                  SessionItem(
                    wordId: words[0].id,
                    categoryId: 'seed-category-basics',
                    mode: LearningMode.hybrid,
                    stageAtEnqueue: SrsStage.s3,
                    position: 0,
                    status: QueueItemStatus.answered,
                    isNewCard: false,
                  ),
                ],
                newCardsIncluded: 0,
                reviewsIncluded: 2,
                newCardPolicy: NewCardPolicy.allowed,
              ),
              now: now,
            );
        await repositories.learningSessionRepository.completeSession(
          sessionId: firstSession.id,
          completedAt: now.add(const Duration(minutes: 5)),
        );

        final secondSession = await repositories.learningSessionRepository
            .createSessionFromQueueResult(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
              trainingArea: TrainingArea.all,
              sessionSize: 20,
              queueBuildResult: QueueBuildResult(
                items: [
                  SessionItem(
                    wordId: words[1].id,
                    categoryId: 'seed-category-basics',
                    mode: LearningMode.hybrid,
                    stageAtEnqueue: SrsStage.s3,
                    position: 0,
                    status: QueueItemStatus.retryPending,
                    isNewCard: false,
                  ),
                  SessionItem(
                    wordId: words[2].id,
                    categoryId: 'seed-category-basics',
                    mode: LearningMode.hybrid,
                    stageAtEnqueue: SrsStage.s3,
                    position: 1,
                    status: QueueItemStatus.answered,
                    isNewCard: false,
                  ),
                ],
                newCardsIncluded: 0,
                reviewsIncluded: 2,
                newCardPolicy: NewCardPolicy.allowed,
              ),
              now: now.add(const Duration(minutes: 10)),
            );
        await repositories.learningSessionRepository.completeSession(
          sessionId: secondSession.id,
          completedAt: now.add(const Duration(minutes: 15)),
        );

        final cards = await container.read(
          localReplayCardsProvider(
            const LocalReplayCardsRequest(
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
            ),
          ).future,
        );

        expect(cards.map((card) => card.wordId), [
          words[0].id,
          words[1].id,
          words[2].id,
        ]);
      },
    );

    test('replay_cards_are_isolated_by_learning_mode', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_replay_cards_mode_isolation_test_',
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

      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final words = await repositories.wordRepository.loadWordsForCategory(
        categoryId: 'seed-category-basics',
      );
      final timeWord = words[0];
      final hybridWord = words[1];
      final now = DateTime(2026, 5, 18, 10);

      await repositories.learningSessionRepository.createSessionFromQueueResult(
        categoryId: 'seed-category-basics',
        mode: LearningMode.time,
        trainingArea: TrainingArea.all,
        sessionSize: 20,
        queueBuildResult: QueueBuildResult(
          items: [
            SessionItem(
              wordId: timeWord.id,
              categoryId: 'seed-category-basics',
              mode: LearningMode.time,
              stageAtEnqueue: SrsStage.s1,
              position: 0,
              status: QueueItemStatus.answered,
              isNewCard: false,
            ),
          ],
          newCardsIncluded: 0,
          reviewsIncluded: 1,
          newCardPolicy: NewCardPolicy.allowed,
        ),
        now: now,
      );
      await repositories.learningSessionRepository.createSessionFromQueueResult(
        categoryId: 'seed-category-basics',
        mode: LearningMode.hybrid,
        trainingArea: TrainingArea.all,
        sessionSize: 20,
        queueBuildResult: QueueBuildResult(
          items: [
            SessionItem(
              wordId: hybridWord.id,
              categoryId: 'seed-category-basics',
              mode: LearningMode.hybrid,
              stageAtEnqueue: SrsStage.s3,
              position: 0,
              status: QueueItemStatus.answered,
              isNewCard: false,
            ),
          ],
          newCardsIncluded: 0,
          reviewsIncluded: 1,
          newCardPolicy: NewCardPolicy.allowed,
        ),
        now: now.add(const Duration(minutes: 1)),
      );

      final timeCards = await container.read(
        localReplayCardsProvider(
          const LocalReplayCardsRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.time,
          ),
        ).future,
      );
      final hybridCards = await container.read(
        localReplayCardsProvider(
          const LocalReplayCardsRequest(
            categoryId: 'seed-category-basics',
            mode: LearningMode.hybrid,
          ),
        ).future,
      );

      expect(timeCards.map((card) => card.wordId), [timeWord.id]);
      expect(hybridCards.map((card) => card.wordId), [hybridWord.id]);
    });
  });
}
