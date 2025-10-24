import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:talvori/features/words/ui/ui_constants.dart';
import '../widgets/level_badge.dart';

typedef SwipeDecision = Future<void> Function(bool correct);

class SwipeableWordCard extends StatefulWidget {
  final String frontText;
  final String backText;
  final String? level;               // CEFR Level (A1-C2)
  final bool showTranslation;
  final bool gesturesEnabled;        // blockt Flip/Swipe bei pausiertem Timer
  final Widget? footer;              // TimerBar etc.
  final SwipeDecision onSwipe;       // true = right/correct, false = left/incorrect
  final VoidCallback onFlip;         // UI -> Controller.toggleFlip()

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
    // Sync Flip-Animation mit showTranslation
    if (widget.showTranslation && _flipCtrl.status != AnimationStatus.forward && _flipCtrl.value == 0) {
      _flipCtrl.forward();
    } else if (!widget.showTranslation && _flipCtrl.value != 0) {
      _flipCtrl.reverse();
    }
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    super.dispose();
  }

  void _resetPos() {
    setState(() {
      _offset = Offset.zero;
      _rotation = 0;
    });
  }

  Future<void> _animateAway(bool correct) async {
    final width = MediaQuery.of(context).size.width;
    final endX = correct ? width * 1.5 : -width * 1.5;

    HapticFeedback.mediumImpact();
    setState(() {
      _offset = Offset(endX, _offset.dy - 100);
      _rotation = correct ? 0.5 : -0.5;
    });

    await Future.delayed(const Duration(milliseconds: 300));
    await widget.onSwipe(correct);

    // Flip zurück auf Front
    _flipCtrl.reset();

    await Future.delayed(const Duration(milliseconds: 50));
    setState(() {
      _offset = Offset.zero;
      _rotation = 0;
      _slidingIn = true;
    });
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _slidingIn = false);
  }

  @override
  Widget build(BuildContext context) {
    final threshold = MediaQuery.of(context).size.width * 0.35;

    return GestureDetector(
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
      },
      onPanEnd: (_) {
        if (!_dragging) return;
        setState(() => _dragging = false);
        if (!widget.gesturesEnabled) {
          _resetPos();
          return;
        }
        if (_offset.dx > threshold) {
          _animateAway(true);
        } else if (_offset.dx < -threshold) {
          _animateAway(false);
        } else {
          _resetPos();
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
          ..translate(_offset.dx, _offset.dy)
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
          child: isFront ? _buildFront() : Transform(
            transform: Matrix4.identity()..rotateY(math.pi),
            alignment: Alignment.center,
            child: _buildBack(),
          ),
        );
      },
    );
  }

  Widget _buildFront() {
    return _CardShell(
      child: Stack(
        children: [
          Positioned(top: 12, right: 12, child: LevelBadge(level: widget.level)),
          const Positioned(
            top: 12, left: 12,
            child: Icon(Icons.rocket_launch_rounded, color: Colors.white70, size: 20),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 28),
              child: _AdaptiveText(widget.frontText),
            ),
          ),
          if (widget.footer != null)
            Positioned(bottom: 8, left: 30, right: 30, child: widget.footer!),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _CardShell(
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
          if (widget.footer != null)
            Positioned(bottom: 8, left: 30, right: 30, child: widget.footer!),
        ],
      ),
    );
  }
}

/// re-usable Shell
class _CardShell extends StatelessWidget {
  final Widget child;
  final bool dark;
  const _CardShell({required this.child, this.dark = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.78,
      height: MediaQuery.of(context).size.height * 0.52,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF3A3939) : WordsUIConstants.cardBackground,
        borderRadius: BorderRadius.circular(WordsUIConstants.borderRadius),
        border: Border.all(color: Colors.white24),
        boxShadow: WordsUIConstants.cardShadow,
      ),
      child: child,
    );
  }
}

class _AdaptiveText extends StatelessWidget {
  final String text;
  final bool back;
  const _AdaptiveText(this.text, {this.back = false});

  @override
  Widget build(BuildContext context) {
    final wordCount = text.split(' ').length;
    final isPhrase = wordCount > 1;
    final total = text.length;

    double fontSize; int maxLines;

    if (isPhrase) {
      if (back) {
        if (total > 50) { fontSize = 24; maxLines = 5; }
        else if (total > 35) { fontSize = 26; maxLines = 4; }
        else if (total > 20) { fontSize = 28; maxLines = 3; }
        else { fontSize = 30; maxLines = 2; }
      } else {
        if (total > 40) { fontSize = 26; maxLines = 4; }
        else if (total > 25) { fontSize = 28; maxLines = 3; }
        else { fontSize = 30; maxLines = 2; }
      }
    } else {
      if (back) {
        if (total > 20) { fontSize = 26; maxLines = 3; }
        else if (total > 14) { fontSize = 28; maxLines = 2; }
        else if (total > 10) { fontSize = 30; maxLines = 2; }
        else { fontSize = 32; maxLines = 1; }
      } else {
        if (total > 18) { fontSize = 28; maxLines = 2; }
        else if (total > 12) { fontSize = 30; maxLines = 2; }
        else { fontSize = 34; maxLines = 1; }
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

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16, left: 0, right: 0,
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.swipe_left,  color: Colors.red.withOpacity(0.6),   size: 16),
            const SizedBox(width: 4),
            Text('Falsch',  style: TextStyle(color: Colors.red.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            Text('•', style: TextStyle(color: Colors.white.withOpacity(0.3))),
            const SizedBox(width: 16),
            Text('Richtig', style: TextStyle(color: Colors.green.withOpacity(0.7), fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 4),
            Icon(Icons.swipe_right, color: Colors.green.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }
}
