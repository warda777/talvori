import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/services/supabase_words_local_import_service.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime.utc(2026, 5, 24, 12);

  Future<Database> openDatabase() async {
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
    String? sourceLanguage,
    String? targetLanguage,
    String? level,
  }) async {
    await db.insert('words', {
      'id': id,
      'category_id': categoryId,
      'term': term,
      'translation': translation,
      'translation_status': translation.isEmpty ? 'pending' : 'translated',
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'level': level,
      'sort_order': 0,
      'is_archived': 0,
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  Future<void> seedProgress(Database db, {required String wordId}) async {
    await db.insert('word_progress', {
      'id': 'progress-$wordId',
      'word_id': wordId,
      'category_id': 'seed-category-travel',
      'mode_id': 'time',
      'stage': 's2',
      'pass_count': 4,
      'wrong_count': 1,
      'next_due_at': '2026-05-25T12:00:00.000Z',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  SupabaseWordsLocalImportBundle bundle({
    List<SupabaseRemoteWord>? words,
    List<SupabaseRemoteCategory>? categories,
    List<SupabaseRemoteWordCategory>? links,
  }) {
    return SupabaseWordsLocalImportBundle(
      words: words ?? const [],
      categories: categories ?? const [],
      wordCategories: links ?? const [],
    );
  }

  const travel = SupabaseRemoteCategory(id: 'remote-travel', name: 'Travel');
  const top500 = SupabaseRemoteCategory(
    id: 'remote-top-500',
    name: 'Top 500 Words',
  );
  const a1 = SupabaseRemoteCategory(id: 'remote-a1', name: 'A1');

  group('SupabaseWordsLocalImportService', () {
    test('dry-run does not write local words or memberships', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      final service = SupabaseWordsLocalImportService();

      final report = await service.preview(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-ticket',
              text: 'ticket',
              translation: 'Fahrkarte',
              fromLang: 'en',
              toLang: 'de',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-ticket',
              categoryId: 'remote-travel',
            ),
          ],
        ),
        now: now,
      );

      expect(report.localWordsCreated, 1);
      expect(await db.query('words'), isEmpty);
      expect(await db.query('word_world_memberships'), isEmpty);
    });

    test('apply inserts words, level and thematic membership', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      final service = SupabaseWordsLocalImportService();

      final report = await service.apply(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-ticket',
              text: 'ticket',
              translation: 'Fahrkarte',
              fromLang: 'EN',
              toLang: 'DE',
              level: 'A2',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-ticket',
              categoryId: 'remote-travel',
            ),
          ],
        ),
        now: now,
      );

      expect(report.localWordsCreated, 1);
      expect(report.membershipsCreated, 1);
      expect(report.levelsSet, 1);
      final words = await db.query('words');
      expect(words, hasLength(1));
      expect(words.single['id'], 'remote-ticket');
      expect(words.single['term'], 'ticket');
      expect(words.single['translation'], 'Fahrkarte');
      expect(words.single['source_language'], 'en');
      expect(words.single['target_language'], 'de');
      expect(words.single['level'], 'A2');
      final memberships = await db.query('word_world_memberships');
      expect(memberships.single['word_id'], 'remote-ticket');
      expect(memberships.single['category_id'], 'word-world-travel');
    });

    test(
      'second apply reuses existing word and creates no duplicates',
      () async {
        final db = await openDatabase();
        addTearDown(db.close);
        final service = SupabaseWordsLocalImportService();
        final remoteBundle = bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-ticket',
              text: 'ticket',
              translation: 'Fahrkarte',
              fromLang: 'en',
              toLang: 'de',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-ticket',
              categoryId: 'remote-travel',
            ),
          ],
        );

        await service.apply(database: db, bundle: remoteBundle, now: now);
        final second = await service.apply(
          database: db,
          bundle: remoteBundle,
          now: now,
        );

        expect(second.localWordsCreated, 0);
        expect(second.localWordsReused, 1);
        expect(second.membershipsCreated, 0);
        expect(await db.query('words'), hasLength(1));
        expect(await db.query('word_world_memberships'), hasLength(1));
      },
    );

    test('existing local word is reused and level is filled', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'seed-category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'local-ticket',
        categoryId: 'seed-category-travel',
        term: 'Ticket',
        translation: 'Fahrkarte',
        sourceLanguage: 'en',
        targetLanguage: 'de',
      );
      final service = SupabaseWordsLocalImportService();

      final report = await service.apply(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-ticket',
              text: 'ticket',
              translation: 'Fahrkarte',
              fromLang: 'en',
              toLang: 'de',
              level: 'B1',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-ticket',
              categoryId: 'remote-travel',
            ),
          ],
        ),
        now: now,
      );

      expect(report.localWordsCreated, 0);
      expect(report.localWordsReused, 1);
      expect(report.levelsSet, 1);
      final words = await db.query('words');
      expect(words, hasLength(1));
      expect(words.single['id'], 'local-ticket');
      expect(words.single['level'], 'B1');
    });

    test('A1 and Top 500 are not imported as word-world memberships', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      final service = SupabaseWordsLocalImportService();

      final report = await service.apply(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-basic',
              text: 'house',
              translation: 'Haus',
              fromLang: 'en',
              toLang: 'de',
            ),
          ],
          categories: const [a1, top500],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-basic',
              categoryId: 'remote-a1',
            ),
            SupabaseRemoteWordCategory(
              wordId: 'remote-basic',
              categoryId: 'remote-top-500',
            ),
          ],
        ),
        now: now,
      );

      expect(report.membershipsCreated, 0);
      expect(report.levelsSet, 1);
      expect(report.skippedCategoryNames, containsAll(['A1', 'Top 500 Words']));
      expect(await db.query('word_world_memberships'), isEmpty);
      final words = await db.query('words');
      expect(words.single['category_id'], 'local-category-remote-import');
      expect(words.single['level'], 'A1');
    });

    test('creates missing thematic category locally', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      final service = SupabaseWordsLocalImportService();

      await service.apply(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-flight',
              text: 'flight',
              translation: 'Flug',
              fromLang: 'en',
              toLang: 'de',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-flight',
              categoryId: 'remote-travel',
            ),
          ],
        ),
        now: now,
      );

      final categories = await db.query(
        'categories',
        where: 'id = ?',
        whereArgs: ['word-world-travel'],
      );
      expect(categories.single['name'], 'Travel');
    });

    test('word_progress remains unchanged during apply', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'seed-category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'local-ticket',
        categoryId: 'seed-category-travel',
        term: 'ticket',
        translation: 'Fahrkarte',
        sourceLanguage: 'en',
        targetLanguage: 'de',
      );
      await seedProgress(db, wordId: 'local-ticket');
      final before = await db.query('word_progress');
      final service = SupabaseWordsLocalImportService();

      final report = await service.apply(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-ticket',
              text: 'ticket',
              translation: 'Fahrkarte',
              fromLang: 'en',
              toLang: 'de',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-ticket',
              categoryId: 'remote-travel',
            ),
          ],
        ),
        now: now,
      );
      final after = await db.query('word_progress');

      expect(report.wordProgressRowsBefore, 1);
      expect(report.wordProgressRowsAfter, 1);
      expect(after, before);
    });

    test('translation conflict does not overwrite local translation', () async {
      final db = await openDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'seed-category-travel', name: 'Travel');
      await seedWord(
        db,
        id: 'local-move',
        categoryId: 'seed-category-travel',
        term: 'move',
        translation: 'bewegen',
        sourceLanguage: 'en',
        targetLanguage: 'de',
      );
      final service = SupabaseWordsLocalImportService();

      final report = await service.apply(
        database: db,
        bundle: bundle(
          words: const [
            SupabaseRemoteWord(
              id: 'remote-move',
              text: 'move',
              translation: 'umziehen',
              fromLang: 'en',
              toLang: 'de',
            ),
          ],
          categories: const [travel],
          links: const [
            SupabaseRemoteWordCategory(
              wordId: 'remote-move',
              categoryId: 'remote-travel',
            ),
          ],
        ),
        now: now,
      );

      expect(report.translationConflicts, hasLength(1));
      final words = await db.query('words');
      expect(words.single['translation'], 'bewegen');
    });
  });
}
