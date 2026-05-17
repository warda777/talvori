import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_bootstrap_result.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/local_repository_factory.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/services/local_learning_session_facade.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localBootstrapProvider', () {
    test('local_bootstrap_provider_creates_bootstrap_result', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_bootstrap_provider_test_',
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

      final result = await container.read(localBootstrapProvider.future);
      final categories = await result.database.query('categories');

      expect(result, isA<LocalAppBootstrapResult>());
      expect(result.databasePath, endsWith(LocalAppDatabasePath.databaseName));
      expect(result.repositoryFactory, isA<LocalRepositoryFactory>());
      expect(result.learningSessionFacade, isA<LocalLearningSessionFacade>());
      expect(
        categories.map((row) => row['id']),
        contains('seed-category-basics'),
      );
    });

    test('local_bootstrap_provider_closes_database_on_dispose', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_bootstrap_provider_dispose_test_',
      );
      addTearDown(() async {
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final container = ProviderContainer(
        overrides: [
          localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
        ],
      );

      final result = await container.read(localBootstrapProvider.future);
      final tablesBeforeDispose = await result.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );

      expect(tablesBeforeDispose, isNotEmpty);
      expect(result.database.isOpen, isTrue);

      container.dispose();

      await _expectDatabaseAccessFails(
        () => result.database.query('categories'),
      );
    });

    test(
      'local_bootstrap_provider_does_not_touch_old_word_progress_database',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_bootstrap_provider_old_db_test_',
        );
        addTearDown(() async {
          final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
          await databaseFactoryFfi.deleteDatabase(databasePath);
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final container = ProviderContainer(
          overrides: [
            localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
          ],
        );

        final result = await container.read(localBootstrapProvider.future);
        final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

        expect(
          result.databasePath,
          endsWith(LocalAppDatabasePath.databaseName),
        );
        expect(result.databasePath, isNot(contains('word_progress.db')));
        expect(oldDatabaseFile.existsSync(), isFalse);

        container.dispose();
        await Future<void>.delayed(Duration.zero);
      },
    );

    test('local_learning_session_facade_provider_exposes_facade', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_facade_provider_test_',
      );
      addTearDown(() async {
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final container = ProviderContainer(
        overrides: [
          localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
        ],
      );

      final facade = await container.read(
        localLearningSessionFacadeProvider.future,
      );
      final result = await container.read(localBootstrapProvider.future);
      final categories = await result.database.query('categories');
      final words = await result.database.query(
        'words',
        where: 'category_id = ?',
        whereArgs: ['seed-category-basics'],
      );
      final learningSessions = await result.database.query('learning_sessions');
      final reviewHistory = await result.database.query('review_history');
      final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

      expect(facade, isA<LocalLearningSessionFacade>());
      expect(
        categories.map((row) => row['id']),
        contains('seed-category-basics'),
      );
      expect(words, isNotEmpty);
      expect(learningSessions, isEmpty);
      expect(reviewHistory, isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);

      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });

    test(
      'local_learning_session_facade_provider_uses_existing_bootstrap_result',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_facade_provider_existing_result_test_',
        );
        addTearDown(() async {
          final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
          await databaseFactoryFfi.deleteDatabase(databasePath);
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final container = ProviderContainer(
          overrides: [
            localBootstrapDatabasesPathProvider.overrideWithValue(tempDir.path),
          ],
        );

        final result = await container.read(localBootstrapProvider.future);
        final facade = await container.read(
          localLearningSessionFacadeProvider.future,
        );
        final databaseFiles = Directory(
          tempDir.path,
        ).listSync().whereType<File>().toList();
        final categories = await result.database.query('categories');
        final learningSessions = await result.database.query(
          'learning_sessions',
        );
        final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

        expect(identical(facade, result.learningSessionFacade), isTrue);
        expect(
          databaseFiles.where(
            (file) => file.path.endsWith(LocalAppDatabasePath.databaseName),
          ),
          hasLength(1),
        );
        expect(oldDatabaseFile.existsSync(), isFalse);
        expect(
          categories.map((row) => row['id']),
          contains('seed-category-basics'),
        );
        expect(learningSessions, isEmpty);

        container.dispose();
        await Future<void>.delayed(Duration.zero);
      },
    );
  });
}

Future<void> _expectDatabaseAccessFails(
  Future<List<Map<String, Object?>>> Function() query,
) async {
  for (var attempt = 0; attempt < 20; attempt += 1) {
    try {
      await query();
    } catch (_) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  fail('Database still accepted queries after ProviderContainer.dispose().');
}
