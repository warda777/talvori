// lib/features/words/ui/widgets/card_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/category_design_preferences.dart';
import 'package:talvori/features/words/application/primary_language_provider.dart';
import 'package:talvori/features/words/ui/cards/swipeable_word_card.dart';
import 'package:talvori/features/words/ui/widgets/timer_bar.dart';

class CardArea extends ConsumerWidget {
  final GlobalKey? cardKey; // ← NEU: für Plasma-Link
  final void Function(double dx)? onDragUpdate; // ← NEU: für Plasma-Link
  final VoidCallback? onDragEnd; // ← NEU: für Plasma-Link
  final VoidCallback? onDragReturn; // ← NEU: für Plasma-Link wieder anzeigen
  final void Function(bool correct)?
  onSwipeCommit; // ← NEU: für Pulse-Animation
  final VoidCallback?
  onSettingsTap; // Glow-Einstellungen öffnen (Button oben links auf der Karte)
  final GlobalKey? passCountButtonKey; // Für Sparkle bei Stage-Up
  final void Function(BuildContext context, bool correct)?
  onSwipeWillStart; // Vor Karten-Animation
  final CategoryDesignPreferences? designPreferences;

  const CardArea({
    super.key,
    this.cardKey, // ← NEU
    this.onDragUpdate, // ← NEU
    this.onDragEnd, // ← NEU
    this.onDragReturn, // ← NEU
    this.onSwipeCommit, // ← NEU
    this.onSettingsTap,
    this.passCountButtonKey,
    this.onSwipeWillStart,
    this.designPreferences,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(currentWordProvider);
    final isPaused = ref.watch(isPausedProvider);
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);
    final primaryLanguage = ref.watch(primaryLanguageProvider);
    final design = designPreferences ?? const CategoryDesignPreferences();
    final cardStyle = design.overrides[CategoryDesignElement.learnCard];
    final cardBorderStyle =
        design.overrides[CategoryDesignElement.learnCardBorder];
    final cardGlowStyle =
        design.overrides[CategoryDesignElement.learnCardGlow] ??
        cardBorderStyle;
    final cardGlowAccent =
        cardGlowStyle?.color ??
        CategoryDesignDefaults.accentFor(CategoryDesignElement.learnCardGlow);
    final wordTextAccent = design
        .styleFor(CategoryDesignElement.learnWordText)
        .color;
    final audioAccent = design
        .styleFor(CategoryDesignElement.audioButton)
        .color;
    final audioFill = design
        .styleFor(CategoryDesignElement.audioButtonFill)
        .color;
    final audioIcon = design
        .styleFor(CategoryDesignElement.audioButtonIcon)
        .color;
    final levelBadgeAccent = design
        .styleFor(CategoryDesignElement.levelBadge)
        .color;
    final levelBadgeFill = design
        .styleFor(CategoryDesignElement.levelBadgeFill)
        .color;
    final levelBadgeText = design
        .styleFor(CategoryDesignElement.levelBadgeText)
        .color;
    final pulseEnabled =
        cardGlowStyle == null ||
        cardGlowStyle.pulse != CategoryDesignPulseStrength.off;

    final isEmpty = s.shuffledWordIds.isEmpty;
    final categoryMastered = s.categoryMastered;
    // Während des Ladens nichts anzeigen – sonst wirkt es wie ein Fehler
    final showEmptyError =
        isEmpty && !s.loading && !s.showFinalStartButton && !categoryMastered;
    final hint = showEmptyError
        ? '\n\n(${s.emptyQueueHint ?? 'catId=${s.categoryId}'})'
        : '';
    final word =
        current?.text ??
        (isEmpty
            ? (categoryMastered
                  ? 'Herzlichen Glückwunsch, du hast diese Kategorie erfolgreich absolviert!'
                  : (s.showFinalStartButton
                        ? 'Alle Wörter sind in Stufe 5. Starte die Final\u00A0Round, um sie zu meistern.'
                        : (showEmptyError
                              ? 'Keine Wörter verfügbar$hint'
                              : '—')))
            : '—');
    final translation =
        current?.translation ??
        (isEmpty && (s.showFinalStartButton || categoryMastered)
            ? (categoryMastered
                  ? 'Congratulations, you have successfully completed this category!'
                  : 'All words reached Stage 5. Press Final\u00A0Round to master them.')
            : '');

    // Hauptsprache bestimmt, welche Sprache auf der Vorderseite ist
    // Final-Round-Hinweis: immer Deutsch vorne, Englisch hinten
    final String frontText;
    final String backText;
    if (isEmpty && (s.showFinalStartButton || categoryMastered)) {
      frontText = word; // Deutsch
      backText = translation; // Englisch
    } else {
      frontText = primaryLanguage == PrimaryLanguage.english
          ? word
          : translation;
      backText = primaryLanguage == PrimaryLanguage.english
          ? translation
          : word;
    }

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
          passCount: s.finalPassActive && (current?.srsStage ?? 0) == 5
              ? (current?.passCount ?? 0).clamp(0, 2)
              : current?.passCount,
          showTranslation: s.showTranslation,
          gesturesEnabled:
              !isPaused &&
              !s.isSubmitting &&
              !s.showFinalStartButton &&
              !categoryMastered,
          footer: TimerBar(s: s),
          onSettingsTap: onSettingsTap,
          cardBackgroundColor: cardStyle?.color?.withValues(alpha: 0.18),
          cardBorderColor: cardBorderStyle?.color,
          cardGlowColor: cardGlowStyle?.glow == CategoryDesignGlowStrength.off
              ? Colors.transparent
              : cardGlowStyle == null
              ? null
              : cardGlowAccent,
          cardGlowIntensity: CategoryDesignDefaults.glowIntensityFor(
            cardGlowStyle?.glow ?? CategoryDesignGlowStrength.normal,
          ),
          cardPulseSpeed: CategoryDesignDefaults.pulseSpeedFor(
            cardGlowStyle?.pulse ?? CategoryDesignPulseStrength.normal,
          ),
          wordTextColor: wordTextAccent,
          audioAccentColor: audioAccent,
          audioFillColor: audioFill,
          audioIconColor: audioIcon,
          levelBadgeColor: levelBadgeAccent,
          levelBadgeFillColor: levelBadgeFill,
          levelBadgeTextColor: levelBadgeText,
          pulseEnabled: pulseEnabled,
          passCountButtonKey: passCountButtonKey,
          onSwipeWillStart: onSwipeWillStart,
          onSwipe: (correct) async {
            final paused = s.timerPaused;
            final active = s.timerActive;
            final running = s.running;
            if (correct) {
              debugPrint(
                '✅ UI SwipeRight angekommen | paused=$paused active=$active running=$running',
              );
              onSwipeCommit?.call(true);
            } else {
              debugPrint(
                '✅ UI SwipeLeft angekommen | paused=$paused active=$active running=$running',
              );
              onSwipeCommit?.call(false);
            }
            c.setShowTranslation(false);
          },
          onFlip: () => c.toggleFlip(),
          onDragUpdate: onDragUpdate,
          onDragEnd: onDragEnd,
          onDragReturn: onDragReturn,
        ),
      ),
    );
  }
}
