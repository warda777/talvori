import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

class LearningModeSelector extends ConsumerWidget {
  const LearningModeSelector({super.key, this.spacing = 12});

  final double spacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(srsModeControllerProvider).mode;

    return LearningModeSelectorView(
      selectedMode: selectedMode,
      onModeSelected: ref.read(srsModeControllerProvider.notifier).setMode,
      spacing: spacing,
    );
  }
}

class LearningModeSelectorView extends StatelessWidget {
  const LearningModeSelectorView({
    super.key,
    required this.selectedMode,
    required this.onModeSelected,
    this.spacing = 12,
  });

  final SrsSystem selectedMode;
  final ValueChanged<SrsSystem> onModeSelected;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LearningModeButton(
          label: 'Zeitplan',
          selected: selectedMode == SrsSystem.time,
          onTap: () => onModeSelected(SrsSystem.time),
        ),
        SizedBox(width: spacing),
        _LearningModeButton(
          label: 'Limitlos',
          selected: selectedMode == SrsSystem.adaptive,
          onTap: () => onModeSelected(SrsSystem.adaptive),
        ),
        SizedBox(width: spacing),
        _LearningModeButton(
          label: 'Kombiniert',
          selected: selectedMode == SrsSystem.hybrid,
          onTap: () => onModeSelected(SrsSystem.hybrid),
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
      color: selected ? Colors.white : Colors.white.withValues(alpha: 0.58),
      fontWeight: FontWeight.w700,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2D2C2E) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? Colors.white : const Color(0xFF2D2C2E),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.26),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Text(label, style: textStyle),
      ),
    );
  }
}
