import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_practice_card.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_practice_cards_provider.dart';
import 'package:talvori/core/local_database/providers/shared_text_import_service_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/features/favorites/application/local_favorites_provider.dart';
import 'package:talvori/features/favorites/data/local_favorites_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<ProviderContainer> createContainer(
    String prefix, {
    List<String> favoriteWordIds = const <String>[],
  }) async {
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
        localFavoritesRepositoryProvider.overrideWithValue(
          _MemoryLocalFavoritesRepository(favoriteWordIds),
        ),
      ],
    );
    return container;
  }

  Future<void> setStage(
    ProviderContainer container, {
    required String wordId,
    required SrsStage stage,
    LearningMode mode = LearningMode.time,
  }) async {
    final bootstrap = await container.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final progress = await repositories.wordProgressRepository.loadProgress(
      wordId: wordId,
      categoryId: 'seed-category-basics',
      mode: mode,
    );
    await repositories.wordProgressRepository.saveProgress(
      updatedProgress: progress!.copyWith(stage: stage),
      updatedAt: DateTime(2026, 5, 18),
    );
  }

  test('all_stages_loads_only_s1_to_s5_and_excludes_s0', () async {
    final container = await createContainer('talvori_local_practice_all_');
    final bootstrap = await container.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.progressInitializationService
        .initializeProgressForCategoryAndMode(
          categoryId: 'seed-category-basics',
          mode: LearningMode.time,
          now: DateTime(2026, 5, 18),
        );

    await setStage(container, wordId: 'seed-basics-hello', stage: SrsStage.s0);
    await setStage(container, wordId: 'seed-basics-water', stage: SrsStage.s1);
    await setStage(container, wordId: 'seed-basics-food', stage: SrsStage.s2);
    await setStage(container, wordId: 'seed-basics-house', stage: SrsStage.s5);

    final cards = await container.read(
      localPracticeCardsProvider(
        const LocalPracticeCardsRequest(
          categoryId: 'seed-category-basics',
          mode: LearningMode.time,
          selection: LocalPracticeSelection.allStages(),
        ),
      ).future,
    );

    expect(
      cards.map((card) => card.wordId),
      isNot(contains('seed-basics-hello')),
    );
    expect(cards.map((card) => card.stage), isNot(contains(SrsStage.s0)));
    expect(cards.map((card) => card.wordId), contains('seed-basics-water'));
    expect(cards.map((card) => card.wordId), contains('seed-basics-food'));
    expect(cards.map((card) => card.wordId), contains('seed-basics-house'));
  });

  test('single_stage_loads_only_requested_stage', () async {
    final container = await createContainer('talvori_local_practice_single_');
    final bootstrap = await container.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.progressInitializationService
        .initializeProgressForCategoryAndMode(
          categoryId: 'seed-category-basics',
          mode: LearningMode.adaptive,
          now: DateTime(2026, 5, 18),
        );

    await setStage(
      container,
      wordId: 'seed-basics-water',
      stage: SrsStage.s2,
      mode: LearningMode.adaptive,
    );
    await setStage(
      container,
      wordId: 'seed-basics-food',
      stage: SrsStage.s3,
      mode: LearningMode.adaptive,
    );

    final cards = await container.read(
      localPracticeCardsProvider(
        const LocalPracticeCardsRequest(
          categoryId: 'seed-category-basics',
          mode: LearningMode.adaptive,
          selection: LocalPracticeSelection.singleStage(SrsStage.s2),
        ),
      ).future,
    );

    expect(cards.map((card) => card.wordId), contains('seed-basics-water'));
    expect(
      cards.map((card) => card.wordId),
      isNot(contains('seed-basics-food')),
    );
    expect(cards.every((card) => card.stage == SrsStage.s2), isTrue);
  });

  test('practice_cards_are_category_and_mode_isolated', () async {
    final container = await createContainer('talvori_local_practice_isolated_');
    final bootstrap = await container.read(localBootstrapProvider.future);
    await bootstrap.repositoryFactory.progressInitializationService
        .initializeProgressForCategoryAndMode(
          categoryId: 'seed-category-basics',
          mode: LearningMode.time,
          now: DateTime(2026, 5, 18),
        );
    await bootstrap.repositoryFactory.progressInitializationService
        .initializeProgressForCategoryAndMode(
          categoryId: 'seed-category-basics',
          mode: LearningMode.hybrid,
          now: DateTime(2026, 5, 18),
        );

    await setStage(container, wordId: 'seed-basics-water', stage: SrsStage.s4);
    await setStage(
      container,
      wordId: 'seed-basics-water',
      stage: SrsStage.s1,
      mode: LearningMode.hybrid,
    );

    final timeCards = await container.read(
      localPracticeCardsProvider(
        const LocalPracticeCardsRequest(
          categoryId: 'seed-category-basics',
          mode: LearningMode.time,
          selection: LocalPracticeSelection.singleStage(SrsStage.s4),
        ),
      ).future,
    );
    final hybridCards = await container.read(
      localPracticeCardsProvider(
        const LocalPracticeCardsRequest(
          categoryId: 'seed-category-basics',
          mode: LearningMode.hybrid,
          selection: LocalPracticeSelection.singleStage(SrsStage.s4),
        ),
      ).future,
    );

    expect(timeCards.map((card) => card.wordId), contains('seed-basics-water'));
    expect(hybridCards, isEmpty);
  });

  test('practice_cards_for_word_world_use_membership_words', () async {
    final container = await createContainer('talvori_local_practice_world_');
    final bootstrap = await container.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final now = DateTime(2026, 5, 27, 10);
    await repositories.categoryRepository.upsertCategory(
      id: 'category-travel',
      name: 'Travel',
      now: now,
    );
    await repositories.wordRepository.upsertWord(
      id: 'word-ticket',
      categoryId: 'seed-category-basics',
      term: 'ticket',
      translation: 'Fahrkarte',
      now: now,
    );
    await repositories.wordRepository.upsertWord(
      id: 'word-hotel',
      categoryId: 'seed-category-basics',
      term: 'hotel',
      translation: 'Hotel',
      now: now,
    );
    await repositories.wordRepository.addWordWorldMembership(
      wordId: 'word-ticket',
      categoryId: 'category-travel',
      createdAt: now,
    );
    await repositories.wordRepository.addWordWorldMembership(
      wordId: 'word-hotel',
      categoryId: 'category-travel',
      createdAt: now,
    );
    await repositories.progressInitializationService
        .initializeProgressForCategoryAndMode(
          categoryId: 'category-travel',
          mode: LearningMode.time,
          now: now,
        );
    final ticketProgress = await repositories.wordProgressRepository
        .loadProgress(
          wordId: 'word-ticket',
          categoryId: 'category-travel',
          mode: LearningMode.time,
        );
    await repositories.wordProgressRepository.saveProgress(
      updatedProgress: ticketProgress!.copyWith(stage: SrsStage.s2),
      updatedAt: now,
    );

    final cards = await container.read(
      localPracticeCardsProvider(
        const LocalPracticeCardsRequest(
          categoryId: 'category-travel',
          mode: LearningMode.time,
          selection: LocalPracticeSelection.singleStage(SrsStage.s2),
        ),
      ).future,
    );

    expect(cards.map((card) => card.wordId), ['word-ticket']);
  });

  test('local_source_practice_cards_use_filtered_source_words', () async {
    final container = await createContainer(
      'talvori_local_practice_source_filter_',
      favoriteWordIds: const ['local-my-words-aurora'],
    );
    final bootstrap = await container.read(localBootstrapProvider.future);
    final importService = await container.read(
      sharedTextImportServiceProvider.future,
    );
    final favoriteResult = await importService.importRawText(
      rawText: 'aurora',
      now: DateTime(2026, 5, 21, 10),
    );
    final otherResult = await importService.importRawText(
      rawText: 'canyon',
      now: DateTime(2026, 5, 21, 11),
    );

    for (final result in [favoriteResult, otherResult]) {
      final word = result.word!;
      final progress = await bootstrap.repositoryFactory.wordProgressRepository
          .ensureProgressForWord(
            wordId: word.id,
            categoryId: localMyWordsCategoryId,
            mode: LearningMode.time,
            now: DateTime(2026, 5, 21, 11, 30),
          );
      await bootstrap.repositoryFactory.wordProgressRepository.saveProgress(
        updatedProgress: progress.copyWith(stage: SrsStage.s2),
        updatedAt: DateTime(2026, 5, 21, 12),
      );
    }

    final cards = await container.read(
      localPracticeCardsProvider(
        LocalPracticeCardsRequest(
          categoryId: LocalLearningSource.favorites.id,
          mode: LearningMode.time,
          selection: LocalPracticeSelection.singleStage(SrsStage.s2),
        ),
      ).future,
    );

    expect(cards.map((card) => card.term), ['aurora']);
  });
}

class _MemoryLocalFavoritesRepository implements LocalFavoritesRepository {
  _MemoryLocalFavoritesRepository(this._wordIds);

  List<String> _wordIds;

  @override
  Future<List<String>> loadWordIds() async => [..._wordIds];

  @override
  Future<void> saveWordIds(List<String> wordIds) async {
    _wordIds = [...wordIds];
  }
}
