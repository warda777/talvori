import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/features/words/application/local_known_review_controller.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Future<ProviderContainer> createSeededContainer(
    String prefix, {
    bool addMemberships = true,
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
      ],
    );
    final bootstrap = await container.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final now = DateTime(2026, 5, 29, 11);

    await repositories.categoryRepository.upsertCategory(
      id: 'category-health-review',
      name: 'Health & Fitness',
      sortOrder: 1,
      now: now,
    );
    await repositories.categoryRepository.upsertCategory(
      id: 'seed-category-basics',
      name: 'Basics',
      sortOrder: 0,
      now: now,
    );
    final debugWord = await repositories.wordRepository.upsertWord(
      id: 'word-debug-basics',
      categoryId: 'seed-category-basics',
      term: 'debug',
      translation: 'Debug',
      now: now.subtract(const Duration(minutes: 1)),
    );
    if (addMemberships) {
      await repositories.wordRepository.addWordWorldMembership(
        wordId: debugWord.id,
        categoryId: 'seed-category-basics',
        createdAt: now.subtract(const Duration(minutes: 1)),
      );
    }
    final ticket = await repositories.wordRepository.upsertWord(
      id: 'word-ticket-review',
      categoryId: 'category-health-review',
      term: 'ticket',
      translation: 'Fahrkarte',
      now: now,
    );
    if (addMemberships) {
      await repositories.wordRepository.addWordWorldMembership(
        wordId: ticket.id,
        categoryId: 'category-health-review',
        createdAt: now,
      );
    }
    final hotel = await repositories.wordRepository.upsertWord(
      id: 'word-hotel-review',
      categoryId: 'category-health-review',
      term: 'hotel',
      translation: 'Hotel',
      now: now.add(const Duration(minutes: 1)),
    );
    if (addMemberships) {
      await repositories.wordRepository.addWordWorldMembership(
        wordId: hotel.id,
        categoryId: 'category-health-review',
        createdAt: now.add(const Duration(minutes: 1)),
      );
    }
    if (!addMemberships) {
      await bootstrap.database.delete(
        'word_world_memberships',
        where: 'category_id = ?',
        whereArgs: ['category-health-review'],
      );
    }

    return container;
  }

  test('selectCategory loads local unknown words', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_select_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );

    await container
        .read(localKnownReviewControllerProvider.notifier)
        .selectCategory(category);

    final state = container.read(localKnownReviewControllerProvider).value!;
    expect(state.selectedCategoryId, 'category-health-review');
    expect(state.selectedCategoryName, 'Gesundheit & Fitness');
    expect(
      state.categories.map((item) => item.name),
      isNot(contains('Basics')),
    );
    expect(
      state.categories.map((item) => item.name),
      isNot(contains('Grundlagen')),
    );
    expect(state.words.map((word) => word.id), [
      'word-hotel-review',
      'word-ticket-review',
    ]);
  });

  test('selected category is persisted and restored on rebuild', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_persist_category_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );

    await container
        .read(localKnownReviewControllerProvider.notifier)
        .selectCategory(category);
    container.invalidate(localKnownReviewControllerProvider);
    final rebuilt = await container.read(
      localKnownReviewControllerProvider.future,
    );

    expect(rebuilt.selectedCategoryId, 'category-health-review');
    expect(rebuilt.selectedCategoryName, 'Gesundheit & Fitness');
  });

  test('remaining count updates live when word is reviewed', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_live_remaining_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );
    final controller = container.read(
      localKnownReviewControllerProvider.notifier,
    );
    await controller.selectCategory(category);
    var state = container.read(localKnownReviewControllerProvider).value!;
    expect(state.remainingUnreviewedCountForCurrentCategory, 2);

    await controller.markKeepLearning(state.words.first);
    state = container.read(localKnownReviewControllerProvider).value!;

    expect(state.keepLearningCount, 1);
    expect(state.remainingUnreviewedCountForCurrentCategory, 1);
  });

  test(
    'markCurrentKnown sets membership known and updates known count',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_mark_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);

      final marked = await controller.markCurrentKnown();

      expect(marked?.id, 'word-hotel-review');
      final bootstrap = await container.read(localBootstrapProvider.future);
      final knownWords = await bootstrap.repositoryFactory.wordRepository
          .loadKnownWordsForCategory(categoryId: 'category-health-review');
      expect(knownWords.map((word) => word.id), ['word-hotel-review']);
      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.currentWord?.id, 'word-ticket-review');
      expect(state.knownCount, 1);
      expect(state.canUndo, isTrue);
    },
  );

  test('markCurrentKnown keeps wheel index on next sensible word', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_index_stable_',
    );
    final bootstrap = await container.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final now = DateTime(2026, 5, 29, 12);
    await repositories.categoryRepository.upsertCategory(
      id: 'category-index-review',
      name: 'Health & Fitness',
      sortOrder: 99,
      now: now,
    );
    for (final entry in [
      ('word-index-a', 'alpha'),
      ('word-index-b', 'bravo'),
      ('word-index-c', 'charlie'),
      ('word-index-d', 'delta'),
    ]) {
      final word = await repositories.wordRepository.upsertWord(
        id: entry.$1,
        categoryId: 'category-index-review',
        term: entry.$2,
        translation: entry.$2,
        now: now,
      );
      await repositories.wordRepository.addWordWorldMembership(
        wordId: word.id,
        categoryId: 'category-index-review',
        createdAt: now,
      );
    }
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-index-review',
    );
    final controller = container.read(
      localKnownReviewControllerProvider.notifier,
    );
    await controller.selectCategory(category);
    final before = container.read(localKnownReviewControllerProvider).value!;
    final bravo = before.words.firstWhere((word) => word.id == 'word-index-b');
    controller.setCurrentWord(bravo);

    final marked = await controller.markCurrentKnown();

    final after = container.read(localKnownReviewControllerProvider).value!;
    expect(marked?.id, 'word-index-b');
    expect(after.words.map((word) => word.id), [
      'word-index-a',
      'word-index-c',
      'word-index-d',
    ]);
    expect(after.currentIndex, 1);
    expect(after.currentWord?.id, 'word-index-c');
  });

  test(
    'markCurrentKnown marks the centered word and keeps reviewed count stable',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_center_sync_',
      );
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      final now = DateTime(2026, 5, 29, 13);
      await repositories.categoryRepository.upsertCategory(
        id: 'category-gaming-review',
        name: 'Gaming',
        sortOrder: 2,
        now: now,
      );
      for (final entry in [
        ('word-heart-review', 'heart'),
        ('word-sport-review', 'sport'),
        ('word-walk-review', 'walk'),
        ('word-rest-review', 'rest'),
      ]) {
        final word = await repositories.wordRepository.upsertWord(
          id: entry.$1,
          categoryId: 'category-gaming-review',
          term: entry.$2,
          translation: entry.$2,
          sortOrder: switch (entry.$2) {
            'heart' => 0,
            'sport' => 1,
            'walk' => 2,
            'rest' => 3,
            _ => 9,
          },
          now: now,
        );
        await repositories.wordRepository.addWordWorldMembership(
          wordId: word.id,
          categoryId: 'category-gaming-review',
          createdAt: now,
        );
      }

      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-gaming-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      var state = container.read(localKnownReviewControllerProvider).value!;
      final heart = state.words.firstWhere((word) => word.term == 'heart');
      final sport = state.words.firstWhere((word) => word.term == 'sport');
      final walk = state.words.firstWhere((word) => word.term == 'walk');
      final rest = state.words.firstWhere((word) => word.term == 'rest');

      await controller.markKeepLearning(heart);
      await controller.markKeepLearning(sport);
      await controller.markKeepLearning(walk);
      controller.setCurrentWord(rest);
      state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.currentWord?.term, 'rest');
      expect(state.keepLearningCount, 3);

      final marked = await controller.markCurrentKnown();

      expect(marked?.term, 'rest');
      final knownWords = await repositories.wordRepository.loadKnownWords();
      expect(knownWords.map((word) => word.term), contains('rest'));
      expect(knownWords.map((word) => word.term), isNot(contains('heart')));
      final after = container.read(localKnownReviewControllerProvider).value!;
      expect(after.knownCount, 1);
      expect(after.keepLearningCount, 3);
      expect(after.words.map((word) => word.term), ['heart', 'sport', 'walk']);
      expect(after.currentWord?.term, 'walk');
      expect(
        await repositories.wordRepository.countReviewedForLearningWords(),
        3,
      );
    },
  );

  test(
    'markCurrentKnown persists when review words started without memberships',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_mark_missing_memberships_',
        addMemberships: false,
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);

      final marked = await controller.markCurrentKnown();

      expect(marked?.id, 'word-hotel-review');
      final bootstrap = await container.read(localBootstrapProvider.future);
      expect(
        await bootstrap.repositoryFactory.wordRepository.countKnownWords(),
        1,
      );

      container.invalidate(localKnownReviewControllerProvider);
      final rebuilt = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final rebuiltCategory = rebuilt.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      await container
          .read(localKnownReviewControllerProvider.notifier)
          .selectCategory(rebuiltCategory);
      final reselected = container
          .read(localKnownReviewControllerProvider)
          .value!;

      expect(reselected.knownCount, 1);
      expect(reselected.words.map((word) => word.id), ['word-ticket-review']);
    },
  );

  test(
    'markCurrentKnown keeps reviewed count when current word was not reviewed',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_known_non_reviewed_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final state = container.read(localKnownReviewControllerProvider).value!;
      final hotel = state.words.firstWhere(
        (word) => word.id == 'word-hotel-review',
      );
      final ticket = state.words.firstWhere(
        (word) => word.id == 'word-ticket-review',
      );
      await controller.markKeepLearning(hotel);
      controller.setCurrentWord(ticket);

      await controller.markCurrentKnown();

      final after = container.read(localKnownReviewControllerProvider).value!;
      expect(after.knownCount, 1);
      expect(after.keepLearningCount, 1);
    },
  );

  test(
    'known counter reloads from database after existing and new known marks',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_known_three_',
        addMemberships: false,
      );
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repositories = bootstrap.repositoryFactory;
      await repositories.wordRepository.upsertWord(
        id: 'word-bus-review',
        categoryId: 'category-health-review',
        term: 'bus',
        translation: 'Bus',
        now: DateTime(2026, 5, 29, 11, 2),
      );
      await repositories.wordRepository.setWordWorldMembershipKnown(
        wordId: 'word-ticket-review',
        categoryId: 'category-health-review',
        known: true,
      );

      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      await container.read(localKnownReviewControllerProvider.future);
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      final initial = container.read(localKnownReviewControllerProvider).value!;
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      await controller.selectCategory(category);

      await controller.markCurrentKnown();
      await controller.markCurrentKnown();

      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.knownCount, 3);
      expect(state.words, isEmpty);
      expect(await repositories.wordRepository.countKnownWords(), 3);

      container.invalidate(localKnownReviewControllerProvider);
      final rebuilt = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final rebuiltCategory = rebuilt.categories.firstWhere(
        (item) => item.id == 'category-health-review',
        orElse: () => category,
      );
      await container
          .read(localKnownReviewControllerProvider.notifier)
          .selectCategory(rebuiltCategory);
      final reselected = container
          .read(localKnownReviewControllerProvider)
          .value!;

      expect(reselected.knownCount, 3);
      expect(reselected.words, isEmpty);
    },
  );

  test(
    'markKeepLearning persists reviewed-for-learning without known write',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_keep_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);

      final before = container.read(localKnownReviewControllerProvider).value!;
      await controller.markKeepLearning(before.currentWord!);

      final bootstrap = await container.read(localBootstrapProvider.future);
      final knownWords = await bootstrap.repositoryFactory.wordRepository
          .loadKnownWordsForCategory(categoryId: 'category-health-review');
      expect(knownWords, isEmpty);
      expect(
        await bootstrap.repositoryFactory.wordRepository
            .countReviewedForLearningWords(),
        1,
      );
      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.keepLearningCount, 1);
      expect(state.currentWord?.id, 'word-hotel-review');
    },
  );

  test(
    'markKeepLearning keeps latest centered word after async counter reload',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_keep_latest_center_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final before = container.read(localKnownReviewControllerProvider).value!;
      final firstWord = before.currentWord!;
      final secondWord = before.words.last;

      final keepLearningFuture = controller.markKeepLearning(firstWord);
      controller.setCurrentWord(secondWord);
      await keepLearningFuture;

      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.currentWord?.id, secondWord.id);
      expect(state.keepLearningCount, 1);
    },
  );

  test(
    'markKeepLearning persists reviewed count without preexisting membership',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_keep_missing_memberships_',
        addMemberships: false,
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final before = container.read(localKnownReviewControllerProvider).value!;

      await controller.markKeepLearning(before.currentWord!);

      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.keepLearningCount, 1);

      container.invalidate(localKnownReviewControllerProvider);
      final rebuilt = await container.read(
        localKnownReviewControllerProvider.future,
      );
      expect(rebuilt.keepLearningCount, 1);
    },
  );

  test(
    'reviewed words are not loaded as unknown after controller rebuild',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_reviewed_rebuild_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final reviewed = container
          .read(localKnownReviewControllerProvider)
          .value!
          .currentWord!;

      await controller.markKeepLearning(reviewed);
      container.invalidate(localKnownReviewControllerProvider);
      final rebuilt = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final rebuiltCategory = rebuilt.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      await container
          .read(localKnownReviewControllerProvider.notifier)
          .selectCategory(rebuiltCategory);

      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.keepLearningCount, 1);
      expect(state.words.map((word) => word.id), isNot(contains(reviewed.id)));
    },
  );

  test(
    'completed category remains visible and can be reset or restarted',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_completed_actions_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      var state = container.read(localKnownReviewControllerProvider).value!;

      await controller.markKeepLearning(state.currentWord!);
      state = container.read(localKnownReviewControllerProvider).value!;
      controller.setCurrentWord(state.words.last);
      await controller.markCurrentKnown();

      state = container.read(localKnownReviewControllerProvider).value!;
      final completedCategory = state.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      expect(completedCategory.isCompleted, isTrue);
      expect(state.keepLearningCount, 1);
      expect(state.knownCount, 1);

      await controller.resetSelectedCategoryReview();

      state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.knownCount, 0);
      expect(state.keepLearningCount, 0);
      expect(state.words.map((word) => word.id), [
        'word-hotel-review',
        'word-ticket-review',
      ]);
    },
  );

  test(
    'unmarkKeepLearning does not remove reviewed mark from earlier session',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_keep_previous_',
      );
      final bootstrap = await container.read(localBootstrapProvider.future);
      final repository = bootstrap.repositoryFactory.wordRepository;
      await repository.markReviewedForLearning(
        wordId: 'word-hotel-review',
        categoryId: 'category-health-review',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final word = await repository.loadWordById('word-hotel-review');
      expect(word, isNotNull);

      await controller.unmarkKeepLearning(word!);

      final after = container.read(localKnownReviewControllerProvider).value!;
      expect(after.keepLearningCount, 1);
      expect(after.words.map((item) => item.id), isNot(contains(word.id)));
      expect(await repository.countReviewedForLearningWords(), 1);
    },
  );

  test('unmarkKeepLearning reduces counter when wheel turns back', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_keep_down_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );
    final controller = container.read(
      localKnownReviewControllerProvider.notifier,
    );
    await controller.selectCategory(category);
    final before = container.read(localKnownReviewControllerProvider).value!;
    final word = before.currentWord!;

    await controller.markKeepLearning(word);
    await controller.unmarkKeepLearning(word);

    final bootstrap = await container.read(localBootstrapProvider.future);
    final state = container.read(localKnownReviewControllerProvider).value!;
    expect(state.keepLearningCount, 0);
    expect(
      await bootstrap.repositoryFactory.wordRepository
          .countReviewedForLearningWords(),
      0,
    );
  });

  test(
    'markKeepLearning counts each word once and persists across category reload',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_keep_reset_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final before = container.read(localKnownReviewControllerProvider).value!;

      await controller.markKeepLearning(before.currentWord!);
      await controller.markKeepLearning(before.currentWord!);

      expect(
        container
            .read(localKnownReviewControllerProvider)
            .value!
            .keepLearningCount,
        1,
      );

      await controller.selectCategory(category);

      expect(
        container
            .read(localKnownReviewControllerProvider)
            .value!
            .keepLearningCount,
        1,
      );
    },
  );

  test('markCurrentKnown removes word from keep learning count', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_known_removes_keep_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );
    final controller = container.read(
      localKnownReviewControllerProvider.notifier,
    );
    await controller.selectCategory(category);
    final before = container.read(localKnownReviewControllerProvider).value!;

    await controller.markKeepLearning(before.currentWord!);
    await controller.markCurrentKnown();

    final state = container.read(localKnownReviewControllerProvider).value!;
    expect(state.knownCount, 1);
    expect(state.keepLearningCount, 0);
  });

  test(
    'controller rebuild loads persistent known and keep-learning counts',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_rebuild_counts_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      var state = container.read(localKnownReviewControllerProvider).value!;

      await controller.markKeepLearning(state.currentWord!);
      state = container.read(localKnownReviewControllerProvider).value!;
      controller.setCurrentWord(state.words.last);
      await controller.markCurrentKnown();

      container.invalidate(localKnownReviewControllerProvider);
      final rebuilt = await container.read(
        localKnownReviewControllerProvider.future,
      );

      expect(rebuilt.knownCount, 1);
      expect(rebuilt.keepLearningCount, 1);
    },
  );

  test(
    'undo restores keep learning count when known word was above line',
    () async {
      final container = await createSeededContainer(
        'talvori_local_known_review_controller_undo_keep_',
      );
      final subscription = container.listen(
        localKnownReviewControllerProvider,
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(subscription.close);
      final initial = await container.read(
        localKnownReviewControllerProvider.future,
      );
      final category = initial.categories.firstWhere(
        (item) => item.id == 'category-health-review',
      );
      final controller = container.read(
        localKnownReviewControllerProvider.notifier,
      );
      await controller.selectCategory(category);
      final before = container.read(localKnownReviewControllerProvider).value!;

      await controller.markKeepLearning(before.currentWord!);
      await controller.markCurrentKnown();
      await controller.undoLastKnown();

      final state = container.read(localKnownReviewControllerProvider).value!;
      expect(state.knownCount, 0);
      expect(state.keepLearningCount, 1);
    },
  );

  test('undoLastKnown restores known words in reverse order', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_undo_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );
    final controller = container.read(
      localKnownReviewControllerProvider.notifier,
    );
    await controller.selectCategory(category);

    final first = await controller.markCurrentKnown();
    final second = await controller.markCurrentKnown();

    expect(first?.id, 'word-hotel-review');
    expect(second?.id, 'word-ticket-review');
    final bootstrap = await container.read(localBootstrapProvider.future);
    var knownWords = await bootstrap.repositoryFactory.wordRepository
        .loadKnownWordsForCategory(categoryId: 'category-health-review');
    expect(knownWords.map((word) => word.id), [
      'word-hotel-review',
      'word-ticket-review',
    ]);

    await controller.undoLastKnown();

    knownWords = await bootstrap.repositoryFactory.wordRepository
        .loadKnownWordsForCategory(categoryId: 'category-health-review');
    expect(knownWords.map((word) => word.id), ['word-hotel-review']);
    var state = container.read(localKnownReviewControllerProvider).value!;
    expect(state.currentWord?.id, 'word-ticket-review');
    expect(state.canUndo, isTrue);

    await controller.undoLastKnown();

    knownWords = await bootstrap.repositoryFactory.wordRepository
        .loadKnownWordsForCategory(categoryId: 'category-health-review');
    expect(knownWords, isEmpty);
    state = container.read(localKnownReviewControllerProvider).value!;
    expect(state.currentWord?.id, 'word-hotel-review');
    expect(state.canUndo, isFalse);
  });

  test('setCurrentWord follows local wheel selection', () async {
    final container = await createSeededContainer(
      'talvori_local_known_review_controller_wheel_',
    );
    final subscription = container.listen(
      localKnownReviewControllerProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);
    final initial = await container.read(
      localKnownReviewControllerProvider.future,
    );
    final category = initial.categories.firstWhere(
      (item) => item.id == 'category-health-review',
    );
    final controller = container.read(
      localKnownReviewControllerProvider.notifier,
    );
    await controller.selectCategory(category);
    final before = container.read(localKnownReviewControllerProvider).value!;
    final ticket = before.words.firstWhere(
      (word) => word.id == 'word-ticket-review',
    );

    controller.setCurrentWord(ticket);

    final after = container.read(localKnownReviewControllerProvider).value!;
    expect(after.currentWord?.id, 'word-ticket-review');
  });
}
