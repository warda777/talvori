import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localCategoryDetailGroupItemsProvider', () {
    test('enriches_mapped_items_with_local_word_count', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_category_detail_group_items_provider_test_',
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

      final items = await container.read(
        localCategoryDetailGroupItemsProvider('health_fitness').future,
      );

      expect(items.length, 26);
      final health = items.singleWhere(
        (item) => item.wordHubKey == 'health_fitness',
      );
      final travel = items.singleWhere((item) => item.wordHubKey == 'travel');
      final home = items.singleWhere(
        (item) => item.wordHubKey == 'home_living',
      );

      expect(health.displayLabel, 'Health & Fitness');
      expect(health.localCategoryId, 'seed-category-basics');
      expect(health.vocabsCount, 25);
      expect(travel.displayLabel, 'Travel');
      expect(travel.localCategoryId, 'seed-category-travel');
      expect(travel.vocabsCount, 3);
      expect(home.displayLabel, 'Home & Living');
      expect(home.localCategoryId, isNull);
      expect(home.vocabsCount, 0);
      expect(
        items.map((item) => item.displayLabel),
        isNot(contains('Exam Practice')),
      );
      expect(
        items.map((item) => item.displayLabel),
        isNot(contains('Top 500 Words')),
      );
      expect(items.map((item) => item.displayLabel), isNot(contains('A1')));
      expect(items.map((item) => item.displayLabel), isNot(contains('C2')));
    });

    test(
      'counts_imported_word_world_memberships_and_excludes_archived',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_category_detail_group_items_provider_memberships_test_',
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
        final now = DateTime.utc(2026, 5, 26);
        await bootstrap.repositoryFactory.categoryRepository.upsertCategory(
          id: 'word-world-home-and-living',
          name: 'Home & Living',
          now: now,
        );
        await bootstrap.repositoryFactory.wordRepository.upsertWord(
          id: 'home-active',
          categoryId: 'word-world-home-and-living',
          term: 'sofa',
          translation: 'Sofa',
          sourceLanguage: 'en',
          targetLanguage: 'de',
          now: now,
        );
        await bootstrap.repositoryFactory.wordRepository.upsertWord(
          id: 'home-archived',
          categoryId: 'word-world-home-and-living',
          term: 'attic',
          translation: 'Dachboden',
          sourceLanguage: 'en',
          targetLanguage: 'de',
          isArchived: true,
          now: now,
        );

        final items = await container.read(
          localCategoryDetailGroupItemsProvider('home_living').future,
        );
        final home = items.singleWhere(
          (item) => item.wordHubKey == 'home_living',
        );

        expect(home.localCategoryId, 'word-world-home-and-living');
        expect(home.vocabsCount, 1);
      },
    );

    test(
      'falls_back_to_category_id_count_when_memberships_are_empty',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_category_detail_group_items_provider_fallback_test_',
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
        final now = DateTime.utc(2026, 5, 26).toIso8601String();
        await bootstrap.repositoryFactory.categoryRepository.upsertCategory(
          id: 'word-world-science',
          name: 'Science',
          now: DateTime.utc(2026, 5, 26),
        );
        await bootstrap.database.insert('words', {
          'id': 'science-active',
          'category_id': 'word-world-science',
          'term': 'atom',
          'translation': 'Atom',
          'translation_status': 'translated',
          'source_language': 'en',
          'target_language': 'de',
          'translation_error': null,
          'level': 'B1',
          'example_sentence': null,
          'notes': null,
          'sort_order': 0,
          'is_archived': 0,
          'created_at': now,
          'updated_at': now,
        });
        await bootstrap.database.insert('words', {
          'id': 'science-archived',
          'category_id': 'word-world-science',
          'term': 'gravity',
          'translation': 'Schwerkraft',
          'translation_status': 'translated',
          'source_language': 'en',
          'target_language': 'de',
          'translation_error': null,
          'level': 'B1',
          'example_sentence': null,
          'notes': null,
          'sort_order': 1,
          'is_archived': 1,
          'created_at': now,
          'updated_at': now,
        });

        final items = await container.read(
          localCategoryDetailGroupItemsProvider('science').future,
        );
        final science = items.singleWhere(
          (item) => item.wordHubKey == 'science',
        );

        expect(science.localCategoryId, 'word-world-science');
        expect(science.vocabsCount, 1);
      },
    );

    test('returns_empty_list_for_unknown_key_without_fallback_count', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final items = await container.read(
        localCategoryDetailGroupItemsProvider('unknown').future,
      );

      expect(items, isEmpty);
    });
  });
}
