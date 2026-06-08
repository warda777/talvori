import 'package:flutter/material.dart';

import 'bank_meaning_puzzle_preview.dart';

// Local manual preview entry only:
// flutter run -t lib/features/world/local_world/ui/widgets/bank_meaning_puzzle_preview_main.dart
//
// This file is intentionally not routed, exported, or connected to Home,
// navigation, providers, persistence, assets, tests, automatic word placement,
// BuildState, or frame_started.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BankMeaningPuzzlePreview(),
    ),
  );
}
