import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

/// Controller für die Rotation des Chrome-Icons
/// Asynchron zur GlowOrb-Animation (eigene Sequenz)
class RotatingChromeIconController {
  late AnimationController ctrl;
  late Animation<double> rotationAnimation;
  late Animation<double> fadeAnimation;
  static final math.Random _random = math.Random();

  void init({
    required TickerProvider vsync,
    Duration fadeInDuration = const Duration(milliseconds: 800),
    Duration rotationDuration = const Duration(milliseconds: 3000),
    Duration fadeOutDuration = const Duration(milliseconds: 800),
    Duration pauseDuration = const Duration(seconds: 10),
    bool loop = true,
  }) {
    final totalDuration =
        fadeInDuration + rotationDuration + fadeOutDuration + pauseDuration;

    ctrl = AnimationController(duration: totalDuration, vsync: vsync);

    final rotationStart =
        fadeInDuration.inMilliseconds / totalDuration.inMilliseconds;
    final rotationEnd =
        (fadeInDuration.inMilliseconds + rotationDuration.inMilliseconds) /
        totalDuration.inMilliseconds;

    rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: ctrl,
        curve: Interval(rotationStart, rotationEnd, curve: Curves.linear),
      ),
    );

    fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: fadeInDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: rotationDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: fadeOutDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: pauseDuration.inMilliseconds / totalDuration.inMilliseconds,
      ),
    ]).animate(ctrl);

    if (loop) {
      final randomDelay = Duration(milliseconds: _random.nextInt(5000));
      Future.delayed(randomDelay, () {
        try {
          ctrl.repeat();
        } catch (_) {}
      });
    }
  }

  void dispose() {
    if (ctrl.isAnimating) ctrl.stop();
    ctrl.dispose();
  }
}

/// Widget für das rotierende Chrome-Icon mit wechselnden Farben
/// Asynchron zur GlowOrb-Animation (eigene Sequenz)
class RotatingChromeIcon extends StatefulWidget {
  final Widget icon; // Das SvgPicture oder Icon
  final Duration
  duration; // Dauer einer Rotation (sollte mit GlowOrb übereinstimmen)
  final bool loop; // Endlos wiederholen
  final RotatingChromeIconController?
  controller; // Optional: externer Controller
  final List<Color> colors; // Farben, die sich während der Rotation ändern

  const RotatingChromeIcon({
    super.key,
    required this.icon,
    this.duration = const Duration(milliseconds: 3000),
    this.loop = true,
    this.controller,
    this.colors = const [
      Color(0xFFB1CCFE), // Hellblau
      Color(0xFFA05260), // Rötlich
      Color(0xFFE4B866), // Gelblich/Gold
    ],
  });

  @override
  State<RotatingChromeIcon> createState() => _RotatingChromeIconState();
}

class _RotatingChromeIconState extends State<RotatingChromeIcon>
    with SingleTickerProviderStateMixin {
  late RotatingChromeIconController _internalController;
  RotatingChromeIconController? _controller;
  bool _ownsController = false; // <— NEU

  @override
  void initState() {
    super.initState();

    // Verwende externen Controller oder erstelle internen
    _controller = widget.controller ?? RotatingChromeIconController();
    _ownsController = widget.controller == null;

    if (_ownsController) {
      _controller!.init(
        vsync: this,
        rotationDuration: widget.duration,
        loop: widget.loop,
      );
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller!.rotationAnimation,
      builder: (context, child) {
        final isActive = _controller!.ctrl.isAnimating;
        if (!widget.loop && !isActive) {
          return child!;
        }
        // Berechne die aktuelle Farbe basierend auf dem Rotationswert
        // Interpoliere sanft zwischen den Farben
        final rotationValue = _controller!.rotationAnimation.value;
        final colorProgress =
            (rotationValue * widget.colors.length) % widget.colors.length;
        final colorIndex = colorProgress.floor();
        final nextColorIndex = (colorIndex + 1) % widget.colors.length;
        final t =
            colorProgress -
            colorIndex; // Wert zwischen 0.0 und 1.0 für die Interpolation

        // Interpoliere zwischen den beiden Farben
        final currentColor =
            Color.lerp(
              widget.colors[colorIndex],
              widget.colors[nextColorIndex],
              t,
            ) ??
            widget.colors[colorIndex];

        // Wende ColorFilter auf das Icon an
        // Die Rotation wird extern in spinning_chrome_button.dart angewendet
        return ColorFiltered(
          colorFilter: ColorFilter.mode(currentColor, BlendMode.srcIn),
          child: child,
        );
      },
      child: widget.icon,
    );
  }
}
