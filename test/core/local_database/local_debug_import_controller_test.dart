import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/controllers/local_debug_import_controller.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_controlled_asset_import_service.dart';
import 'package:talvori/core/local_database/services/local_json_asset_import_service.dart';
import 'package:talvori/core/local_database/services/local_json_import_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final fixedNow = DateTime(2026, 5, 14, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  group('LocalDebugImportController', () {
    test('debug_import_controller_imports_default_words_when_called', () async {
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
      final controller = LocalDebugImportController(
        controlledImportService: controlledImportService,
      );
      final oldDatabaseFile = File('word_progress.db');

      expect(await db.query('categories'), isEmpty);
      expect(await db.query('words'), isEmpty);
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);

      await controller.importDefaultWords(now: fixedNow);

      final category = await categoryRepository.loadCategoryById('basics');
      final hello = await wordRepository.loadWordById('basics_hello');
      final water = await wordRepository.loadWordById('basics_water');

      expect(category, isNotNull);
      expect(category!.name, 'Basics');
      expect(hello, isNotNull);
      expect(hello!.term, 'hello');
      expect(water, isNotNull);
      expect(water!.term, 'water');
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
      expect(controller.state.wasSuccessful, isTrue);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.lastImportedAt, fixedNow);
      expect(
        controller.state.lastAction,
        LocalDebugImportControllerAction.importDefaultWords,
      );
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test('debug_import_controller_does_not_import_on_initialization', () async {
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
      final controller = LocalDebugImportController(
        controlledImportService: controlledImportService,
      );
      final oldDatabaseFile = File('word_progress.db');

      expect(await db.query('categories'), isEmpty);
      expect(await db.query('words'), isEmpty);
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.wasSuccessful, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.lastImportedAt, isNull);
      expect(controller.state.lastAction, LocalDebugImportControllerAction.none);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test('debug_import_controller_sets_error_state_on_failure', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final controller = LocalDebugImportController(
        controlledImportService: _FailingControlledAssetImportService(),
      );

      await controller.importDefaultWords(now: fixedNow);

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.wasSuccessful, isFalse);
      expect(controller.state.errorMessage, isNotNull);
      expect(controller.state.errorMessage, contains('debug import failed'));
      expect(controller.state.lastImportedAt, isNull);
      expect(
        controller.state.lastAction,
        LocalDebugImportControllerAction.importDefaultWordsFailed,
      );
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
    });

    test('debug_import_controller_reset_debug_state_does_not_modify_data', () async {
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
      final controller = LocalDebugImportController(
        controlledImportService: controlledImportService,
      );

      await controller.importDefaultWords(now: fixedNow);
      expect(await categoryRepository.loadCategoryById('basics'), isNotNull);
      expect(await wordRepository.loadWordById('basics_hello'), isNotNull);
      expect(await wordRepository.loadWordById('basics_water'), isNotNull);

      controller.resetDebugState();

      expect(controller.state.isLoading, isFalse);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.wasSuccessful, isFalse);
      expect(controller.state.lastImportedAt, isNull);
      expect(
        controller.state.lastAction,
        LocalDebugImportControllerAction.resetDebugState,
      );
      expect(await categoryRepository.loadCategoryById('basics'), isNotNull);
      expect(await wordRepository.loadWordById('basics_hello'), isNotNull);
      expect(await wordRepository.loadWordById('basics_water'), isNotNull);
      expect(await db.query('word_progress'), isEmpty);
      expect(await db.query('learning_sessions'), isEmpty);
      expect(await db.query('review_history'), isEmpty);
    });
  });
}

class _FailingControlledAssetImportService
    implements LocalControlledAssetImportService {
  @override
  Future<void> importRegisteredAsset({
    required String assetKey,
    required DateTime now,
  }) {
    throw StateError('debug import failed');
  }
}
