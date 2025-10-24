import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/application.dart';
import '../widgets/widgets.dart';
import '../cards/swipeable_word_card.dart';


// ---- Farben / UI-Konstanten (wie gehabt) ----
const _kCard = Color(0xFF2D2C2C);
const _kStageOuter = Color(0xFFE4B866);
const _kStageInner = Color(0xFF2D2C2C);
const _kStageInnerRed = Color(0xFFA05260);


// ===== Switches Knobs =====
const double kSwitchesOffsetX = 0.0;
const double kSwitchesOffsetY = -12.0;
const double kSwitchGap = 12.0;

class LearnModeScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String title; // z. B. "Money & Shopping"

  const LearnModeScreen({
    super.key,
    required this.categoryId,
    required this.title,
  });

  @override
  ConsumerState<LearnModeScreen> createState() => _LearnModeScreenState();
}

class _LearnModeScreenState extends ConsumerState<LearnModeScreen> {
  // Controller (Business-Logik)
  late final LearnModeController _controller;

  // Nur UI: Audio
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = ref.read(learnModeControllerProvider.notifier);

    // Init nach 1. Frame (damit Provider hängt)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.init(
        categoryId: widget.categoryId,
        title: widget.title,
      );
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
  
  // === UI helpers ===

  Future<void> _playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'));
    } catch (_) {
      HapticFeedback.lightImpact();
    }
  }
  
  Future<void> _playIncorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/incorrect.mp3'));
    } catch (_) {
      HapticFeedback.mediumImpact();
    }
  }
  
  Future<void> _playNewCardSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/new_card.mp3'));
    } catch (_) {
      HapticFeedback.selectionClick();
    }
  }


  // === Karten UI ===

  WordUserView? _currentWord(LearnModeState s) {
    if (s.shuffledWordIds.isEmpty || s.index >= s.shuffledWordIds.length) {
      return null;
    }
    final wordId = s.shuffledWordIds[s.index];
    final list = s.wordQueue;
    if (list.isEmpty) return null;
    return list.firstWhere((w) => w.id == wordId, orElse: () => list.first);
  }


  // === Build ===

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(learnModeControllerProvider);
    final c = ref.read(learnModeControllerProvider.notifier);

    final current = _currentWord(s);
    final word = current?.text ?? (s.shuffledWordIds.isEmpty ? 'Keine Wörter\nverfügbar' : '—');
    final translation = current?.translation ?? '';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header: Back + Category Wheel (aus Controller-State)
            SizedBox(
              height: 72,
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => Navigator.of(context).pop(),
                    child: const SizedBox(
                      width: 44,
                      height: 44,
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    ),
                  ),
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(0.0, 0.0),
                      child: Center(
                        child: s.loading
                            ? const SizedBox(
                                width: 280.0,
                                height: 72.0,
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.white54),
                                ),
                              )
                            : CategoryWheel(
                                categories: s.categories.map((c) => c.name).toList(),
                                initialIndex: s.selectedCategoryIndex,
                                onChanged: (idx, label) async {
                                  // Kategorie umschalten → macht Controller (lädt Stages + Queue)
                                  await _controller.selectCategoryIndex(idx);
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            // Karte (Flip + Swipe)
            Expanded(
              child: Center(
                child: Stack(
                  children: [

                    // Karte selbst
                    SwipeableWordCard(
                      frontText: word,
                      backText: translation,
                      level: current?.level,
                      showTranslation: s.showTranslation,
                      gesturesEnabled: !s.timerPaused,
                      onSwipe: (correct) async {
                        if (correct) {
                          _playCorrectSound();
                          c.onSwipeRight();
                        } else {
                          _playIncorrectSound();
                          c.onSwipeLeft();
                        }
                      },
                      onFlip: () {
                        c.toggleFlip();
                      },
                      footer: TimerBar(s: s),
                    ),
                  ],
                ),
              ),
            ),

            // Switches (Levels)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 5),
              child: Transform.translate(
                offset: const Offset(kSwitchesOffsetX, kSwitchesOffsetY),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    VerticalStageSwitch(
                      count: s.stages[0],
                      outerColor:
                          s.stages[0] > 0 ? _kStageInnerRed : Colors.grey.shade400,
                      innerColor: const Color(0xFF2D2D2F),
                      highlight: s.stages[0] > 0,
                      completed: false,
                      label: 'New',
                      note: '0',
                      isFirst: true,
                    ),
                    const SizedBox(width: kSwitchGap),
                    for (int stage = 1; stage <= 5; stage++) ...[
                      VerticalStageSwitch(
                        count: s.stages[stage],
                        outerColor:
                            s.stages[stage] > 0 ? _kStageOuter : Colors.grey.shade400,
                        innerColor: _kStageInner,
                        highlight:
                            s.stages[stage] > 0 && s.stages[stage] < 100, // Ziel optional
                        completed: s.stages[stage] >= 100,
                        label: 'S$stage',
                        note: '$stage',
                      ),
                      if (stage != 5) const SizedBox(width: kSwitchGap),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom Controls
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RoundIcon(
                    icon: Icons.grid_view_rounded,
                    onTap: _showMenu,
                  ),
                  const SizedBox(width: 80),
                  PlayPauseButton(
                    isPlaying: s.timerActive && s.running,
                    onTap: () {
                      if (!s.timerActive) {
                        _controller.startTimer();
      } else {
                        if (s.running) {
                          _controller.pauseTimer();
                        } else {
                          _controller.resumeTimer();
                        }
                      }
                    },
                  ),
                  const SizedBox(width: 80),
                  s.timerActive
                      ? CancelTimerButton(onTap: _controller.cancelTimer)
                      : ResetButton(onResetComplete: _controller.performReset),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  // === Menü ===
  void _showMenu() {
    showWordsMenuSheet(context, items: [
      MenuItemData(Icons.auto_awesome, 'ChatGPT', () {}),
      MenuItemData(Icons.translate_rounded, 'DeepL', () {}),
      MenuItemData(Icons.favorite_border, 'Favorit', () {}),
      MenuItemData(Icons.note_alt_outlined, 'Notizen', () {}),
      MenuItemData(Icons.settings_rounded, 'Einstellungen', () {}),
    ]);
  }
}



