import 'learning_mode.dart';
import 'queue_item_status.dart';
import 'srs_stage.dart';

class SessionItem {
  const SessionItem({
    required this.wordId,
    required this.categoryId,
    required this.mode,
    required this.stageAtEnqueue,
    required this.position,
    required this.status,
    required this.isNewCard,
    this.dueAtEnqueue,
  });

  final String wordId;
  final String categoryId;
  final LearningMode mode;
  final SrsStage stageAtEnqueue;
  final int position;
  final QueueItemStatus status;
  final bool isNewCard;
  final DateTime? dueAtEnqueue;
}
