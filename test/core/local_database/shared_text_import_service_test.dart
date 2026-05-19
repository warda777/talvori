import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_progress_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';

void main() {
  sqfliteFfiInit();

  group('SharedTextImportService', () {
    late Database db;
    late CategoryRepository categoryRepository;
    late WordRepository wordRepository;
    late WordProgressRepository wordProgressRepository;
    late SharedTextImportService service;
    final now = DateTime(2026, 5, 18, 10);

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await LocalDatabaseSchema.createV1(db);
      categoryRepository = CategoryRepository(database: db);
      wordRepository = WordRepository(database: db);
      wordProgressRepository = WordProgressRepository(database: db);
      service = SharedTextImportService(
        categoryRepository: categoryRepository,
        wordRepository: wordRepository,
        wordProgressRepository: wordProgressRepository,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('rejects_empty_input', () async {
      final result = await service.importRawText(rawText: '   ', now: now);

      expect(result.status, SharedTextImportStatus.empty);
      expect(
        await wordRepository.loadWordsForCategory(
          categoryId: localMyWordsCategoryId,
        ),
        isEmpty,
      );
    });

    test('imports_single_word_into_local_my_words_category', () async {
      final result = await service.importRawText(
        rawText: '  Umbrella  ',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.imported);
      expect(result.word?.term, 'umbrella');
      expect(result.word?.translation, '');
      expect(result.word?.categoryId, localMyWordsCategoryId);

      final category = await categoryRepository.loadCategoryById(
        localMyWordsCategoryId,
      );
      expect(category?.name, localMyWordsCategoryLabel);

      final words = await wordRepository.loadWordsForCategory(
        categoryId: localMyWordsCategoryId,
      );
      expect(words, hasLength(1));
      expect(words.single.term, 'umbrella');
    });

    test('imports_single_word_from_android_share_text_with_url', () async {
      final result = await service.importRawText(
        rawText: 'hello\nhttps://example.com/article',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.imported);
      expect(result.word?.term, 'hello');
    });

    test(
      'imports_single_word_from_android_share_text_with_title_and_url',
      () async {
        final result = await service.importRawText(
          rawText: 'hello\nExample Page Title\nhttps://example.com/article',
          now: now,
        );

        expect(result.status, SharedTextImportStatus.imported);
        expect(result.word?.term, 'hello');
      },
    );

    test('imports_single_word_before_url_on_same_line', () async {
      final result = await service.importRawText(
        rawText: 'hello https://example.com/article',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.imported);
      expect(result.word?.term, 'hello');
    });

    test('imports_quoted_or_punctuated_single_word', () async {
      final quoted = await service.importRawText(rawText: '"hello"', now: now);
      final punctuated = await service.importRawText(
        rawText: 'river.',
        now: now,
      );

      expect(quoted.status, SharedTextImportStatus.imported);
      expect(quoted.word?.term, 'hello');
      expect(punctuated.status, SharedTextImportStatus.imported);
      expect(punctuated.word?.term, 'river');
    });

    test('rejects_url_without_word_candidate', () async {
      final result = await service.importRawText(
        rawText: 'https://example.com/article',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.empty);
      expect(
        await wordRepository.countWordsForCategory(
          categoryId: localMyWordsCategoryId,
        ),
        0,
      );
    });

    test('rejects_ambiguous_same_line_share_text', () async {
      final result = await service.importRawText(
        rawText: 'hello ExampleTitle https://example.com',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.invalid);
      expect(
        await wordRepository.countWordsForCategory(
          categoryId: localMyWordsCategoryId,
        ),
        0,
      );
    });

    test('initializes_progress_for_all_srs_modes', () async {
      final result = await service.importRawText(rawText: 'river', now: now);
      final word = result.word!;

      for (final mode in LearningMode.values) {
        final progress = await wordProgressRepository.loadProgress(
          wordId: word.id,
          categoryId: localMyWordsCategoryId,
          mode: mode,
        );
        expect(progress, isNotNull);
        expect(progress?.stage, SrsStage.s0);
        expect(progress?.passCount, 0);
        expect(progress?.wrongCount, 0);
      }
    });

    test('detects_case_insensitive_duplicate_without_second_word', () async {
      final first = await service.importRawText(rawText: 'House', now: now);
      final second = await service.importRawText(
        rawText: 'house',
        now: now.add(const Duration(minutes: 1)),
      );

      expect(first.status, SharedTextImportStatus.imported);
      expect(second.status, SharedTextImportStatus.duplicate);
      expect(second.word?.id, first.word?.id);

      final words = await wordRepository.loadWordsForCategory(
        categoryId: localMyWordsCategoryId,
      );
      expect(words, hasLength(1));
      expect(words.single.term, 'house');
    });

    test('detects_duplicate_after_extracting_word_from_share_text', () async {
      final first = await service.importRawText(rawText: 'Hello', now: now);
      final second = await service.importRawText(
        rawText: 'hello\nhttps://example.com',
        now: now.add(const Duration(minutes: 1)),
      );

      expect(first.status, SharedTextImportStatus.imported);
      expect(second.status, SharedTextImportStatus.duplicate);

      final words = await wordRepository.loadWordsForCategory(
        categoryId: localMyWordsCategoryId,
      );
      expect(words, hasLength(1));
      expect(words.single.term, 'hello');
    });

    test('rejects_multi_word_text_for_phase_one', () async {
      final result = await service.importRawText(
        rawText: 'hello world',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.invalid);
      expect(
        await wordRepository.countWordsForCategory(
          categoryId: localMyWordsCategoryId,
        ),
        0,
      );
    });

    test('rejects_sentence_text_for_phase_one', () async {
      final result = await service.importRawText(
        rawText: 'This is a full sentence.',
        now: now,
      );

      expect(result.status, SharedTextImportStatus.invalid);
      expect(
        await wordRepository.countWordsForCategory(
          categoryId: localMyWordsCategoryId,
        ),
        0,
      );
    });

    test(
      'imported_word_is_available_through_word_repository_queries',
      () async {
        await service.importRawText(rawText: 'mountain', now: now);

        final words = await wordRepository.loadWordsForCategory(
          categoryId: localMyWordsCategoryId,
        );
        final count = await wordRepository.countWordsForCategory(
          categoryId: localMyWordsCategoryId,
        );

        expect(count, 1);
        expect(words.single.term, 'mountain');
        expect(words.single.notes, 'Importiert. Übersetzung ausstehend.');
      },
    );
  });
}
