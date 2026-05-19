import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/services/pending_translation_processor.dart';
import 'package:talvori/core/local_database/translation/fake_translation_client.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('PendingTranslationProcessor', () {
    late Database db;
    late WordRepository wordRepository;
    late PendingTranslationProcessor processor;
    final now = DateTime(2026, 5, 19, 10);
    final processedAt = DateTime(2026, 5, 19, 11);

    setUp(() async {
      db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      await LocalDatabaseSchema.createV1(db);
      await db.insert('categories', {
        'id': 'local-category-my-words',
        'name': 'Meine Wörter',
        'description': null,
        'sort_order': 0,
        'is_archived': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      await db.insert('categories', {
        'id': 'category-other',
        'name': 'Other',
        'description': null,
        'sort_order': 1,
        'is_archived': 0,
        'created_at': now.toIso8601String(),
        'updated_at': now.toIso8601String(),
      });
      wordRepository = WordRepository(database: db);
      processor = PendingTranslationProcessor(
        wordRepository: wordRepository,
        translationClient: FakeTranslationClient(
          translations: {'river': 'fluss', 'mountain': 'berg'},
          failingTerms: {'broken'},
        ),
        now: () => processedAt,
      );
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> seedWord({
      required String id,
      required String term,
      required String categoryId,
      required TranslationStatus status,
      String translation = '',
      String? error,
      bool archived = false,
    }) async {
      await wordRepository.upsertWord(
        id: id,
        categoryId: categoryId,
        term: term,
        translation: translation,
        translationStatus: status,
        sourceLanguage: 'en',
        targetLanguage: 'de',
        translationError: error,
        isArchived: archived,
        now: now,
      );
    }

    test('translates_pending_word_and_clears_error', () async {
      await seedWord(
        id: 'word-river',
        term: 'river',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.pending,
        error: 'old error',
      );

      final result = await processor.processPendingTranslations();

      final word = await wordRepository.loadWordById('word-river');
      expect(result.processed, 1);
      expect(result.translated, 1);
      expect(result.failed, 0);
      expect(word?.translation, 'fluss');
      expect(word?.translationStatus, TranslationStatus.translated);
      expect(word?.translationError, isNull);
      expect(word?.sourceLanguage, 'en');
      expect(word?.targetLanguage, 'de');
      expect(word?.updatedAt, processedAt);
    });

    test('marks_word_failed_when_client_throws', () async {
      await seedWord(
        id: 'word-broken',
        term: 'broken',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.pending,
      );

      final result = await processor.processPendingTranslations();

      final word = await wordRepository.loadWordById('word-broken');
      expect(result.processed, 1);
      expect(result.translated, 0);
      expect(result.failed, 1);
      expect(word?.translationStatus, TranslationStatus.failed);
      expect(word?.translationError, contains('Fake translation failed'));
      expect(word?.translation, '');
      expect(word?.updatedAt, processedAt);
    });

    test('does_not_process_already_translated_or_failed_words', () async {
      await seedWord(
        id: 'word-translated',
        term: 'hello',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.translated,
        translation: 'hallo',
      );
      await seedWord(
        id: 'word-failed',
        term: 'broken',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.failed,
        error: 'network unavailable',
      );

      final result = await processor.processPendingTranslations();

      expect(result.processed, 0);
      expect(result.translated, 0);
      expect(result.failed, 0);
      expect(
        (await wordRepository.loadWordById('word-translated'))?.translation,
        'hallo',
      );
      expect(
        (await wordRepository.loadWordById('word-failed'))?.translationError,
        'network unavailable',
      );
    });

    test('manual_retry_resets_failed_words_and_processes_them', () async {
      await seedWord(
        id: 'word-river',
        term: 'river',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.failed,
        error: 'offline',
      );
      await seedWord(
        id: 'word-other',
        term: 'mountain',
        categoryId: 'category-other',
        status: TranslationStatus.failed,
        error: 'other offline',
      );

      final result = await processor.processPendingAndRetryFailedTranslations(
        categoryId: 'local-category-my-words',
      );

      final retried = await wordRepository.loadWordById('word-river');
      final other = await wordRepository.loadWordById('word-other');
      expect(result.resetFailed, 1);
      expect(result.processed, 1);
      expect(result.translated, 1);
      expect(result.failed, 0);
      expect(retried?.translation, 'fluss');
      expect(retried?.translationStatus, TranslationStatus.translated);
      expect(retried?.translationError, isNull);
      expect(other?.translationStatus, TranslationStatus.failed);
      expect(other?.translationError, 'other offline');
    });

    test('manual_retry_keeps_going_when_retried_word_fails_again', () async {
      await seedWord(
        id: 'word-broken',
        term: 'broken',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.failed,
        error: 'old error',
      );

      final result = await processor.processPendingAndRetryFailedTranslations(
        categoryId: 'local-category-my-words',
      );

      final word = await wordRepository.loadWordById('word-broken');
      expect(result.resetFailed, 1);
      expect(result.processed, 1);
      expect(result.translated, 0);
      expect(result.failed, 1);
      expect(word?.translationStatus, TranslationStatus.failed);
      expect(word?.translationError, contains('Fake translation failed'));
    });

    test(
      'processes_multiple_pending_words_and_keeps_going_after_failure',
      () async {
        await seedWord(
          id: 'word-river',
          term: 'river',
          categoryId: 'local-category-my-words',
          status: TranslationStatus.pending,
        );
        await seedWord(
          id: 'word-broken',
          term: 'broken',
          categoryId: 'local-category-my-words',
          status: TranslationStatus.pending,
        );
        await seedWord(
          id: 'word-mountain',
          term: 'mountain',
          categoryId: 'local-category-my-words',
          status: TranslationStatus.pending,
        );

        final result = await processor.processPendingTranslations();

        expect(result.processed, 3);
        expect(result.translated, 2);
        expect(result.failed, 1);
        expect(
          (await wordRepository.loadWordById('word-river'))?.translation,
          'fluss',
        );
        expect(
          (await wordRepository.loadWordById('word-mountain'))?.translation,
          'berg',
        );
        expect(
          (await wordRepository.loadWordById('word-broken'))?.translationStatus,
          TranslationStatus.failed,
        );
      },
    );

    test('can_limit_processing_to_one_category', () async {
      await seedWord(
        id: 'word-river',
        term: 'river',
        categoryId: 'local-category-my-words',
        status: TranslationStatus.pending,
      );
      await seedWord(
        id: 'word-mountain',
        term: 'mountain',
        categoryId: 'category-other',
        status: TranslationStatus.pending,
      );

      final result = await processor.processPendingTranslations(
        categoryId: 'local-category-my-words',
      );

      expect(result.processed, 1);
      expect(
        (await wordRepository.loadWordById('word-river'))?.translationStatus,
        TranslationStatus.translated,
      );
      expect(
        (await wordRepository.loadWordById('word-mountain'))?.translationStatus,
        TranslationStatus.pending,
      );
    });
  });
}
