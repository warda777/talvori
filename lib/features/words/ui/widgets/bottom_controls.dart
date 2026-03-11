// lib/features/words/ui/widgets/bottom_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/tooltip_settings_provider.dart';
import 'package:talvori/features/words/ui/widgets/contextual_tooltip.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'package:talvori/core/ui/widgets/round_icon.dart';
import 'package:talvori/features/words/ui/widgets/play_pause_button.dart';
import 'package:talvori/features/words/ui/widgets/micro_animations.dart';
import 'package:talvori/features/words/ui/widgets/cancel_timer_button.dart';
import 'package:talvori/features/words/ui/widgets/reset_button.dart';
import 'package:talvori/features/words/ui/widgets/menu_sheet.dart';

class BottomControls extends ConsumerStatefulWidget {
  const BottomControls({super.key});

  @override
  ConsumerState<BottomControls> createState() => _BottomControlsState();
}

class _BottomControlsState extends ConsumerState<BottomControls> {
  final _resetKey = GlobalKey();
  final _playKey = GlobalKey();

  void _maybeShowResetTooltip() {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenResetTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Lernfortschritt zurücksetzen.',
        line2: 'Durch Gedrückthalten aktivieren.',
        targetKey: _resetKey,
      );
      ref.read(hasSeenResetTooltipProvider.notifier).markSeen();
    }
  }

  void _maybeShowPlayTooltip() {
    final showAlways = ref.read(showTooltipsAlwaysProvider);
    final hasSeen = ref.read(hasSeenPlayTooltipProvider);
    if (!showAlways && hasSeen) return;
    if (mounted) {
      ContextualTooltip.show(
        context: context,
        line1: 'Zeitspiel aktivieren.',
        line2: '',
        targetKey: _playKey,
      );
      ref.read(hasSeenPlayTooltipProvider.notifier).markSeen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = ref.watch(isPlayingProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);

    final showRestart = s.categoryMastered && s.categoryMasteredRestartReady;
    final spacing = (s.showFinalStartButton || showRestart) ? 40.0 : WordsUIConstants.largeSpacing;
    return Padding(
      padding: WordsUIConstants.bottomControlsPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundIcon(
            icon: Icons.grid_view_rounded,
            onTap: () => _showMenu(context),
          ),
          SizedBox(width: spacing),
          if (showRestart)
            _RestartButton(onTap: () async => await c.resetAdaptiveCategory())
          else if (s.showFinalStartButton)
            _FinalRoundButton(
              onTap: () => c.startFinalPass(),
            )
          else
            PlayPauseButton(
              tooltipKey: _playKey,
              isPlaying: isPlaying,
              onTap: () {
                _maybeShowPlayTooltip();
                if (!s.timerActive) {
                  c.startTimer();
                } else {
                  if (s.running) {
                    c.pauseTimer();
                  } else {
                    c.resumeTimer();
                  }
                }
              },
            ),
          SizedBox(width: spacing),
          // ✅ Reset-Button immer anzeigen, wenn Timer nicht aktiv
          if (s.timerActive)
            CancelTimerButton(onTap: c.cancelTimer)
          else
            ResetButton(
              tooltipKey: _resetKey,
              onTap: _maybeShowResetTooltip,
              onResetComplete: c.performReset,
            ),
        ],
      ),
    );
  }

  void _showMenu(BuildContext context) {
    showWordsMenuSheet(context, items: [
      MenuItemData(Icons.auto_awesome, 'ChatGPT', () {}),
      MenuItemData(Icons.translate_rounded, 'DeepL', () {}),
      MenuItemData(Icons.favorite_border, 'Favorit', () {}),
      MenuItemData(Icons.note_alt_outlined, 'Notizen', () {}),
      MenuItemData(Icons.settings_rounded, 'Einstellungen', () {}),
    ]);
  }
}

class _FinalRoundButton extends StatelessWidget {
  final VoidCallback onTap;

  const _FinalRoundButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const buttonW = 138.0;
    const buttonH = 48.0;

    return FinalRoundButtonPulse(
      onPressed: onTap,
      child: Container(
        width: buttonW,
        height: buttonH,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFF4CAF50),
            width: 1.5,
          ),
        ),
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2D2D2F),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide.none,
            ),
          ),
          onPressed: onTap,
          child: const Text(
            'Final\u00A0Round',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}

class _RestartButton extends StatelessWidget {
  final VoidCallback onTap;

  const _RestartButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const buttonW = 138.0;
    const buttonH = 48.0;

    return SizedBox(
      width: buttonW,
      height: buttonH,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2D2D2F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        onPressed: onTap,
        child: const Text(
          'Neue Runde',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
