import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/srs/models/requeue_reason.dart';
import 'package:talvori/core/srs/services/requeue_service.dart';

void main() {
  const service = RequeueService();

  group('RequeueService', () {
    test('first_wrong_answer_requeues_after_ten_cards', () {
      final decision = service.applyRequeueForWrongAnswer(
        sameSessionWrongCount: 1,
        remainingQueueSize: 12,
      );

      expect(decision.shouldRequeue, isTrue);
      expect(decision.reason, RequeueReason.wrongAnswer);
      expect(decision.targetOffset, 10);
      expect(decision.effectiveOffset, 10);
      expect(decision.moveToQueueEnd, isFalse);
      expect(decision.markDifficult, isFalse);
      expect(decision.shouldRemoveFromReview, isFalse);
    });

    test('second_wrong_answer_requeues_after_five_cards', () {
      final decision = service.applyRequeueForWrongAnswer(
        sameSessionWrongCount: 2,
        remainingQueueSize: 6,
      );

      expect(decision.shouldRequeue, isTrue);
      expect(decision.reason, RequeueReason.repeatedWrongAnswer);
      expect(decision.targetOffset, 5);
      expect(decision.effectiveOffset, 5);
      expect(decision.moveToQueueEnd, isFalse);
      expect(decision.markDifficult, isFalse);
      expect(decision.shouldRemoveFromReview, isFalse);
    });

    test('third_wrong_answer_marks_difficult_and_moves_to_queue_end', () {
      final decision = service.applyRequeueForWrongAnswer(
        sameSessionWrongCount: 3,
        remainingQueueSize: 14,
      );

      expect(decision.shouldRequeue, isTrue);
      expect(decision.reason, RequeueReason.markedDifficult);
      expect(decision.targetOffset, isNull);
      expect(decision.effectiveOffset, isNull);
      expect(decision.moveToQueueEnd, isTrue);
      expect(decision.markDifficult, isTrue);
      expect(decision.shouldRemoveFromReview, isFalse);
    });

    test('requeue_with_short_queue_moves_to_end_but_does_not_disappear', () {
      final decision = service.applyRequeueForWrongAnswer(
        sameSessionWrongCount: 1,
        remainingQueueSize: 3,
      );

      expect(decision.shouldRequeue, isTrue);
      expect(decision.reason, RequeueReason.wrongAnswer);
      expect(decision.targetOffset, 10);
      expect(decision.effectiveOffset, 3);
      expect(decision.moveToQueueEnd, isTrue);
      expect(decision.markDifficult, isFalse);
      expect(decision.shouldRemoveFromReview, isFalse);
    });
  });
}
