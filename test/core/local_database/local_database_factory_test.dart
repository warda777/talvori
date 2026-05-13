import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_factory.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('LocalDatabaseFactory', () {
    test('production_database_opens_and_creates_schema', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_db_factory_test_',
      );
      final databasePath = '${tempDir.path}/talvori_local_v1.db';
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final db = await const LocalDatabaseFactory().openAtPath(databasePath);
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
        }),
      );
    });

    test('production_database_enables_foreign_keys', () async {
      final tempDir = await Directory.systemTemp.createTemp(
        'talvori_local_db_factory_test_',
      );
      final databasePath = '${tempDir.path}/talvori_local_v1.db';
      addTearDown(() async {
        await databaseFactoryFfi.deleteDatabase(databasePath);
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      });

      final db = await const LocalDatabaseFactory().openAtPath(databasePath);
      addTearDown(db.close);

      final foreignKeys = await db.rawQuery('PRAGMA foreign_keys');

      expect(foreignKeys.single['foreign_keys'], 1);
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
    });

    test(
      'production_database_can_be_opened_twice_without_losing_schema',
      () async {
        final tempDir = await Directory.systemTemp.createTemp(
          'talvori_local_db_factory_test_',
        );
        final databasePath = '${tempDir.path}/talvori_local_v1.db';
        addTearDown(() async {
          await databaseFactoryFfi.deleteDatabase(databasePath);
          if (await tempDir.exists()) {
            await tempDir.delete(recursive: true);
          }
        });

        final firstDb = await const LocalDatabaseFactory().openAtPath(
          databasePath,
        );
        await firstDb.insert('categories', {
          'id': 'category-1',
          'name': 'Basics',
          'created_at': '2026-05-13T10:00:00.000',
          'updated_at': '2026-05-13T10:00:00.000',
        });
        await firstDb.close();

        final secondDb = await const LocalDatabaseFactory().openAtPath(
          databasePath,
        );
        addTearDown(secondDb.close);

        final tables = await secondDb.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table'",
        );
        final tableNames = tables.map((row) => row['name']).toSet();
        final categoryRows = await secondDb.query(
          'categories',
          where: 'id = ?',
          whereArgs: ['category-1'],
        );
        final foreignKeys = await secondDb.rawQuery('PRAGMA foreign_keys');

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
          }),
        );
        expect(categoryRows, hasLength(1));
        expect(categoryRows.single['name'], 'Basics');
        expect(foreignKeys.single['foreign_keys'], 1);
      },
    );
  });
}
