import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/requeue_reason.dart';
import '../../srs/models/review_answer.dart';
import '../../srs/models/srs_stage.dart';
import '../../srs/models/training_area.dart';

class ReviewHistoryEvent {
  const ReviewHistoryEvent({
    required this.id,
    required this.wordId,
    required this.categoryId,
    required this.mode,
    required this.trainingArea,
    required this.answer,
    required this.reviewedAt,
    required this.oldStage,
    required this.newStage,
    required this.oldPassCount,
    required this.newPassCount,
    required this.createdAt,
    this.sessionId,
    this.oldNextDueAt,
    this.newNextDueAt,
    this.requeueReason,
  });

  final String id;
  final String wordId;
  final String categoryId;
  final LearningMode mode;
  final TrainingArea trainingArea;
  final String? sessionId;
  final ReviewAnswer answer;
  final DateTime reviewedAt;
  final SrsStage oldStage;
  final SrsStage newStage;
  final int oldPassCount;
  final int newPassCount;
  final DateTime? oldNextDueAt;
  final DateTime? newNextDueAt;
  final RequeueReason? requeueReason;
  final DateTime createdAt;
}

class ReviewHistoryRepository {
  ReviewHistoryRepository({
    required Database database,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<ReviewHistoryEvent> insertReviewEvent({
    required String wordId,
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required ReviewAnswer answer,
    required DateTime reviewedAt,
    required SrsStage oldStage,
    required SrsStage newStage,
    required int oldPassCount,
    required int newPassCount,
    required DateTime createdAt,
    String? sessionId,
    DateTime? oldNextDueAt,
    DateTime? newNextDueAt,
    RequeueReason? requeueReason,
  }) async {
    final id = _uuid.v4();

    await _database.insert('review_history', {
      'id': id,
      'word_id': wordId,
      'category_id': categoryId,
      'mode_id': mode.name,
      'training_area_id': trainingArea.name,
      'session_id': sessionId,
      'answer': answer.name,
      'reviewed_at': _encodeDateTime(reviewedAt),
      'old_stage': oldStage.name,
      'new_stage': newStage.name,
      'old_pass_count': oldPassCount,
      'new_pass_count': newPassCount,
      'old_next_due_at': _encodeDateTime(oldNextDueAt),
      'new_next_due_at': _encodeDateTime(newNextDueAt),
      'requeue_reason': requeueReason?.name,
      'created_at': _encodeDateTime(createdAt),
    });

    return ReviewHistoryEvent(
      id: id,
      wordId: wordId,
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
      sessionId: sessionId,
      answer: answer,
      reviewedAt: reviewedAt,
      oldStage: oldStage,
      newStage: newStage,
      oldPassCount: oldPassCount,
      newPassCount: newPassCount,
      oldNextDueAt: oldNextDueAt,
      newNextDueAt: newNextDueAt,
      requeueReason: requeueReason,
      createdAt: createdAt,
    );
  }

  Future<List<ReviewHistoryEvent>> loadHistoryForWord(String wordId) async {
    final rows = await _database.query(
      'review_history',
      where: 'word_id = ?',
      whereArgs: [wordId],
      orderBy: 'reviewed_at ASC',
    );

    return rows.map(_mapEvent).toList(growable: false);
  }

  Future<List<ReviewAnswer>> loadRecentAnswers({
    required String categoryId,
    required LearningMode mode,
    required int limit,
  }) async {
    final rows = await _database.query(
      'review_history',
      columns: ['answer'],
      where: 'category_id = ? AND mode_id = ?',
      whereArgs: [categoryId, mode.name],
      orderBy: 'reviewed_at DESC',
      limit: limit,
    );

    return rows
        .map((row) => ReviewAnswer.values.byName(row['answer']! as String))
        .toList(growable: false);
  }

  Future<bool> hasHistoryForCategoryAndMode({
    required String categoryId,
    required LearningMode mode,
  }) async {
    final rows = await _database.query(
      'review_history',
      columns: ['id'],
      where: 'category_id = ? AND mode_id = ?',
      whereArgs: [categoryId, mode.name],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  ReviewHistoryEvent _mapEvent(Map<String, Object?> row) {
    return ReviewHistoryEvent(
      id: row['id']! as String,
      wordId: row['word_id']! as String,
      categoryId: row['category_id']! as String,
      mode: LearningMode.values.byName(row['mode_id']! as String),
      trainingArea: TrainingArea.values.byName(
        row['training_area_id']! as String,
      ),
      sessionId: row['session_id'] as String?,
      answer: ReviewAnswer.values.byName(row['answer']! as String),
      reviewedAt: _decodeDateTime(row['reviewed_at']! as String),
      oldStage: SrsStage.values.byName(row['old_stage']! as String),
      newStage: SrsStage.values.byName(row['new_stage']! as String),
      oldPassCount: row['old_pass_count']! as int,
      newPassCount: row['new_pass_count']! as int,
      oldNextDueAt: _decodeOptionalDateTime(row['old_next_due_at'] as String?),
      newNextDueAt: _decodeOptionalDateTime(row['new_next_due_at'] as String?),
      requeueReason: _decodeRequeueReason(row['requeue_reason'] as String?),
      createdAt: _decodeDateTime(row['created_at']! as String),
    );
  }

  String? _encodeDateTime(DateTime? value) {
    return value?.toIso8601String();
  }

  DateTime _decodeDateTime(String value) {
    return DateTime.parse(value);
  }

  DateTime? _decodeOptionalDateTime(String? value) {
    return value == null ? null : DateTime.parse(value);
  }

  RequeueReason? _decodeRequeueReason(String? value) {
    return value == null ? null : RequeueReason.values.byName(value);
  }
}
