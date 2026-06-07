import 'package:flutter/widgets.dart';

import 'local_world_preview_composition.dart';

// Local manual launch target only:
// flutter run -t lib/features/world/local_world/ui/widgets/local_world_preview_composition_main.dart
//
// This file is intentionally not routed, exported, or connected to Home,
// Onboarding, World, persistence, runtime config, assets, tests, screenshots,
// automatic word placement, build states, or frame_started.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: LocalWorldPreviewComposition(),
    ),
  );
}
