import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';

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
    String? description,
    int sortOrder = 0,
    bool isArchived = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) async {
    await db.insert('categories', {
      'id': id,
      'name': name,
      'description': description,
      'sort_order': sortOrder,
      'is_archived': isArchived ? 1 : 0,
      'created_at': (createdAt ?? now).toIso8601String(),
      'updated_at': (updatedAt ?? now).toIso8601String(),
    });
  }

  group('CategoryRepository', () {
    test('upsert_category_creates_category', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = CategoryRepository(database: db);

      final category = await repository.upsertCategory(
        id: 'category-basics',
        name: 'Basics',
        description: 'Grundwortschatz',
        sortOrder: 1,
        now: now,
      );

      expect(category.id, 'category-basics');
      expect(category.name, 'Basics');
      expect(category.description, 'Grundwortschatz');
      expect(category.sortOrder, 1);
      expect(category.isArchived, isFalse);
      expect(category.createdAt, now);
      expect(category.updatedAt, now);

      final rows = await db.query('categories');
      expect(rows, hasLength(1));
    });

    test('upsert_category_updates_existing_category', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      final repository = CategoryRepository(database: db);
      final updatedAt = now.add(const Duration(minutes: 5));

      await repository.upsertCategory(
        id: 'category-basics',
        name: 'Basics',
        description: 'Old',
        sortOrder: 2,
        now: now,
      );
      final updated = await repository.upsertCategory(
        id: 'category-basics',
        name: 'Updated Basics',
        description: 'New',
        sortOrder: 7,
        isArchived: true,
        now: updatedAt,
      );

      expect(updated.id, 'category-basics');
      expect(updated.name, 'Updated Basics');
      expect(updated.description, 'New');
      expect(updated.sortOrder, 7);
      expect(updated.isArchived, isTrue);
      expect(updated.createdAt, now);
      expect(updated.updatedAt, updatedAt);

      final rows = await db.query('categories');
      expect(rows, hasLength(1));
    });

    test('load_category_by_id_returns_matching_category', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      await seedCategory(db, id: 'category-travel', name: 'Travel');
      final repository = CategoryRepository(database: db);

      final found = await repository.loadCategoryById('category-travel');
      final missing = await repository.loadCategoryById('missing');

      expect(found, isNotNull);
      expect(found!.id, 'category-travel');
      expect(found.name, 'Travel');
      expect(missing, isNull);
    });

    test(
      'load_categories_returns_non_archived_sorted_by_sort_order_then_name',
      () async {
        final db = await openSchemaDatabase();
        addTearDown(db.close);
        await seedCategory(db, id: 'category-z', name: 'Zulu', sortOrder: 2);
        await seedCategory(db, id: 'category-b', name: 'Beta', sortOrder: 1);
        await seedCategory(db, id: 'category-a', name: 'Alpha', sortOrder: 1);
        await seedCategory(
          db,
          id: 'category-archived',
          name: 'Archived',
          sortOrder: 0,
          isArchived: true,
        );
        final repository = CategoryRepository(database: db);

        final categories = await repository.loadCategories();

        expect(categories.map((category) => category.id), [
          'category-a',
          'category-b',
          'category-z',
        ]);
        expect(categories.every((category) => !category.isArchived), isTrue);
      },
    );

    test('load_categories_can_include_archived', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(
        db,
        id: 'category-active',
        name: 'Active',
        sortOrder: 1,
      );
      await seedCategory(
        db,
        id: 'category-archived',
        name: 'Archived',
        sortOrder: 0,
        isArchived: true,
      );
      final repository = CategoryRepository(database: db);

      final categories = await repository.loadCategories(includeArchived: true);

      expect(categories.map((category) => category.id), [
        'category-archived',
        'category-active',
      ]);
      expect(categories.where((category) => category.isArchived), hasLength(1));
    });

    test('archive_category_sets_is_archived_and_updated_at', () async {
      final db = await openSchemaDatabase();
      addTearDown(db.close);
      await seedCategory(db, id: 'category-basics', name: 'Basics');
      final repository = CategoryRepository(database: db);
      final archivedAt = now.add(const Duration(minutes: 8));

      await repository.archiveCategory(
        id: 'category-basics',
        archived: true,
        updatedAt: archivedAt,
      );

      final category = await repository.loadCategoryById('category-basics');
      expect(category!.isArchived, isTrue);
      expect(category.updatedAt, archivedAt);

      final rows = await db.query('categories');
      expect(rows.single['is_archived'], 1);
      expect(rows.single['updated_at'], archivedAt.toIso8601String());
    });
  });
}
