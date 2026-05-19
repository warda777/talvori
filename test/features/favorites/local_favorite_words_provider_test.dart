import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/favorites/application/local_favorite_words_provider.dart';
import 'package:talvori/features/favorites/application/local_favorites_provider.dart';
import 'package:talvori/features/favorites/data/local_favorites_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test(
    'localFavoriteWordsProvider resolves favorite word ids locally',
    () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_favorite_words_provider_test_',
      );
      final favoritesRepository = _MemoryLocalFavoritesRepository([
        'favorite-word-1',
        'favorite-word-1',
        'missing-word',
      ]);

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
          localFavoritesRepositoryProvider.overrideWithValue(
            favoritesRepository,
          ),
        ],
      );

      final bootstrap = await container.read(localBootstrapProvider.future);
      final now = DateTime(2026, 5, 19, 12);
      await bootstrap.repositoryFactory.categoryRepository.upsertCategory(
        id: localMyWordsCategoryId,
        name: localMyWordsCategoryLabel,
        sortOrder: 1,
        now: now,
      );
      await bootstrap.repositoryFactory.wordRepository.upsertWord(
        id: 'favorite-word-1',
        categoryId: localMyWordsCategoryId,
        term: 'spark',
        translation: '',
        now: now,
      );

      final words = await container.read(localFavoriteWordsProvider.future);

      expect(words, hasLength(1));
      expect(words.single.id, 'favorite-word-1');
      expect(words.single.term, 'spark');
      expect(words.single.categoryId, localMyWordsCategoryId);
    },
  );
}

class _MemoryLocalFavoritesRepository implements LocalFavoritesRepository {
  _MemoryLocalFavoritesRepository(this._wordIds);

  List<String> _wordIds;

  @override
  Future<List<String>> loadWordIds() async => [..._wordIds];

  @override
  Future<void> saveWordIds(List<String> wordIds) async {
    _wordIds = [...wordIds];
  }
}
