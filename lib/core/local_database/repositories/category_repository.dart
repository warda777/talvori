import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/local_category.dart';

class CategoryRepository {
  CategoryRepository({required Database database, Uuid uuid = const Uuid()})
    : _database = database,
      _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<LocalCategory> upsertCategory({
    String? id,
    required String name,
    String? description,
    int sortOrder = 0,
    bool isArchived = false,
    required DateTime now,
  }) async {
    final categoryId = id ?? _uuid.v4();
    final existing = await loadCategoryById(categoryId);

    if (existing == null) {
      await _database.insert('categories', {
        'id': categoryId,
        'name': name,
        'description': description,
        'sort_order': sortOrder,
        'is_archived': isArchived ? 1 : 0,
        'created_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      });
    } else {
      await _database.update(
        'categories',
        {
          'name': name,
          'description': description,
          'sort_order': sortOrder,
          'is_archived': isArchived ? 1 : 0,
          'updated_at': _encodeDateTime(now),
        },
        where: 'id = ?',
        whereArgs: [categoryId],
      );
    }

    return (await loadCategoryById(categoryId))!;
  }

  Future<LocalCategory?> loadCategoryById(String id) async {
    final rows = await _database.query(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapCategory(rows.single);
  }

  Future<List<LocalCategory>> loadCategories({
    bool includeArchived = false,
  }) async {
    final rows = await _database.query(
      'categories',
      where: includeArchived ? null : 'is_archived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: 'sort_order ASC, name ASC',
    );

    return rows.map(_mapCategory).toList(growable: false);
  }

  Future<void> archiveCategory({
    required String id,
    required bool archived,
    required DateTime updatedAt,
  }) async {
    await _database.update(
      'categories',
      {
        'is_archived': archived ? 1 : 0,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  LocalCategory _mapCategory(Map<String, Object?> row) {
    return LocalCategory(
      id: row['id']! as String,
      name: row['name']! as String,
      description: row['description'] as String?,
      sortOrder: row['sort_order']! as int,
      isArchived: (row['is_archived']! as int) == 1,
      createdAt: _decodeDateTime(row['created_at']! as String),
      updatedAt: _decodeDateTime(row['updated_at']! as String),
    );
  }

  String _encodeDateTime(DateTime value) {
    return value.toIso8601String();
  }

  DateTime _decodeDateTime(String value) {
    return DateTime.parse(value);
  }
}
