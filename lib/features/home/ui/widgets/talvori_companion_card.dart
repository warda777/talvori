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

class TalvoriCompanionCard extends StatefulWidget {
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
  static const _messageFontSize = 17.0;
  static const _messageLineHeight = 1.3;
  static const _messageVisibleLines = 5;
  static const _messageMaxHeight =
      _messageFontSize * _messageLineHeight * _messageVisibleLines;

  @override
  State<TalvoriCompanionCard> createState() => _TalvoriCompanionCardState();
}

class _TalvoriCompanionCardState extends State<TalvoriCompanionCard> {
  late final ScrollController _messageScrollController;

  @override
  void initState() {
    super.initState();
    _messageScrollController = ScrollController();
  }

  @override
  void dispose() {
    _messageScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accentForMood(widget.mood);
    final hasQuickActions = widget.quickActions.isNotEmpty;
    final effectiveMascotMood =
        widget.mascotMood ?? _mascotMoodForCompanion(widget.mood);
    final effectiveEmotion =
        widget.emotion ??
        TalvoriMascotAssets.emotionForLegacyMood(effectiveMascotMood);
    final companionDisplayName = TalvoriMascotAssets.companionDisplayNameFor(
      widget.mascotStyle,
    );
    final effectiveTitle =
        widget.title.trim().isEmpty || widget.title == 'Talvori'
        ? companionDisplayName
        : widget.title;
    final effectiveMascotSize = widget.isExpanded
        ? widget.mascotSize
        : widget.mascotSize * widget.compactMascotScale;

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
          final topInset =
              (widget.bubbleVisible
                      ? TalvoriCompanionCard.estimatedBubbleHeight
                      : 0.0)
                  .clamp(
                    0.0,
                    widget.bubbleVisible
                        ? TalvoriCompanionCard.estimatedBubbleHeight
                        : 0.0,
                  )
                  .toDouble();
          final messageStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.88),
            fontSize: TalvoriCompanionCard._messageFontSize,
            height: TalvoriCompanionCard._messageLineHeight,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          );
          final messageViewportHeight = _measureMessageHeight(
            context: context,
            text: widget.message,
            style: messageStyle,
            maxWidth: bubbleWidth - 24,
            maxHeight: TalvoriCompanionCard._messageMaxHeight,
          );

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
                    onTap: widget.onMascotTap,
                    child: SizedBox(
                      width: effectiveMascotSize,
                      height: effectiveMascotSize,
                      child: TalvoriSpiritMascot(
                        assetPath: TalvoriMascotAssets.spiritPathFor(
                          effectiveEmotion,
                          style: widget.mascotStyle,
                        ),
                        isActive:
                            widget.isExpanded ||
                            widget.inputVisible ||
                            widget.isThinking,
                        compactMode: !widget.isExpanded,
                        glowIntensity: widget.isExpanded ? 0.95 : 0.64,
                        semanticLabel:
                            '$companionDisplayName Lerngeist ${effectiveMascotMood.name}',
                      ),
                    ),
                  ),
                ),
                if (widget.bubbleVisible)
                  Positioned(
                    left: bubbleLeft,
                    bottom: bubbleBottom,
                    child: SizedBox(
                      width: bubbleWidth,
                      child: GestureDetector(
                        key: const Key('talvori-companion-bubble'),
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onBubbleTap,
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
                                  if (widget.isThinking)
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
                                        if (widget.showChatHint) ...[
                                          _CompanionChatHint(
                                            accent: accent,
                                            onTap: widget.onBubbleTap,
                                          ),
                                          const SizedBox(width: 7),
                                        ],
                                        InkWell(
                                          key: const Key(
                                            'talvori-companion-chat-icon',
                                          ),
                                          customBorder: const CircleBorder(),
                                          onTap: widget.onBubbleTap,
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
                              SizedBox(
                                height: messageViewportHeight,
                                child: RawScrollbar(
                                  key: const Key(
                                    'talvori-companion-message-scrollbar',
                                  ),
                                  controller: _messageScrollController,
                                  thumbVisibility: false,
                                  interactive: false,
                                  radius: const Radius.circular(999),
                                  thickness: 3,
                                  thumbColor: Colors.white.withValues(
                                    alpha: 0.38,
                                  ),
                                  trackVisibility: false,
                                  child: SingleChildScrollView(
                                    key: const Key(
                                      'talvori-companion-message-scroll',
                                    ),
                                    controller: _messageScrollController,
                                    physics: const BouncingScrollPhysics(),
                                    child: Text(
                                      widget.message,
                                      style: messageStyle,
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
                                    for (final action in widget.quickActions)
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

  static double _measureMessageHeight({
    required BuildContext context,
    required String text,
    required TextStyle? style,
    required double maxWidth,
    required double maxHeight,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final lineHeight = painter.preferredLineHeight;
    final naturalHeight = painter.height + 1;
    return naturalHeight.clamp(lineHeight, maxHeight).toDouble();
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
