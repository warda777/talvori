import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/local_repository_factory.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_json_import_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/training_area.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 13, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  group('LocalJsonImportService', () {
    test('local_import_fixture_can_be_loaded_from_test_file', () async {
      final fixture = File('test/fixtures/local_import/default_words_v1.json');

      final contents = await fixture.readAsString();
      final decoded = jsonDecode(contents);

      expect(decoded, isA<List<Object?>>());
      final categories = decoded as List<Object?>;
      expect(categories, isNotEmpty);

      final firstCategory = categories.first;
      expect(firstCategory, isA<Map<String, Object?>>());
      final category = firstCategory as Map<String, Object?>;
      expect(category, contains('id'));
      expect(category, contains('name'));
      expect(category, contains('words'));
      expect(category['words'], isA<List<Object?>>());
      expect(category['words'] as List<Object?>, isNotEmpty);
    });

    test('real_asset_file_has_valid_json_structure', () async {
      final assetFile = File('assets/local_import/default_words_v1.json');

      expect(assetFile.existsSync(), isTrue);
      final contents = await assetFile.readAsString();
      final decoded = jsonDecode(contents);

      expect(decoded, isA<List<Object?>>());
      final categories = decoded as List<Object?>;
      expect(categories, isNotEmpty);

      final firstCategory = categories.first;
      expect(firstCategory, isA<Map<String, Object?>>());
      final category = firstCategory as Map<String, Object?>;
      expect(category, contains('id'));
      expect(category, contains('name'));
      expect(category, contains('description'));
      expect(category, contains('sort_order'));
      expect(category, contains('is_archived'));
      expect(category, contains('words'));
      expect(category['words'], isA<List<Object?>>());
      final words = category['words'] as List<Object?>;
      expect(words, isNotEmpty);

      final firstWord = words.first;
      expect(firstWord, isA<Map<String, Object?>>());
      final word = firstWord as Map<String, Object?>;
      expect(word, contains('id'));
      expect(word, contains('term'));
      expect(word, contains('translation'));
      expect(word, contains('example_sentence'));
      expect(word, contains('notes'));
      expect(word, contains('sort_order'));
      expect(word, contains('is_archived'));
    });

    test('asset_is_registered_and_loadable_with_root_bundle', () async {
      final contents = await rootBundle.loadString(
        'assets/local_import/default_words_v1.json',
      );

      expect(contents, isNotEmpty);
      final decoded = jsonDecode(contents);

      expect(decoded, isA<List<Object?>>());
      final categories = decoded as List<Object?>;
      expect(categories, isNotEmpty);

      final firstCategory = categories.first;
      expect(firstCategory, isA<Map<String, Object?>>());
      final category = firstCategory as Map<String, Object?>;
      expect(category, contains('id'));
      expect(category, contains('name'));
      expect(category, contains('words'));
    });

    test(
      'loaded_asset_can_be_imported_with_local_json_import_service',
      () async {
        final importJson = await rootBundle.loadString(
          'assets/local_import/default_words_v1.json',
        );
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final categoryRepository = CategoryRepository(database: db);
        final wordRepository = WordRepository(database: db);
        final importService = LocalJsonImportService(
          categoryRepository: categoryRepository,
          wordRepository: wordRepository,
        );
        final oldDatabaseFile = File('word_progress.db');

        expect(oldDatabaseFile.existsSync(), isFalse);

        await importService.importFromJsonString(json: importJson, now: now);

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
      },
    );

    test(
      'real_asset_file_can_be_imported_with_local_json_import_service',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        final categoryRepository = CategoryRepository(database: db);
        final wordRepository = WordRepository(database: db);
        final importService = LocalJsonImportService(
          categoryRepository: categoryRepository,
          wordRepository: wordRepository,
        );
        final assetFile = File('assets/local_import/default_words_v1.json');
        final oldDatabaseFile = File('word_progress.db');

        expect(oldDatabaseFile.existsSync(), isFalse);

        final importJson = await assetFile.readAsString();
        await importService.importFromJsonString(json: importJson, now: now);

        final category = await categoryRepository.loadCategoryById('basics');
        final hello = await wordRepository.loadWordById('basics_hello');
        final water = await wordRepository.loadWordById('basics_water');
        final progressRows = await db.query('word_progress');
        final sessionRows = await db.query('learning_sessions');
        final historyRows = await db.query('review_history');

        expect(category, isNotNull);
        expect(category!.name, 'Basics');
        expect(
          category.description,
          'Essential starter words for local offline-first import.',
        );
        expect(category.sortOrder, 1);
        expect(category.isArchived, isFalse);
        expect(hello, isNotNull);
        expect(hello!.term, 'hello');
        expect(hello.translation, 'hallo');
        expect(hello.exampleSentence, 'Hello, how are you?');
        expect(hello.notes, 'Common greeting.');
        expect(hello.sortOrder, 1);
        expect(hello.isArchived, isFalse);
        expect(water, isNotNull);
        expect(water!.term, 'water');
        expect(water.translation, 'Wasser');
        expect(water.exampleSentence, 'I would like some water.');
        expect(water.notes, 'Useful everyday noun.');
        expect(water.sortOrder, 2);
        expect(water.isArchived, isFalse);
        expect(progressRows, isEmpty);
        expect(sessionRows, isEmpty);
        expect(historyRows, isEmpty);
        expect(oldDatabaseFile.existsSync(), isFalse);
      },
    );

    test('real_asset_file_import_is_idempotent', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final assetFile = File('assets/local_import/default_words_v1.json');
      final oldDatabaseFile = File('word_progress.db');

      expect(oldDatabaseFile.existsSync(), isFalse);

      final importJson = await assetFile.readAsString();
      await importService.importFromJsonString(json: importJson, now: now);
      final categoriesAfterFirstRun = await db.query('categories');
      final wordsAfterFirstRun = await db.query('words');
      final categoryIdsAfterFirstRun = categoriesAfterFirstRun
          .map((category) => category['id']! as String)
          .toSet();
      final wordIdsAfterFirstRun = wordsAfterFirstRun
          .map((word) => word['id']! as String)
          .toSet();

      await importService.importFromJsonString(
        json: importJson,
        now: now.add(const Duration(minutes: 5)),
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

    test('real_asset_file_words_can_start_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repositoryFactory = LocalRepositoryFactory(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: repositoryFactory.categoryRepository,
        wordRepository: repositoryFactory.wordRepository,
      );
      final assetFile = File('assets/local_import/default_words_v1.json');
      final oldDatabaseFile = File('word_progress.db');

      expect(oldDatabaseFile.existsSync(), isFalse);

      final importJson = await assetFile.readAsString();
      await importService.importFromJsonString(json: importJson, now: now);
      final progressRowsAfterImport = await db.query('word_progress');
      final sessionRowsAfterImport = await db.query('learning_sessions');
      final historyRowsAfterImport = await db.query('review_history');

      await repositoryFactory.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: 'basics',
            mode: LearningMode.adaptive,
            now: now,
          );
      final readState = await repositoryFactory.learningSessionFacade
          .startOrResumeLearning(
            categoryId: 'basics',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final activeSessions = await db.query(
        'learning_sessions',
        where:
            'category_id = ? AND mode_id = ? AND training_area_id = ? AND status = ?',
        whereArgs: [
          'basics',
          LearningMode.adaptive.name,
          TrainingArea.all.name,
          'active',
        ],
      );
      final sessionItems = await db.query('session_items');

      expect(progressRowsAfterImport, isEmpty);
      expect(sessionRowsAfterImport, isEmpty);
      expect(historyRowsAfterImport, isEmpty);
      expect(readState.sessionId, isNotEmpty);
      expect(readState.currentWordId, isNotNull);
      expect(readState.currentTerm, isNotNull);
      expect(readState.currentTranslation, isNotNull);
      expect(readState.currentStage, SrsStage.s0);
      expect(readState.canSubmitAnswer, isTrue);
      expect(activeSessions, hasLength(1));
      expect(sessionItems, isNotEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test('local_import_fixture_creates_categories_and_words', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final fixture = File('test/fixtures/local_import/default_words_v1.json');

      final importJson = await fixture.readAsString();
      await importService.importFromJsonString(json: importJson, now: now);

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final category = await categoryRepository.loadCategoryById('basics');
      final word = await wordRepository.loadWordById('basics_hello');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoryRows, isNotEmpty);
      expect(wordRows, isNotEmpty);
      expect(category, isNotNull);
      expect(category!.name, 'Basics');
      expect(category.description, 'Essential starter words for local import tests.');
      expect(category.sortOrder, 1);
      expect(category.isArchived, isFalse);
      expect(word, isNotNull);
      expect(word!.term, 'hello');
      expect(word.translation, 'hallo');
      expect(word.exampleSentence, 'Hello, how are you?');
      expect(word.notes, 'Common greeting.');
      expect(word.sortOrder, 1);
      expect(word.isArchived, isFalse);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('local_import_fixture_is_idempotent', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final fixture = File('test/fixtures/local_import/default_words_v1.json');

      final importJson = await fixture.readAsString();
      await importService.importFromJsonString(json: importJson, now: now);
      final categoriesAfterFirstRun = await db.query('categories');
      final wordsAfterFirstRun = await db.query('words');
      final categoryIdsAfterFirstRun = categoriesAfterFirstRun
          .map((category) => category['id']! as String)
          .toSet();
      final wordIdsAfterFirstRun = wordsAfterFirstRun
          .map((word) => word['id']! as String)
          .toSet();

      await importService.importFromJsonString(
        json: importJson,
        now: now.add(const Duration(minutes: 5)),
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
    });

    test('local_import_fixture_words_can_start_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repositoryFactory = LocalRepositoryFactory(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: repositoryFactory.categoryRepository,
        wordRepository: repositoryFactory.wordRepository,
      );
      final fixture = File('test/fixtures/local_import/default_words_v1.json');
      final oldDatabaseFile = File('word_progress.db');

      expect(oldDatabaseFile.existsSync(), isFalse);

      final importJson = await fixture.readAsString();
      await importService.importFromJsonString(json: importJson, now: now);
      final progressRowsAfterImport = await db.query('word_progress');
      final sessionRowsAfterImport = await db.query('learning_sessions');
      final historyRowsAfterImport = await db.query('review_history');

      await repositoryFactory.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: 'basics',
            mode: LearningMode.adaptive,
            now: now,
          );
      final readState = await repositoryFactory.learningSessionFacade
          .startOrResumeLearning(
            categoryId: 'basics',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final activeSessions = await db.query(
        'learning_sessions',
        where:
            'category_id = ? AND mode_id = ? AND training_area_id = ? AND status = ?',
        whereArgs: [
          'basics',
          LearningMode.adaptive.name,
          TrainingArea.all.name,
          'active',
        ],
      );
      final sessionItems = await db.query('session_items');

      expect(progressRowsAfterImport, isEmpty);
      expect(sessionRowsAfterImport, isEmpty);
      expect(historyRowsAfterImport, isEmpty);
      expect(readState.sessionId, isNotEmpty);
      expect(readState.currentWordId, isNotNull);
      expect(readState.currentTerm, isNotNull);
      expect(readState.currentTranslation, isNotNull);
      expect(readState.currentStage, SrsStage.s0);
      expect(readState.canSubmitAnswer, isTrue);
      expect(activeSessions, hasLength(1));
      expect(sessionItems, isNotEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test('local_import_creates_categories_and_words', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "import-category-basics",
    "name": "Import Basics",
    "description": "Imported starter words.",
    "sort_order": 2,
    "is_archived": false,
    "words": [
      {
        "id": "import-basics-hello",
        "term": "hello",
        "translation": "hallo",
        "example_sentence": "Hello there.",
        "notes": "Greeting.",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "import-basics-old",
        "term": "old",
        "translation": "alt",
        "sort_order": 2,
        "is_archived": true
      }
    ]
  }
]
''';

      await importService.importFromJsonString(json: importJson, now: now);

      final category = await categoryRepository.loadCategoryById(
        'import-category-basics',
      );
      final activeWords = await wordRepository.loadWordsForCategory(
        categoryId: 'import-category-basics',
      );
      final allWords = await wordRepository.loadWordsForCategory(
        categoryId: 'import-category-basics',
        includeArchived: true,
      );
      final hello = await wordRepository.loadWordById('import-basics-hello');
      final old = await wordRepository.loadWordById('import-basics-old');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(category, isNotNull);
      expect(category!.name, 'Import Basics');
      expect(category.description, 'Imported starter words.');
      expect(category.sortOrder, 2);
      expect(category.isArchived, isFalse);
      expect(activeWords, hasLength(1));
      expect(allWords, hasLength(2));
      expect(hello, isNotNull);
      expect(hello!.term, 'hello');
      expect(hello.translation, 'hallo');
      expect(hello.exampleSentence, 'Hello there.');
      expect(hello.notes, 'Greeting.');
      expect(hello.sortOrder, 1);
      expect(hello.isArchived, isFalse);
      expect(old, isNotNull);
      expect(old!.term, 'old');
      expect(old.translation, 'alt');
      expect(old.sortOrder, 2);
      expect(old.isArchived, isTrue);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('local_import_is_idempotent', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "import-category-basics",
    "name": "Import Basics",
    "description": "Imported starter words.",
    "sort_order": 2,
    "is_archived": false,
    "words": [
      {
        "id": "import-basics-hello",
        "term": "hello",
        "translation": "hallo",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "import-basics-water",
        "term": "water",
        "translation": "Wasser",
        "sort_order": 2,
        "is_archived": false
      }
    ]
  }
]
''';

      await importService.importFromJsonString(json: importJson, now: now);
      final categoriesAfterFirstRun = await db.query('categories');
      final wordsAfterFirstRun = await db.query('words');
      final categoryIdsAfterFirstRun = categoriesAfterFirstRun
          .map((category) => category['id']! as String)
          .toSet();
      final wordIdsAfterFirstRun = wordsAfterFirstRun
          .map((word) => word['id']! as String)
          .toSet();

      await importService.importFromJsonString(
        json: importJson,
        now: now.add(const Duration(minutes: 5)),
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
    });

    test('local_import_does_not_create_progress', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "import-category-travel",
    "name": "Travel",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "import-travel-ticket",
        "term": "ticket",
        "translation": "Fahrkarte",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "import-travel-station",
        "term": "station",
        "translation": "Bahnhof",
        "sort_order": 2,
        "is_archived": false
      }
    ]
  }
]
''';

      await importService.importFromJsonString(json: importJson, now: now);

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoryRows, isNotEmpty);
      expect(wordRows, isNotEmpty);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('imported_words_can_initialize_progress_and_start_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repositoryFactory = LocalRepositoryFactory(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: repositoryFactory.categoryRepository,
        wordRepository: repositoryFactory.wordRepository,
      );
      const importJson = '''
[
  {
    "id": "import-category-session",
    "name": "Session Import",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "import-session-hello",
        "term": "hello",
        "translation": "hallo",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "import-session-water",
        "term": "water",
        "translation": "Wasser",
        "sort_order": 2,
        "is_archived": false
      },
      {
        "id": "import-session-book",
        "term": "book",
        "translation": "Buch",
        "sort_order": 3,
        "is_archived": false
      }
    ]
  }
]
''';

      await importService.importFromJsonString(json: importJson, now: now);
      final progressRowsAfterImport = await db.query('word_progress');
      final sessionRowsAfterImport = await db.query('learning_sessions');
      final historyRowsAfterImport = await db.query('review_history');

      await repositoryFactory.progressInitializationService
          .initializeProgressForCategoryAndMode(
            categoryId: 'import-category-session',
            mode: LearningMode.adaptive,
            now: now,
          );
      final readState = await repositoryFactory.learningSessionFacade
          .startOrResumeLearning(
            categoryId: 'import-category-session',
            mode: LearningMode.adaptive,
            trainingArea: TrainingArea.all,
            now: now,
          );
      final activeSessions = await db.query(
        'learning_sessions',
        where:
            'category_id = ? AND mode_id = ? AND training_area_id = ? AND status = ?',
        whereArgs: [
          'import-category-session',
          LearningMode.adaptive.name,
          TrainingArea.all.name,
          'active',
        ],
      );
      final sessionItems = await db.query('session_items');

      expect(progressRowsAfterImport, isEmpty);
      expect(sessionRowsAfterImport, isEmpty);
      expect(historyRowsAfterImport, isEmpty);
      expect(readState.sessionId, isNotEmpty);
      expect(readState.currentWordId, isNotNull);
      expect(readState.currentTerm, isNotNull);
      expect(readState.currentTranslation, isNotNull);
      expect(readState.currentStage, SrsStage.s0);
      expect(readState.canSubmitAnswer, isTrue);
      expect(activeSessions, hasLength(1));
      expect(sessionItems, isNotEmpty);
    });

    test('local_import_rejects_missing_category_id', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "",
    "name": "Broken Category",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "broken-word",
        "term": "broken",
        "translation": "kaputt",
        "sort_order": 1,
        "is_archived": false
      }
    ]
  }
]
''';

      expect(
        () => importService.importFromJsonString(json: importJson, now: now),
        throwsA(isA<FormatException>()),
      );

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoryRows, isEmpty);
      expect(wordRows, isEmpty);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('local_import_rejects_missing_word_term', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "valid-category",
    "name": "Valid Category",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "word-without-term",
        "term": "",
        "translation": "kaputt",
        "sort_order": 1,
        "is_archived": false
      }
    ]
  }
]
''';

      expect(
        () => importService.importFromJsonString(json: importJson, now: now),
        throwsA(isA<FormatException>()),
      );

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoryRows, isEmpty);
      expect(wordRows, isEmpty);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('local_import_rejects_duplicate_category_ids_in_import_file', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "duplicate-category",
    "name": "First",
    "sort_order": 1,
    "is_archived": false,
    "words": []
  },
  {
    "id": "duplicate-category",
    "name": "Second",
    "sort_order": 2,
    "is_archived": false,
    "words": []
  }
]
''';

      expect(
        () => importService.importFromJsonString(json: importJson, now: now),
        throwsA(isA<FormatException>()),
      );

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoryRows, isEmpty);
      expect(wordRows, isEmpty);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('local_import_rejects_duplicate_word_ids_in_import_file', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final importService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      const importJson = '''
[
  {
    "id": "valid-category",
    "name": "Valid Category",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "duplicate-word",
        "term": "first",
        "translation": "erste",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "duplicate-word",
        "term": "second",
        "translation": "zweite",
        "sort_order": 2,
        "is_archived": false
      }
    ]
  }
]
''';

      expect(
        () => importService.importFromJsonString(json: importJson, now: now),
        throwsA(isA<FormatException>()),
      );

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(categoryRows, isEmpty);
      expect(wordRows, isEmpty);
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });
  });
}
