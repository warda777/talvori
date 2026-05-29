import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_app_database_path.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/providers/local_bootstrap_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/words/application/category_vocabulary/category_vocabulary_controller.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  Future<ProviderContainer> createContainer(String prefix) async {
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
      ],
    );
    return container;
  }

  test('markKnown and restoreKnown update membership known state', () async {
    final container = await createContainer(
      'talvori_category_vocabulary_known_',
    );
    final bootstrap = await container.read(localBootstrapProvider.future);
    final repositories = bootstrap.repositoryFactory;
    final now = DateTime(2026, 5, 29, 10);
    await repositories.categoryRepository.upsertCategory(
      id: 'category-travel',
      name: 'Travel',
      now: now,
    );
    final word = await repositories.wordRepository.upsertWord(
      id: 'word-ticket',
      categoryId: 'seed-category-basics',
      term: 'ticket',
      translation: 'Fahrkarte',
      now: now,
    );
    await repositories.wordRepository.addWordWorldMembership(
      wordId: word.id,
      categoryId: 'category-travel',
      createdAt: now,
    );

    var knownWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.knownWords).future,
    );
    expect(knownWords, isEmpty);

    await container
        .read(categoryVocabularyControllerProvider.notifier)
        .markKnown(categoryId: 'category-travel', word: word);

    knownWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.knownWords).future,
    );
    expect(knownWords.map((item) => item.id), ['word-ticket']);

    final categoryWords = await container.read(
      localWordsForCategoryProvider('category-travel').future,
    );
    expect(categoryWords.map((item) => item.id), ['word-ticket']);
    expect(categoryWords.single.isKnownForCategory, isTrue);

    await container
        .read(categoryVocabularyControllerProvider.notifier)
        .restoreKnown(categoryId: 'category-travel', word: word);

    knownWords = await container.read(
      localWordsForSourceProvider(LocalLearningSource.knownWords).future,
    );
    expect(knownWords, isEmpty);

    final restoredCategoryWords = await container.read(
      localWordsForCategoryProvider('category-travel').future,
    );
    expect(restoredCategoryWords.single.isKnownForCategory, isFalse);
  });
}
