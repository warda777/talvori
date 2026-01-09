// lib/features/words/ui/widgets/card_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/widgets/timer_bar.dart';

class CardArea extends ConsumerWidget {
  final GlobalKey? cardKey; // ← NEU: für Plasma-Link
  final void Function(double dx)? onDragUpdate; // ← NEU: für Plasma-Link
  final VoidCallback? onDragEnd; // ← NEU: für Plasma-Link
  final VoidCallback? onDragReturn; // ← NEU: für Plasma-Link wieder anzeigen
  final void Function(bool correct)? onSwipeCommit; // ← NEU: für Pulse-Animation

  const CardArea({
    super.key,
    this.cardKey, // ← NEU
    this.onDragUpdate, // ← NEU
    this.onDragEnd, // ← NEU
    this.onDragReturn, // ← NEU
    this.onSwipeCommit, // ← NEU
  });

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
          key: cardKey,
          frontText: word,
          backText: translation,
          level: current?.level,
          showTranslation: s.showTranslation,
          gesturesEnabled: !isPaused,
          footer: TimerBar(s: s),
          onSwipe: (correct) async {
            onSwipeCommit?.call(correct); // Pulse-Animation triggern
            if (correct) {
              c.onSwipeRight();
            } else {
              c.onSwipeLeft();
            }
          },
          onFlip: () => c.toggleFlip(),
          onDragUpdate: onDragUpdate, // ← NEU
          onDragEnd: onDragEnd, // ← NEU
          onDragReturn: onDragReturn, // ← NEU
        ),
      ),
    );
  }
}
