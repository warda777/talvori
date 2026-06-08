import 'package:flutter/material.dart';

import 'starter_island_plot_board_preview.dart';

// Local preview entry only, with no app integration.
//
// Start command:
// flutter run -t lib/features/world/local_world/ui/widgets/starter_island_plot_board_preview_main.dart
//
// Island-First check: the board is the game space, plot slots carry later
// play moments, and UI remains HUD/signage instead of a learning window.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StarterIslandPlotBoardPreview(),
    ),
  );
}
