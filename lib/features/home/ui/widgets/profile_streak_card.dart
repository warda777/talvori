import 'package:flutter/material.dart';
import '../../../words/ui/widgets/progress_ring.dart' as w;

class ProfileStreakCard extends StatelessWidget {
  final List<bool> streak;

  const ProfileStreakCard({super.key, required this.streak});

  static const _days = ['Sa', 'Su', 'Mo', 'Tu', 'We', 'Th', 'Fr'];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Your streak', style: t.textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final active = i < streak.length && streak[i];
                    return Column(
                      children: [
                        w.ProgressRing(
                          size: 18,
                          thickness: 2.5,
                          percent: active ? 1.0 : 0.0,
                        ),
                        const SizedBox(height: 6),
                        Text(_days[i], style: t.textTheme.labelSmall),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  // später: share action oder Detailansicht
                },
                icon: const Icon(Icons.ios_share_rounded, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
