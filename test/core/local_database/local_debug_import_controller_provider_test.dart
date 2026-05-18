import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/controllers/local_debug_import_controller.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_debug_import_controller_provider.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('localDebugImportControllerProvider', () {
    test('debug_import_controller_provider_exposes_initial_state', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_debug_import_controller_provider_test_',
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

      final debugState = await container.read(
        localDebugImportControllerProvider.future,
      );
      final bootstrapResult = await container.read(
        localBootstrapProvider.future,
      );
      final categories = await bootstrapResult.database.query('categories');
      final words = await bootstrapResult.database.query('words');
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

      expect(debugState.isLoading, isFalse);
      expect(debugState.errorMessage, isNull);
      expect(debugState.wasSuccessful, isFalse);
      expect(debugState.lastImportedAt, isNull);
      expect(debugState.lastAction, LocalDebugImportControllerAction.none);
      expect(categories, isNotEmpty);
      expect(words, isNotEmpty);
      expect(wordProgress, isEmpty);
      expect(learningSessions, isEmpty);
      expect(reviewHistory, isEmpty);
      expect(oldDatabaseFile.existsSync(), isFalse);
    });

    test(
      'debug_import_controller_provider_imports_when_notifier_called',
      () async {
        final fixedNow = DateTime(2026, 5, 14, 11);
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_debug_import_controller_provider_import_test_',
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
            localDebugImportAssetBundleProvider.overrideWithValue(
              MemoryAssetBundle({
                LocalDebugImportController.defaultWordsAssetKey:
                    _defaultWordsJson,
              }),
            ),
          ],
        );

        await container.read(localDebugImportControllerProvider.future);
        final bootstrapResult = await container.read(
          localBootstrapProvider.future,
        );
        final categoriesBefore = await bootstrapResult.database.query(
          'categories',
        );
        final wordsBefore = await bootstrapResult.database.query('words');

        expect(categoriesBefore, isNotEmpty);
        expect(wordsBefore, isNotEmpty);

        await container
            .read(localDebugImportControllerProvider.notifier)
            .importDefaultWords(now: fixedNow);

        final categories = await bootstrapResult.database.query(
          'categories',
          where: 'id = ?',
          whereArgs: ['basics'],
        );
        final helloWords = await bootstrapResult.database.query(
          'words',
          where: 'id = ?',
          whereArgs: ['basics_hello'],
        );
        final waterWords = await bootstrapResult.database.query(
          'words',
          where: 'id = ?',
          whereArgs: ['basics_water'],
        );
        final debugState =
            container.read(localDebugImportControllerProvider)
                as AsyncData<LocalDebugImportControllerState>;
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
        expect(helloWords, hasLength(1));
        expect(waterWords, hasLength(1));
        expect(debugState.value.isLoading, isFalse);
        expect(debugState.value.wasSuccessful, isTrue);
        expect(debugState.value.errorMessage, isNull);
        expect(debugState.value.lastImportedAt, fixedNow);
        expect(
          debugState.value.lastAction,
          LocalDebugImportControllerAction.importDefaultWords,
        );
        expect(wordProgress, isEmpty);
        expect(learningSessions, isEmpty);
        expect(reviewHistory, isEmpty);
        expect(oldDatabaseFile.existsSync(), isFalse);
      },
    );
  });
}

const _defaultWordsJson = '''
[
  {
    "id": "basics",
    "name": "Basics",
    "description": "Debug import basics.",
    "sort_order": 1,
    "is_archived": false,
    "words": [
      {
        "id": "basics_hello",
        "term": "hello",
        "translation": "hallo",
        "example_sentence": "Hello, how are you?",
        "notes": "Greeting",
        "sort_order": 1,
        "is_archived": false
      },
      {
        "id": "basics_water",
        "term": "water",
        "translation": "Wasser",
        "example_sentence": "I drink water.",
        "notes": "Basic noun",
        "sort_order": 2,
        "is_archived": false
      }
    ]
  }
]
''';

class MemoryAssetBundle extends AssetBundle {
  MemoryAssetBundle(this._assets);

  final Map<String, String> _assets;

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError('load is not used by this test bundle.');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _assets[key];
    if (value == null) {
      throw StateError('Missing test asset: $key');
    }
    return value;
  }
}
