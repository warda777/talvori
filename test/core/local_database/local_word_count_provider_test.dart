import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/shared_text_import_service_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localWordCountProvider', () {
    test('loads_word_count_for_local_category', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_count_provider_test_',
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

      final count = await container.read(
        localWordCountProvider('seed-category-basics').future,
      );

      expect(count, 25);
    });

    test('returns_zero_for_empty_or_unknown_category', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_count_provider_empty_test_',
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

      final unknownCount = await container.read(
        localWordCountProvider('unknown-category').future,
      );
      final emptyCount = await container.read(
        localWordCountProvider('').future,
      );

      expect(unknownCount, 0);
      expect(emptyCount, 0);
    });

    test('counts_imported_words_in_local_my_words_category', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_count_my_words_provider_test_',
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

      final importService = await container.read(
        sharedTextImportServiceProvider.future,
      );
      await importService.importRawText(
        rawText: 'umbrella',
        now: DateTime(2026, 5, 18, 10),
      );

      final count = await container.read(
        localWordCountProvider(localMyWordsCategoryId).future,
      );

      expect(count, 1);
    });

    test('counts_word_world_memberships_before_category_id_fallback', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_count_word_world_provider_test_',
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
      await repositories.categoryRepository.upsertCategory(
        id: 'category-travel',
        name: 'Travel',
        now: DateTime(2026, 5, 27, 10),
      );
      await repositories.wordRepository.upsertWord(
        id: 'word-ticket',
        categoryId: 'seed-category-basics',
        term: 'ticket',
        translation: 'Fahrkarte',
        now: DateTime(2026, 5, 27, 10),
      );
      await repositories.wordRepository.upsertWord(
        id: 'word-hotel',
        categoryId: 'seed-category-basics',
        term: 'hotel',
        translation: 'Hotel',
        now: DateTime(2026, 5, 27, 10),
      );
      await repositories.wordRepository.addWordWorldMembership(
        wordId: 'word-ticket',
        categoryId: 'category-travel',
        createdAt: DateTime(2026, 5, 27, 10),
      );
      await repositories.wordRepository.addWordWorldMembership(
        wordId: 'word-hotel',
        categoryId: 'category-travel',
        createdAt: DateTime(2026, 5, 27, 10),
      );

      final count = await container.read(
        localWordCountProvider('category-travel').future,
      );

      expect(count, 2);
    });

    test('counts_disabled_word_world_memberships_for_visible_vocabs', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_count_disabled_word_world_provider_test_',
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
      final now = DateTime(2026, 5, 28, 10);
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
      await repositories.wordRepository.setWordWorldMembershipDisabled(
        wordId: 'word-hotel',
        categoryId: 'category-travel',
        disabled: true,
      );

      final count = await container.read(
        localWordCountProvider('category-travel').future,
      );
      final words = await container.read(
        localWordsForCategoryProvider('category-travel').future,
      );

      expect(count, 2);
      expect(words.map((word) => word.id), ['word-hotel', 'word-ticket']);
      expect(
        words
            .singleWhere((word) => word.id == 'word-hotel')
            .isDisabledForCategory,
        isTrue,
      );
    });

    test('my_words_count_is_zero_before_first_import', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_count_my_words_empty_provider_test_',
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

      final count = await container.read(
        localWordCountProvider(localMyWordsCategoryId).future,
      );

      expect(count, 0);
    });
  });
}
