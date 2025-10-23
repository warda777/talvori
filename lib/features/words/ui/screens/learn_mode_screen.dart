import 'dart:async';
import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import '../../application/learn_mode_controller.dart';


// ---- Farben / UI-Konstanten (wie gehabt) ----
const _kCard = Color(0xFF2D2C2C);
const _kStageOuter = Color(0xFFE4B866);
const _kStageInner = Color(0xFF2D2C2C);
const _kStageInnerRed = Color(0xFFA05260);

// ===== Category Wheel Knobs =====
const double kWheelWidth = 280.0;
const double kWheelHeight = 72.0;
const double kWheelItemExtent = 34.0;
const double kWheelPillWidth = 240.0;
const double kWheelPillRadius = 14.0;

const double kWheelActiveOpacity = 1.0;
const double kWheelNeighborOpacity = 0.55;
const double kWheelFarOpacity = 0.30;

const double kWheelActiveScale = 1.00;
const double kWheelNeighborScale = 0.94;
const double kWheelFarScale = 0.88;

const double kWheelGlowBlur = 18.0;
const double kWheelGlowOpacity = 0.35;

const double kWheelEdgeFadeHeight = 24.0;

const double kWheelArrowRightOut = 22.0;
const int kWheelArrowAutoHideMs = 800;
const double kWheelArrowNudge = 0.0;
const double kWheelOffsetX = 0.0;
const double kWheelOffsetY = 0.0;

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

  WordUserView? _currentWord() {
    final s = ref.read(learnModeControllerProvider);
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

    final current = _currentWord();
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
                      offset: const Offset(kWheelOffsetX, kWheelOffsetY),
                      child: Center(
                        child: s.loading
                            ? const SizedBox(
                                width: kWheelWidth,
                                height: kWheelHeight,
                                child: Center(
                                  child: CircularProgressIndicator(color: Colors.white54),
                                ),
                              )
                            : _CategoryWheel(
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
                    _VerticalStageSwitch(
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
                      _VerticalStageSwitch(
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
                  _RoundIcon(
                    icon: Icons.grid_view_rounded,
                    onTap: _showMenu,
                  ),
                  const SizedBox(width: 80),
                  _PlayPauseButton(
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
                      ? _CancelTimerButton(onTap: _controller.cancelTimer)
                      : _ResetButton(onResetComplete: _controller.performReset),
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
    final current = _currentWord();
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
            child: _buildTimerBar(s),
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
            child: _buildTimerBar(s),
          ),
        ],
      ),
    );
  }
  
  // === Timer-Bar (aus Controller-State) ===
  Widget _buildTimerBar(LearnModeState s) {
    final progress =
        (s.remainingMillis / (s.timeLimit * 1000.0)).clamp(0.0, 1.0);
    final isLowTime = s.remainingMillis <= 3000; // 3 Sekunden
    final isActive = s.timerActive;
    
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? Colors.black.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Stack(
          children: [
            if (isActive)
              Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLowTime
                            ? [Colors.red.shade700, Colors.red.shade400]
                            : [const Color(0xFFB1CCFE), const Color(0xFFD0E0FF)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
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

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
       child: InkWell(
         customBorder: const CircleBorder(),
         onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Icon(icon, color: Colors.white70),
        ),
      ),
    );
  }
}

class _CancelTimerButton extends StatelessWidget {
  final VoidCallback onTap;
  const _CancelTimerButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
                          child: Container(
          width: 44,
          height: 44,
                            decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.close_rounded, color: Colors.red, size: 24),
        ),
      ),
    );
  }
}

class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const _PlayPauseButton({required this.isPlaying, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
                          child: Container(
          width: 64,
          height: 64,
                            decoration: BoxDecoration(
            color: const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }
}

/// Reset-Button mit Hold-to-Confirm:
/// - Langes Drücken startet einen 3s-Countdown im Overlay.
/// - Haptik bei Start & Abschluss.
/// - Finger loslassen → Abbruch.
/// - Nach Ablauf wird [onResetComplete] aufgerufen.
class _ResetButton extends StatefulWidget {
  final Future<void> Function() onResetComplete;

  const _ResetButton({required this.onResetComplete});

  @override
  State<_ResetButton> createState() => _ResetButtonState();
}

class _ResetButtonState extends State<_ResetButton>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  int _countdown = 3;
  OverlayEntry? _overlayEntry;

  void _onLongPressStart(LongPressStartDetails details) {
    setState(() {
      _isPressed = true;
      _countdown = 3;
    });

    HapticFeedback.mediumImpact();
    _showOverlay();
    _startCountdown();
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    _cancel();
  }

  void _onLongPressCancel() {
    _cancel();
  }

  void _cancel() {
    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
    _removeOverlay();
    HapticFeedback.lightImpact();
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Reset',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Lernfortschritt?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 40),
              // Countdown
              StatefulBuilder(
                builder: (context, setOverlayState) {
                  return Text(
                    '$_countdown',
                    style: const TextStyle(
                      color: Color(0xFFA05260),
                      fontSize: 80,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                'Finger gedrückt halten...',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> _startCountdown() async {
    for (int i = 3; i > 0; i--) {
      if (!_isPressed) {
        _removeOverlay();
        return;
      }
      setState(() => _countdown = i);
      _overlayEntry?.markNeedsBuild();
      await Future.delayed(const Duration(seconds: 1));
    }

    if (!_isPressed) {
      _removeOverlay();
      return;
    }

    // Countdown fertig → bestätigen
    _removeOverlay();
    HapticFeedback.heavyImpact();

    await widget.onResetComplete();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lernfortschritt wurde zurückgesetzt'),
          duration: Duration(seconds: 2),
          backgroundColor: Color(0xFFA05260),
        ),
      );
    }

    setState(() {
      _isPressed = false;
      _countdown = 3;
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: _onLongPressStart,
      onLongPressEnd: _onLongPressEnd,
      onLongPressCancel: _onLongPressCancel,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _isPressed
                ? const Color(0xFFA05260)
                : const Color(0xFF2D2D2F),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.black, width: 1),
          ),
          child: Icon(
            Icons.refresh_rounded,
            color: _isPressed ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }
}

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

// ===== Category Wheel (UI-only) =====

class _CategoryWheel extends StatefulWidget {
  final List<String> categories;
  final int initialIndex;
  final void Function(int index, String label) onChanged;

  const _CategoryWheel({
    required this.categories,
    required this.initialIndex,
    required this.onChanged,
  });

  @override
  State<_CategoryWheel> createState() => _CategoryWheelState();
}

class _CategoryWheelState extends State<_CategoryWheel>
    with SingleTickerProviderStateMixin {
  Timer? _notifyDebounce;
  late FixedExtentScrollController _ctrl;
  late int _current;
  bool _showArrows = false;
  bool _flashUp = false;
  bool _flashDown = false;
  DateTime _lastMove = DateTime.now();

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
    _ctrl = FixedExtentScrollController(initialItem: _current);
  }

  @override
  void dispose() {
    _notifyDebounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _CategoryWheel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.categories.length != oldWidget.categories.length) {
      _current = _current.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
    }

    if (widget.initialIndex != oldWidget.initialIndex &&
        !_ctrl.position.isScrollingNotifier.value) {
      final newIndex =
          widget.initialIndex.clamp(0, (widget.categories.length - 1).clamp(0, 9999));
      _current = newIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _ctrl.jumpToItem(_current);
      });
    }
  }

  void _onChanged(int idx) {
    if (idx == _current) return;
    final oldCurrent = _current;
    setState(() {
      _flashUp = idx < oldCurrent;
      _flashDown = idx > oldCurrent;
      _showArrows = true;
      _current = idx;
      _lastMove = DateTime.now();
    });

    HapticFeedback.lightImpact();

    Future.delayed(const Duration(milliseconds: kWheelArrowAutoHideMs), () {
      if (mounted &&
          DateTime.now().difference(_lastMove).inMilliseconds >=
              kWheelArrowAutoHideMs) {
        setState(() => _showArrows = false);
      }
    });

    widget.onChanged(idx, widget.categories[idx]);
  }

  @override
  Widget build(BuildContext context) {
    final cats = widget.categories;
    if (cats.isEmpty) {
      return Container(
        width: kWheelWidth,
        height: kWheelHeight,
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text('Loading...', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return SizedBox(
      width: kWheelWidth,
      height: kWheelHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _EdgeFade(
            fadeHeight: kWheelEdgeFadeHeight,
            child: ListWheelScrollView.useDelegate(
              controller: _ctrl,
              itemExtent: kWheelItemExtent,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: _onChanged,
              diameterRatio: 2.2,
              perspective: 0.002,
              overAndUnderCenterOpacity: 1,
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: cats.length,
                builder: (context, index) {
                  final dist = (index - _current).abs();

                  final opacity = dist == 0
                      ? kWheelActiveOpacity
                      : (dist == 1 ? kWheelNeighborOpacity : kWheelFarOpacity);

                  final scale = dist == 0
                      ? kWheelActiveScale
                      : (dist == 1 ? kWheelNeighborScale : kWheelFarScale);

                  return Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 120),
                      opacity: opacity,
                      child: Transform.scale(
                        scale: scale,
                        child: _AdaptivePill(
                          text: cats[index],
                          width: kWheelPillWidth,
                          height: kWheelItemExtent - 6,
                          radius: kWheelPillRadius,
                          active: dist == 0,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Pfeile rechts
          Positioned.fill(
            right: -kWheelArrowRightOut,
            child: IgnorePointer(
              ignoring: false,
              child: Align(
                alignment: Alignment.centerRight,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showArrows ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.only(right: kWheelArrowNudge),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ArrowIcon(
                          up: true,
                          flash: _flashUp,
                          onTap: () => _ctrl.animateToItem(
                            (_current - 1).clamp(0, cats.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _ArrowIcon(
                          up: false,
                          flash: _flashDown,
                          onTap: () => _ctrl.animateToItem(
                            (_current + 1).clamp(0, cats.length - 1),
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdaptivePill extends StatelessWidget {
  final String text;
  final double width;
  final double height;
  final double radius;
  final bool active;
  const _AdaptivePill({
    required this.text,
    required this.width,
    required this.height,
    required this.radius,
    required this.active,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _kCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white24),
        boxShadow: active && kWheelGlowBlur > 0
            ? [
                BoxShadow(
                  color: Colors.white.withOpacity(kWheelGlowOpacity),
                  blurRadius: kWheelGlowBlur,
                  spreadRadius: 0,
                ),
              ]
            : const [],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.visible,
            style: TextStyle(
              color: Colors.white,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 15,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _EdgeFade extends StatelessWidget {
  final double fadeHeight;
  final Widget child;
  const _EdgeFade({required this.fadeHeight, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: fadeHeight,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.7),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.4),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.1),
                    Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                  ],
                  stops: [0.0, 0.3, 0.6, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ArrowIcon extends StatelessWidget {
  final bool up;
  final bool flash;
  final VoidCallback onTap;
  const _ArrowIcon({required this.up, required this.flash, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 120),
        opacity: 0.7,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white24),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          alignment: Alignment.center,
          child: Icon(
            up ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _VerticalStageSwitch extends StatelessWidget {
  final int count;
  final Color outerColor;
  final Color innerColor;
  final bool highlight;
  final bool completed;
  final String label; // "S1" / "New"
  final String note; // "0".."5"
  final bool isFirst;

  const _VerticalStageSwitch({
    required this.count,
    required this.outerColor,
    required this.innerColor,
    required this.highlight,
    required this.completed,
    required this.label,
    required this.note,
    this.isFirst = false,
  });

  double _getSwitchPosition() => count > 0 ? 2.0 : 18.0;

  @override
  Widget build(BuildContext context) {
    final badgeGlow = highlight
        ? [BoxShadow(color: outerColor.withOpacity(0.8), blurRadius: 14, spreadRadius: 1)]
        : const <BoxShadow>[];

    return Padding(
      padding: EdgeInsets.only(left: isFirst ? 6 : 0, right: isFirst ? 4 : 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Switch
          Container(
            width: 42,
            height: 75,
            decoration: BoxDecoration(
              color: outerColor,
              borderRadius: BorderRadius.circular(21),
              boxShadow: badgeGlow,
              border: Border.all(color: Colors.black.withOpacity(0.2), width: 1),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  left: 2,
                  right: 2,
                  top: _getSwitchPosition(),
                  child: Container(
                    width: 38,
                    height: 52,
                    decoration: BoxDecoration(
                      color: innerColor,
                      borderRadius: BorderRadius.circular(21),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 42,
            child: Text(
              note,
              textAlign: TextAlign.center,
                    style: const TextStyle(
                  fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
      ),
    );
  }
}
