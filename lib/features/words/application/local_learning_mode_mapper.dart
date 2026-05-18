import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

LearningMode localLearningModeFromSrsSystem(SrsSystem mode) {
  return switch (mode) {
    SrsSystem.time => LearningMode.time,
    SrsSystem.adaptive => LearningMode.adaptive,
    SrsSystem.hybrid => LearningMode.hybrid,
  };
}
