import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import 'package:talvori/features/words/application/card_glow_settings_provider.dart';
import '../widgets/level_badge.dart';

typedef SwipeDecision = Future<void> Function(bool correct);

class SwipeableWordCard extends StatefulWidget {
  final String frontText;
  final String backText;
  final String? level; // CEFR Level (A1-C2)
  final bool showTranslation;
  final bool gesturesEnabled; // blockt Flip/Swipe bei pausiertem Timer
  final Widget? footer; // TimerBar etc.
  final Widget?
  quickActions; // Aktionen, die fest zur swipebaren Karte gehören.
  final int? srsStage; // 0..5 (für Streak-Progress Anzeige)
  final int? streak; // korrekt-in-a-row in current stage
  final int? passCount; // A-SRS: wie oft in aktueller Stage richtig (0, 1, 2)
  final SwipeDecision onSwipe; // true = right/correct, false = left/incorrect
  final VoidCallback onFlip; // UI -> Controller.toggleFlip()
  final void Function(double dx)?
  onDragUpdate; // ← NEU: für Plasma-Link (dx für Stage-Berechnung)
  final VoidCallback? onDragEnd; // ← NEU: für Plasma-Link verstecken
  final VoidCallback?
  onDragReturn; // ← NEU: für Plasma-Link wieder anzeigen wenn Karte zurückkommt
  final VoidCallback?
  onSettingsTap; // Glow-Einstellungen (fest auf der Vorderseite)
  final GlobalKey? passCountButtonKey; // Für Sparkle-Effekt bei Stage-Up
  final void Function(BuildContext context, bool correct)?
  onSwipeWillStart; // Vor Karten-Animation (für Sparkle)
  final VoidCallback? onSpeak;
  final double cardWidthFactor;
  final double cardHeightFactor;
  final Color? cardBackgroundColor;
  final Color? cardBorderColor;
  final Color? cardGlowColor;
  final double? cardWidth;
  final double? cardHeight;

  const SwipeableWordCard({
    super.key,
    required this.frontText,
    required this.backText,
    required this.level,
    required this.showTranslation,
    required this.gesturesEnabled,
    required this.onSwipe,
    required this.onFlip,
    this.footer,
    this.quickActions,
    this.srsStage,
    this.streak,
    this.passCount,
    this.onDragUpdate, // ← NEU
    this.onDragEnd, // ← NEU
    this.onDragReturn, // ← NEU
    this.onSettingsTap,
    this.passCountButtonKey,
    this.onSwipeWillStart,
    this.onSpeak,
    this.cardWidthFactor = 0.78,
    this.cardHeightFactor = 0.52,
    this.cardBackgroundColor,
    this.cardBorderColor,
    this.cardGlowColor,
    this.cardWidth,
    this.cardHeight,
  });

  @override
  State<SwipeableWordCard> createState() => _SwipeableWordCardState();
}

class _SwipeableWordCardState extends State<SwipeableWordCard>
    with TickerProviderStateMixin {
  late final AnimationController _flipCtrl;
  late final Animation<double> _flipAnim;

  Offset _offset = Offset.zero;
  double _rotation = 0;
  bool _dragging = false;
  bool _slidingIn = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _flipAnim = CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut);
  }

  @override
  void didUpdateWidget(covariant SwipeableWordCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_isDisposed || !mounted) return;
    // Sync Flip-Animation mit showTranslation
    if (widget.showTranslation &&
        _flipCtrl.status != AnimationStatus.forward &&
        _flipCtrl.value == 0) {
      _flipCtrl.forward();
    } else if (!widget.showTranslation && _flipCtrl.value != 0) {
      _flipCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _flipCtrl.dispose();
    super.dispose();
  }

  void _resetPos() {
    if (_isDisposed || !mounted) return;
    setState(() {
      _offset = Offset.zero;
      _rotation = 0;
    });
  }

  Future<void> _animateAway(bool correct) async {
    if (_isDisposed || !mounted) return;
    final width = MediaQuery.of(context).size.width;
    final endX = correct ? width * 1.5 : -width * 1.5;

    HapticFeedback.mediumImpact();
    widget.onDragEnd?.call(); // Plasma-Link verstecken beim Commit
    setState(() {
      _offset = Offset(endX, _offset.dy - 100);
      _rotation = correct ? 0.5 : -0.5;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    if (_isDisposed || !mounted) return;
    await widget.onSwipe(correct);
    if (_isDisposed || !mounted) return;

    // Flip zurück auf Front
    _flipCtrl.reset();

    await Future.delayed(const Duration(milliseconds: 50));
    if (_isDisposed || !mounted) return;
    setState(() {
      _offset = Offset.zero;
      _rotation = 0;
      _slidingIn = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_isDisposed && mounted) setState(() => _slidingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final threshold = MediaQuery.of(context).size.width * 0.35;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (!widget.gesturesEnabled) return;
        HapticFeedback.selectionClick();
        widget.onFlip();
      },
      onPanUpdate: (d) {
        if (!widget.gesturesEnabled) return;
        setState(() {
          _dragging = true;
          _offset += d.delta;
          _rotation = (_offset.dx / 1000).clamp(-0.26, 0.26);
        });
        // Plasma-Link Update: Weitergeben des dx-Werts für Stage-Berechnung
        widget.onDragUpdate?.call(_offset.dx);
      },
      onPanEnd: (_) {
        if (!_dragging) return;
        setState(() => _dragging = false);
        widget.onDragEnd?.call(); // Plasma-Link verstecken
        if (!widget.gesturesEnabled) {
          _resetPos();
          widget.onDragReturn?.call(); // Karte kommt zurück
          return;
        }
        if (_offset.dx > threshold) {
          widget.onSwipeWillStart?.call(context, true);
          _animateAway(true);
        } else if (_offset.dx < -threshold) {
          widget.onSwipeWillStart?.call(context, false);
          _animateAway(false);
        } else {
          _resetPos();
          // Karte kommt zurück - Link wieder anzeigen nach Animation
          Future.delayed(const Duration(milliseconds: 300), () {
            if (_isDisposed || !mounted) return;
            widget.onDragReturn?.call();
          });
        }
      },
      child: AnimatedContainer(
        duration: _dragging
            ? Duration.zero
            : (_slidingIn
                  ? const Duration(milliseconds: 400)
                  : const Duration(milliseconds: 300)),
        curve: _slidingIn ? Curves.easeOutCubic : Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(_offset.dx, _offset.dy, 0, 1)
          ..rotateZ(_slidingIn ? 0 : _rotation),
        child: _buildFlip(),
      ),
    );
  }

  Widget _buildFlip() {
    return AnimatedBuilder(
      animation: _flipAnim,
      builder: (_, __) {
        final angle = _flipAnim.value * math.pi;
        final isFront = angle < math.pi / 2;

        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: isFront
              ? _buildFront()
              : Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: _buildBack(),
                ),
        );
      },
    );
  }

  Widget _buildFront() {
    final isDiagnostic =
        widget.frontText.contains('Keine Wörter verfügbar') ||
        widget.frontText.contains('All words reached Stage 5') ||
        widget.frontText.contains('Alle Wörter sind in Stufe 5');
    final isCongratulation =
        widget.frontText.contains('Herzlichen Glückwunsch') ||
        widget.frontText.contains('Congratulations');
    return _CardShell(
      widthFactor: widget.cardWidthFactor,
      heightFactor: widget.cardHeightFactor,
      backgroundColor: widget.cardBackgroundColor,
      borderColor: widget.cardBorderColor,
      glowColor: widget.cardGlowColor,
      width: widget.cardWidth,
      height: widget.cardHeight,
      child: Stack(
        children: [
          if (!isDiagnostic && !isCongratulation)
            Positioned(
              top: 12,
              right: 12,
              child: LevelBadge(level: widget.level),
            ),
          if (!isDiagnostic && !isCongratulation && widget.onSpeak != null)
            Positioned(
              top: widget.onSettingsTap == null ? 12 : 58,
              left: 12,
              child: _PronunciationButton(onPressed: widget.onSpeak!),
            ),
          if (!isDiagnostic && !isCongratulation && widget.passCount != null)
            Positioned(
              bottom: 28,
              left: 12,
              child: _PassCountIndicator(
                passCount: widget.passCount!,
                buttonKey: widget.passCountButtonKey,
              ),
            ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: isDiagnostic
                  ? SingleChildScrollView(
                      child: _AdaptiveText(
                        widget.frontText,
                        forceMultiline: true,
                      ),
                    )
                  : isCongratulation
                  ? SingleChildScrollView(
                      child: _AdaptiveText(
                        widget.frontText,
                        forceMultiline: true,
                        compactFont: true,
                      ),
                    )
                  : _AdaptiveText(widget.frontText),
            ),
          ),
          if (widget.footer != null)
            Positioned(bottom: 8, left: 30, right: 30, child: widget.footer!),
          if (widget.quickActions != null)
            Positioned(right: 14, bottom: 64, child: widget.quickActions!),
          if (widget.onSettingsTap != null)
            Positioned(
              top: 12,
              left: 12,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: widget.onSettingsTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D2D2F).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.settings_rounded,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _CardShell(
      widthFactor: widget.cardWidthFactor,
      heightFactor: widget.cardHeightFactor,
      backgroundColor: widget.cardBackgroundColor,
      borderColor: widget.cardBorderColor,
      glowColor: widget.cardGlowColor,
      width: widget.cardWidth,
      height: widget.cardHeight,
      dark: true,
      child: Stack(
        children: [
          const _SwipeHint(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: _AdaptiveText(widget.backText, back: true),
            ),
          ),
          _StreakProgressBadge(
            srsStage: widget.srsStage,
            streak: widget.streak,
          ),
          if (widget.passCount != null)
            Positioned(
              bottom: 28,
              left: 12,
              child: _PassCountIndicator(
                passCount: widget.passCount!,
                buttonKey: widget.passCountButtonKey,
              ),
            ),
          if (widget.footer != null)
            Positioned(bottom: 8, left: 30, right: 30, child: widget.footer!),
          if (widget.quickActions != null)
            Positioned(right: 14, bottom: 64, child: widget.quickActions!),
          if (widget.onSpeak != null)
            Positioned(
              top: 12,
              left: 12,
              child: _PronunciationButton(onPressed: widget.onSpeak!),
            ),
        ],
      ),
    );
  }
}

class _PronunciationButton extends StatelessWidget {
  const _PronunciationButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey('learn-card-pronunciation-button'),
        borderRadius: BorderRadius.circular(20),
        onTap: onPressed,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0B1820).withValues(alpha: 0.92),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF5DDCFF), width: 1.1),
            boxShadow: const [
              BoxShadow(color: Color(0x225DDCFF), blurRadius: 14),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.volume_up_rounded,
            color: Color(0xFFB8FFF6),
            size: 22,
          ),
        ),
      ),
    );
  }
}

/// Kleiner Button links unten: zeigt an, wie oft die Karte schon richtig beantwortet wurde.
/// Farbe: 0=weiß, 1=hellblau, 2=grün. Zahl: 0, 1, 2. Tippen öffnet Erklärung.
class _PassCountIndicator extends StatelessWidget {
  final int passCount; // 0, 1 oder 2 (3 = mastered, Karte weg)
  final GlobalKey? buttonKey;

  const _PassCountIndicator({required this.passCount, this.buttonKey});

  static Color _colorFor(int count) {
    switch (count) {
      case 0:
        return Colors.white;
      case 1:
        return const Color(0xFF64B5F6); // Hellblau
      case 2:
        return const Color(0xFF81C784); // Hellgrün
      default:
        return Colors.white;
    }
  }

  static Color _textColorFor(int count) {
    switch (count) {
      case 0:
        return const Color(0xFF333333); // Dunkel auf Weiß
      case 1:
      case 2:
        return Colors.white; // Weiß auf Blau/Grün
      default:
        return const Color(0xFF333333);
    }
  }

  void _showExplanation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Fortschritt-Anzeige'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Der Button links unten zeigt die Zahl (0, 1, 2) und die Farbe – wie oft du diese Karte schon richtig beantwortet hast:',
            ),
            SizedBox(height: 16),
            _LegendRow(color: Colors.white, text: 'Weiß – erstes Mal dran'),
            _LegendRow(
              color: Color(0xFF64B5F6),
              text: 'Hellblau – einmal richtig',
            ),
            _LegendRow(
              color: Color(0xFF81C784),
              text: 'Grün – zweimal richtig',
            ),
            SizedBox(height: 12),
            Text(
              'Nach drei richtigen Antworten wird die Karte gemastert.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(passCount);
    final textColor = _textColorFor(passCount);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showExplanation(context),
        child: Container(
          key: buttonKey,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$passCount',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendRow({required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _StreakProgressBadge extends StatelessWidget {
  final int? srsStage; // 0..5
  final int? streak; // korrekt in a row in current stage
  const _StreakProgressBadge({this.srsStage, this.streak});

  int _requiredCorrect(int stage) {
    if (stage <= 0) return 1;
    if (stage <= 3) return 2;
    return 3; // S4 und S5
  }

  @override
  Widget build(BuildContext context) {
    final stage = srsStage;
    final s = streak;
    if (stage == null || s == null) return const SizedBox.shrink();

    final required = _requiredCorrect(stage);
    final done = s.clamp(0, required);

    return Positioned(
      left: 30,
      // 8px (TimerBar bottom) + 6px (ProgressBar height) + 6px Abstand
      bottom: 24,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$done von $required',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// re-usable Shell mit animiertem Glow-Effekt
class _CardShell extends ConsumerStatefulWidget {
  final Widget child;
  final bool dark;
  final double widthFactor;
  final double heightFactor;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? glowColor;
  final double? width;
  final double? height;
  const _CardShell({
    required this.child,
    this.dark = false,
    this.widthFactor = 0.78,
    this.heightFactor = 0.52,
    this.backgroundColor,
    this.borderColor,
    this.glowColor,
    this.width,
    this.height,
  });

  @override
  ConsumerState<_CardShell> createState() => _CardShellState();
}

class _CardShellState extends ConsumerState<_CardShell>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    // Feste Dauer für kontinuierliche Atmung (wie vorher)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 3000,
      ), // Langsame, sanfte Pulsierung wie Atmung
    )..repeat();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth =
        widget.width ?? MediaQuery.of(context).size.width * widget.widthFactor;
    final cardHeight =
        widget.height ??
        MediaQuery.of(context).size.height * widget.heightFactor;
    final borderRadius = WordsUIConstants.borderRadius;
    final accentColor = widget.glowColor ?? const Color(0xFFB16CFF);

    // Lade persistente Einstellungen aus Provider (Steuerung jetzt im Settings-Popup)
    final settings = ref.watch(cardGlowSettingsProvider);

    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        // Kontinuierliche Atmung: Animation läuft immer mit konstanter Geschwindigkeit
        // Die Amplitude wird mit pulseSpeed multipliziert für smooth Übergang
        final baseValue = _glowController.value;

        // Phase bleibt konstant (kontinuierliche Atmung)
        final pulseValue = baseValue * 2 * math.pi;

        // Amplitude wird mit pulseSpeed multipliziert:
        // - Bei speed = 0: Amplitude = 0 → pulse = 0.5 (statisch)
        // - Bei speed > 0: Amplitude steigt smooth → pulse atmet smooth
        final pulse = 0.5 + 0.5 * math.sin(pulseValue) * settings.pulseSpeed;

        final glowSpread = 12.0 + (48.0 - 12.0) * pulse;

        return Stack(
          children: [
            Container(
              width: cardWidth,
              height: cardHeight,
              decoration: BoxDecoration(
                color: widget.dark
                    ? (widget.backgroundColor ?? const Color(0xFF3A3939))
                    : (widget.backgroundColor ??
                          WordsUIConstants.cardBackground),
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: (widget.borderColor ?? accentColor).withValues(
                    alpha: 0.6,
                  ),
                  width: 1.5,
                ),
                boxShadow: [
                  // Ursprüngliche Schatten beibehalten
                  ...WordsUIConstants.cardShadow,
                  // Animierter Glow-Effekt (mit Intensitäts-Steuerung aus Provider)
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: 0.25 * (0.6 + 0.4 * pulse) * settings.intensity,
                    ),
                    blurRadius:
                        (60 + glowSpread * 2.0).clamp(0.0, 100.0) *
                        settings.intensity,
                    spreadRadius: glowSpread * 1.5 * settings.intensity,
                  ),
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: 0.30 * (0.5 + 0.5 * pulse) * settings.intensity,
                    ),
                    blurRadius:
                        (45 + glowSpread * 1.5).clamp(0.0, 100.0) *
                        settings.intensity,
                    spreadRadius: glowSpread * 1.2 * settings.intensity,
                  ),
                  BoxShadow(
                    color: accentColor.withValues(
                      alpha: 0.35 * (0.5 + 0.5 * pulse) * settings.intensity,
                    ),
                    blurRadius:
                        (35 + glowSpread * 1.2).clamp(0.0, 100.0) *
                        settings.intensity,
                    spreadRadius: glowSpread * 0.9 * settings.intensity,
                  ),
                  BoxShadow(
                    color: const Color(0xFFEFE9FF).withValues(
                      alpha: 0.45 * (0.3 + 0.7 * pulse) * settings.intensity,
                    ),
                    blurRadius:
                        (18 + glowSpread * 0.5).clamp(0.0, 100.0) *
                        settings.intensity,
                    spreadRadius: glowSpread * 0.3 * settings.intensity,
                  ),
                ],
              ),
              child: widget.child,
            ),
          ],
        );
      },
    );
  }
}

class _AdaptiveText extends StatelessWidget {
  final String text;
  final bool back;
  final bool forceMultiline;
  final bool compactFont;
  const _AdaptiveText(
    this.text, {
    this.back = false,
    this.forceMultiline = false,
    this.compactFont = false,
  });

  @override
  Widget build(BuildContext context) {
    final wordCount = text.split(' ').length;
    final isPhrase = wordCount > 1 || forceMultiline;
    final total = text.length;

    double fontSize;
    int maxLines;

    const double bump = 4.0; // Größere Schrift auf der Karte
    if (isPhrase || forceMultiline) {
      if (forceMultiline) {
        fontSize = compactFont ? 16 : 22;
        maxLines = 20;
      } else if (back) {
        if (total > 50) {
          fontSize = 24 + bump;
          maxLines = 5;
        } else if (total > 35) {
          fontSize = 26 + bump;
          maxLines = 4;
        } else if (total > 20) {
          fontSize = 28 + bump;
          maxLines = 3;
        } else {
          fontSize = 30 + bump;
          maxLines = 2;
        }
      } else {
        if (total > 40) {
          fontSize = 26 + bump;
          maxLines = 4;
        } else if (total > 25) {
          fontSize = 28 + bump;
          maxLines = 3;
        } else {
          fontSize = 30 + bump;
          maxLines = 2;
        }
      }
    } else {
      if (back) {
        if (total > 20) {
          fontSize = 26 + bump;
          maxLines = 3;
        } else if (total > 14) {
          fontSize = 28 + bump;
          maxLines = 2;
        } else if (total > 10) {
          fontSize = 30 + bump;
          maxLines = 2;
        } else {
          fontSize = 32 + bump;
          maxLines = 1;
        }
      } else {
        if (total > 18) {
          fontSize = 28 + bump;
          maxLines = 2;
        } else if (total > 12) {
          fontSize = 30 + bump;
          maxLines = 2;
        } else {
          fontSize = 34 + bump;
          maxLines = 1;
        }
      }
    }

    return Text(
      text.isNotEmpty ? text : '—',
      textAlign: TextAlign.center,
      maxLines: maxLines,
      overflow: TextOverflow.visible,
      softWrap: true,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.33,
      ),
    );
  }
}

class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  static Widget _buildRow() => Row(
    mainAxisSize: MainAxisSize.min,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(
        Icons.swipe_left,
        color: Colors.red.withValues(alpha: 0.6),
        size: 16,
      ),
      const SizedBox(width: 4),
      Text(
        'Falsch',
        style: TextStyle(
          color: Colors.red.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 16),
      Text('•', style: TextStyle(color: Colors.white.withValues(alpha: 0.3))),
      const SizedBox(width: 16),
      Text(
        'Richtig',
        style: TextStyle(
          color: Colors.green.withValues(alpha: 0.7),
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(width: 4),
      Icon(
        Icons.swipe_right,
        color: Colors.green.withValues(alpha: 0.6),
        size: 16,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      left: 0,
      right: 0,
      child: Center(child: _buildRow()),
    );
  }
}
