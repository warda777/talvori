import 'dart:math' as math;
import 'package:flutter/material.dart';

class MyWordsBackground extends StatelessWidget {
  final Widget? child; // optionaler Inhalt über dem Hintergrund
  const MyWordsBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // dunkler, weicher Hintergrund
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.2),
              radius: 1.0,
              colors: [Color(0xFF0E0F12), Color(0xFF0A0B0E)],
              stops: [0.2, 1.0],
            ),
          ),
        ),

        // Glow-Flares im Hintergrund
        _goldGlow(const Offset(-120, 40), 220),
        _goldGlow(const Offset(140, -60), 180),
        _goldGlow(const Offset(80, 180), 240, opacity: .18),

        // Schwebende Notizzettel (leicht transparent + Kanten-Glow)
        _FloatingNote(
          size: const Size(270, 210),
          angleDeg: -12,
          offset: const Offset(-14, -6),
          depth: 0.6,
        ),
        _FloatingNote(
          size: const Size(280, 220),
          angleDeg: -4,
          offset: const Offset(8, 18),
          depth: 0.8,
        ),
        _FloatingNote(
          size: const Size(300, 230),
          angleDeg: 6,
          offset: const Offset(22, 36),
          depth: 1.0, // vorderster Zettel
          strongEdge: true,
        ),

        // Kind oben drauf
        if (child != null) Positioned.fill(child: child!),
      ],
    );
  }

  static Widget _goldGlow(Offset center, double radius, {double opacity = .22}) {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _GlowPainter(
            center: center,
            radius: radius,
            color: const Color(0xFFFFC66A).withOpacity(opacity),
          ),
        ),
      ),
    );
  }
}

class _FloatingNote extends StatefulWidget {
  final Size size;
  final double angleDeg;
  final Offset offset;
  final double depth;       // 0..1 für Z-Reihenfolge/Transparenz
  final bool strongEdge;    // vorderster Zettel: stärkere Kante

  const _FloatingNote({
    required this.size,
    required this.angleDeg,
    required this.offset,
    required this.depth,
    this.strongEdge = false,
  });

  @override
  State<_FloatingNote> createState() => _FloatingNoteState();
}

class _FloatingNoteState extends State<_FloatingNote>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 6))
        ..repeat(reverse: true);

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final baseOpacity = 0.25 + 0.35 * widget.depth;
    final edgeOpacity  = widget.strongEdge ? 0.9 : (0.55 + 0.25 * widget.depth);
    final glowOpacity  = widget.strongEdge ? 0.45 : (0.25 + 0.15 * widget.depth);

    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        // sanftes Schweben + minimales Kippen
        final t = Curves.easeInOut.transform(_c.value);
        final dy = Tween(begin: -4.0, end: 6.0).transform(t);
        final da = Tween(begin: -0.7, end: 0.7).transform(t);

        return Positioned.fill(
          child: Transform.translate(
            offset: widget.offset + Offset(0, dy),
            child: Transform.rotate(
              angle: (widget.angleDeg + da) * math.pi / 180,
              child: Center(
                child: CustomPaint(
                  size: widget.size,
                  painter: _NotePainter(
                    fillColor: const Color(0xFF131418).withOpacity(baseOpacity),
                    edgeColor: const Color(0xFFFFD085).withOpacity(edgeOpacity),
                    glowColor: const Color(0xFFFFB857).withOpacity(glowOpacity),
                    corner: 22,
                    edgeWidth: 1.2,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NotePainter extends CustomPainter {
  final Color fillColor, edgeColor, glowColor;
  final double corner, edgeWidth;

  _NotePainter({
    required this.fillColor,
    required this.edgeColor,
    required this.glowColor,
    required this.corner,
    required this.edgeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size, Radius.circular(corner),
    );

    // Outer glow (weiche goldene Aura)
    final glowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 24);
    canvas.drawRRect(rrect, glowPaint);

    // Füllung (leicht transparent)
    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [fillColor.withOpacity(.85), fillColor.withOpacity(.55)],
      ).createShader(Offset.zero & size);
    canvas.drawRRect(rrect, fill);

    // feine, leuchtende Kante
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = edgeWidth
      ..color = edgeColor;
    canvas.drawRRect(rrect.deflate(edgeWidth * .5), edge);
  }

  @override
  bool shouldRepaint(covariant _NotePainter old) =>
      old.fillColor != fillColor ||
      old.edgeColor != edgeColor ||
      old.glowColor != glowColor;
}

class _GlowPainter extends CustomPainter {
  final Offset center;
  final double radius;
  final Color color;

  _GlowPainter({required this.center, required this.radius, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2 + center.dx, size.height / 2 + center.dy);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0)],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: radius));
    canvas.drawCircle(c, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _GlowPainter old) =>
      old.center != center || old.radius != radius || old.color != color;
}
