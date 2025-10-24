// lib/features/words/ui/widgets/card_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/widgets/timer_bar.dart';

class CardArea extends ConsumerWidget {
  const CardArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentWordProvider);
    final isPaused = ref.watch(isPausedProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);


    final word = current?.text ?? (s.shuffledWordIds.isEmpty ? 'Keine Wörter\nverfügbar' : '—');
    final translation = current?.translation ?? '';

    return Expanded(
      child: Center(
        child: SwipeableWordCard(
          frontText: word,
          backText: translation,
          level: current?.level,
          showTranslation: s.showTranslation,
          gesturesEnabled: !isPaused,
          footer: TimerBar(s: s),
          onSwipe: (correct) async {
            if (correct) {
              c.onSwipeRight();
            } else {
              c.onSwipeLeft();
            }
          },
          onFlip: () => c.toggleFlip(),
        ),
      ),
    );
  }
}
