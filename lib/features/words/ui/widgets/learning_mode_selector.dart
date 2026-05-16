import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/level_selection_provider.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

class LearningModeSelector extends ConsumerWidget {
  const LearningModeSelector({super.key, this.spacing = 14});

  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(srsModeControllerProvider).mode;

    return LearningModeSelectorView(
      selectedMode: selectedMode,
      onModeSelected: (mode) {
        ref.read(srsModeControllerProvider.notifier).setMode(mode);
        ref.read(levelSelectionProvider.notifier).state =
            LevelSelectionMode.s0toS5;
        ref.read(selectingSingleProvider.notifier).state = false;
      },
      spacing: spacing,
    );
  }
}

class LearningModeSelectorView extends StatelessWidget {
  const LearningModeSelectorView({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
    this.spacing = 14,
  });

  final SrsSystem selectedMode;
  final ValueChanged<SrsSystem> onModeSelected;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: _LearningModeButton(
            label: 'Zeitplan',
            selected: selectedMode == SrsSystem.time,
            onTap: () => onModeSelected(SrsSystem.time),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _LearningModeButton(
            label: 'Limitlos',
            selected: selectedMode == SrsSystem.adaptive,
            onTap: () => onModeSelected(SrsSystem.adaptive),
          ),
        ),
        SizedBox(width: spacing),
        Expanded(
          child: _LearningModeButton(
            label: 'Kombiniert',
            selected: selectedMode == SrsSystem.hybrid,
            onTap: () => onModeSelected(SrsSystem.hybrid),
          ),
        ),
      ],
    );
  }
}

class _LearningModeButton extends StatelessWidget {
  const _LearningModeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.78),
      fontWeight: FontWeight.w800,
      letterSpacing: 0.1,
      shadows: selected
          ? [
              Shadow(
                color: const Color(0xFFF5BFCB).withValues(alpha: 0.38),
                blurRadius: 12,
              ),
            ]
          : null,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 38,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: selected
                  ? const [Color(0xFF202129), Color(0xFF050505)]
                  : const [Color(0xFF151519), Color(0xFF030303)],
            ),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: selected
                  ? const Color(0xFFF5BFCB)
                  : const Color(0xFFB36BFF),
              width: selected ? 1.7 : 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFF5BFCB,
                ).withValues(alpha: selected ? 0.34 : 0.14),
                blurRadius: selected ? 16 : 10,
                spreadRadius: selected ? 0.8 : 0,
              ),
              BoxShadow(
                color: const Color(
                  0xFFB36BFF,
                ).withValues(alpha: selected ? 0.36 : 0.16),
                blurRadius: selected ? 20 : 12,
                spreadRadius: selected ? 0.5 : 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: selected
                    ? Colors.white.withValues(alpha: 0.42)
                    : const Color(0xFFF5BFCB).withValues(alpha: 0.22),
                width: 0.8,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(label, style: textStyle, maxLines: 1),
            ),
          ),
        ),
      ),
    );
  }
}
