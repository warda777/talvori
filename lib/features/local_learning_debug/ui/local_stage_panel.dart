import 'package:flutter/material.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

class LocalStagePanel extends StatelessWidget {
  const LocalStagePanel({super.key, this.currentStage});

  final SrsStage? currentStage;

  static const _stages = [
    SrsStage.s0,
    SrsStage.s1,
    SrsStage.s2,
    SrsStage.s3,
    SrsStage.s4,
    SrsStage.s5,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: SizedBox(
        height: 78,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SizedBox(
              width: 44,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  'Stufen',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.62),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            for (final stage in _stages) ...[
              Expanded(
                child: _LocalStageSwitch(
                  label: stage.name.toUpperCase(),
                  isActive: stage == currentStage,
                  isNewStage: stage == SrsStage.s0,
                ),
              ),
              if (stage != _stages.last)
                const SizedBox(width: WordsLayout.switchGap / 2),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocalStageSwitch extends StatelessWidget {
  const _LocalStageSwitch({
    required this.label,
    required this.isActive,
    required this.isNewStage,
  });

  final String label;
  final bool isActive;
  final bool isNewStage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outerColor = isNewStage
        ? const Color(0xFFA05260)
        : const Color(0xFFE4B866);
    final innerColor = isActive
        ? const Color(0xFF542C78)
        : const Color(0xFF1A1A1A);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: isActive ? 74 : 66,
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
      decoration: BoxDecoration(
        color: outerColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? Colors.white.withValues(alpha: 0.82)
              : Colors.white.withValues(alpha: 0.18),
          width: isActive ? 1.4 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: outerColor.withValues(alpha: 0.34),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: innerColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
