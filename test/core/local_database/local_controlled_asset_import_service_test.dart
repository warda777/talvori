import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_bootstrap.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_controlled_asset_import_service.dart';
import 'package:talvori/core/local_database/services/local_json_asset_import_service.dart';
import 'package:talvori/core/local_database/services/local_json_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  const assetKey = 'assets/local_import/default_words_v1.json';
  final fixedNow = DateTime(2026, 5, 13, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  group('LocalControlledAssetImportService', () {
    test('controlled_import_loads_registered_asset_and_imports_words', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final jsonImportService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final assetImportService = LocalJsonAssetImportService(
        assetBundle: rootBundle,
        jsonImportService: jsonImportService,
      );
      final controlledImportService = LocalControlledAssetImportService(
        assetImportService: assetImportService,
      );
      final oldDatabaseFile = File('word_progress.db');

      expect(oldDatabaseFile.existsSync(), isFalse);

      await controlledImportService.importRegisteredAsset(
        assetKey: assetKey,
        now: fixedNow,
      );

      final category = await categoryRepository.loadCategoryById('basics');
      final hello = await wordRepository.loadWordById('basics_hello');
      final water = await wordRepository.loadWordById('basics_water');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(category, isNotNull);
      expect(category!.name, 'Basics');
      expect(hello, isNotNull);
      expect(hello!.term, 'hello');
      expect(hello.translation, 'hallo');
      expect(water, isNotNull);
      expect(water!.term, 'water');
      expect(water.translation, 'Wasser');
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test('controlled_import_is_idempotent', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final jsonImportService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final assetImportService = LocalJsonAssetImportService(
        assetBundle: rootBundle,
        jsonImportService: jsonImportService,
      );
      final controlledImportService = LocalControlledAssetImportService(
        assetImportService: assetImportService,
      );
      final oldDatabaseFile = File('word_progress.db');

      expect(oldDatabaseFile.existsSync(), isFalse);

      await controlledImportService.importRegisteredAsset(
        assetKey: assetKey,
        now: fixedNow,
      );
      final categoriesAfterFirstRun = await db.query('categories');
      final wordsAfterFirstRun = await db.query('words');
      final categoryIdsAfterFirstRun = categoriesAfterFirstRun
          .map((category) => category['id']! as String)
          .toSet();
      final wordIdsAfterFirstRun = wordsAfterFirstRun
          .map((word) => word['id']! as String)
          .toSet();

      await controlledImportService.importRegisteredAsset(
        assetKey: assetKey,
        now: fixedNow.add(const Duration(minutes: 5)),
      );
      final categoriesAfterSecondRun = await db.query('categories');
      final wordsAfterSecondRun = await db.query('words');
      final categoryIdsAfterSecondRun = categoriesAfterSecondRun
          .map((category) => category['id']! as String)
          .toSet();
      final wordIdsAfterSecondRun = wordsAfterSecondRun
          .map((word) => word['id']! as String)
          .toSet();
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoriesAfterSecondRun, hasLength(categoriesAfterFirstRun.length));
      expect(wordsAfterSecondRun, hasLength(wordsAfterFirstRun.length));
      expect(categoryIdsAfterSecondRun, categoryIdsAfterFirstRun);
      expect(wordIdsAfterSecondRun, wordIdsAfterFirstRun);
      expect(categoryIdsAfterSecondRun, hasLength(categoriesAfterSecondRun.length));
      expect(wordIdsAfterSecondRun, hasLength(wordsAfterSecondRun.length));
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test(
      'controlled_import_does_not_run_on_bootstrap_without_explicit_call',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_controlled_import_bootstrap_test_',
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
          now: fixedNow,
        );
        addTearDown(result.database.close);
        final oldDatabaseFile = File('${tempDir.path}/word_progress.db');

        final categories = await result.database.query('categories');
        final words = await result.database.query('words');
        final progressRows = await result.database.query('word_progress');
        final sessionRows = await result.database.query('learning_sessions');
        final historyRows = await result.database.query('review_history');

        expect(categories, isEmpty);
        expect(words, isEmpty);
        expect(progressRows, isEmpty);
        expect(sessionRows, isEmpty);
        expect(historyRows, isEmpty);
        expect(oldDatabaseFile.existsSync(), isFalse);
      },
    );
  });
}
