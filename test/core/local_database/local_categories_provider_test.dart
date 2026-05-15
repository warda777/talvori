import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localCategoriesProvider', () {
    test('local_categories_provider_loads_imported_categories', () async {
      final fixedNow = DateTime(2026, 5, 15, 10);
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_categories_provider_test_',
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
        id: 'basics',
        name: 'Basics',
        description: 'Local basics category.',
        sortOrder: 1,
        isArchived: false,
        now: fixedNow,
      );

      final categories = await container.read(localCategoriesProvider.future);
      final basics = categories.singleWhere(
        (category) => category.id == 'basics',
      );
      final wordProgress = await bootstrapResult.database.query(
        'word_progress',
      );
      final learningSessions = await bootstrapResult.database.query(
        'learning_sessions',
      );
      final reviewHistory = await bootstrapResult.database.query(
        'review_history',
      );
      final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

      expect(categories, hasLength(1));
      expect(basics.name, 'Basics');
      expect(basics.isArchived, isFalse);
      expect(wordProgress, isEmpty);
      expect(learningSessions, isEmpty);
      expect(reviewHistory, isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test('local_categories_provider_does_not_import_on_read', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_categories_provider_empty_test_',
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

      final categories = await container.read(localCategoriesProvider.future);
      final bootstrapResult = await container.read(
        localBootstrapProvider.future,
      );
      final categoryRows = await bootstrapResult.database.query('categories');
      final wordRows = await bootstrapResult.database.query('words');
      final wordProgress = await bootstrapResult.database.query(
        'word_progress',
      );
      final learningSessions = await bootstrapResult.database.query(
        'learning_sessions',
      );
      final reviewHistory = await bootstrapResult.database.query(
        'review_history',
      );
      final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

      expect(categories, isEmpty);
      expect(categoryRows, isEmpty);
      expect(wordRows, isEmpty);
      expect(wordProgress, isEmpty);
      expect(learningSessions, isEmpty);
      expect(reviewHistory, isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });
  });
}
