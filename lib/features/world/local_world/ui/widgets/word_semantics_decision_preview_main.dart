import 'package:flutter/widgets.dart';

import 'word_semantics_decision_preview.dart';

// Local manual launch target only:
// flutter run -t lib/features/world/local_world/ui/widgets/word_semantics_decision_preview_main.dart
//
// This file is intentionally not routed, exported, or connected to Home,
// Onboarding, World, persistence, runtime config, assets, tests, screenshots,
// automatic word placement, build states, build wheel, or frame_started.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WordSemanticsDecisionPreview());
}
