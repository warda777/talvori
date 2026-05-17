import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/srs_stage.dart';
import '../../srs/models/word_progress.dart';

class WordProgressRepository {
  WordProgressRepository({required Database database, Uuid uuid = const Uuid()})
    : _database = database,
      _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<WordProgress> ensureProgressForWord({
    required String wordId,
    required String categoryId,
    required LearningMode mode,
    required DateTime now,
  }) async {
    final existing = await _loadProgress(
      wordId: wordId,
      categoryId: categoryId,
      mode: mode,
    );

    if (existing != null) {
      return existing;
    }

    await _database.insert('word_progress', {
      'id': _uuid.v4(),
      'word_id': wordId,
      'category_id': categoryId,
      'mode_id': mode.name,
      'stage': SrsStage.s0.name,
      'pass_count': 0,
      'wrong_count': 0,
      'next_due_at': null,
      'last_reviewed_at': null,
      'created_at': _encodeDateTime(now),
      'updated_at': _encodeDateTime(now),
    });

    return _loadProgress(
      wordId: wordId,
      categoryId: categoryId,
      mode: mode,
    ).then((progress) => progress!);
  }

  Future<void> saveProgress({
    required WordProgress updatedProgress,
    required DateTime updatedAt,
  }) async {
    await _database.update(
      'word_progress',
      {
        'stage': updatedProgress.stage.name,
        'pass_count': updatedProgress.passCount,
        'wrong_count': updatedProgress.wrongCount,
        'next_due_at': _encodeDateTime(updatedProgress.nextDueAt),
        'last_reviewed_at': _encodeDateTime(updatedProgress.lastReviewedAt),
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'word_id = ? AND category_id = ? AND mode_id = ?',
      whereArgs: [
        updatedProgress.wordId,
        updatedProgress.categoryId,
        updatedProgress.mode.name,
      ],
    );
  }

  Future<WordProgress?> loadProgress({
    required String wordId,
    required String categoryId,
    required LearningMode mode,
  }) {
    return _loadProgress(wordId: wordId, categoryId: categoryId, mode: mode);
  }

  Future<List<int>> countByStage({
    required String categoryId,
    required LearningMode mode,
  }) async {
    final rows = await _database.rawQuery(
      '''
SELECT stage, COUNT(*) AS count
FROM word_progress
WHERE category_id = ? AND mode_id = ?
GROUP BY stage
''',
      [categoryId, mode.name],
    );

    final counts = List<int>.filled(SrsStage.values.length, 0);
    for (final row in rows) {
      final stageName = row['stage'] as String?;
      final count = row['count'] as int? ?? 0;
      if (stageName == null) continue;
      final stage = SrsStage.values.byName(stageName);
      counts[stage.index] = count;
    }

    return counts;
  }

  Future<void> resetCategoryProgressToS0({
    required String categoryId,
    required LearningMode mode,
    required DateTime updatedAt,
  }) async {
    await _database.update(
      'word_progress',
      {
        'stage': SrsStage.s0.name,
        'pass_count': 0,
        'wrong_count': 0,
        'next_due_at': null,
        'last_reviewed_at': null,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: 'category_id = ? AND mode_id = ?',
      whereArgs: [categoryId, mode.name],
    );
  }

  Future<List<WordProgress>> loadDueProgresses({
    required String categoryId,
    required LearningMode mode,
    required DateTime now,
  }) async {
    final rows = await _database.query(
      'word_progress',
      where: '''
category_id = ?
AND mode_id = ?
AND stage != ?
AND next_due_at IS NOT NULL
AND next_due_at <= ?
''',
      whereArgs: [
        categoryId,
        mode.name,
        SrsStage.s0.name,
        _encodeDateTime(now),
      ],
      orderBy: 'next_due_at ASC',
    );

    return rows.map(_mapProgress).toList(growable: false);
  }

  Future<List<WordProgress>> loadNewProgresses({
    required String categoryId,
    required LearningMode mode,
    required int limit,
  }) async {
    final rows = await _database.query(
      'word_progress',
      where: 'category_id = ? AND mode_id = ? AND stage = ?',
      whereArgs: [categoryId, mode.name, SrsStage.s0.name],
      orderBy: 'created_at ASC',
      limit: limit,
    );

    return rows.map(_mapProgress).toList(growable: false);
  }

  Future<WordProgress?> _loadProgress({
    required String wordId,
    required String categoryId,
    required LearningMode mode,
  }) async {
    final rows = await _database.query(
      'word_progress',
      where: 'word_id = ? AND category_id = ? AND mode_id = ?',
      whereArgs: [wordId, categoryId, mode.name],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapProgress(rows.single);
  }

  WordProgress _mapProgress(Map<String, Object?> row) {
    return WordProgress(
      wordId: row['word_id']! as String,
      categoryId: row['category_id']! as String,
      mode: LearningMode.values.byName(row['mode_id']! as String),
      stage: SrsStage.values.byName(row['stage']! as String),
      passCount: row['pass_count']! as int,
      wrongCount: row['wrong_count']! as int,
      nextDueAt: _decodeDateTime(row['next_due_at'] as String?),
      lastReviewedAt: _decodeDateTime(row['last_reviewed_at'] as String?),
    );
  }

  String? _encodeDateTime(DateTime? value) {
    return value?.toIso8601String();
  }

  DateTime? _decodeDateTime(String? value) {
    return value == null ? null : DateTime.parse(value);
  }
}
