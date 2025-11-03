import 'package:flutter/material.dart';
// vorhandenes Badge wiederverwenden
import '../../../words/ui/widgets/mini_badge.dart' as w;

class ProfilePremiumCard extends StatelessWidget {
  final bool isPremium;
  final VoidCallback? onTap;

  const ProfilePremiumCard({
    super.key,
    required this.isPremium,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final c = t.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(isPremium ? 'Premium aktiv' : 'Go Premium',
                      style: t.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(
                    isPremium
                        ? 'Alle Kategorien, Wörter & Themes freigeschaltet.'
                        : 'Access all categories, words, themes, and remove ads!',
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (!isPremium) const w.MiniBadge(label: 'Upgrade'),
          ],
        ),
      ),
    );
  }
}
