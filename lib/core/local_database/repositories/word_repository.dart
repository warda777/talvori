import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/local_word.dart';

class WordRepository {
  WordRepository({required Database database, Uuid uuid = const Uuid()})
    : _database = database,
      _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<LocalWord> upsertWord({
    String? id,
    required String categoryId,
    required String term,
    required String translation,
    String? exampleSentence,
    String? notes,
    int sortOrder = 0,
    bool isArchived = false,
    required DateTime now,
  }) async {
    final wordId = id ?? _uuid.v4();
    final existing = await loadWordById(wordId);

    if (existing == null) {
      await _database.insert('words', {
        'id': wordId,
        'category_id': categoryId,
        'term': term,
        'translation': translation,
        'example_sentence': exampleSentence,
        'notes': notes,
        'sort_order': sortOrder,
        'is_archived': isArchived ? 1 : 0,
        'created_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      });
    } else {
      await _database.update(
        'words',
        {
          'category_id': categoryId,
          'term': term,
          'translation': translation,
          'example_sentence': exampleSentence,
          'notes': notes,
          'sort_order': sortOrder,
          'is_archived': isArchived ? 1 : 0,
          'updated_at': _encodeDateTime(now),
        },
        where: 'id = ?',
        whereArgs: [wordId],
      );
    }

    return (await loadWordById(wordId))!;
  }

  Future<LocalWord?> loadWordById(String id) async {
    final rows = await _database.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapWord(rows.single);
  }

  Future<List<LocalWord>> loadWordsForCategory({
    required String categoryId,
    bool includeArchived = false,
  }) async {
    final rows = await _database.query(
      'words',
      where: includeArchived
          ? 'category_id = ?'
          : 'category_id = ? AND is_archived = ?',
      whereArgs: includeArchived ? [categoryId] : [categoryId, 0],
      orderBy: 'sort_order ASC, term ASC',
    );

    return rows.map(_mapWord).toList(growable: false);
  }

  Future<void> archiveWord({
    required String id,
    required bool archived,
    required DateTime updatedAt,
  }) async {
    await _database.update(
      'words',
      {
        'is_archived': archived ? 1 : 0,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<String>> loadWordIdsForCategory({
    required String categoryId,
    bool includeArchived = false,
  }) async {
    final rows = await _database.query(
      'words',
      columns: ['id'],
      where: includeArchived
          ? 'category_id = ?'
          : 'category_id = ? AND is_archived = ?',
      whereArgs: includeArchived ? [categoryId] : [categoryId, 0],
      orderBy: 'sort_order ASC, term ASC',
    );

    return rows.map((row) => row['id']! as String).toList(growable: false);
  }

  LocalWord _mapWord(Map<String, Object?> row) {
    return LocalWord(
      id: row['id']! as String,
      categoryId: row['category_id']! as String,
      term: row['term']! as String,
      translation: row['translation']! as String,
      exampleSentence: row['example_sentence'] as String?,
      notes: row['notes'] as String?,
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
