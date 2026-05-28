import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;
import 'package:talvori/core/local_database/local_database_factory.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  final now = DateTime(2026, 5, 13, 10);

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<void> seedCategory(
    Database db, {
    required String id,
    required String name,
  }) async {
    await db.insert('categories', {
      'id': id,
      'name': name,
      'description': null,
      'sort_order': 0,
      'is_archived': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> seedWord(
    Database db, {
    required String id,
    required String categoryId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? notes,
    int sortOrder = 0,
    bool isArchived = false,
    String? level,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    final wordRow = {
      'id': id,
      'category_id': categoryId,
      'term': term,
      'translation': translation,
      'example_sentence': exampleSentence,
      'notes': notes,
      'sort_order': sortOrder,
      'is_archived': isArchived ? 1 : 0,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': (updatedAt ?? now).toIso8601String(),
    };
    final columns = await db.rawQuery('PRAGMA table_info(words)');
    if (columns.any((row) => row['name'] == 'level')) {
      wordRow['level'] = level;
    }
    await db.insert('words', wordRow);
  }

  group('WordRepository', () {
    test('upsert_word_creates_word', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = WordRepository(database: db);

      final word = await repository.upsertWord(
        id: 'word-house',
        categoryId: 'category-basics',
        term: 'Haus',
        translation: 'house',
        exampleSentence: 'Das Haus ist klein.',
        notes: 'Noun',
        level: 'A2',
        sortOrder: 1,
        now: now,
      );

      expect(word.id, 'word-house');
      expect(word.categoryId, 'category-basics');
      expect(word.term, 'Haus');
      expect(word.translation, 'house');
      expect(word.translationStatus, TranslationStatus.translated);
      expect(word.exampleSentence, 'Das Haus ist klein.');
      expect(word.notes, 'Noun');
      expect(word.level, 'A2');
      expect(word.sortOrder, 1);
      expect(word.isArchived, isFalse);
      expect(word.createdAt, now);
      expect(word.updatedAt, now);

      final rows = await db.query('words');
      expect(rows, hasLength(1));
      expect(rows.single['translation_status'], 'translated');
      expect(rows.single['level'], 'A2');
    });

    test('upsert_word_without_translation_defaults_to_pending', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = WordRepository(database: db);

      final word = await repository.upsertWord(
        id: 'word-pending',
        categoryId: 'category-basics',
        term: 'umbrella',
        translation: '',
        sourceLanguage: 'en',
        targetLanguage: 'de',
        now: now,
      );

      expect(word.translationStatus, TranslationStatus.pending);
      expect(word.sourceLanguage, 'en');
      expect(word.targetLanguage, 'de');

      final rows = await db.query('words');
      expect(rows.single['translation_status'], 'pending');
      expect(rows.single['source_language'], 'en');
      expect(rows.single['target_language'], 'de');
    });

    test('upsert_word_can_store_failed_translation_status', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = WordRepository(database: db);

      final word = await repository.upsertWord(
        id: 'word-failed',
        categoryId: 'category-basics',
        term: 'umbrella',
        translation: '',
        translationStatus: TranslationStatus.failed,
        translationError: 'network unavailable',
        now: now,
      );

      expect(word.translationStatus, TranslationStatus.failed);
      expect(word.translationError, 'network unavailable');
    });

    test(
      'load_pending_translations_returns_only_pending_active_words',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-basics', name: 'Basics');
        await seedCategory(db, id: 'category-travel', name: 'Travel');
        final repository = WordRepository(database: db);

        await repository.upsertWord(
          id: 'word-pending-b',
          categoryId: 'category-basics',
          term: 'Beta',
          translation: '',
          translationStatus: TranslationStatus.pending,
          sortOrder: 2,
          now: now,
        );
        await repository.upsertWord(
          id: 'word-pending-a',
          categoryId: 'category-basics',
          term: 'Alpha',
          translation: '',
          translationStatus: TranslationStatus.pending,
          sortOrder: 1,
          now: now,
        );
        await repository.upsertWord(
          id: 'word-translated',
          categoryId: 'category-basics',
          term: 'House',
          translation: 'Haus',
          translationStatus: TranslationStatus.translated,
          now: now,
        );
        await repository.upsertWord(
          id: 'word-failed',
          categoryId: 'category-basics',
          term: 'Broken',
          translation: '',
          translationStatus: TranslationStatus.failed,
          translationError: 'network unavailable',
          now: now,
        );
        await repository.upsertWord(
          id: 'word-archived',
          categoryId: 'category-basics',
          term: 'Archived',
          translation: '',
          translationStatus: TranslationStatus.pending,
          isArchived: true,
          now: now,
        );
        await repository.upsertWord(
          id: 'word-travel',
          categoryId: 'category-travel',
          term: 'Airport',
          translation: '',
          translationStatus: TranslationStatus.pending,
          now: now,
        );

        final words = await repository.loadPendingTranslations(
          categoryId: 'category-basics',
        );

        expect(words.map((word) => word.id), [
          'word-pending-a',
          'word-pending-b',
        ]);
        expect(
          words.every(
            (word) =>
                word.categoryId == 'category-basics' &&
                word.translationStatus == TranslationStatus.pending,
          ),
          isTrue,
        );
      },
    );

    test('load_pending_translations_can_include_archived_words', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = WordRepository(database: db);

      await repository.upsertWord(
        id: 'word-active',
        categoryId: 'category-basics',
        term: 'Active',
        translation: '',
        translationStatus: TranslationStatus.pending,
        sortOrder: 1,
        now: now,
      );
      await repository.upsertWord(
        id: 'word-archived',
        categoryId: 'category-basics',
        term: 'Archived',
        translation: '',
        translationStatus: TranslationStatus.pending,
        sortOrder: 0,
        isArchived: true,
        now: now,
      );

      final words = await repository.loadPendingTranslations(
        categoryId: 'category-basics',
        includeArchived: true,
      );

      expect(words.map((word) => word.id), ['word-archived', 'word-active']);
    });

    test('update_translation_sets_translated_and_clears_error', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = WordRepository(database: db);
      final updatedAt = now.add(const Duration(minutes: 15));

      await repository.upsertWord(
        id: 'word-river',
        categoryId: 'category-basics',
        term: 'river',
        translation: '',
        translationStatus: TranslationStatus.failed,
        sourceLanguage: 'en',
        targetLanguage: 'de',
        translationError: 'old error',
        now: now,
      );

      final updated = await repository.updateTranslation(
        id: 'word-river',
        translation: 'Fluss',
        updatedAt: updatedAt,
      );

      expect(updated, isNotNull);
      expect(updated!.translation, 'Fluss');
      expect(updated.translationStatus, TranslationStatus.translated);
      expect(updated.translationError, isNull);
      expect(updated.sourceLanguage, 'en');
      expect(updated.targetLanguage, 'de');
      expect(updated.updatedAt, updatedAt);
    });

    test('mark_translation_failed_sets_failed_status_and_error', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = WordRepository(database: db);
      final failedAt = now.add(const Duration(minutes: 20));

      await repository.upsertWord(
        id: 'word-river',
        categoryId: 'category-basics',
        term: 'river',
        translation: '',
        translationStatus: TranslationStatus.pending,
        now: now,
      );

      final failed = await repository.markTranslationFailed(
        id: 'word-river',
        error: 'offline',
        updatedAt: failedAt,
      );

      expect(failed, isNotNull);
      expect(failed!.translationStatus, TranslationStatus.failed);
      expect(failed.translationError, 'offline');
      expect(failed.translation, '');
      expect(failed.updatedAt, failedAt);
    });

    test('reset_failed_translations_to_pending_clears_error', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedCategory(db, id: 'category-other', name: 'Other');
      final repository = WordRepository(database: db);
      final resetAt = now.add(const Duration(minutes: 25));

      await repository.upsertWord(
        id: 'word-failed',
        categoryId: 'category-basics',
        term: 'river',
        translation: '',
        translationStatus: TranslationStatus.failed,
        translationError: 'offline',
        now: now,
      );
      await repository.upsertWord(
        id: 'word-pending',
        categoryId: 'category-basics',
        term: 'mountain',
        translation: '',
        translationStatus: TranslationStatus.pending,
        now: now,
      );
      await repository.upsertWord(
        id: 'word-other',
        categoryId: 'category-other',
        term: 'airport',
        translation: '',
        translationStatus: TranslationStatus.failed,
        translationError: 'other error',
        now: now,
      );

      final resetCount = await repository.resetFailedTranslationsToPending(
        categoryId: 'category-basics',
        updatedAt: resetAt,
      );

      final retried = await repository.loadWordById('word-failed');
      final pending = await repository.loadWordById('word-pending');
      final other = await repository.loadWordById('word-other');

      expect(resetCount, 1);
      expect(retried?.translationStatus, TranslationStatus.pending);
      expect(retried?.translationError, isNull);
      expect(retried?.updatedAt, resetAt);
      expect(pending?.translationStatus, TranslationStatus.pending);
      expect(other?.translationStatus, TranslationStatus.failed);
      expect(other?.translationError, 'other error');
    });

    test('upsert_word_updates_existing_word', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      final repository = WordRepository(database: db);
      final updatedAt = now.add(const Duration(minutes: 5));

      await repository.upsertWord(
        id: 'word-house',
        categoryId: 'category-basics',
        term: 'Haus',
        translation: 'house',
        exampleSentence: 'Old example',
        notes: 'Old notes',
        sortOrder: 2,
        now: now,
      );
      final updated = await repository.upsertWord(
        id: 'word-house',
        categoryId: 'category-travel',
        term: 'Hotel',
        translation: 'hotel',
        exampleSentence: 'Das Hotel ist nah.',
        notes: 'Updated notes',
        sortOrder: 7,
        isArchived: true,
        now: updatedAt,
      );

      expect(updated.id, 'word-house');
      expect(updated.categoryId, 'category-travel');
      expect(updated.term, 'Hotel');
      expect(updated.translation, 'hotel');
      expect(updated.exampleSentence, 'Das Hotel ist nah.');
      expect(updated.notes, 'Updated notes');
      expect(updated.sortOrder, 7);
      expect(updated.isArchived, isTrue);
      expect(updated.createdAt, now);
      expect(updated.updatedAt, updatedAt);

      final rows = await db.query('words');
      expect(rows, hasLength(1));
    });

    test('load_word_by_id_returns_matching_word', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedWord(
        db,
        id: 'word-house',
        categoryId: 'category-basics',
        term: 'Haus',
        translation: 'house',
      );
      await seedWord(
        db,
        id: 'word-car',
        categoryId: 'category-basics',
        term: 'Auto',
        translation: 'car',
      );
      final repository = WordRepository(database: db);

      final found = await repository.loadWordById('word-car');
      final missing = await repository.loadWordById('missing');

      expect(found, isNotNull);
      expect(found!.id, 'word-car');
      expect(found.term, 'Auto');
      expect(found.translation, 'car');
      expect(missing, isNull);
    });

    test('update_word_changes_term_translation_and_updated_at', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedWord(
        db,
        id: 'word-house',
        categoryId: 'category-basics',
        term: 'Haus',
        translation: 'house',
        exampleSentence: 'Das Haus ist klein.',
        notes: 'Noun',
        createdAt: now,
        updatedAt: now,
      );
      final repository = WordRepository(database: db);
      final updatedAt = now.add(const Duration(minutes: 12));

      final updated = await repository.updateWord(
        id: 'word-house',
        term: 'Zuhause',
        translation: 'home',
        updatedAt: updatedAt,
      );

      expect(updated, isNotNull);
      expect(updated!.term, 'Zuhause');
      expect(updated.translation, 'home');
      expect(updated.translationStatus, TranslationStatus.translated);
      expect(updated.categoryId, 'category-basics');
      expect(updated.exampleSentence, 'Das Haus ist klein.');
      expect(updated.notes, 'Noun');
      expect(updated.createdAt, now);
      expect(updated.updatedAt, updatedAt);
    });

    test('update_word_returns_null_for_missing_word', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = WordRepository(database: db);

      final updated = await repository.updateWord(
        id: 'missing',
        term: 'Missing',
        translation: 'missing',
        updatedAt: now,
      );

      expect(updated, isNull);
    });

    test('migration_defaults_existing_words_by_translation_presence', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_word_repo_migration_test_',
      );
      addTearDown(() async {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });
      final path = p.join(tempDir.path, 'local.db');
      var legacyDb = await databaseFactoryFfi.openDatabase(path);
      await legacyDb.execute('''
CREATE TABLE categories (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)
''');
      await legacyDb.execute('''
CREATE TABLE words (
  id TEXT PRIMARY KEY,
  category_id TEXT NOT NULL,
  term TEXT NOT NULL,
  translation TEXT NOT NULL,
  example_sentence TEXT,
  notes TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_archived INTEGER NOT NULL DEFAULT 0,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (category_id) REFERENCES categories (id)
)
''');
      await seedCategory(legacyDb, id: 'category-basics', name: 'Basics');
      await seedWord(
        legacyDb,
        id: 'word-translated',
        categoryId: 'category-basics',
        term: 'House',
        translation: 'Haus',
      );
      await seedWord(
        legacyDb,
        id: 'word-pending',
        categoryId: 'category-basics',
        term: 'Umbrella',
        translation: '',
      );
      await legacyDb.setVersion(1);
      await legacyDb.close();

      final migratedDb = await const LocalDatabaseFactory().openAtPath(path);
      addTearDown(migratedDb.close);
      final repository = WordRepository(database: migratedDb);

      final translated = await repository.loadWordById('word-translated');
      final pending = await repository.loadWordById('word-pending');

      expect(translated?.translationStatus, TranslationStatus.translated);
      expect(pending?.translationStatus, TranslationStatus.pending);
    });

    test('load_words_for_category_returns_only_that_category_sorted', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'word-z',
        categoryId: 'category-basics',
        term: 'Zulu',
        translation: 'zulu',
        sortOrder: 2,
      );
      await seedWord(
        db,
        id: 'word-b',
        categoryId: 'category-basics',
        term: 'Beta',
        translation: 'beta',
        sortOrder: 1,
      );
      await seedWord(
        db,
        id: 'word-a',
        categoryId: 'category-basics',
        term: 'Alpha',
        translation: 'alpha',
        sortOrder: 1,
      );
      await seedWord(
        db,
        id: 'word-other-category',
        categoryId: 'category-travel',
        term: 'Airport',
        translation: 'airport',
        sortOrder: 0,
      );
      final repository = WordRepository(database: db);

      final words = await repository.loadWordsForCategory(
        categoryId: 'category-basics',
      );

      expect(words.map((word) => word.id), ['word-a', 'word-b', 'word-z']);
      expect(
        words.every((word) => word.categoryId == 'category-basics'),
        isTrue,
      );
    });

    test('load_words_for_category_excludes_archived_by_default', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedWord(
        db,
        id: 'word-active',
        categoryId: 'category-basics',
        term: 'Active',
        translation: 'active',
      );
      await seedWord(
        db,
        id: 'word-archived',
        categoryId: 'category-basics',
        term: 'Archived',
        translation: 'archived',
        isArchived: true,
      );
      final repository = WordRepository(database: db);

      final words = await repository.loadWordsForCategory(
        categoryId: 'category-basics',
      );

      expect(words.map((word) => word.id), ['word-active']);
      expect(words.every((word) => !word.isArchived), isTrue);
    });

    test('load_words_for_category_can_include_archived', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedWord(
        db,
        id: 'word-active',
        categoryId: 'category-basics',
        term: 'Active',
        translation: 'active',
        sortOrder: 1,
      );
      await seedWord(
        db,
        id: 'word-archived',
        categoryId: 'category-basics',
        term: 'Archived',
        translation: 'archived',
        sortOrder: 0,
        isArchived: true,
      );
      final repository = WordRepository(database: db);

      final words = await repository.loadWordsForCategory(
        categoryId: 'category-basics',
        includeArchived: true,
      );

      expect(words.map((word) => word.id), ['word-archived', 'word-active']);
      expect(words.where((word) => word.isArchived), hasLength(1));
    });

    test('upsert_word_adds_membership_for_thematic_word_world', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      final repository = WordRepository(database: db);

      await repository.upsertWord(
        id: 'word-ticket',
        categoryId: 'category-travel',
        term: 'ticket',
        translation: 'Fahrkarte',
        now: now,
      );

      final memberships = await repository.loadMembershipsForWord(
        'word-ticket',
      );
      expect(memberships, hasLength(1));
      expect(memberships.single.categoryId, 'category-travel');
    });

    test(
      'upsert_word_does_not_add_membership_for_packages_or_levels',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-basics', name: 'Basics');
        await seedCategory(db, id: 'category-a1', name: 'A1');
        await seedCategory(db, id: 'category-top', name: 'Top 500 Words');
        final repository = WordRepository(database: db);

        await repository.upsertWord(
          id: 'word-basics',
          categoryId: 'category-basics',
          term: 'hello',
          translation: 'hallo',
          now: now,
        );
        await repository.upsertWord(
          id: 'word-a1',
          categoryId: 'category-a1',
          term: 'behind',
          translation: 'hinter',
          now: now,
        );
        await repository.upsertWord(
          id: 'word-top',
          categoryId: 'category-top',
          term: 'move',
          translation: 'bewegen',
          now: now,
        );

        expect(await repository.loadMembershipsForWord('word-basics'), isEmpty);
        expect(await repository.loadMembershipsForWord('word-a1'), isEmpty);
        expect(await repository.loadMembershipsForWord('word-top'), isEmpty);
      },
    );

    test(
      'load_words_for_word_world_reads_memberships_and_excludes_archived',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-travel', name: 'Travel');
        await seedCategory(db, id: 'category-basics', name: 'Basics');
        await seedWord(
          db,
          id: 'word-ticket',
          categoryId: 'category-basics',
          term: 'ticket',
          translation: 'Fahrkarte',
          sortOrder: 2,
        );
        await seedWord(
          db,
          id: 'word-hotel',
          categoryId: 'category-basics',
          term: 'hotel',
          translation: 'Hotel',
          sortOrder: 1,
        );
        await seedWord(
          db,
          id: 'word-archived',
          categoryId: 'category-basics',
          term: 'archived',
          translation: 'archiviert',
          isArchived: true,
        );
        final repository = WordRepository(database: db);
        await repository.addWordWorldMembership(
          wordId: 'word-ticket',
          categoryId: 'category-travel',
          createdAt: now,
        );
        await repository.addWordWorldMembership(
          wordId: 'word-hotel',
          categoryId: 'category-travel',
          createdAt: now,
        );
        await repository.addWordWorldMembership(
          wordId: 'word-archived',
          categoryId: 'category-travel',
          createdAt: now,
        );

        final words = await repository.loadWordsForWordWorld(
          categoryId: 'category-travel',
        );

        expect(words.map((word) => word.id), ['word-hotel', 'word-ticket']);
      },
    );

    test(
      'word_world_ids_and_count_read_memberships_and_exclude_archived',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-travel', name: 'Travel');
        await seedCategory(db, id: 'category-basics', name: 'Basics');
        await seedWord(
          db,
          id: 'word-ticket',
          categoryId: 'category-basics',
          term: 'ticket',
          translation: 'Fahrkarte',
          sortOrder: 2,
        );
        await seedWord(
          db,
          id: 'word-hotel',
          categoryId: 'category-basics',
          term: 'hotel',
          translation: 'Hotel',
          sortOrder: 1,
        );
        await seedWord(
          db,
          id: 'word-archived',
          categoryId: 'category-basics',
          term: 'archived',
          translation: 'archiviert',
          isArchived: true,
        );
        final repository = WordRepository(database: db);
        await repository.addWordWorldMembership(
          wordId: 'word-ticket',
          categoryId: 'category-travel',
          createdAt: now,
        );
        await repository.addWordWorldMembership(
          wordId: 'word-hotel',
          categoryId: 'category-travel',
          createdAt: now,
        );
        await repository.addWordWorldMembership(
          wordId: 'word-archived',
          categoryId: 'category-travel',
          createdAt: now,
        );

        final ids = await repository.loadWordIdsForWordWorld(
          categoryId: 'category-travel',
        );
        final count = await repository.countWordsForWordWorld(
          categoryId: 'category-travel',
        );

        expect(ids, ['word-hotel', 'word-ticket']);
        expect(count, 2);
      },
    );

    test('load_words_for_word_world_falls_back_to_category_id', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'word-ticket',
        categoryId: 'category-travel',
        term: 'ticket',
        translation: 'Fahrkarte',
      );
      final repository = WordRepository(database: db);

      final words = await repository.loadWordsForWordWorld(
        categoryId: 'category-travel',
      );

      expect(words.map((word) => word.id), ['word-ticket']);
    });

    test('word_world_ids_and_count_fall_back_to_category_id', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'word-ticket',
        categoryId: 'category-travel',
        term: 'ticket',
        translation: 'Fahrkarte',
      );
      final repository = WordRepository(database: db);

      final ids = await repository.loadWordIdsForWordWorld(
        categoryId: 'category-travel',
      );
      final count = await repository.countWordsForWordWorld(
        categoryId: 'category-travel',
      );

      expect(ids, ['word-ticket']);
      expect(count, 1);
    });

    test('add_word_world_membership_ignores_duplicates', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'word-ticket',
        categoryId: 'category-travel',
        term: 'ticket',
        translation: 'Fahrkarte',
      );
      final repository = WordRepository(database: db);

      await repository.addWordWorldMembership(
        wordId: 'word-ticket',
        categoryId: 'category-travel',
        createdAt: now,
      );
      await repository.addWordWorldMembership(
        wordId: 'word-ticket',
        categoryId: 'category-travel',
        createdAt: now,
      );

      final memberships = await db.query('word_world_memberships');
      expect(memberships, hasLength(1));
    });

    test(
      'disabled_word_world_membership_stays_visible_but_not_practiceable',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-travel', name: 'Travel');
        await seedWord(
          db,
          id: 'word-ticket',
          categoryId: 'category-travel',
          term: 'ticket',
          translation: 'Fahrkarte',
        );
        final repository = WordRepository(database: db);
        await repository.addWordWorldMembership(
          wordId: 'word-ticket',
          categoryId: 'category-travel',
          createdAt: now,
        );

        await repository.setWordWorldMembershipDisabled(
          wordId: 'word-ticket',
          categoryId: 'category-travel',
          disabled: true,
        );

        final visible = await repository.loadWordsForWordWorld(
          categoryId: 'category-travel',
          includeDisabled: true,
        );
        final practiceable = await repository.loadWordsForWordWorld(
          categoryId: 'category-travel',
        );
        final ids = await repository.loadWordIdsForWordWorld(
          categoryId: 'category-travel',
        );

        expect(visible, hasLength(1));
        expect(visible.single.isDisabledForCategory, isTrue);
        expect(practiceable, isEmpty);
        expect(ids, isEmpty);
      },
    );

    test('add_or_link_word_to_word_world_reuses_existing_word', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      await seedCategory(db, id: 'category-work', name: 'Work & Careers');
      await seedWord(
        db,
        id: 'word-ticket',
        categoryId: 'category-travel',
        term: 'Ticket',
        translation: 'Fahrkarte',
      );
      final repository = WordRepository(database: db);

      final word = await repository.addOrLinkWordToWordWorld(
        categoryId: 'category-work',
        term: ' ticket ',
        translation: 'Ticket',
        now: now,
      );

      expect(word.id, 'word-ticket');
      expect(await db.query('words'), hasLength(1));
      expect(
        await repository.wordWorldMembershipExists(
          wordId: 'word-ticket',
          categoryId: 'category-work',
        ),
        isTrue,
      );
    });

    test('set_word_level_updates_only_word_level', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'word-ticket',
        categoryId: 'category-travel',
        term: 'ticket',
        translation: 'Fahrkarte',
      );
      final repository = WordRepository(database: db);
      final updatedAt = now.add(const Duration(minutes: 30));

      final updated = await repository.setWordLevel(
        wordId: 'word-ticket',
        level: 'A2',
        updatedAt: updatedAt,
      );

      expect(updated?.level, 'A2');
      expect(updated?.categoryId, 'category-travel');
      expect(updated?.updatedAt, updatedAt);
    });

    test('archive_word_sets_is_archived_and_updated_at', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedWord(
        db,
        id: 'word-house',
        categoryId: 'category-basics',
        term: 'Haus',
        translation: 'house',
      );
      final repository = WordRepository(database: db);
      final archivedAt = now.add(const Duration(minutes: 8));

      await repository.archiveWord(
        id: 'word-house',
        archived: true,
        updatedAt: archivedAt,
      );

      final word = await repository.loadWordById('word-house');
      expect(word!.isArchived, isTrue);
      expect(word.updatedAt, archivedAt);

      final rows = await db.query('words');
      expect(rows.single['is_archived'], 1);
      expect(rows.single['updated_at'], archivedAt.toIso8601String());
    });

    test(
      'load_word_ids_for_category_returns_ids_for_progress_initialization',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-basics', name: 'Basics');
        await seedCategory(db, id: 'category-travel', name: 'Travel');
        await seedWord(
          db,
          id: 'word-b',
          categoryId: 'category-basics',
          term: 'Beta',
          translation: 'beta',
          sortOrder: 1,
        );
        await seedWord(
          db,
          id: 'word-a',
          categoryId: 'category-basics',
          term: 'Alpha',
          translation: 'alpha',
          sortOrder: 1,
        );
        await seedWord(
          db,
          id: 'word-archived',
          categoryId: 'category-basics',
          term: 'Archived',
          translation: 'archived',
          sortOrder: 0,
          isArchived: true,
        );
        await seedWord(
          db,
          id: 'word-other-category',
          categoryId: 'category-travel',
          term: 'Airport',
          translation: 'airport',
          sortOrder: 0,
        );
        final repository = WordRepository(database: db);

        final ids = await repository.loadWordIdsForCategory(
          categoryId: 'category-basics',
        );

        expect(ids, ['word-a', 'word-b']);
      },
    );
  });
}
