import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/repositories/word_source_repository.dart';

void main() {
  sqfliteFfiInit();

  group('WordSourceRepository', () {
    late Database db;
    late WordSourceRepository repository;
    final now = DateTime(2026, 5, 22, 10);

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await LocalDatabaseSchema.createV1(db);
      await CategoryRepository(
        database: db,
      ).upsertCategory(id: 'category-1', name: 'Meine Wörter', now: now);
      await WordRepository(database: db).upsertWord(
        id: 'word-1',
        categoryId: 'category-1',
        term: 'emergency',
        translation: 'Notfall',
        now: now,
      );
      repository = WordSourceRepository(database: db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saves_and_reads_word_source_locally', () async {
      final source = await repository.saveSource(
        wordId: 'word-1',
        sourceUrl: 'https://example.com/article',
        sourceTitle: 'Example Article',
        sourceApp: 'Safari',
        sharedTextPreview: 'emergency',
        createdAt: now,
      );

      expect(source?.wordId, 'word-1');
      expect(source?.sourceUrl, 'https://example.com/article');

      final sources = await repository.loadSourcesForWord('word-1');
      expect(sources, hasLength(1));
      expect(sources.single.sourceTitle, 'Example Article');
      expect(sources.single.sourceApp, 'Safari');
      expect(sources.single.sharedTextPreview, 'emergency');
    });

    test('does_not_duplicate_same_word_and_url', () async {
      final first = await repository.saveSource(
        wordId: 'word-1',
        sourceUrl: 'https://example.com/article?utm_source=news',
        createdAt: now,
      );
      final second = await repository.saveSource(
        wordId: 'word-1',
        sourceUrl: 'https://example.com/article?utm_source=news',
        createdAt: now.add(const Duration(minutes: 1)),
      );

      expect(second?.id, first?.id);
      expect(await repository.loadSourcesForWord('word-1'), hasLength(1));
    });

    test('allows_multiple_sources_for_same_word', () async {
      await repository.saveSource(
        wordId: 'word-1',
        sourceUrl: 'https://example.com/one',
        createdAt: now,
      );
      await repository.saveSource(
        wordId: 'word-1',
        sourceUrl: 'https://example.com/two',
        createdAt: now.add(const Duration(minutes: 1)),
      );

      final sources = await repository.loadSourcesForWord('word-1');
      expect(sources.map((source) => source.sourceUrl), [
        'https://example.com/two',
        'https://example.com/one',
      ]);
    });

    test('ignores_non_web_urls', () async {
      final source = await repository.saveSource(
        wordId: 'word-1',
        sourceUrl: 'talvori://share',
        createdAt: now,
      );

      expect(source, isNull);
      expect(await repository.loadSourcesForWord('word-1'), isEmpty);
    });
  });
}
