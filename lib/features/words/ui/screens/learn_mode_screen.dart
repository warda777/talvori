import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/application.dart';
import '../widgets/widgets.dart';


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

class _LearnModeScreenState extends ConsumerState<LearnModeScreen>
    with TickerProviderStateMixin {
  // Controller (Business-Logik)
  late final LearnModeController _controller;

  // Nur UI: Flip- und Swipe-Animation + Audio
  AnimationController? _flipController;
  Animation<double>? _flipAnimation;
  
  Offset _cardOffset = Offset.zero;
  double _cardRotation = 0.0;
  bool _isDragging = false;
  bool _isSlidingIn = false;
  
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = ref.read(learnModeControllerProvider.notifier);

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController!, curve: Curves.easeInOut),
    );

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
    _flipController?.dispose();
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

  void _resetCardPosition() {
    setState(() {
      _cardOffset = Offset.zero;
      _cardRotation = 0.0;
    });
  }

  Future<void> _animateCardAway(bool correct) async {
    final s = ref.read(learnModeControllerProvider);
    
    // Blockiere Swipe, wenn Timer pausiert ist
    if (s.timerPaused) {
      print('🚫 Swipe blockiert: Timer ist pausiert');
      return;
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = correct ? screenWidth * 1.5 : -screenWidth * 1.5;
    
    HapticFeedback.mediumImpact();
    setState(() {
      _cardOffset = Offset(endX, _cardOffset.dy - 100);
      _cardRotation = correct ? 0.5 : -0.5;
    });
    
    // Warte auf die Weg-Animation
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Antwort ans System
        if (correct) {
      _controller.onSwipeRight();
        } else {
      _controller.onSwipeLeft();
        }
        
    // Flip zurück auf Vorderseite
    _flipController?.reset();
        
    // Kurze Pause, dann hereinsliden
    await Future.delayed(const Duration(milliseconds: 50));
    _playNewCardSound();
        setState(() {
      _cardOffset = Offset.zero;
      _cardRotation = 0.0;
      _isSlidingIn = true;
    });

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isSlidingIn = false);
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

  String _getSrsLevelDisplay(int? stage) {
    final st = stage ?? 0;
    switch (st) {
      case 0:
        return 'A1';
      case 1:
        return 'A2';
      case 2:
        return 'B1';
      case 3:
        return 'B2';
      case 4:
        return 'C1';
      case 5:
        return 'C2';
      default:
        return 'A1';
    }
  }

  // === Build ===

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(learnModeControllerProvider);

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
                    if (_isDragging) ...[
                      // Rechts = Richtig (Grün)
                      Positioned(
                        right: 40,
                        top: MediaQuery.of(context).size.height * 0.25,
                        child: AnimatedOpacity(
                          opacity: (_cardOffset.dx > 50) ? 0.8 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.green, width: 3),
                            ),
                            child: const Icon(Icons.check, color: Colors.green, size: 48),
                          ),
                        ),
                      ),
                      // Links = Falsch (Rot)
                      Positioned(
                        left: 40,
                        top: MediaQuery.of(context).size.height * 0.25,
                        child: AnimatedOpacity(
                          opacity: (_cardOffset.dx < -50) ? 0.8 : 0.0,
                          duration: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.red, width: 3),
                            ),
                            child: const Icon(Icons.close, color: Colors.red, size: 48),
                          ),
                        ),
                      ),
                    ],

                    // Karte selbst
                    GestureDetector(
                      onTap: () {
                        if (s.wordQueue.isEmpty) return;
                        
                        // Blockiere Flip, wenn Timer pausiert ist
                        if (s.timerPaused) {
                          print('🚫 Flip blockiert: Timer ist pausiert');
                          return;
                        }
                        
                        HapticFeedback.selectionClick();
                        _controller.toggleFlip();
                        if (s.showTranslation) {
                          _flipController?.reverse();
                        } else {
                          _flipController?.forward();
                        }
                      },
                      onPanUpdate: (details) {
                        // Blockiere Pan-Gesten, wenn Timer pausiert ist
                        if (s.timerPaused) return;
                        
                        setState(() {
                          _isDragging = true;
                          _cardOffset += details.delta;
                          _cardRotation =
                              (_cardOffset.dx / 1000).clamp(-0.26, 0.26); // ±15°
                        });
                      },
                      onPanEnd: (details) {
                        if (!_isDragging) return;
                        
                        // Blockiere Pan-End, wenn Timer pausiert ist
                        if (s.timerPaused) {
                          setState(() => _isDragging = false);
                          _resetCardPosition();
                          return;
                        }
                        
                        setState(() => _isDragging = false);

                        final screenWidth = MediaQuery.of(context).size.width;
                        final threshold = screenWidth * 0.35;

                        if (_cardOffset.dx > threshold) {
                          _playCorrectSound();
                          _animateCardAway(true);
                        } else if (_cardOffset.dx < -threshold) {
                          _playIncorrectSound();
                          _animateCardAway(false);
    } else {
                          _resetCardPosition();
                        }
                      },
                      child: AnimatedContainer(
                        duration: _isDragging
                            ? Duration.zero
                            : (_isSlidingIn
                                ? const Duration(milliseconds: 400)
                                : const Duration(milliseconds: 300)),
                        curve: _isSlidingIn ? Curves.easeOutCubic : Curves.easeOut,
                        transform: Matrix4.identity()
                          ..translate(_cardOffset.dx, _cardOffset.dy)
                          ..rotateZ(_isSlidingIn ? 0.0 : _cardRotation),
                        child: _flipAnimation == null
                            ? _buildCardFront(context, s, word)
                            : AnimatedBuilder(
                                animation: _flipAnimation!,
                                builder: (context, child) {
                                  final angle = _flipAnimation!.value * math.pi;
                                  final isFront = angle < math.pi / 2;

                                  return Transform(
                                    transform: Matrix4.identity()
                                      ..setEntry(3, 2, 0.001)
                                      ..rotateY(angle),
                                    alignment: Alignment.center,
                                    child: isFront
                                        ? _buildCardFront(context, s, word)
                                        : Transform(
                                            transform: Matrix4.identity()..rotateY(math.pi),
                                            alignment: Alignment.center,
                                            child: _buildCardBack(context, s, translation),
                                          ),
                                  );
                                },
                              ),
                      ),
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

  // === Card Faces ===
  Widget _buildCardFront(BuildContext context, LearnModeState s, String word) {
    final current = _currentWord(s);
    final stage = current?.srsStage ?? 0;

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          // Level Badge
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Text(
                _getSrsLevelDisplay(stage),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ),
          const Positioned(
            top: 12,
            left: 12,
            child: Icon(Icons.rocket_launch_rounded, color: Colors.white70, size: 20),
          ),
          // Wort in der Mitte
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LayoutBuilder(
                    builder: (_, constraints) {
                      final wordCount = word.split(' ').length;
                      final isPhrase = wordCount > 1;
                      final totalLength = word.length;
                      
                      double fontSize;
                      int maxLines;
                      
                      if (isPhrase) {
                        if (totalLength > 40) {
                          fontSize = 26.0;
                          maxLines = 4;
                        } else if (totalLength > 25) {
                          fontSize = 28.0;
                          maxLines = 3;
                        } else {
                          fontSize = 30.0;
                          maxLines = 2;
                        }
                      } else {
                        if (totalLength > 18) {
                          fontSize = 28.0;
                          maxLines = 2;
                        } else if (totalLength > 12) {
                          fontSize = 30.0;
                          maxLines = 2;
                        } else {
                          fontSize = 34.0;
                          maxLines = 1;
                        }
                      }
                      return Text(
                        word,
                        textAlign: TextAlign.center,
                        maxLines: maxLines,
                        overflow: TextOverflow.visible,
                        softWrap: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                          height: 1.3,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: const Icon(
                      Icons.volume_up_rounded,
                      color: Colors.white70,
                      size: 32,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Timer-Bar
          Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: TimerBar(
              remainingMillis: s.remainingMillis,
              timeLimitSeconds: s.timeLimit,
              active: s.timerActive,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(
      BuildContext context, LearnModeState s, String translation) {
    final text = translation.isNotEmpty ? translation : '—';

    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: const Color(0xFF3A3939),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white24),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 12)),
        ],
      ),
      child: Stack(
        children: [
          // Swipe-Hinweis oben
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                  Icon(Icons.swipe_left,
                      color: Colors.red.withOpacity(0.6), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Falsch',
                        style: TextStyle(
                          color: Colors.red.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 16),
                  Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
                      const SizedBox(width: 16),
                      Text(
                        'Richtig',
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.7),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                  Icon(Icons.swipe_right,
                      color: Colors.green.withOpacity(0.6), size: 16),
                    ],
                  ),
              ),
            ),
          // Übersetzung zentriert
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: LayoutBuilder(
                builder: (_, __) {
                  final wordCount = text.split(' ').length;
                  final isPhrase = wordCount > 1;
                  final totalLength = text.length;
                  
                  double fontSize;
                  int maxLines;
                  
                  if (isPhrase) {
                    if (totalLength > 50) {
                      fontSize = 24.0;
                      maxLines = 5;
                    } else if (totalLength > 35) {
                      fontSize = 26.0;
                      maxLines = 4;
                    } else if (totalLength > 20) {
                      fontSize = 28.0;
                      maxLines = 3;
                    } else {
                      fontSize = 30.0;
                      maxLines = 2;
                    }
                  } else {
                    if (totalLength > 20) {
                      fontSize = 26.0;
                      maxLines = 3;
                    } else if (totalLength > 14) {
                      fontSize = 28.0;
                      maxLines = 2;
                    } else if (totalLength > 10) {
                      fontSize = 30.0;
                      maxLines = 2;
                    } else {
                      fontSize = 32.0;
                      maxLines = 1;
                    }
                  }
                  
                  return Text(
                    text,
                    textAlign: TextAlign.center,
                    maxLines: maxLines,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      height: 1.35,
                    ),
                  );
                },
              ),
            ),
          ),
          // Timer-Bar
          Positioned(
            bottom: 8,
            left: 30,
            right: 30,
            child: TimerBar(
              remainingMillis: s.remainingMillis,
              timeLimitSeconds: s.timeLimit,
              active: s.timerActive,
                ),
              ),
          ],
      ),
    );
  }


  // === Menü (Stub) ===
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.75),
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MenuRow(
                  items: [
                    _MenuItem(icon: Icons.auto_awesome, label: 'ChatGPT', onTap: () {}),
                    _MenuItem(icon: Icons.translate_rounded, label: 'DeepL', onTap: () {}),
                    _MenuItem(icon: Icons.favorite_border, label: 'Favorit', onTap: () {}),
                    _MenuItem(icon: Icons.note_alt_outlined, label: 'Notizen', onTap: () {}),
                    _MenuItem(icon: Icons.settings_rounded, label: 'Einstellungen', onTap: () {}),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ====== Widgets (UI-only, keine Business-Logik) ======





class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}

class _MenuRow extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuRow({required this.items});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: items
          .map(
            (it) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.85, end: 1.0),
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutBack,
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: InkWell(
                customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.of(context).pop();
                      it.onTap();
                    },
                child: Container(
                      width: 56,
                      height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(it.icon, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 8),
                Text(it.label,
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
            ),
          )
          .toList(),
    );
  }
}


