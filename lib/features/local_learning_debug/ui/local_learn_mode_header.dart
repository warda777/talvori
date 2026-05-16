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
    final backgroundColor = colors?.surfaceBg ?? const Color(0xFF08080A);
    final displayTitle = title ?? categoryId;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: WordsLayout.wheelHeight,
          child: Row(
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.school_rounded, color: Color(0xFFB1CCFE)),
              ),
              Expanded(
                child: Container(
                  height: 54,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151518),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFB1CCFE).withValues(alpha: 0.12),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        displayTitle,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.0,
                        ),
                      ),
                      if (modeLabel != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          modeLabel!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.66),
                            fontWeight: FontWeight.w700,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFB1CCFE).withValues(alpha: 0.45),
                  ),
                ),
                child: const Text(
                  'L',
                  style: TextStyle(
                    color: Color(0xFFB1CCFE),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
