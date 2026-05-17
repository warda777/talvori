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
        await _insertRequeueItem(transaction, reviewInput, reviewResult);
      } else if (_shouldContinueInSession(reviewResult)) {
        await _insertContinuationItem(transaction, reviewInput, reviewResult);
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
    if (progress.mode != LearningMode.adaptive) return false;
    return progress.stage != SrsStage.s5;
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
  ) async {
    final progress = reviewResult.updatedProgress;
    final decision = reviewResult.requeueDecision!;
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

    await transaction.insert('session_items', {
      'id': _uuid.v4(),
      'session_id': reviewInput.sessionContext.sessionId,
      'word_id': progress.wordId,
      'category_id': progress.categoryId,
      'mode_id': progress.mode.name,
      'stage_at_enqueue': progress.stage.name,
      'position': nextPosition,
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

  Future<void> _insertContinuationItem(
    Transaction transaction,
    ReviewInput reviewInput,
    ReviewResult reviewResult,
  ) async {
    final progress = reviewResult.updatedProgress;
    final nextPosition = await _nextSessionItemPosition(
      transaction,
      reviewInput.sessionContext.sessionId,
    );

    await transaction.insert('session_items', {
      'id': _uuid.v4(),
      'session_id': reviewInput.sessionContext.sessionId,
      'word_id': progress.wordId,
      'category_id': progress.categoryId,
      'mode_id': progress.mode.name,
      'stage_at_enqueue': progress.stage.name,
      'position': nextPosition,
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
