import 'requeue_reason.dart';

class RequeueDecision {
  const RequeueDecision({
    required this.shouldRequeue,
    required this.reason,
    required this.targetOffset,
    required this.effectiveOffset,
    required this.moveToQueueEnd,
    required this.markDifficult,
    required this.shouldRemoveFromReview,
  });

  final bool shouldRequeue;
  final RequeueReason reason;
  final int? targetOffset;
  final int? effectiveOffset;
  final bool moveToQueueEnd;
  final bool markDifficult;
  final bool shouldRemoveFromReview;
}
