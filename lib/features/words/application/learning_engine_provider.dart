import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Zwei Engines: Zeitbasiert (Ebbinghaus) vs. Adaptiv (lernbasiert)
enum LearningEngine { timeSRS, adaptiveSRS }

final learningEngineProvider =
    StateProvider<LearningEngine>((_) => LearningEngine.timeSRS);
