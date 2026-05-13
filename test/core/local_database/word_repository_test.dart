import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';

void main() {
  sqfliteFfiInit();

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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    await db.insert('words', {
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
    });
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
        sortOrder: 1,
        now: now,
      );

      expect(word.id, 'word-house');
      expect(word.categoryId, 'category-basics');
      expect(word.term, 'Haus');
      expect(word.translation, 'house');
      expect(word.exampleSentence, 'Das Haus ist klein.');
      expect(word.notes, 'Noun');
      expect(word.sortOrder, 1);
      expect(word.isArchived, isFalse);
      expect(word.createdAt, now);
      expect(word.updatedAt, now);

      final rows = await db.query('words');
      expect(rows, hasLength(1));
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
