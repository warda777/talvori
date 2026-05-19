import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
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
