import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';

void main() {
  sqfliteFfiInit();

  Future<Database> openSchemaDatabase() async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await LocalDatabaseSchema.createV1(db);
    return db;
  }

  Future<void> insertCategory(Database db, {String id = 'category-1'}) async {
    await db.insert('categories', {
      'id': id,
      'name': 'Basics',
      'created_at': '2026-05-13T10:00:00.000',
      'updated_at': '2026-05-13T10:00:00.000',
    });
  }

  Future<void> insertWord(
    Database db, {
    String id = 'word-1',
    String categoryId = 'category-1',
  }) async {
    await db.insert('words', {
      'id': id,
      'category_id': categoryId,
      'term': 'hello',
      'translation': 'hallo',
      'created_at': '2026-05-13T10:00:00.000',
      'updated_at': '2026-05-13T10:00:00.000',
    });
  }

  Future<void> insertLearningSession(
    Database db, {
    String id = 'session-1',
    String categoryId = 'category-1',
    String modeId = 'time',
    String trainingAreaId = 'all',
    String status = 'active',
  }) async {
    await db.insert('learning_sessions', {
      'id': id,
      'category_id': categoryId,
      'mode_id': modeId,
      'training_area_id': trainingAreaId,
      'status': status,
      'session_size': 20,
      'started_at': '2026-05-13T10:00:00.000',
      'last_activity_at': '2026-05-13T10:00:00.000',
      'created_at': '2026-05-13T10:00:00.000',
      'updated_at': '2026-05-13T10:00:00.000',
    });
  }

  group('LocalDatabaseSchema', () {
    test('creates_all_v1_tables', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);

      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type = 'table'",
      );
      final tableNames = tables.map((row) => row['name']).toSet();

      expect(
        tableNames,
        containsAll({
          'categories',
          'words',
          'word_progress',
          'review_history',
          'learning_sessions',
          'session_items',
          'settings',
          'word_sources',
        }),
      );
    });

    test('word_progress_is_unique_per_word_category_and_mode', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db);

      final progress = {
        'word_id': 'word-1',
        'category_id': 'category-1',
        'mode_id': 'time',
        'stage': 's0',
        'created_at': '2026-05-13T10:00:00.000',
        'updated_at': '2026-05-13T10:00:00.000',
      };

      await db.insert('word_progress', {'id': 'progress-1', ...progress});

      expect(
        () => db.insert('word_progress', {'id': 'progress-2', ...progress}),
        throwsA(isA<DatabaseException>()),
      );

      await db.insert('word_progress', {
        'id': 'progress-3',
        ...progress,
        'mode_id': 'adaptive',
      });
    });

    test(
      'learning_sessions_allows_only_one_active_session_per_context',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await insertCategory(db);

        await insertLearningSession(db, id: 'session-1');

        expect(
          () => insertLearningSession(db, id: 'session-2'),
          throwsA(isA<DatabaseException>()),
        );

        await insertLearningSession(db, id: 'session-3', status: 'completed');
        await insertLearningSession(db, id: 'session-4', modeId: 'hybrid');
        await insertLearningSession(
          db,
          id: 'session-5',
          trainingAreaId: 'reviewOnly',
        );
      },
    );

    test('session_items_position_is_unique_per_session', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await insertCategory(db);
      await insertWord(db);
      await insertLearningSession(db);

      final item = {
        'session_id': 'session-1',
        'word_id': 'word-1',
        'category_id': 'category-1',
        'mode_id': 'time',
        'stage_at_enqueue': 's1',
        'position': 0,
        'status': 'queued',
        'created_at': '2026-05-13T10:00:00.000',
        'updated_at': '2026-05-13T10:00:00.000',
      };

      await db.insert('session_items', {'id': 'item-1', ...item});

      expect(
        () => db.insert('session_items', {'id': 'item-2', ...item}),
        throwsA(isA<DatabaseException>()),
      );

      await db.insert('session_items', {
        'id': 'item-3',
        ...item,
        'position': 1,
        'requeue_reason': 'wrongAnswer',
      });
    });

    test('foreign_keys_reject_orphan_rows', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);

      expect(
        () => db.insert('words', {
          'id': 'orphan-word',
          'category_id': 'missing-category',
          'term': 'hello',
          'translation': 'hallo',
          'created_at': '2026-05-13T10:00:00.000',
          'updated_at': '2026-05-13T10:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );

      await insertCategory(db);

      expect(
        () => db.insert('word_progress', {
          'id': 'orphan-progress',
          'word_id': 'missing-word',
          'category_id': 'category-1',
          'mode_id': 'time',
          'stage': 's0',
          'created_at': '2026-05-13T10:00:00.000',
          'updated_at': '2026-05-13T10:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );

      expect(
        () => db.insert('learning_sessions', {
          'id': 'orphan-session',
          'category_id': 'missing-category',
          'mode_id': 'time',
          'training_area_id': 'all',
          'status': 'active',
          'session_size': 20,
          'started_at': '2026-05-13T10:00:00.000',
          'last_activity_at': '2026-05-13T10:00:00.000',
          'created_at': '2026-05-13T10:00:00.000',
          'updated_at': '2026-05-13T10:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );

      await insertWord(db);
      await insertLearningSession(db);

      expect(
        () => db.insert('review_history', {
          'id': 'orphan-review-history',
          'word_id': 'word-1',
          'category_id': 'category-1',
          'mode_id': 'time',
          'training_area_id': 'all',
          'session_id': 'missing-session',
          'answer': 'correct',
          'reviewed_at': '2026-05-13T10:00:00.000',
          'old_stage': 's0',
          'new_stage': 's1',
          'old_pass_count': 0,
          'new_pass_count': 0,
          'created_at': '2026-05-13T10:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );

      expect(
        () => db.insert('session_items', {
          'id': 'orphan-session-item',
          'session_id': 'missing-session',
          'word_id': 'word-1',
          'category_id': 'category-1',
          'mode_id': 'time',
          'stage_at_enqueue': 's1',
          'position': 0,
          'status': 'queued',
          'created_at': '2026-05-13T10:00:00.000',
          'updated_at': '2026-05-13T10:00:00.000',
        }),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
