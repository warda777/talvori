import 'srs_stage.dart';
import 'word_progress.dart';

class StageTransitionResult {
  const StageTransitionResult({
    required this.progress,
    required this.oldStage,
    required this.newStage,
    required this.oldPassCount,
    required this.newPassCount,
  });

  final WordProgress progress;
  final SrsStage oldStage;
  final SrsStage newStage;
  final int oldPassCount;
  final int newPassCount;

  bool get stageChanged => oldStage != newStage;
}
