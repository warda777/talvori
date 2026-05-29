import 'package:flutter/material.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/home/ui/widgets/talvori_spirit_mascot.dart';

enum TalvoriCompanionMood { neutral, happy, streak, tired, proud }

class TalvoriCompanionCard extends StatelessWidget {
  const TalvoriCompanionCard({
    super.key,
    this.mood = TalvoriCompanionMood.neutral,
    this.mascotSize = 156,
    this.mascotMood,
    this.emotion,
    this.mascotStyle = TalvoriMascotStyle.female,
    this.title = 'Talvori',
    this.message = 'Bereit für dein nächstes Wort?',
    this.bubbleVisible = true,
    this.isExpanded = true,
    this.compactMascotScale = 0.62,
    this.inputVisible = false,
    this.isThinking = false,
    this.messageMaxLines = 3,
    this.onMascotTap,
    this.onBubbleTap,
  });

  final TalvoriCompanionMood mood;
  final double mascotSize;
  final TalvoriMascotMood? mascotMood;
  final TaliEmotion? emotion;
  final TalvoriMascotStyle mascotStyle;
  final String title;
  final String message;
  final bool bubbleVisible;
  final bool isExpanded;
  final double compactMascotScale;
  final bool inputVisible;
  final bool isThinking;
  final int messageMaxLines;
  final VoidCallback? onMascotTap;
  final VoidCallback? onBubbleTap;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForMood(mood);
    final effectiveMascotMood = mascotMood ?? _mascotMoodForCompanion(mood);
    final effectiveEmotion =
        emotion ??
        TalvoriMascotAssets.emotionForLegacyMood(effectiveMascotMood);
    final effectiveMascotSize = isExpanded
        ? mascotSize
        : mascotSize * compactMascotScale;

    return Semantics(
      label: 'Tali ${effectiveMascotMood.name}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bubbleLeft = effectiveMascotSize * 0.68;
          final bubbleBottom = effectiveMascotSize * 0.82;
          final bubbleWidth = (constraints.maxWidth - bubbleLeft - 4)
              .clamp(160.0, 260.0)
              .toDouble();
          final topInset = bubbleVisible ? 88.0 : 0.0;

          return SizedBox(
            key: const Key('talvori-companion-card'),
            width: double.infinity,
            height: topInset + effectiveMascotSize + 18,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onMascotTap,
                    child: SizedBox(
                      width: effectiveMascotSize,
                      height: effectiveMascotSize,
                      child: TalvoriSpiritMascot(
                        assetPath: TalvoriMascotAssets.spiritPathFor(
                          effectiveEmotion,
                          style: mascotStyle,
                        ),
                        isActive: isExpanded || inputVisible || isThinking,
                        compactMode: !isExpanded,
                        glowIntensity: isExpanded ? 0.95 : 0.64,
                        semanticLabel:
                            'Talvori Lerngeist ${effectiveMascotMood.name}',
                      ),
                    ),
                  ),
                ),
                if (bubbleVisible)
                  Positioned(
                    left: bubbleLeft,
                    bottom: bubbleBottom,
                    child: SizedBox(
                      width: bubbleWidth,
                      child: GestureDetector(
                        key: const Key('talvori-companion-bubble'),
                        behavior: HitTestBehavior.opaque,
                        onTap: onBubbleTap,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF07101A,
                            ).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.34),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.34),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                              BoxShadow(
                                color: accent.withValues(alpha: 0.13),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: accent,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0,
                                          ),
                                    ),
                                  ),
                                  if (isThinking)
                                    SizedBox(
                                      key: const Key(
                                        'talvori-companion-thinking-indicator',
                                      ),
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: accent,
                                      ),
                                    )
                                  else
                                    Tooltip(
                                      message: 'Chat öffnen',
                                      key: const Key(
                                        'talvori-companion-chat-icon',
                                      ),
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap: onBubbleTap,
                                        child: Container(
                                          width: 30,
                                          height: 30,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: accent.withValues(
                                              alpha: 0.16,
                                            ),
                                            border: Border.all(
                                              color: accent.withValues(
                                                alpha: 0.55,
                                              ),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: accent.withValues(
                                                  alpha: 0.2,
                                                ),
                                                blurRadius: 12,
                                              ),
                                            ],
                                          ),
                                          child: Icon(
                                            Icons.chat_bubble_outline_rounded,
                                            size: 17,
                                            color: accent,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                message,
                                maxLines: messageMaxLines,
                                overflow: TextOverflow.clip,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      height: 1.18,
                                      letterSpacing: 0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
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

  static TalvoriMascotMood _mascotMoodForCompanion(TalvoriCompanionMood mood) {
    return switch (mood) {
      TalvoriCompanionMood.neutral => TalvoriMascotMood.greeting,
      TalvoriCompanionMood.happy => TalvoriMascotMood.happy,
      TalvoriCompanionMood.streak => TalvoriMascotMood.proud,
      TalvoriCompanionMood.tired => TalvoriMascotMood.tired,
      TalvoriCompanionMood.proud => TalvoriMascotMood.proud,
    };
  }
}
