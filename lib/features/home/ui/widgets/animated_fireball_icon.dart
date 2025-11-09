import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedFireballIconController {
  _AnimatedFireballIconState? _state;

  bool get isAnimating => _state?._isPlaying ?? false;

  void play() => _state?._playFromController();

  void _attach(_AnimatedFireballIconState state) {
    _state = state;
  }

  void _detach(_AnimatedFireballIconState state) {
    if (_state == state) {
      _state = null;
    }
  }
}

/// Animiertes Fireball-Icon mit optionalem Auto-Play
class AnimatedFireballIcon extends StatefulWidget {
  final double size;
  final Color baseColor; // Ursprungsfarbe (z.B. gold)
  final Color animationColor; // Farbe während der Animation (#A05260)
  final Duration animationInterval; // Intervall zwischen Auto-Animationen
  final Duration animationDuration; // Dauer der Animation
  final bool autoPlay;
  final AnimatedFireballIconController? controller;

  const AnimatedFireballIcon({
    super.key,
    required this.size,
    required this.baseColor,
    this.animationColor = const Color(0xFFA05260),
    this.animationInterval = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 800),
    this.autoPlay = true,
    this.controller,
  });

  @override
  State<AnimatedFireballIcon> createState() => _AnimatedFireballIconState();
}

class _AnimatedFireballIconState extends State<AnimatedFireballIcon>
    with TickerProviderStateMixin {
  late final AnimationController _colorController;
  late final AnimationController _flameController;
  late final AnimationController _wobbleController;
  late final AnimationController _repaintController;
  late final Animation<Color?> _colorAnimation;
  late final Animation<double> _flameAnimation;
  late final Animation<double> _wobbleAnimation;

  AnimatedFireballIconController? _externalController;
  Timer? _autoPlayTimer;
  bool _autoPlayEnabled = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();

    _colorController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _flameController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _wobbleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _repaintController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    )..repeat();

    _colorAnimation = TweenSequence<Color?>([
      TweenSequenceItem(
        tween: ColorTween(
          begin: widget.baseColor,
          end: widget.animationColor,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.1,
      ),
      TweenSequenceItem(
        tween: ConstantTween<Color?>(widget.animationColor),
        weight: 0.8,
      ),
      TweenSequenceItem(
        tween: ColorTween(
          begin: widget.animationColor,
          end: widget.baseColor,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.1,
      ),
    ]).animate(_colorController);

    _flameAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.06,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 0.88),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.06,
      ),
    ]).animate(_flameController);

    _wobbleAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _wobbleController, curve: Curves.easeInOut),
    );

    _attachController(widget.controller);
    _autoPlayEnabled = widget.autoPlay;
    if (_autoPlayEnabled) {
      _scheduleNextAutoPlay(immediate: true);
    }
  }

  void _attachController(AnimatedFireballIconController? controller) {
    if (controller == _externalController) return;
    _externalController?._detach(this);
    _externalController = controller;
    _externalController?._attach(this);
  }

  void _scheduleNextAutoPlay({bool immediate = false}) {
    if (!_autoPlayEnabled) return;
    _autoPlayTimer?.cancel();
    final delay = immediate ? Duration.zero : widget.animationInterval;
    _autoPlayTimer = Timer(delay, () {
      if (!mounted || !_autoPlayEnabled) return;
      _runAnimation(scheduleNext: true);
    });
  }

  void _runAnimation({bool scheduleNext = false}) {
    if (!mounted || _isPlaying) return;
    _isPlaying = true;

    _colorController.forward(from: 0.0).whenComplete(() {
      if (!mounted) return;
      _colorController.reset();
      _isPlaying = false;
      if (_autoPlayEnabled && scheduleNext) {
        _scheduleNextAutoPlay();
      }
    });

    _flameController.forward(from: 0.0).whenComplete(() {
      if (!mounted) return;
      _flameController.reset();
      _wobbleController.stop();
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _flameController.isAnimating) {
        _wobbleController.repeat(reverse: true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant AnimatedFireballIcon oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _attachController(widget.controller);
    }

    if (widget.autoPlay != oldWidget.autoPlay) {
      _autoPlayEnabled = widget.autoPlay;
      if (_autoPlayEnabled) {
        _scheduleNextAutoPlay(immediate: true);
      } else {
        _autoPlayTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _colorController.dispose();
    _flameController.dispose();
    _wobbleController.dispose();
    _repaintController.dispose();
    _externalController?._detach(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _colorAnimation,
          builder: (_, __) {
            return SvgPicture.asset(
              'assets/icons/fireball_black.svg',
              width: widget.size,
              height: widget.size,
              colorFilter: ColorFilter.mode(
                _colorAnimation.value ?? widget.baseColor,
                BlendMode.srcIn,
              ),
            );
          },
        ),
        AnimatedBuilder(
          animation: Listenable.merge([
            _flameAnimation,
            _wobbleAnimation,
            _repaintController,
          ]),
          builder: (_, __) {
            if (_flameAnimation.value <= 0) {
              return const SizedBox.shrink();
            }

            return CustomPaint(
              size: Size(widget.size * 2.5, widget.size * 2.5),
              painter: _FlamePainter(
                opacity: _flameAnimation.value,
                wobble: _wobbleAnimation.value,
                color: widget.animationColor,
              ),
            );
          },
        ),
      ],
    );
  }

  // Schnittstelle für den Controller
  void _playFromController() => _runAnimation(scheduleNext: _autoPlayEnabled);
}

class _FlamePainter extends CustomPainter {
  final double opacity;
  final double wobble;
  final Color color;

  _FlamePainter({
    required this.opacity,
    required this.wobble,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final time = DateTime.now().millisecondsSinceEpoch / 100.0;

    for (int i = 0; i < 12; i++) {
      final baseAngle = (i * 2 * math.pi) / 12;
      final wobbleOffset = wobble * 8.0 * math.sin(baseAngle * 2);
      final angle = baseAngle + wobbleOffset * 0.1;

      final baseDistance = size.width * 0.35;
      final dynamicDistance =
          baseDistance + math.sin(time * 0.5 + i * 0.5) * size.width * 0.1;

      final x = center.dx + math.cos(angle) * dynamicDistance;
      final y = center.dy + math.sin(angle) * dynamicDistance;

      final baseWidth = size.width * 0.12;
      final baseHeight = size.width * 0.2;
      final pulse = 1.0 + math.sin(time + i) * 0.3;
      final flameWidth = baseWidth * opacity * pulse;
      final flameHeight = baseHeight * opacity * pulse;

      final gradient = RadialGradient(
        colors: [
          color.withOpacity(opacity * 0.9),
          color.withOpacity(opacity * 0.6),
          color.withOpacity(opacity * 0.3),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCenter(
            center: Offset(x, y),
            width: flameWidth,
            height: flameHeight,
          ),
        )
        ..style = PaintingStyle.fill;

      final flamePath = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: flameWidth,
            height: flameHeight,
          ),
        );

      canvas.drawPath(flamePath, paint);

      if (i % 2 == 0) {
        final smallX = x + math.cos(angle + math.pi / 4) * flameWidth * 0.3;
        final smallY = y + math.sin(angle + math.pi / 4) * flameHeight * 0.3;

        final smallPaint = Paint()
          ..color = color.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(
          Offset(smallX, smallY),
          flameWidth * 0.15,
          smallPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) {
    return true;
  }
}
