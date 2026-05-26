import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum TalvoriCompanionMood { neutral, happy, streak, tired, proud }

class TalvoriCompanionCard extends StatelessWidget {
  const TalvoriCompanionCard({
    super.key,
    this.mood = TalvoriCompanionMood.neutral,
  });

  final TalvoriCompanionMood mood;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForMood(mood);

    return Semantics(
      label: 'Talvori Companion ${mood.name}',
      child: Container(
        key: const Key('talvori-companion-card'),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF101821).withValues(alpha: 0.9),
              const Color(0xFF060A10).withValues(alpha: 0.96),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.18),
              blurRadius: 26,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.14),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.34),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/icons/fireball_black.svg',
                width: 44,
                height: 44,
                colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Talvori',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _subtitleForMood(mood),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.72),
                      height: 1.25,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _accentForMood(TalvoriCompanionMood mood) {
    return switch (mood) {
      TalvoriCompanionMood.neutral => const Color(0xFF9FCED0),
      TalvoriCompanionMood.happy => const Color(0xFF76E0A7),
      TalvoriCompanionMood.streak => const Color(0xFFFFC95C),
      TalvoriCompanionMood.tired => const Color(0xFF92A3FF),
      TalvoriCompanionMood.proud => const Color(0xFFFF8BB7),
    };
  }

  static String _subtitleForMood(TalvoriCompanionMood mood) {
    return switch (mood) {
      TalvoriCompanionMood.neutral => 'Bereit für dein nächstes Wort.',
      TalvoriCompanionMood.happy => 'Stark, das sitzt.',
      TalvoriCompanionMood.streak => 'Deine Serie wächst.',
      TalvoriCompanionMood.tired => 'Kurz durchatmen, dann weiter.',
      TalvoriCompanionMood.proud => 'Das war sauber gelöst.',
    };
  }
}
