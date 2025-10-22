import 'dart:async';
import 'package:flutter/material.dart';

/// TapFlash: kurzer Glow/Flash beim Tippen, dann onTapAfter().
/// - Für Kreise: [shape] = BoxShape.circle
/// - Für Pillen/Buttons: [shape] = BoxShape.rectangle + [borderRadius]
class TapFlash extends StatefulWidget {
  final Widget child;
  final FutureOr<void> Function()? onTapAfter;
  final Color color;
  final Duration duration;       // Gesamtdauer (hin & zurück)
  final double maxOpacity;       // 0..1, Helligkeit des Flash
  final double blur;             // Weichheit des Glows
  final double spread;           // Ausbreitung (Pixel)
  final BoxShape shape;          // circle / rectangle
  final BorderRadius? borderRadius; // für rectangle

  const TapFlash({
    super.key,
    required this.child,
    this.onTapAfter,
    required this.color,
    this.duration = const Duration(milliseconds: 240),
    this.maxOpacity = 0.85,
    this.blur = 18,
    this.spread = 6,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  State<TapFlash> createState() => _TapFlashState();
}

class _TapFlashState extends State<TapFlash> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _a = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  bool _running = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _run() async {
    if (_running) return;
    _running = true;
    try {
      await _c.forward();
      if (mounted) await _c.reverse();
      final cb = widget.onTapAfter;
      if (cb != null) await cb();
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Der Glow sitzt als Overlay über dem Child und wird per Opacity animiert.
    final borderRadius = widget.borderRadius ?? BorderRadius.circular(20);

    final glow = AnimatedBuilder(
      animation: _a,
      builder: (_, __) {
        final opacity = _a.value * widget.maxOpacity;
        final color = widget.color.withValues(alpha: opacity);

        final decoration = widget.shape == BoxShape.circle
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: widget.blur, spreadRadius: widget.spread),
                ],
              )
            : BoxDecoration(
                borderRadius: borderRadius,
                boxShadow: [
                  BoxShadow(color: color, blurRadius: widget.blur, spreadRadius: widget.spread),
                ],
              );

        return IgnorePointer(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 1),
            opacity: opacity > 0 ? 1 : 0,
            child: Container(decoration: decoration),
          ),
        );
      },
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _run,
      child: Stack(
        fit: StackFit.passthrough,
        alignment: Alignment.center,
        children: [
          widget.child,
          Positioned.fill(child: glow),
        ],
      ),
    );
  }
}
