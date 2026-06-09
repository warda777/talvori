import 'package:flutter/material.dart';

import 'local_object_foundation_buildsite_puzzle_preview.dart';

// Local manual preview entry only:
// flutter run -t lib/features/world/local_world/ui/widgets/local_object_foundation_buildsite_puzzle_preview_main.dart
//
// This file is intentionally not routed, exported, or connected to Home,
// navigation, providers, persistence, assets, tests, automatic word placement,
// BuildState, rewards, economy, SRS, word_progress, or frame_started.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocalObjectFoundationBuildsitePuzzlePreview(),
    ),
  );
}
