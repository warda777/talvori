import 'package:flutter/widgets.dart';

import 'compact_local_world_surface_preview.dart';

// Local manual launch target only:
// flutter run -t lib/features/world/local_world/ui/widgets/compact_local_world_surface_preview_main.dart
//
// This file is intentionally not routed, exported, or connected to any
// productive app surface. It exists only for isolated manual preview runs.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const Directionality(
      textDirection: TextDirection.ltr,
      child: CompactLocalWorldSurfacePreview(),
    ),
  );
}
