import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/local_json_asset_import_service.dart';
import 'package:talvori/core/local_database/services/local_json_import_service.dart';

void main() {
  sqfliteFfiInit();

  group('LocalJsonAssetImportService', () {
    test('local_asset_import_loads_json_from_bundle', () async {
      const assetKey = 'assets/local_import/default_words_v1.json';
      const json = '[{"id":"basics","name":"Basics","words":[]}]';
      final assetBundle = MemoryAssetBundle({assetKey: json});
      final service = LocalJsonAssetImportService(assetBundle: assetBundle);

      final result = await service.loadJsonFromAsset(assetKey);

      expect(result, json);
      expect(assetBundle.loadedKeys, [assetKey]);
    });

    test('local_asset_import_delegates_to_json_import_service', () async {
      const assetKey = 'assets/local_import/default_words_v1.json';
      const json = '''
[
  {
    "id": "asset-basics",
    "name": "Asset Basics",
    "description": "Loaded from a memory asset bundle.",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "asset-basics-hello",
        "term": "hello",
        "translation": "hallo",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "asset-basics-water",
        "term": "water",
        "translation": "Wasser",
        "sort_order": 2,
        "is_archived": false
      }
    ]
  }
]
''';
      final now = DateTime(2026, 5, 13, 10);
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await LocalDatabaseSchema.createV1(db);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final jsonImportService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final assetBundle = MemoryAssetBundle({assetKey: json});
      final assetImportService = LocalJsonAssetImportService(
        assetBundle: assetBundle,
        jsonImportService: jsonImportService,
      );

      await assetImportService.importFromAsset(assetKey: assetKey, now: now);

      final categoryRows = await db.query('categories');
      final wordRows = await db.query('words');
      final progressRows = await db.query('word_progress');
      final sessionRows = await db.query('learning_sessions');
      final historyRows = await db.query('review_history');

      expect(assetBundle.loadedKeys, [assetKey]);
      expect(categoryRows, hasLength(1));
      expect(wordRows, hasLength(2));
      expect(progressRows, isEmpty);
      expect(sessionRows, isEmpty);
      expect(historyRows, isEmpty);
    });

    test('local_asset_import_is_idempotent', () async {
      const assetKey = 'assets/local_import/default_words_v1.json';
      const json = '''
[
  {
    "id": "asset-basics",
    "name": "Asset Basics",
    "description": "Loaded from a memory asset bundle.",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "asset-basics-hello",
        "term": "hello",
        "translation": "hallo",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "asset-basics-water",
        "term": "water",
        "translation": "Wasser",
        "sort_order": 2,
        "is_archived": false
      }
    ]
  }
]
''';
      final now = DateTime(2026, 5, 13, 10);
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await LocalDatabaseSchema.createV1(db);
      final categoryRepository = CategoryRepository(database: db);
      final wordRepository = WordRepository(database: db);
      final jsonImportService = LocalJsonImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
      );
      final assetBundle = MemoryAssetBundle({assetKey: json});
      final assetImportService = LocalJsonAssetImportService(
        assetBundle: assetBundle,
        jsonImportService: jsonImportService,
      );

      await assetImportService.importFromAsset(assetKey: assetKey, now: now);
      final categoriesAfterFirstRun = await db.query('categories');
      final wordsAfterFirstRun = await db.query('words');
      final categoryIdsAfterFirstRun = categoriesAfterFirstRun
          .map((category) => category['id']! as String)
          .toSet();
      final wordIdsAfterFirstRun = wordsAfterFirstRun
          .map((word) => word['id']! as String)
          .toSet();

      await assetImportService.importFromAsset(
        assetKey: assetKey,
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
  });
}

class MemoryAssetBundle extends AssetBundle {
  MemoryAssetBundle(this._assets);

  final Map<String, String> _assets;
  final List<String> loadedKeys = [];

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError('load is not used by this test bundle.');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    loadedKeys.add(key);
    final value = _assets[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    return value;
  }
}
