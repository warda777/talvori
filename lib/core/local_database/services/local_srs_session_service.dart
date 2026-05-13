import '../../srs/models/learning_mode.dart';
import '../../srs/models/queue_build_input.dart';
import '../../srs/models/queue_item_status.dart';
import '../../srs/models/review_answer.dart';
import '../../srs/models/review_input.dart';
import '../../srs/models/session_config.dart';
import '../../srs/models/session_context.dart';
import '../../srs/models/training_area.dart';
import '../../srs/services/srs_engine.dart';
import '../models/local_srs_session_state.dart';
import '../repositories/learning_session_repository.dart';
import '../repositories/review_history_repository.dart';
import '../repositories/word_progress_repository.dart';
import 'srs_review_persistence_service.dart';

class LocalSrsSessionService {
  const LocalSrsSessionService({
    required WordProgressRepository wordProgressRepository,
    required ReviewHistoryRepository reviewHistoryRepository,
    required LearningSessionRepository learningSessionRepository,
    required SrsReviewPersistenceService reviewPersistenceService,
    SrsEngine srsEngine = const SrsEngine(),
  }) : _wordProgressRepository = wordProgressRepository,
       _reviewHistoryRepository = reviewHistoryRepository,
       _learningSessionRepository = learningSessionRepository,
       _reviewPersistenceService = reviewPersistenceService,
       _srsEngine = srsEngine;

  static const int defaultSessionSize = 20;
  static const int recentAnswerLimit = 10;

  final WordProgressRepository _wordProgressRepository;
  final ReviewHistoryRepository _reviewHistoryRepository;
  final LearningSessionRepository _learningSessionRepository;
  final SrsReviewPersistenceService _reviewPersistenceService;
  final SrsEngine _srsEngine;

  Future<LocalSrsSessionState> startOrResumeSession({
    required String categoryId,
    required LearningMode mode,
    required TrainingArea trainingArea,
    required DateTime now,
    int sessionSize = defaultSessionSize,
  }) async {
    final existingSession = await _learningSessionRepository.findActiveSession(
      categoryId: categoryId,
      mode: mode,
      trainingArea: trainingArea,
    );

    if (existingSession != null) {
      final existingItems = await _learningSessionRepository.loadSessionItems(
        existingSession.id,
      );
      return _toState(session: existingSession, items: existingItems);
    }

    final dueReviewProgresses = await _wordProgressRepository.loadDueProgresses(
      categoryId: categoryId,
      mode: mode,
      now: now,
    );
    final newProgresses = await _wordProgressRepository.loadNewProgresses(
      categoryId: categoryId,
      mode: mode,
      limit: sessionSize,
    );
    final recentAnswers = await _reviewHistoryRepository.loadRecentAnswers(
      categoryId: categoryId,
      mode: mode,
      limit: recentAnswerLimit,
    );

    final queueBuildResult = _srsEngine.buildSessionQueue(
      QueueBuildInput(
        config: SessionConfig(
          mode: mode,
          trainingArea: trainingArea,
          now: now,
          sessionSize: sessionSize,
        ),
        dueReviewProgresses: dueReviewProgresses,
        newProgresses: newProgresses,
        recentAnswers: recentAnswers,
      ),
    );

    final session = await _learningSessionRepository
        .createSessionFromQueueResult(
          categoryId: categoryId,
          mode: mode,
          trainingArea: trainingArea,
          sessionSize: sessionSize,
          queueBuildResult: queueBuildResult,
          now: now,
        );
    final items = await _learningSessionRepository.loadSessionItems(session.id);

    return _toState(session: session, items: items);
  }

  Future<LocalSrsSessionState> submitAnswer({
    required String sessionId,
    required ReviewAnswer answer,
    required DateTime now,
  }) async {
    final session = await _learningSessionRepository.loadSession(sessionId);
    if (session == null) {
      throw StateError('No session found for id $sessionId.');
    }

    final items = await _learningSessionRepository.loadSessionItems(sessionId);
    final currentItem = _currentItem(
      items: items.where(_isRemaining).toList(growable: false),
      currentPosition: session.currentPosition,
    );
    if (currentItem == null) {
      throw StateError('No current session item found for session $sessionId.');
    }

    final progress = await _wordProgressRepository.loadProgress(
      wordId: currentItem.wordId,
      categoryId: currentItem.categoryId,
      mode: currentItem.mode,
    );
    if (progress == null) {
      throw StateError(
        'No word_progress found for word ${currentItem.wordId}.',
      );
    }

    final recentAnswers = await _reviewHistoryRepository.loadRecentAnswers(
      categoryId: session.categoryId,
      mode: session.mode,
      limit: recentAnswerLimit,
    );
    final reviewInput = ReviewInput(
      progress: progress,
      answer: answer,
      trainingArea: session.trainingArea,
      reviewedAt: now,
      sessionContext: SessionContext(
        sessionId: session.id,
        currentPosition: session.currentPosition,
        recentAnswers: recentAnswers,
        sameSessionWrongCountsByWordId: _sameSessionWrongCountsByWordId(items),
        remainingQueueSize: _remainingQueueSizeAfterCurrent(items, currentItem),
      ),
    );
    final reviewResult = _srsEngine.reviewCard(reviewInput);
    final nextPosition = currentItem.position + 1;

    await _reviewPersistenceService.persistReviewResult(
      reviewInput: reviewInput,
      reviewResult: reviewResult,
      sessionItemId: currentItem.id,
      nextPosition: nextPosition,
    );

    final updatedSession = await _learningSessionRepository.loadSession(
      session.id,
    );
    final updatedItems = await _learningSessionRepository.loadSessionItems(
      session.id,
    );

    return _toState(session: updatedSession!, items: updatedItems);
  }

  Future<LocalSrsSessionState> completeSessionIfFinished({
    required String sessionId,
    required DateTime now,
  }) async {
    final session = await _learningSessionRepository.loadSession(sessionId);
    if (session == null) {
      throw StateError('No session found for id $sessionId.');
    }

    final items = await _learningSessionRepository.loadSessionItems(sessionId);
    if (!items.any(_isRemaining)) {
      await _learningSessionRepository.completeSession(
        sessionId: sessionId,
        completedAt: now,
      );
    }

    final updatedSession = await _learningSessionRepository.loadSession(
      sessionId,
    );
    final updatedItems = await _learningSessionRepository.loadSessionItems(
      sessionId,
    );

    return _toState(session: updatedSession!, items: updatedItems);
  }

  LocalSrsSessionState _toState({
    required LearningSessionRecord session,
    required List<LocalSessionItemRecord> items,
  }) {
    final answeredCount = items.where(_isAnswered).length;
    final remainingItems = items.where(_isRemaining).toList(growable: false);
    final currentItem = _currentItem(
      items: remainingItems,
      currentPosition: session.currentPosition,
    );

    return LocalSrsSessionState(
      sessionId: session.id,
      categoryId: session.categoryId,
      mode: session.mode,
      trainingArea: session.trainingArea,
      status: session.status,
      sessionSize: session.sessionSize,
      currentPosition: session.currentPosition,
      totalItems: items.length,
      answeredCount: answeredCount,
      remainingCount: remainingItems.length,
      currentWordId: currentItem?.wordId,
      canCompleteSession: remainingItems.isEmpty,
    );
  }

  LocalSessionItemRecord? _currentItem({
    required List<LocalSessionItemRecord> items,
    required int currentPosition,
  }) {
    for (final item in items) {
      if (item.position >= currentPosition) {
        return item;
      }
    }

    return items.isEmpty ? null : items.first;
  }

  bool _isAnswered(LocalSessionItemRecord item) {
    return item.status == QueueItemStatus.answered ||
        item.status == QueueItemStatus.done ||
        item.status == QueueItemStatus.difficult;
  }

  bool _isRemaining(LocalSessionItemRecord item) {
    return item.status == QueueItemStatus.queued ||
        item.status == QueueItemStatus.shown ||
        item.status == QueueItemStatus.retryPending;
  }

  int _remainingQueueSizeAfterCurrent(
    List<LocalSessionItemRecord> items,
    LocalSessionItemRecord currentItem,
  ) {
    return items
        .where(_isRemaining)
        .where((item) => item.position > currentItem.position)
        .length;
  }

  Map<String, int> _sameSessionWrongCountsByWordId(
    List<LocalSessionItemRecord> items,
  ) {
    final counts = <String, int>{};

    for (final item in items) {
      final currentCount = counts[item.wordId] ?? 0;
      if (item.sameSessionWrongCount > currentCount) {
        counts[item.wordId] = item.sameSessionWrongCount;
      }
    }

    return counts;
  }
}
