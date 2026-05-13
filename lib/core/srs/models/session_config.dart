import 'learning_mode.dart';
import 'training_area.dart';

class SessionConfig {
  const SessionConfig({
    required this.mode,
    required this.trainingArea,
    required this.now,
    this.sessionSize = 20,
  }) : assert(sessionSize > 0);

  final LearningMode mode;
  final TrainingArea trainingArea;
  final DateTime now;
  final int sessionSize;
}
