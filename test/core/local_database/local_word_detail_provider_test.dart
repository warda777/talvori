import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localWordDetailProvider', () {
    test('loads_local_word_with_progress_when_available', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_detail_provider_test_',
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
      await bootstrapResult.repositoryFactory.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: 'seed-category-basics',
            mode: LearningMode.adaptive,
            now: DateTime(2026, 1, 1),
          );

      final detail = await container.read(
        localWordDetailProvider(
          const LocalWordDetailRequest(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
          ),
        ).future,
      );

      expect(detail, isNotNull);
      expect(detail!.word.term, 'hello');
      expect(detail.word.translation, 'hallo');
      expect(detail.progress, isNotNull);
      expect(detail.progress!.passCount, 0);
    });

    test('returns_null_for_empty_or_mismatched_request', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_word_detail_provider_empty_test_',
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

      final empty = await container.read(
        localWordDetailProvider(
          const LocalWordDetailRequest(wordId: '', categoryId: ''),
        ).future,
      );
      final mismatched = await container.read(
        localWordDetailProvider(
          const LocalWordDetailRequest(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-travel',
          ),
        ).future,
      );

      expect(empty, isNull);
      expect(mismatched, isNull);
    });
  });
}
