import 'package:flutter/material.dart';
import '../../../../ui/common/mini_badge.dart' as w;

class VocabPromoCard extends StatelessWidget {
  final VoidCallback? onStart;

  const VocabPromoCard({super.key, this.onStart});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Textblock
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Try Game shuffle', style: t.textTheme.titleMedium),
                const SizedBox(height: 4),
                Text('A mix of all games', style: t.textTheme.bodySmall),
                const SizedBox(height: 10),
                _StartPill(onTap: onStart),
              ],
            ),
          ),
          // optional kleines Badge rechts
          const w.MiniBadge(label: 'Start'),
        ],
      ),
    );
  }
}

class _StartPill extends StatelessWidget {
  final VoidCallback? onTap;
  const _StartPill({this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = t.colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: c.surface.withOpacity(0.6),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: c.outlineVariant),
        ),
        child: Text('Start', style: t.textTheme.labelMedium),
      ),
    );
  }
}
