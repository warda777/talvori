import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

class LocalLearnModeHeader extends StatelessWidget {
  const LocalLearnModeHeader({
    super.key,
    required this.categoryId,
    this.title,
    this.modeLabel,
  });

  final String categoryId;
  final String? title;
  final String? modeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<WordsColors>();
    final backgroundColor = colors?.surfaceBg ?? theme.colorScheme.surface;
    final foregroundColor = theme.colorScheme.onSurface;
    final displayTitle = title ?? categoryId;

    return Container(
      width: double.infinity,
      padding: WordsLayout.topPadding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 72),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.4,
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (modeLabel != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      modeLabel!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: foregroundColor.withValues(alpha: 0.68),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
