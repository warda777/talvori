import '../models/learning_mode.dart';
import '../models/new_card_policy.dart';
import '../models/queue_build_input.dart';
import '../models/queue_build_result.dart';
import '../models/queue_item_status.dart';
import '../models/session_item.dart';
import '../models/training_area.dart';
import '../models/word_progress.dart';
import 'new_card_policy_service.dart';

class QueueBuilder {
  const QueueBuilder({
    NewCardPolicyService newCardPolicyService = const NewCardPolicyService(),
  }) : _newCardPolicyService = newCardPolicyService;

  final NewCardPolicyService _newCardPolicyService;

  QueueBuildResult buildSessionQueue(QueueBuildInput input) {
    final config = input.config;

    if (config.mode == LearningMode.adaptive &&
        config.trainingArea == TrainingArea.all) {
      return _buildAdaptiveQueue(input);
    }

    return _buildReviewFirstQueue(input);
  }

  QueueBuildResult _buildReviewFirstQueue(QueueBuildInput input) {
    final config = input.config;
    final items = <SessionItem>[];
    var reviewIndex = 0;
    var newIndex = 0;

    while (items.length < config.sessionSize &&
        reviewIndex < input.dueReviewProgresses.length) {
      items.add(_itemFromProgress(input.dueReviewProgresses[reviewIndex]));
      reviewIndex++;
    }

    final policyResult = _newCardPolicyService.evaluate(
      mode: config.mode,
      trainingArea: config.trainingArea,
      recentAnswers: input.recentAnswers,
      remainingSessionSlots: config.sessionSize - items.length,
      allowExpandedTimeNewCards: config.allowExpandedTimeNewCards,
    );

    while (items.length < config.sessionSize &&
        newIndex < input.newProgresses.length &&
        newIndex < policyResult.allowedNewCardCount) {
      items.add(
        _itemFromProgress(input.newProgresses[newIndex], isNewCard: true),
      );
      newIndex++;
    }

    return _result(items: items, newCardPolicy: policyResult.policy);
  }

  QueueBuildResult _buildAdaptiveQueue(QueueBuildInput input) {
    final config = input.config;
    final items = <SessionItem>[];
    var reviewIndex = 0;
    var newIndex = 0;

    final policyResult = _newCardPolicyService.evaluate(
      mode: config.mode,
      trainingArea: config.trainingArea,
      recentAnswers: input.recentAnswers,
      remainingSessionSlots: config.sessionSize,
      allowExpandedTimeNewCards: config.allowExpandedTimeNewCards,
    );
    final maxNewCards = policyResult.allowedNewCardCount;

    if (input.dueReviewProgresses.isEmpty) {
      while (items.length < config.sessionSize &&
          newIndex < input.newProgresses.length &&
          newIndex < maxNewCards) {
        items.add(
          _itemFromProgress(input.newProgresses[newIndex], isNewCard: true),
        );
        newIndex++;
      }

      return _result(items: items, newCardPolicy: policyResult.policy);
    }

    while (items.length < config.sessionSize) {
      var reviewsAddedInGroup = 0;
      while (items.length < config.sessionSize &&
          reviewIndex < input.dueReviewProgresses.length &&
          reviewsAddedInGroup < 2) {
        items.add(_itemFromProgress(input.dueReviewProgresses[reviewIndex]));
        reviewIndex++;
        reviewsAddedInGroup++;
      }

      if (items.length < config.sessionSize &&
          newIndex < input.newProgresses.length &&
          newIndex < maxNewCards) {
        items.add(
          _itemFromProgress(input.newProgresses[newIndex], isNewCard: true),
        );
        newIndex++;
      }

      if (reviewIndex >= input.dueReviewProgresses.length) {
        while (items.length < config.sessionSize &&
            newIndex < input.newProgresses.length &&
            newIndex < maxNewCards) {
          items.add(
            _itemFromProgress(input.newProgresses[newIndex], isNewCard: true),
          );
          newIndex++;
        }
        break;
      }

      if (reviewsAddedInGroup == 0 &&
          (newIndex >= input.newProgresses.length || newIndex >= maxNewCards)) {
        break;
      }
    }

    return _result(items: items, newCardPolicy: policyResult.policy);
  }

  SessionItem _itemFromProgress(
    WordProgress progress, {
    bool isNewCard = false,
  }) {
    return SessionItem(
      wordId: progress.wordId,
      categoryId: progress.categoryId,
      mode: progress.mode,
      stageAtEnqueue: progress.stage,
      position: 0,
      status: QueueItemStatus.queued,
      isNewCard: isNewCard,
      dueAtEnqueue: progress.nextDueAt,
    );
  }

  QueueBuildResult _result({
    required List<SessionItem> items,
    required NewCardPolicy newCardPolicy,
  }) {
    final positionedItems = [
      for (var index = 0; index < items.length; index++)
        SessionItem(
          wordId: items[index].wordId,
          categoryId: items[index].categoryId,
          mode: items[index].mode,
          stageAtEnqueue: items[index].stageAtEnqueue,
          position: index,
          status: items[index].status,
          isNewCard: items[index].isNewCard,
          dueAtEnqueue: items[index].dueAtEnqueue,
        ),
    ];

    return QueueBuildResult(
      items: positionedItems,
      newCardsIncluded: positionedItems.where((item) => item.isNewCard).length,
      reviewsIncluded: positionedItems.where((item) => !item.isNewCard).length,
      newCardPolicy: newCardPolicy,
    );
  }
}
