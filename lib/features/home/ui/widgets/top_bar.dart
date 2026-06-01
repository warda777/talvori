import 'package:flutter/material.dart';

import 'package:talvori/features/common/widgets/fireball_bounce_animation.dart';
import 'package:talvori/features/home/ui/widgets/glitch_disappear_effect.dart';
import 'package:talvori/features/home/ui/widgets/progress_pill.dart';
import 'package:talvori/features/home/ui/widgets/tap_flash.dart';

class HomeTopBar extends StatefulWidget {
  const HomeTopBar({
    super.key,
    required this.onAllWords,
    required this.onRewards,
    required this.buttonKey,
    this.onProgressTap,
    this.selected = 1,
    this.max = 5,
    this.showProgress = true,
    this.progressPillKey,
    this.counterKey,
    this.crownButtonKey,
    this.fireballKey,
    this.onProgressAnimationStart,
    this.onProgressAnimationComplete,
  });

  final VoidCallback onAllWords;
  final VoidCallback onRewards;
  final VoidCallback? onProgressTap;
  final int selected;
  final int max;
  final bool showProgress;
  final GlobalKey? progressPillKey;
  final GlobalKey? counterKey;
  final GlobalKey? crownButtonKey;
  final GlobalKey<FireballBounceAnimationState>? fireballKey;
  final GlobalKey buttonKey;
  final VoidCallback? onProgressAnimationStart;
  final VoidCallback? onProgressAnimationComplete;

  @override
  State<HomeTopBar> createState() => _HomeTopBarState();
}

class _HomeTopBarState extends State<HomeTopBar> {
  bool _glitchEffectActive = false;

  Widget _buildProgressPill() {
    final useKey = !_glitchEffectActive;
    final pill = ProgressPill(
      key: useKey ? widget.progressPillKey : null,
      counterKey: useKey ? widget.counterKey : null,
      selected: widget.selected,
      max: widget.max,
      barWidth: 54,
      onAnimationStart: widget.onProgressAnimationStart,
      onAnimationComplete: () {
        widget.onProgressAnimationComplete?.call();
        if (widget.selected < widget.max || !mounted) return;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          setState(() => _glitchEffectActive = true);
        });
      },
    );

    final tappablePill = widget.onProgressTap == null
        ? pill
        : TapFlash(
            color: const Color(0xFFFFC96B),
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(20),
            maxOpacity: 0.56,
            blur: 30,
            spread: -4,
            duration: const Duration(milliseconds: 220),
            onTapAfter: widget.onProgressTap,
            child: pill,
          );

    if (!_glitchEffectActive) return tappablePill;

    return GlitchDisappearEffect(
      duration: const Duration(milliseconds: 800),
      onComplete: () {
        if (!mounted) return;
        setState(() => _glitchEffectActive = false);
      },
      child: tappablePill,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 34,
      child: Align(
        alignment: Alignment.centerLeft,
        child: (widget.showProgress || _glitchEffectActive)
            ? _buildProgressPill()
            : const SizedBox.shrink(),
      ),
    );
  }
}
