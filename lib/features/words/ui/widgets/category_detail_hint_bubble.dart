import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
/// Sprechblase mit kontextabhängigem Hinweistext für den Category Detail Screen.
/// Zeigt unterschiedliche Texte je nach Modus, Level-Auswahl und S0-Lock.
class CategoryDetailHintBubble extends ConsumerWidget {
  const CategoryDetailHintBubble({
    super.key,
    required this.categoryId,
    this.s0Locked = false,
    this.stages = const [0, 0, 0, 0, 0, 0],
  });

  final String? categoryId;
  final bool s0Locked;
  /// Stage-Counts [S0, S1, S2, S3, S4, S5] – für Single-Hinweis „verfügbar“
  final List<int> stages;

  static String _stagePrefix(SrsSystem mode) {
    switch (mode) {
      case SrsSystem.time:
        return 'T';
      case SrsSystem.adaptive:
        return 'A';
      case SrsSystem.hybrid:
        return 'H';
    }
  }

  static String _modusLabel(SrsSystem mode) {
    switch (mode) {
      case SrsSystem.time:
        return 'T-SRS';
      case SrsSystem.adaptive:
        return 'A-SRS';
      case SrsSystem.hybrid:
        return 'Hybrid';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(levelSelectionProvider);
    final selecting = ref.watch(selectingSingleProvider);
    final singleStage = ref.watch(singleStageProvider);
    final srsMode = ref.watch(srsModeControllerProvider).mode;
    final prefix = _stagePrefix(srsMode);

    String text;

    if (s0Locked && mode == LevelSelectionMode.s0toS5) {
      text = 'Neue Karten pausiert';
    } else if (mode == LevelSelectionMode.single && selecting) {
      final s1toS5 = stages.length >= 6 ? stages.sublist(1, 6) : <int>[];
      final allStagesActive = s1toS5.isNotEmpty && s1toS5.every((c) => c > 0);
      text = allStagesActive ? 'Wähle eine Stufe' : 'Wähle eine verfügbare Stufe';
    } else if (mode == LevelSelectionMode.single) {
      text = 'Stufe $prefix$singleStage aktiv\nDrücke Start';
    } else if (mode == LevelSelectionMode.s1toS5) {
      text = 'Trainingsbereich $prefix${1}–$prefix${5} aktiv\nDrücke Start';
    } else {
      text = 'Du lernst mit ${_modusLabel(srsMode)}\nDrücke Start';
    }

    return _SpeechBubble(text: text);
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          height: 1.4,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
