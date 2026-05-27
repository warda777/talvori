import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../models/local_word.dart';
import '../models/local_word_world_membership.dart';
import '../models/translation_status.dart';
import '../local_database_schema.dart';

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
    TranslationStatus? translationStatus,
    String? sourceLanguage,
    String? targetLanguage,
    String? translationError,
    String? level,
    String? exampleSentence,
    String? notes,
    int sortOrder = 0,
    bool isArchived = false,
    required DateTime now,
  }) async {
    final wordId = id ?? _uuid.v4();
    final existing = await loadWordById(wordId);
    final resolvedTranslationStatus =
        translationStatus ?? _statusForTranslation(translation);

    if (existing == null) {
      await _database.insert('words', {
        'id': wordId,
        'category_id': categoryId,
        'term': term,
        'translation': translation,
        'translation_status': resolvedTranslationStatus.dbValue,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'translation_error': translationError,
        'level': level,
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
          'translation_status': resolvedTranslationStatus.dbValue,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
          'translation_error': translationError,
          'level': level,
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

    await _addMembershipForThematicCategoryIfNeeded(
      wordId: wordId,
      categoryId: categoryId,
      now: now,
    );

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

  Future<LocalWord?> updateWord({
    required String id,
    required String term,
    required String translation,
    TranslationStatus? translationStatus,
    String? sourceLanguage,
    String? targetLanguage,
    String? translationError,
    required DateTime updatedAt,
  }) async {
    final existing = await loadWordById(id);
    if (existing == null) return null;
    final resolvedTranslationStatus =
        translationStatus ?? _statusForTranslation(translation);
    final updatedRows = await _database.update(
      'words',
      {
        'term': term,
        'translation': translation,
        'translation_status': resolvedTranslationStatus.dbValue,
        'source_language': sourceLanguage ?? existing.sourceLanguage,
        'target_language': targetLanguage ?? existing.targetLanguage,
        'translation_error': translationError,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updatedRows == 0) {
      return null;
    }

    return loadWordById(id);
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

  Future<List<LocalWord>> loadWordsForWordWorld({
    required String categoryId,
    bool includeArchived = false,
  }) async {
    final rows = await _database.rawQuery(
      '''
SELECT w.*
FROM words w
JOIN word_world_memberships m ON m.word_id = w.id
WHERE m.category_id = ?
${includeArchived ? '' : 'AND w.is_archived = 0'}
ORDER BY w.sort_order ASC, w.term ASC
''',
      [categoryId],
    );

    final membershipCountRows = await _database.rawQuery(
      '''
SELECT COUNT(*) AS count
FROM word_world_memberships
WHERE category_id = ?
''',
      [categoryId],
    );
    final membershipCount = membershipCountRows.single['count'] as int? ?? 0;
    if (membershipCount > 0) {
      return rows.map(_mapWord).toList(growable: false);
    }

    return loadWordsForCategory(
      categoryId: categoryId,
      includeArchived: includeArchived,
    );
  }

  Future<List<String>> loadWordIdsForWordWorld({
    required String categoryId,
    bool includeArchived = false,
  }) async {
    final membershipCount = await _countWordWorldMemberships(categoryId);
    if (membershipCount == 0) {
      return loadWordIdsForCategory(
        categoryId: categoryId,
        includeArchived: includeArchived,
      );
    }

    final rows = await _database.rawQuery(
      '''
SELECT w.id
FROM words w
JOIN word_world_memberships m ON m.word_id = w.id
WHERE m.category_id = ?
${includeArchived ? '' : 'AND w.is_archived = 0'}
ORDER BY w.sort_order ASC, w.term ASC
''',
      [categoryId],
    );

    return rows.map((row) => row['id']! as String).toList(growable: false);
  }

  Future<int> countWordsForWordWorld({
    required String categoryId,
    bool includeArchived = false,
  }) async {
    final membershipCount = await _countWordWorldMemberships(categoryId);
    if (membershipCount == 0) {
      return countWordsForCategory(
        categoryId: categoryId,
        includeArchived: includeArchived,
      );
    }

    final rows = await _database.rawQuery(
      includeArchived
          ? '''
SELECT COUNT(*) AS count
FROM words w
JOIN word_world_memberships m ON m.word_id = w.id
WHERE m.category_id = ?
'''
          : '''
SELECT COUNT(*) AS count
FROM words w
JOIN word_world_memberships m ON m.word_id = w.id
WHERE m.category_id = ? AND w.is_archived = ?
''',
      includeArchived ? [categoryId] : [categoryId, 0],
    );

    return rows.single['count'] as int? ?? 0;
  }

  Future<void> addWordWorldMembership({
    required String wordId,
    required String categoryId,
    required DateTime createdAt,
  }) async {
    await _database.insert('word_world_memberships', {
      'word_id': wordId,
      'category_id': categoryId,
      'created_at': _encodeDateTime(createdAt),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<LocalWordWorldMembership>> loadMembershipsForWord(
    String wordId,
  ) async {
    final rows = await _database.query(
      'word_world_memberships',
      where: 'word_id = ?',
      whereArgs: [wordId],
      orderBy: 'created_at ASC, category_id ASC',
    );

    return rows.map(_mapMembership).toList(growable: false);
  }

  Future<LocalWord?> setWordLevel({
    required String wordId,
    required String? level,
    required DateTime updatedAt,
  }) async {
    final updatedRows = await _database.update(
      'words',
      {'level': level, 'updated_at': _encodeDateTime(updatedAt)},
      where: 'id = ?',
      whereArgs: [wordId],
    );
    if (updatedRows == 0) return null;
    return loadWordById(wordId);
  }

  Future<List<LocalWord>> loadAllWords({bool includeArchived = false}) async {
    final rows = await _database.query(
      'words',
      where: includeArchived ? null : 'is_archived = ?',
      whereArgs: includeArchived ? null : [0],
      orderBy: 'sort_order ASC, created_at DESC, term ASC',
    );

    return rows.map(_mapWord).toList(growable: false);
  }

  Future<int> countAllWords({bool includeArchived = false}) async {
    final rows = await _database.rawQuery(
      includeArchived
          ? 'SELECT COUNT(*) AS count FROM words'
          : 'SELECT COUNT(*) AS count FROM words WHERE is_archived = ?',
      includeArchived ? null : [0],
    );

    return rows.single['count'] as int? ?? 0;
  }

  Future<List<LocalWord>> loadPendingTranslations({
    String? categoryId,
    bool includeArchived = false,
  }) async {
    final where = <String>['translation_status = ?'];
    final whereArgs = <Object?>[TranslationStatus.pending.dbValue];
    if (categoryId != null) {
      where.add('category_id = ?');
      whereArgs.add(categoryId);
    }
    if (!includeArchived) {
      where.add('is_archived = ?');
      whereArgs.add(0);
    }

    final rows = await _database.query(
      'words',
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'sort_order ASC, term ASC',
    );

    return rows.map(_mapWord).toList(growable: false);
  }

  Future<LocalWord?> updateTranslation({
    required String id,
    required String translation,
    String? sourceLanguage,
    String? targetLanguage,
    required DateTime updatedAt,
  }) async {
    final existing = await loadWordById(id);
    if (existing == null) return null;

    final updatedRows = await _database.update(
      'words',
      {
        'translation': translation,
        'translation_status': TranslationStatus.translated.dbValue,
        'source_language': sourceLanguage ?? existing.sourceLanguage,
        'target_language': targetLanguage ?? existing.targetLanguage,
        'translation_error': null,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updatedRows == 0) return null;
    return loadWordById(id);
  }

  Future<LocalWord?> markTranslationFailed({
    required String id,
    required String error,
    required DateTime updatedAt,
  }) async {
    final updatedRows = await _database.update(
      'words',
      {
        'translation_status': TranslationStatus.failed.dbValue,
        'translation_error': error,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    if (updatedRows == 0) return null;
    return loadWordById(id);
  }

  Future<int> resetFailedTranslationsToPending({
    String? categoryId,
    bool includeArchived = false,
    required DateTime updatedAt,
  }) async {
    final where = <String>['translation_status = ?'];
    final whereArgs = <Object?>[TranslationStatus.failed.dbValue];
    if (categoryId != null) {
      where.add('category_id = ?');
      whereArgs.add(categoryId);
    }
    if (!includeArchived) {
      where.add('is_archived = ?');
      whereArgs.add(0);
    }

    return _database.update(
      'words',
      {
        'translation_status': TranslationStatus.pending.dbValue,
        'translation_error': null,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: where.join(' AND '),
      whereArgs: whereArgs,
    );
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

  Future<int> _countWordWorldMemberships(String categoryId) async {
    final rows = await _database.rawQuery(
      '''
SELECT COUNT(*) AS count
FROM word_world_memberships
WHERE category_id = ?
''',
      [categoryId],
    );
    return rows.single['count'] as int? ?? 0;
  }

  Future<int> countWordsForCategory({
    required String categoryId,
    bool includeArchived = false,
  }) async {
    final rows = await _database.rawQuery(
      includeArchived
          ? 'SELECT COUNT(*) AS count FROM words WHERE category_id = ?'
          : '''
SELECT COUNT(*) AS count
FROM words
WHERE category_id = ? AND is_archived = ?
''',
      includeArchived ? [categoryId] : [categoryId, 0],
    );

    return rows.single['count'] as int? ?? 0;
  }

  LocalWord _mapWord(Map<String, Object?> row) {
    return LocalWord(
      id: row['id']! as String,
      categoryId: row['category_id']! as String,
      term: row['term']! as String,
      translation: row['translation']! as String,
      translationStatus: TranslationStatus.fromDbValue(
        row['translation_status'],
      ),
      sourceLanguage: row['source_language'] as String?,
      targetLanguage: row['target_language'] as String?,
      translationError: row['translation_error'] as String?,
      level: row['level'] as String?,
      exampleSentence: row['example_sentence'] as String?,
      notes: row['notes'] as String?,
      sortOrder: row['sort_order']! as int,
      isArchived: (row['is_archived']! as int) == 1,
      createdAt: _decodeDateTime(row['created_at']! as String),
      updatedAt: _decodeDateTime(row['updated_at']! as String),
    );
  }

  LocalWordWorldMembership _mapMembership(Map<String, Object?> row) {
    return LocalWordWorldMembership(
      wordId: row['word_id']! as String,
      categoryId: row['category_id']! as String,
      createdAt: _decodeDateTime(row['created_at']! as String),
    );
  }

  Future<void> _addMembershipForThematicCategoryIfNeeded({
    required String wordId,
    required String categoryId,
    required DateTime now,
  }) async {
    final rows = await _database.query(
      'categories',
      columns: ['name'],
      where: 'id = ?',
      whereArgs: [categoryId],
      limit: 1,
    );
    if (rows.isEmpty) return;
    final categoryName = rows.single['name'] as String?;
    if (!LocalDatabaseSchema.isThematicWordWorldName(categoryName)) return;
    await addWordWorldMembership(
      wordId: wordId,
      categoryId: categoryId,
      createdAt: now,
    );
  }

  String _encodeDateTime(DateTime value) {
    return value.toIso8601String();
  }

  DateTime _decodeDateTime(String value) {
    return DateTime.parse(value);
  }

  TranslationStatus _statusForTranslation(String translation) {
    return translation.trim().isEmpty
        ? TranslationStatus.pending
        : TranslationStatus.translated;
  }
}
