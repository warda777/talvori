import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../srs/models/learning_mode.dart';
import '../../srs/models/queue_build_result.dart';
import '../../srs/models/queue_item_status.dart';
import '../../srs/models/requeue_reason.dart';
import '../../srs/models/session_item.dart';
import '../../srs/models/srs_stage.dart';
import '../../srs/models/training_area.dart';

class LearningSessionRecord {
  const LearningSessionRecord({
    required this.id,
    required this.categoryId,
    required this.mode,
    required this.trainingArea,
    required this.status,
    required this.sessionSize,
    required this.currentPosition,
    required this.startedAt,
    required this.lastActivityAt,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  final String id;
  final String categoryId;
  final LearningMode mode;
  final TrainingArea trainingArea;
  final String status;
  final int sessionSize;
  final int currentPosition;
  final DateTime startedAt;
  final DateTime lastActivityAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class LocalSessionItemRecord {
  const LocalSessionItemRecord({
    required this.id,
    required this.sessionId,
    required this.wordId,
    required this.categoryId,
    required this.mode,
    required this.stageAtEnqueue,
    required this.position,
    required this.status,
    required this.isNewCard,
    required this.sameSessionWrongCount,
    required this.createdAt,
    required this.updatedAt,
    this.dueAtEnqueue,
    this.retryAfterPosition,
    this.requeueReason,
    this.shownAt,
    this.answeredAt,
  });

  final String id;
  final String sessionId;
  final String wordId;
  final String categoryId;
  final LearningMode mode;
  final SrsStage stageAtEnqueue;
  final int position;
  final QueueItemStatus status;
  final bool isNewCard;
  final DateTime? dueAtEnqueue;
  final int? retryAfterPosition;
  final RequeueReason? requeueReason;
  final int sameSessionWrongCount;
  final DateTime? shownAt;
  final DateTime? answeredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class LearningSessionRepository {
  LearningSessionRepository({
    required Database database,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<LearningSessionRecord?> findActiveSession({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
  }) async {
    final rows = await _database.query(
      'learning_sessions',
      where: '''
category_id = ?
AND mode_id = ?
AND training_area_id = ?
AND status = ?
''',
      whereArgs: [categoryId, mode.name, trainingArea.name, 'active'],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapSession(rows.single);
  }

  Future<LearningSessionRecord?> findLatestCompletedSession({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
  }) async {
    final rows = await _database.query(
      'learning_sessions',
      where: '''
category_id = ?
AND mode_id = ?
AND training_area_id = ?
AND status = ?
''',
      whereArgs: [categoryId, mode.name, trainingArea.name, 'completed'],
      orderBy: 'completed_at DESC, updated_at DESC',
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapSession(rows.single);
  }

  Future<LearningSessionRecord?> loadSession(String sessionId) async {
    final rows = await _database.query(
      'learning_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return _mapSession(rows.single);
  }

  Future<LearningSessionRecord> createSessionFromQueueResult({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required int sessionSize,
    required QueueBuildResult queueBuildResult,
    required DateTime now,
  }) async {
    final existing = await findActiveSession(
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
    );

    if (existing != null) {
      return existing;
    }

    final sessionId = _uuid.v4();

    await _database.transaction((transaction) async {
      await transaction.insert('learning_sessions', {
        'id': sessionId,
        'category_id': categoryId,
        'mode_id': mode.name,
        'training_area_id': trainingArea.name,
        'status': 'active',
        'session_size': sessionSize,
        'current_position': 0,
        'started_at': _encodeDateTime(now),
        'last_activity_at': _encodeDateTime(now),
        'completed_at': null,
        'created_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      });

      for (final item in queueBuildResult.items) {
        await transaction.insert(
          'session_items',
          _sessionItemToRow(sessionId: sessionId, item: item, now: now),
        );
      }
    });

    return (await findActiveSession(
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
    ))!;
  }

  Future<List<LocalSessionItemRecord>> loadSessionItems(
    String sessionId,
  ) async {
    final rows = await _database.query(
      'session_items',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'position ASC',
    );

    return rows.map(_mapSessionItem).toList(growable: false);
  }

  Future<void> updateCurrentPosition({
    required String sessionId,
    required int position,
    required DateTime now,
  }) async {
    await _database.update(
      'learning_sessions',
      {
        'current_position': position,
        'last_activity_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<LocalSessionItemRecord> addRequeueItem({
    required String sessionId,
    required String originalItemId,
    required String wordId,
    required String categoryId,
    required LearningMode mode,
    required SrsStage stageAtEnqueue,
    required int sameSessionWrongCount,
    required RequeueReason requeueReason,
    required DateTime now,
    int? retryAfterPosition,
  }) async {
    final newItemId = _uuid.v4();

    await _database.transaction((transaction) async {
      await transaction.update(
        'session_items',
        {
          'status': QueueItemStatus.answered.name,
          'answered_at': _encodeDateTime(now),
          'updated_at': _encodeDateTime(now),
        },
        where: 'id = ?',
        whereArgs: [originalItemId],
      );

      final nextPosition = await _nextPosition(transaction, sessionId);

      await transaction.insert('session_items', {
        'id': newItemId,
        'session_id': sessionId,
        'word_id': wordId,
        'category_id': categoryId,
        'mode_id': mode.name,
        'stage_at_enqueue': stageAtEnqueue.name,
        'position': nextPosition,
        'status': QueueItemStatus.retryPending.name,
        'is_new_card': 0,
        'due_at_enqueue': null,
        'retry_after_position': retryAfterPosition,
        'requeue_reason': requeueReason.name,
        'same_session_wrong_count': sameSessionWrongCount,
        'shown_at': null,
        'answered_at': null,
        'created_at': _encodeDateTime(now),
        'updated_at': _encodeDateTime(now),
      });
    });

    final rows = await _database.query(
      'session_items',
      where: 'id = ?',
      whereArgs: [newItemId],
      limit: 1,
    );

    return _mapSessionItem(rows.single);
  }

  Future<void> completeSession({
    required String sessionId,
    required DateTime completedAt,
  }) async {
    await _database.update(
      'learning_sessions',
      {
        'status': 'completed',
        'completed_at': _encodeDateTime(completedAt),
        'last_activity_at': _encodeDateTime(completedAt),
        'updated_at': _encodeDateTime(completedAt),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> _nextPosition(Transaction transaction, String sessionId) async {
    final rows = await transaction.rawQuery(
      'SELECT MAX(position) AS max_position FROM session_items WHERE session_id = ?',
      [sessionId],
    );
    final maxPosition = rows.single['max_position'] as int?;
    return maxPosition == null ? 0 : maxPosition + 1;
  }

  Map<String, Object?> _sessionItemToRow({
    required String sessionId,
    required SessionItem item,
    required DateTime now,
  }) {
    return {
      'id': _uuid.v4(),
      'session_id': sessionId,
      'word_id': item.wordId,
      'category_id': item.categoryId,
      'mode_id': item.mode.name,
      'stage_at_enqueue': item.stageAtEnqueue.name,
      'position': item.position,
      'status': item.status.name,
      'is_new_card': item.isNewCard ? 1 : 0,
      'due_at_enqueue': _encodeDateTime(item.dueAtEnqueue),
      'retry_after_position': null,
      'requeue_reason': null,
      'same_session_wrong_count': 0,
      'shown_at': null,
      'answered_at': null,
      'created_at': _encodeDateTime(now),
      'updated_at': _encodeDateTime(now),
    };
  }

  LearningSessionRecord _mapSession(Map<String, Object?> row) {
    return LearningSessionRecord(
      id: row['id']! as String,
      categoryId: row['category_id']! as String,
      mode: LearningMode.values.byName(row['mode_id']! as String),
      trainingArea: TrainingArea.values.byName(
        row['training_area_id']! as String,
      ),
      status: row['status']! as String,
      sessionSize: row['session_size']! as int,
      currentPosition: row['current_position']! as int,
      startedAt: _decodeDateTime(row['started_at']! as String),
      lastActivityAt: _decodeDateTime(row['last_activity_at']! as String),
      completedAt: _decodeOptionalDateTime(row['completed_at'] as String?),
      createdAt: _decodeDateTime(row['created_at']! as String),
      updatedAt: _decodeDateTime(row['updated_at']! as String),
    );
  }

  LocalSessionItemRecord _mapSessionItem(Map<String, Object?> row) {
    return LocalSessionItemRecord(
      id: row['id']! as String,
      sessionId: row['session_id']! as String,
      wordId: row['word_id']! as String,
      categoryId: row['category_id']! as String,
      mode: LearningMode.values.byName(row['mode_id']! as String),
      stageAtEnqueue: SrsStage.values.byName(
        row['stage_at_enqueue']! as String,
      ),
      position: row['position']! as int,
      status: QueueItemStatus.values.byName(row['status']! as String),
      isNewCard: (row['is_new_card']! as int) == 1,
      dueAtEnqueue: _decodeOptionalDateTime(row['due_at_enqueue'] as String?),
      retryAfterPosition: row['retry_after_position'] as int?,
      requeueReason: _decodeRequeueReason(row['requeue_reason'] as String?),
      sameSessionWrongCount: row['same_session_wrong_count']! as int,
      shownAt: _decodeOptionalDateTime(row['shown_at'] as String?),
      answeredAt: _decodeOptionalDateTime(row['answered_at'] as String?),
      createdAt: _decodeDateTime(row['created_at']! as String),
      updatedAt: _decodeDateTime(row['updated_at']! as String),
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
