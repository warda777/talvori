import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:talvori/features/words/ui/widgets/single_stage_picker.dart';

class LevelSelectionController {
  static Future<void> handleModeChange(
    BuildContext context,
    WidgetRef ref,
    LevelSelectionMode mode,
  ) async {
    // WICHTIG: singleStage zurücksetzen, wenn Mode nicht single ist
    if (mode != LevelSelectionMode.single) {
      ref.read(singleStageProvider.notifier).state = 1; // Reset auf Default
    }
    
    ref.read(levelSelectionProvider.notifier).state = mode;

    if (mode == LevelSelectionMode.single) {
      final picked = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: const Color(0xFF1E1E1F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        builder: (_) => const SingleStagePicker(),
      );
      if (picked != null) {
        ref.read(singleStageProvider.notifier).state = picked;
      }
    }
  }
}
