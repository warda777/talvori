import 'requeue_decision.dart';
import 'srs_stage.dart';
import 'word_progress.dart';

class ReviewResult {
  const ReviewResult({
    required this.updatedProgress,
    required this.oldStage,
    required this.newStage,
    required this.oldPassCount,
    required this.newPassCount,
    required this.stageChanged,
    required this.nextDueAt,
    required this.requeueDecision,
  });

  final WordProgress updatedProgress;
  final SrsStage oldStage;
  final SrsStage newStage;
  final int oldPassCount;
  final int newPassCount;
  final bool stageChanged;
  final DateTime? nextDueAt;
  final RequeueDecision? requeueDecision;
}
