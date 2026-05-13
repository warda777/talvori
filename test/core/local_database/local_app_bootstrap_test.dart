import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_bootstrap.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/local_repository_factory.dart';
import 'package:talvori/core/local_database/services/local_learning_session_facade.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LocalAppBootstrap', () {
    test('bootstrap_opens_database_and_builds_facade', () async {
      final now = DateTime(2026, 5, 13, 10);
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_app_bootstrap_test_',
      );
      addTearDown(() async {
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final result = await const LocalAppBootstrap().bootstrap(
        databasesPath: tempDir.path,
        seedDefaults: false,
        now: now,
      );
      addTearDown(result.database.close);

      final tables = await result.database.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final tableNames = tables.map((row) => row['name']).toSet();
      final categories = await result.database.query('categories');
      final words = await result.database.query('words');

      expect(result.databasePath, endsWith(LocalAppDatabasePath.databaseName));
      expect(
        tableNames,
        containsAll({
          'categories',
          'words',
          'word_progress',
          'review_history',
          'learning_sessions',
          'session_items',
          'settings',
        }),
      );
      expect(result.repositoryFactory, isA<LocalRepositoryFactory>());
      expect(result.learningSessionFacade, isA<LocalLearningSessionFacade>());
      expect(categories, isEmpty);
      expect(words, isEmpty);
    });

    test('bootstrap_can_seed_defaults_when_requested', () async {
      final now = DateTime(2026, 5, 13, 10);
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_app_bootstrap_seed_test_',
      );
      addTearDown(() async {
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final result = await const LocalAppBootstrap().bootstrap(
        databasesPath: tempDir.path,
        seedDefaults: true,
        now: now,
      );
      addTearDown(result.database.close);

      final categories = await result.database.query('categories');
      final words = await result.database.query('words');
      final wordProgress = await result.database.query('word_progress');
      final learningSessions = await result.database.query('learning_sessions');
      final reviewHistory = await result.database.query('review_history');
      final categoryNames = categories.map((row) => row['name']).toSet();

      expect(categoryNames, containsAll({'Basics', 'Travel', 'Exam Practice'}));
      expect(words, isNotEmpty);
      expect(wordProgress, isEmpty);
      expect(learningSessions, isEmpty);
      expect(reviewHistory, isEmpty);
      expect(result.learningSessionFacade, isA<LocalLearningSessionFacade>());
    });

    test('bootstrap_does_not_touch_old_word_progress_database', () async {
      final now = DateTime(2026, 5, 13, 10);
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_app_bootstrap_old_db_test_',
      );
      addTearDown(() async {
        final databasePath = LocalAppDatabasePath.buildPath(tempDir.path);
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final result = await const LocalAppBootstrap().bootstrap(
        databasesPath: tempDir.path,
        seedDefaults: false,
        now: now,
      );
      addTearDown(result.database.close);

      final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

      expect(result.databasePath, endsWith(LocalAppDatabasePath.databaseName));
      expect(result.databasePath, isNot(contains('word_progress.db')));
      expect(oldDatabaseFile.existsSync(), isFalse);
    });
  });
}
