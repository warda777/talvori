import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

import '../../srs/models/queue_item_status.dart';
import '../../srs/models/learning_mode.dart';
import '../../srs/models/review_input.dart';
import '../../srs/models/review_result.dart';
import '../../srs/models/srs_stage.dart';
import '../../srs/models/training_area.dart';

class SrsReviewPersistenceService {
  SrsReviewPersistenceService({
    required Database database,
    Uuid uuid = const Uuid(),
  }) : _database = database,
       _uuid = uuid;

  final Database _database;
  final Uuid _uuid;

  Future<void> persistReviewResult({
    required ReviewInput reviewInput,
    required ReviewResult reviewResult,
    required String sessionItemId,
    required int nextPosition,
  }) async {
    await _database.transaction((transaction) async {
      if (reviewInput.trainingArea != TrainingArea.focused) {
        await _updateProgress(transaction, reviewResult);
      }
      await _insertReviewHistory(transaction, reviewInput, reviewResult);
      await _markSessionItemAnswered(transaction, sessionItemId, reviewInput);

      final requeueDecision = reviewResult.requeueDecision;
      if (requeueDecision != null && requeueDecision.shouldRequeue) {
        await _insertRequeueItem(
          transaction,
          reviewInput,
          reviewResult,
          sessionItemId,
        );
      } else if (_shouldContinueInSession(reviewResult)) {
        await _insertContinuationItem(
          transaction,
          reviewInput,
          reviewResult,
          sessionItemId,
        );
      }

      await _updateSessionPosition(
        transaction,
        sessionId: reviewInput.sessionContext.sessionId,
        nextPosition: nextPosition,
        reviewedAt: reviewInput.reviewedAt,
      );
    });
  }

  bool _shouldContinueInSession(ReviewResult reviewResult) {
    final progress = reviewResult.updatedProgress;
    if (progress.mode == LearningMode.adaptive) {
      return progress.stage != SrsStage.s5;
    }
    if (progress.mode == LearningMode.hybrid) {
      return progress.stage.index <= SrsStage.s2.index;
    }
    if (progress.mode == LearningMode.time) {
      return reviewResult.oldStage == SrsStage.s0 &&
          reviewResult.newStage == SrsStage.s1;
    }
    return false;
  }

  Future<void> _updateProgress(
    Transaction transaction,
    ReviewResult reviewResult,
  ) async {
    final progress = reviewResult.updatedProgress;
    final updatedRows = await transaction.update(
      'word_progress',
      {
        'stage': progress.stage.name,
        'pass_count': progress.passCount,
        'wrong_count': progress.wrongCount,
        'next_due_at': _encodeDateTime(progress.nextDueAt),
        'last_reviewed_at': _encodeDateTime(progress.lastReviewedAt),
        'updated_at': _encodeDateTime(progress.lastReviewedAt),
      },
      where: 'word_id = ? AND category_id = ? AND mode_id = ?',
      whereArgs: [progress.wordId, progress.categoryId, progress.mode.name],
    );

    if (updatedRows != 1) {
      throw StateError('Expected one word_progress row to update.');
    }
  }

  Future<void> _insertReviewHistory(
    Transaction transaction,
    ReviewInput reviewInput,
    ReviewResult reviewResult,
  ) async {
    final progress = reviewResult.updatedProgress;

    await transaction.insert('review_history', {
      'id': _uuid.v4(),
      'word_id': progress.wordId,
      'category_id': progress.categoryId,
      'mode_id': progress.mode.name,
      'training_area_id': reviewInput.trainingArea.name,
      'session_id': reviewInput.sessionContext.sessionId,
      'answer': reviewInput.answer.name,
      'reviewed_at': _encodeDateTime(reviewInput.reviewedAt),
      'old_stage': reviewResult.oldStage.name,
      'new_stage': reviewResult.newStage.name,
      'old_pass_count': reviewResult.oldPassCount,
      'new_pass_count': reviewResult.newPassCount,
      'old_next_due_at': _encodeDateTime(reviewInput.progress.nextDueAt),
      'new_next_due_at': _encodeDateTime(reviewResult.nextDueAt),
      'requeue_reason': reviewResult.requeueDecision?.reason.name,
      'created_at': _encodeDateTime(reviewInput.reviewedAt),
    });
  }

  Future<void> _markSessionItemAnswered(
    Transaction transaction,
    String sessionItemId,
    ReviewInput reviewInput,
  ) async {
    final updatedRows = await transaction.update(
      'session_items',
      {
        'status': QueueItemStatus.answered.name,
        'answered_at': _encodeDateTime(reviewInput.reviewedAt),
        'updated_at': _encodeDateTime(reviewInput.reviewedAt),
      },
      where: 'id = ?',
      whereArgs: [sessionItemId],
    );

    if (updatedRows != 1) {
      throw StateError('Expected one session_item row to update.');
    }
  }

  Future<void> _insertRequeueItem(
    Transaction transaction,
    ReviewInput reviewInput,
    ReviewResult reviewResult,
    String sessionItemId,
  ) async {
    final progress = reviewResult.updatedProgress;
    final decision = reviewResult.requeueDecision!;
    await _deactivateOpenDuplicateItems(
      transaction,
      sessionId: reviewInput.sessionContext.sessionId,
      wordId: progress.wordId,
      exceptItemId: sessionItemId,
      updatedAt: reviewInput.reviewedAt,
    );

    final nextPosition = await _nextSessionItemPosition(
      transaction,
      reviewInput.sessionContext.sessionId,
    );
    final sameSessionWrongCount =
        reviewInput.sessionContext.wrongCountForWord(progress.wordId) + 1;
    final retryAfterPosition =
        decision.moveToQueueEnd || decision.effectiveOffset == null
        ? null
        : reviewInput.sessionContext.currentPosition +
              decision.effectiveOffset!;
    final insertPosition = retryAfterPosition == null
        ? nextPosition
        : _max(
            nextPosition: reviewInput.sessionContext.currentPosition + 1,
            retryAfterPosition: retryAfterPosition,
          );

    if (insertPosition < nextPosition) {
      await _makePositionAvailable(
        transaction,
        sessionId: reviewInput.sessionContext.sessionId,
        position: insertPosition,
      );
    }

    await transaction.insert('session_items', {
      'id': _uuid.v4(),
      'session_id': reviewInput.sessionContext.sessionId,
      'word_id': progress.wordId,
      'category_id': progress.categoryId,
      'mode_id': progress.mode.name,
      'stage_at_enqueue': progress.stage.name,
      'position': insertPosition,
      'status': decision.markDifficult
          ? QueueItemStatus.difficult.name
          : QueueItemStatus.retryPending.name,
      'is_new_card': 0,
      'due_at_enqueue': null,
      'retry_after_position': retryAfterPosition,
      'requeue_reason': decision.reason.name,
      'same_session_wrong_count': sameSessionWrongCount,
      'shown_at': null,
      'answered_at': null,
      'created_at': _encodeDateTime(reviewInput.reviewedAt),
      'updated_at': _encodeDateTime(reviewInput.reviewedAt),
    });
  }

  Future<void> _deactivateOpenDuplicateItems(
    Transaction transaction, {
    required String sessionId,
    required String wordId,
    required String exceptItemId,
    required DateTime updatedAt,
  }) async {
    await transaction.update(
      'session_items',
      {
        'status': QueueItemStatus.answered.name,
        'updated_at': _encodeDateTime(updatedAt),
      },
      where: '''
session_id = ?
AND word_id = ?
AND id != ?
AND status IN (?, ?, ?, ?)
''',
      whereArgs: [
        sessionId,
        wordId,
        exceptItemId,
        QueueItemStatus.queued.name,
        QueueItemStatus.shown.name,
        QueueItemStatus.retryPending.name,
        QueueItemStatus.difficult.name,
      ],
    );
  }

  Future<void> _makePositionAvailable(
    Transaction transaction, {
    required String sessionId,
    required int position,
  }) async {
    const temporaryOffset = 100000;
    await transaction.rawUpdate(
      '''
UPDATE session_items
SET position = position + ?
WHERE session_id = ?
AND position >= ?
''',
      [temporaryOffset, sessionId, position],
    );
    await transaction.rawUpdate(
      '''
UPDATE session_items
SET position = position - ?
WHERE session_id = ?
AND position >= ?
''',
      [temporaryOffset - 1, sessionId, position + temporaryOffset],
    );
  }

  int _max({required int nextPosition, required int retryAfterPosition}) {
    return nextPosition > retryAfterPosition
        ? nextPosition
        : retryAfterPosition;
  }

  Future<void> _insertContinuationItem(
    Transaction transaction,
    ReviewInput reviewInput,
    ReviewResult reviewResult,
    String sessionItemId,
  ) async {
    final progress = reviewResult.updatedProgress;
    await _deactivateOpenDuplicateItems(
      transaction,
      sessionId: reviewInput.sessionContext.sessionId,
      wordId: progress.wordId,
      exceptItemId: sessionItemId,
      updatedAt: reviewInput.reviewedAt,
    );

    final nextPosition = await _nextSessionItemPosition(
      transaction,
      reviewInput.sessionContext.sessionId,
    );
    final insertPosition = await _continuationInsertPosition(
      transaction: transaction,
      sessionId: reviewInput.sessionContext.sessionId,
      mode: progress.mode,
      nextPosition: nextPosition,
      currentPosition: reviewInput.sessionContext.currentPosition,
      remainingQueueSize: reviewInput.sessionContext.remainingQueueSize,
    );

    if (insertPosition < nextPosition) {
      await _makePositionAvailable(
        transaction,
        sessionId: reviewInput.sessionContext.sessionId,
        position: insertPosition,
      );
    }

    await transaction.insert('session_items', {
      'id': _uuid.v4(),
      'session_id': reviewInput.sessionContext.sessionId,
      'word_id': progress.wordId,
      'category_id': progress.categoryId,
      'mode_id': progress.mode.name,
      'stage_at_enqueue': progress.stage.name,
      'position': insertPosition,
      'status': QueueItemStatus.queued.name,
      'is_new_card': 0,
      'due_at_enqueue': _encodeDateTime(reviewResult.nextDueAt),
      'retry_after_position': null,
      'requeue_reason': null,
      'same_session_wrong_count': reviewInput.sessionContext.wrongCountForWord(
        progress.wordId,
      ),
      'shown_at': null,
      'answered_at': null,
      'created_at': _encodeDateTime(reviewInput.reviewedAt),
      'updated_at': _encodeDateTime(reviewInput.reviewedAt),
    });
  }

  Future<int> _continuationInsertPosition({
    required Transaction transaction,
    required String sessionId,
    required LearningMode mode,
    required int nextPosition,
    required int currentPosition,
    required int remainingQueueSize,
  }) async {
    const continuationOffset = 7;
    if (remainingQueueSize <= continuationOffset) {
      return nextPosition;
    }

    final targetPosition = currentPosition + continuationOffset;
    final basePosition = targetPosition < nextPosition
        ? targetPosition
        : nextPosition;

    if (mode != LearningMode.adaptive || basePosition >= nextPosition) {
      return basePosition;
    }

    final upcomingNewRows = await transaction.query(
      'session_items',
      columns: ['position'],
      where: '''
session_id = ?
AND position >= ?
AND is_new_card = ?
AND status IN (?, ?)
''',
      whereArgs: [
        sessionId,
        basePosition,
        1,
        QueueItemStatus.queued.name,
        QueueItemStatus.shown.name,
      ],
      orderBy: 'position ASC',
      limit: 2,
    );

    if (upcomingNewRows.length < 2) {
      return basePosition;
    }

    final secondUpcomingNewPosition = upcomingNewRows.last['position']! as int;
    final adaptiveMixedPosition = secondUpcomingNewPosition + 1;
    return adaptiveMixedPosition < nextPosition
        ? adaptiveMixedPosition
        : nextPosition;
  }

  Future<void> _updateSessionPosition(
    Transaction transaction, {
    required String sessionId,
    required int nextPosition,
    required DateTime reviewedAt,
  }) async {
    final updatedRows = await transaction.update(
      'learning_sessions',
      {
        'current_position': nextPosition,
        'last_activity_at': _encodeDateTime(reviewedAt),
        'updated_at': _encodeDateTime(reviewedAt),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    if (updatedRows != 1) {
      throw StateError('Expected one learning_sessions row to update.');
    }
  }

  Future<int> _nextSessionItemPosition(
    Transaction transaction,
    String sessionId,
  ) async {
    final rows = await transaction.rawQuery(
      'SELECT MAX(position) AS max_position FROM session_items WHERE session_id = ?',
      [sessionId],
    );
    final maxPosition = rows.single['max_position'] as int?;
    return maxPosition == null ? 0 : maxPosition + 1;
  }

  String? _encodeDateTime(DateTime? value) {
    return value?.toIso8601String();
  }
}
