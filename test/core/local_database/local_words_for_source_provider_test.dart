import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/local_database/providers/shared_text_import_service_provider.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/features/favorites/application/local_favorites_provider.dart';
import 'package:talvori/features/favorites/data/local_favorites_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<ProviderContainer> createContainer({
    required String prefix,
    List<String> favoriteWordIds = const <String>[],
  }) async {
    final tempDir = await Directory.systemTemp.createTemp(prefix);
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
          _MemoryLocalFavoritesRepository(favoriteWordIds),
        ),
      ],
    );

    return container;
  }

  Future<String> importWord(
    ProviderContainer container,
    String term, {
    DateTime? now,
  }) async {
    final importService = await container.read(
      sharedTextImportServiceProvider.future,
    );
    final result = await importService.importRawText(
      rawText: term,
      now: now ?? DateTime(2026, 5, 21, 10),
    );
    final word = result.word;
    expect(word, isNotNull);
    return word!.id;
  }

  test('local_sources_load_distinct_word_sets', () async {
    final container = await createContainer(
      prefix: 'talvori_local_words_for_source_distinct_',
      favoriteWordIds: const ['local-my-words-river'],
    );

    await importWord(container, 'river');
    await importWord(container, 'harbor');

    final allWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.allWords).future,
    );
    final myWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.myWords).future,
    );
    final favorites = await container.read(
      localWordsForSourceProvider(LocalLearningSource.favorites).future,
    );

    expect(allWords.map((word) => word.term), contains('hello'));
    expect(allWords.map((word) => word.term), containsAll(['river', 'harbor']));
    expect(myWords.map((word) => word.term), containsAll(['river', 'harbor']));
    expect(myWords.map((word) => word.term), isNot(contains('hello')));
    expect(favorites.map((word) => word.term), ['river']);
  });

  test('known_words_reads_mastered_local_progress_without_writing', () async {
    final container = await createContainer(
      prefix: 'talvori_local_words_for_source_known_',
    );
    final knownWordId = await importWord(container, 'lantern');
    await importWord(container, 'meadow');

    final bootstrap = await container.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final progress = await repositories.wordProgressRepository
        .ensureProgressForWord(
          wordId: knownWordId,
          categoryId: localMyWordsCategoryId,
          mode: LearningMode.time,
          now: DateTime(2026, 5, 21, 10, 30),
        );
    await repositories.wordProgressRepository.saveProgress(
      updatedProgress: progress.copyWith(stage: SrsStage.s5),
      updatedAt: DateTime(2026, 5, 21, 11),
    );

    final knownWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.knownWords).future,
    );

    expect(knownWords.map((word) => word.term), ['lantern']);
  });

  test('my_mix_uses_a_distinct_local_mix_instead_of_my_words_clone', () async {
    final container = await createContainer(
      prefix: 'talvori_local_words_for_source_mix_',
      favoriteWordIds: const ['local-my-words-word-3'],
    );

    for (var index = 0; index < 7; index += 1) {
      await importWord(
        container,
        'word-$index',
        now: DateTime(2026, 5, 21, 8, index),
      );
    }

    final myWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.myWords).future,
    );
    final myMix = await container.read(
      localWordsForSourceProvider(LocalLearningSource.myMix).future,
    );

    expect(myWords.map((word) => word.term), hasLength(7));
    expect(
      myMix.map((word) => word.term).toList(growable: false),
      isNot(myWords.map((word) => word.term).toList(growable: false)),
    );
    expect(myMix.map((word) => word.term), contains('word-3'));
  });

  test('source_ids_are_honored_by_category_provider_delegate', () async {
    final container = await createContainer(
      prefix: 'talvori_local_words_for_source_category_delegate_',
      favoriteWordIds: const ['local-my-words-signal'],
    );

    await importWord(container, 'signal');
    await importWord(container, 'forest');

    final words = await container.read(
      localWordsForCategoryProvider(LocalLearningSource.favorites.id).future,
    );

    expect(words.map((word) => word.term), ['signal']);
  });
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
