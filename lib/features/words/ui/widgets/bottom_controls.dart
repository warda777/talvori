// lib/features/words/ui/widgets/bottom_controls.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'package:talvori/core/ui/widgets/round_icon.dart';
import 'package:talvori/features/words/ui/widgets/play_pause_button.dart';
import 'package:talvori/features/words/ui/widgets/cancel_timer_button.dart';
import 'package:talvori/features/words/ui/widgets/reset_button.dart';
import 'package:talvori/features/words/ui/widgets/menu_sheet.dart';

class BottomControls extends ConsumerWidget {
  const BottomControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            isPlaying: isPlaying,
            onTap: () {
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
          s.timerActive
              ? CancelTimerButton(onTap: c.cancelTimer)
              : ResetButton(onResetComplete: c.performReset),
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
