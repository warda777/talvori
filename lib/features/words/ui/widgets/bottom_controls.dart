// lib/features/words/ui/widgets/bottom_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/tooltip_settings_provider.dart';
import 'package:talvori/features/words/ui/widgets/contextual_tooltip.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'package:talvori/core/ui/widgets/round_icon.dart';
import 'package:talvori/features/words/ui/widgets/play_pause_button.dart';
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

    return Padding(
      padding: WordsUIConstants.bottomControlsPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RoundIcon(
            icon: Icons.grid_view_rounded,
            onTap: () => _showMenu(context),
          ),
          const SizedBox(width: WordsUIConstants.largeSpacing),
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
          const SizedBox(width: WordsUIConstants.largeSpacing),
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
