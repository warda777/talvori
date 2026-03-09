// lib/features/words/ui/widgets/card_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/primary_language_provider.dart';
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
    final primaryLanguage = ref.watch(primaryLanguageProvider);

    final isEmpty = s.shuffledWordIds.isEmpty;
    final hint = isEmpty
        ? '\n\n(${s.emptyQueueHint ?? 'catId=${s.categoryId}'})'
        : '';
    final word = current?.text ?? (isEmpty ? 'Keine Wörter verfügbar$hint' : '—');
    final translation = current?.translation ?? '';

    // Hauptsprache bestimmt, welche Sprache auf der Vorderseite ist
    final frontText = primaryLanguage == PrimaryLanguage.english ? word : translation;
    final backText = primaryLanguage == PrimaryLanguage.english ? translation : word;
    
    // showTranslation: true = zeigt Rückseite (Nebensprache), false = zeigt Vorderseite (Hauptsprache)
    // Wenn Hauptsprache Deutsch ist und showTranslation true, dann zeigt es Englisch (Rückseite)
    // Wenn Hauptsprache Englisch ist und showTranslation true, dann zeigt es Deutsch (Rückseite)
    // Die Logik bleibt gleich, nur frontText/backText werden getauscht

    return Expanded(
      child: Center(
        child: SwipeableWordCard(
          key: cardKey,
          frontText: frontText,
          backText: backText,
          level: current?.level,
          srsStage: current?.srsStage,
          streak: current?.streak,
          showTranslation: s.showTranslation,
          gesturesEnabled: !isPaused && !s.isSubmitting,
          footer: TimerBar(s: s),
          onSwipe: (correct) async {
            final paused = s.timerPaused;
            final active = s.timerActive;
            final running = s.running;
            
            if (correct) {
              debugPrint('✅ UI SwipeRight angekommen | paused=$paused active=$active running=$running');
              onSwipeCommit?.call(true);
            } else {
              debugPrint('✅ UI SwipeLeft angekommen | paused=$paused active=$active running=$running');
              onSwipeCommit?.call(false);
            }
            
            // Nach dem Wischen: Zurück zur Hauptsprache (showTranslation = false)
            c.setShowTranslation(false);
            // Controller wird jetzt in _handleSwipeCommit() im Screen aufgerufen, nicht hier!
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
