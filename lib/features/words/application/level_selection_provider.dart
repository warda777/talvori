import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

/// StateProvider für aktuellen Level-Modus.
/// Zugriff:
///   final mode = ref.watch(levelSelectionProvider);
///   ref.read(levelSelectionProvider.notifier).state = LevelSelectionMode.s1toS5;
final levelSelectionProvider =
    StateProvider<LevelSelectionMode>((ref) => LevelSelectionMode.s0toS5);

// NEU: gewählte Stufe für Single-Mode (S1–S5)
final singleStageProvider = StateProvider<int>((ref) => 1); // 1..5
