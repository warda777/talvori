import '../models/requeue_decision.dart';
import '../models/requeue_reason.dart';

class RequeueService {
  const RequeueService();

  RequeueDecision applyRequeueForWrongAnswer({
    required int sameSessionWrongCount,
    required int remainingQueueSize,
  }) {
    assert(sameSessionWrongCount >= 1);
    assert(remainingQueueSize >= 0);

    if (sameSessionWrongCount >= 3) {
      return const RequeueDecision(
        shouldRequeue: true,
        reason: RequeueReason.markedDifficult,
        targetOffset: null,
        effectiveOffset: null,
        moveToQueueEnd: true,
        markDifficult: true,
        shouldRemoveFromReview: false,
      );
    }

    final targetOffset = sameSessionWrongCount == 1 ? 10 : 5;
    final moveToQueueEnd = remainingQueueSize < targetOffset;

    return RequeueDecision(
      shouldRequeue: true,
      reason: sameSessionWrongCount == 1
          ? RequeueReason.wrongAnswer
          : RequeueReason.repeatedWrongAnswer,
      targetOffset: targetOffset,
      effectiveOffset: moveToQueueEnd ? remainingQueueSize : targetOffset,
      moveToQueueEnd: moveToQueueEnd,
      markDifficult: false,
      shouldRemoveFromReview: false,
    );
  }
}
