import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/shared_text_import_service_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localWordsForCategoryProvider', () {
    test('loads_words_for_local_category', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_words_for_category_provider_test_',
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

      final words = await container.read(
        localWordsForCategoryProvider('seed-category-basics').future,
      );

      expect(words, hasLength(25));
      expect(words.map((word) => word.term), containsAll(['hello', 'water']));
    });

    test('returns_empty_list_for_empty_or_unknown_category', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_words_for_category_provider_empty_test_',
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

      final unknownWords = await container.read(
        localWordsForCategoryProvider('unknown-category').future,
      );
      final emptyWords = await container.read(
        localWordsForCategoryProvider('').future,
      );

      expect(unknownWords, isEmpty);
      expect(emptyWords, isEmpty);
    });

    test('sees_imported_word_in_local_my_words_category', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_words_for_my_words_provider_test_',
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

      final words = await container.read(
        localWordsForCategoryProvider(localMyWordsCategoryId).future,
      );

      expect(words, hasLength(1));
      expect(words.single.term, 'umbrella');
      expect(words.single.translationStatus, TranslationStatus.pending);
    });
  });
}
