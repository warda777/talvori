import 'package:flutter/material.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/home/ui/widgets/talvori_spirit_mascot.dart';

enum TalvoriCompanionMood { neutral, happy, streak, tired, proud }

class TalvoriCompanionQuickAction {
  const TalvoriCompanionQuickAction({
    required this.label,
    required this.onTap,
    this.icon,
    this.key,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final Key? key;
}

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
    this.showChatHint = false,
    this.quickActions = const [],
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
  final bool showChatHint;
  final List<TalvoriCompanionQuickAction> quickActions;
  final VoidCallback? onMascotTap;
  final VoidCallback? onBubbleTap;

  static const estimatedBubbleHeight = 292.0;
  static const _messageMaxHeight = 196.0;
  static const _messageMaxHeightWithQuickActions = 142.0;

  @override
  Widget build(BuildContext context) {
    final accent = _accentForMood(mood);
    final hasQuickActions = quickActions.isNotEmpty;
    final effectiveMascotMood = mascotMood ?? _mascotMoodForCompanion(mood);
    final effectiveEmotion =
        emotion ??
        TalvoriMascotAssets.emotionForLegacyMood(effectiveMascotMood);
    final companionDisplayName = TalvoriMascotAssets.companionDisplayNameFor(
      mascotStyle,
    );
    final effectiveTitle = title.trim().isEmpty || title == 'Talvori'
        ? companionDisplayName
        : title;
    final effectiveMascotSize = isExpanded
        ? mascotSize
        : mascotSize * compactMascotScale;

    return Semantics(
      label: '$companionDisplayName ${effectiveMascotMood.name}',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bubbleWidth = constraints.maxWidth.clamp(160.0, 260.0);
          final bubbleLeft = (effectiveMascotSize * 0.58).clamp(
            20.0,
            (constraints.maxWidth - bubbleWidth).clamp(20.0, 112.0),
          );
          final bubbleBottom = (effectiveMascotSize * 0.98).clamp(
            effectiveMascotSize + 8.0,
            effectiveMascotSize + 24.0,
          );
          final topInset = (bubbleVisible ? estimatedBubbleHeight : 0.0)
              .clamp(0.0, bubbleVisible ? estimatedBubbleHeight : 0.0)
              .toDouble();

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
                            '$companionDisplayName Lerngeist ${effectiveMascotMood.name}',
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
                                      effectiveTitle,
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
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (showChatHint) ...[
                                          _CompanionChatHint(
                                            accent: accent,
                                            onTap: onBubbleTap,
                                          ),
                                          const SizedBox(width: 7),
                                        ],
                                        InkWell(
                                          key: const Key(
                                            'talvori-companion-chat-icon',
                                          ),
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
                                              color: accent.withValues(
                                                alpha: 1,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: hasQuickActions
                                      ? _messageMaxHeightWithQuickActions
                                      : _messageMaxHeight,
                                ),
                                child: SingleChildScrollView(
                                  key: const Key(
                                    'talvori-companion-message-scroll',
                                  ),
                                  physics: const BouncingScrollPhysics(),
                                  child: Text(
                                    message,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Colors.white.withValues(
                                            alpha: 0.82,
                                          ),
                                          height: 1.18,
                                          letterSpacing: 0,
                                        ),
                                  ),
                                ),
                              ),
                              if (hasQuickActions) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final action in quickActions)
                                      _CompanionQuickActionChip(
                                        action: action,
                                        accent: accent,
                                      ),
                                  ],
                                ),
                              ],
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

class _CompanionQuickActionChip extends StatelessWidget {
  const _CompanionQuickActionChip({required this.action, required this.accent});

  final TalvoriCompanionQuickAction action;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: action.key,
      borderRadius: BorderRadius.circular(999),
      onTap: action.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: accent.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (action.icon != null) ...[
              Icon(action.icon, size: 13, color: accent),
              const SizedBox(width: 4),
            ],
            Text(
              action.label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanionChatHint extends StatelessWidget {
  const _CompanionChatHint({required this.accent, this.onTap});

  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Chatten',
      button: true,
      child: GestureDetector(
        key: const Key('home-companion-chat-hint'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent.withValues(alpha: 0.42)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.22),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
              BoxShadow(
                color: accent.withValues(alpha: 0.16),
                blurRadius: 22,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Text(
            'Chatten \u2192',
            maxLines: 1,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFFF4FCFF),
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }
}
