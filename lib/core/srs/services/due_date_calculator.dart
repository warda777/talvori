import '../models/learning_mode.dart';
import '../models/srs_stage.dart';

class DueDateCalculator {
  const DueDateCalculator();

  DateTime calculateNextDueAt({
    required LearningMode mode,
    required SrsStage stage,
    required DateTime now,
  }) {
    final interval = switch (mode) {
      LearningMode.time => _timeModeInterval(stage),
      LearningMode.hybrid => _hybridModeInterval(stage),
      LearningMode.adaptive => Duration.zero,
    };

    return now.add(interval);
  }

  Duration _timeModeInterval(SrsStage stage) {
    return switch (stage) {
      SrsStage.s0 => Duration.zero,
      SrsStage.s1 => const Duration(days: 1),
      SrsStage.s2 => const Duration(days: 3),
      SrsStage.s3 => const Duration(days: 7),
      SrsStage.s4 => const Duration(days: 14),
      SrsStage.s5 => const Duration(days: 30),
    };
  }

  Duration _hybridModeInterval(SrsStage stage) {
    return switch (stage) {
      SrsStage.s0 || SrsStage.s1 || SrsStage.s2 => Duration.zero,
      SrsStage.s3 => const Duration(days: 1),
      SrsStage.s4 => const Duration(days: 3),
      SrsStage.s5 => const Duration(days: 5),
    };
  }
}
