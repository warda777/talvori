import 'dart:math' as math;
import 'package:flutter/material.dart';

/// "Connecting Pieces" – leuchtende, sich zusammensetzende Puzzleteile.
/// Für die Kachel "Words I know".
class WordsIKnowPuzzleBackground extends StatefulWidget {
  const WordsIKnowPuzzleBackground({super.key, this.child});

  /// Optionaler Inhalt über dem Hintergrund (z. B. Label).
  final Widget? child;

  @override
  State<WordsIKnowPuzzleBackground> createState() =>
      _WordsIKnowPuzzleBackgroundState();
}

class _WordsIKnowPuzzleBackgroundState extends State<WordsIKnowPuzzleBackground>
    with SingleTickerProviderStateMixin {
  static const _gold = Color(0xFFFFC66A); // Gold wie bei "My words"
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final t = Curves.easeInOutCubic.transform(_c.value);
        final assemble = _assembleCurve(t); // 0..1: von verstreut -> verbunden
        return Stack(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: const [Color(0xFF020203), Color(0xFF000000)],
                ),
              ),
            ),
            // leichte Abdunklung, damit Glows nicht ausgrauen
            Container(color: Colors.black.withOpacity(0.35)),
            Positioned.fill(
              child: CustomPaint(painter: _GlowBackdropPainter(color: _gold)),
            ),
            // Puzzle-Ebene
            Positioned.fill(
              child: CustomPaint(
                painter: _PuzzlePainter(progress: assemble, color: _gold),
              ),
            ),
            if (widget.child != null) Positioned.fill(child: widget.child!),
          ],
        );
      },
    );
  }

  // Kleine „hold“-Phase im verbundenen Zustand.
  double _assembleCurve(double t) {
    // 0.00–0.70: zusammenfahren, 0.70–0.90: halten, 0.90–1.00: leicht auseinander
    if (t < 0.70) return t / 0.70;
    if (t < 0.90) return 1.0;
    return 1.0 - ((t - 0.90) / 0.10) * 0.12; // 12% auseinander für Loop
  }
}

class _GlowBackdropPainter extends CustomPainter {
  final Color color;
  _GlowBackdropPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) * 0.65;

    final halo = Paint()
      ..shader = RadialGradient(
        colors: [color.withOpacity(0.045), Colors.transparent],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: r * 0.9))
      ..blendMode = BlendMode.plus;
    canvas.drawCircle(center, r, halo);
  }

  @override
  bool shouldRepaint(covariant _GlowBackdropPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _PuzzlePainter extends CustomPainter {
  final double progress; // 0..1
  final Color color;
  _PuzzlePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final shortSide = math.min(size.width, size.height);
    final center = Offset(size.width / 2, size.height / 2);

    // Ziel-Quadrat (2x2 Pieces) – nimmt ~70% der Kachel ein
    final total = shortSide * 0.70;
    final cell = total / 2;

    // Ziel-Offsets der vier Teile (oben-links, oben-rechts, unten-links, unten-rechts)
    final targets = <Offset>[
      center + Offset(-cell, -cell) * 0.5, // TL
      center + Offset(cell, -cell) * 0.5, // TR
      center + Offset(-cell, cell) * 0.5, // BL
      center + Offset(cell, cell) * 0.5, // BR
    ];

    // Startpositionen (verstreut) & Startrotationen
    final starts = <Offset>[
      center + Offset(-total * 0.9, -total * 0.1),
      center + Offset(total * 0.8, -total * 0.5),
      center + Offset(-total * 0.7, total * 0.6),
      center + Offset(total * 0.9, total * 0.3),
    ];
    final startAngles = <double>[-0.35, 0.28, -0.22, 0.40];

    // Für jedes Teil: lerpe Position & Rotation in Richtung Ziel
    for (int i = 0; i < 4; i++) {
      final p = _smooth(progress, i);
      final pos = Offset(
        _lerp(starts[i].dx, targets[i].dx, p),
        _lerp(starts[i].dy, targets[i].dy, p),
      );
      final angle = _lerp(startAngles[i], 0.0, p);

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);

      // Piece zeichnen
      final piece = _piecePath(
        Size(cell, cell),
        // Tabs/Kerben definieren, damit die vier zusammenpassen:
        // TL: rechts=tab, unten=tab
        // TR: links=hole, unten=tab
        // BL: rechts=tab, oben=hole
        // BR: links=hole, oben=hole
        top: (i == 2 || i == 3) ? _Edge.hole : _Edge.flat,
        right: (i == 0 || i == 2)
            ? _Edge.tab
            : ((i == 1 || i == 3) ? _Edge.flat : _Edge.flat),
        bottom: (i == 0 || i == 1) ? _Edge.tab : _Edge.flat,
        left: (i == 1 || i == 3) ? _Edge.hole : _Edge.flat,
        radius: 18,
        tabSize: cell * 0.22,
      );

      // Outer glow
      final glow = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..color = color.withOpacity(0.24)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 22)
        ..blendMode = BlendMode.plus;
      canvas.drawPath(piece, glow);

      // Füllung (sehr transparent, damit es „dezent“ bleibt)
      final fill = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0C0D0F).withOpacity(0.28),
            const Color(0xFF0C0D0F).withOpacity(0.12),
          ],
        ).createShader(Offset.zero & Size(cell, cell));
      canvas.drawPath(piece, fill);

      // Leuchtende Kante
      final edge = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = color.withOpacity(0.95)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 6)
        ..blendMode = BlendMode.plus;
      canvas.drawPath(piece, edge);

      canvas.restore();
    }
  }

  // Sanftere, leicht versetzte Kurve je Teil
  double _smooth(double t, int i) {
    final delay = [0.00, 0.06, 0.12, 0.18][i];
    final x = ((t - delay) / (1.0 - delay)).clamp(0.0, 1.0);
    return Curves.easeOutBack.transform(x);
  }

  // Puzzle-Pfad mit Tabs/Holes (rund, dezent)
  Path _piecePath(
    Size size, {
    required _Edge top,
    required _Edge right,
    required _Edge bottom,
    required _Edge left,
    required double radius,
    required double tabSize,
  }) {
    final w = size.width;
    final h = size.height;
    final r = radius;

    Path edgePath(Offset from, Offset to, _Edge kind, bool isHorizontal) {
      final p = Path()..moveTo(from.dx, from.dy);
      if (kind == _Edge.flat) {
        p.lineTo(to.dx, to.dy);
        return p;
      }
      final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
      final out = tabSize * 0.65;
      final knob = (kind == _Edge.tab) ? out : -out;

      if (isHorizontal) {
        // --- horizontaler Rand: Welle nach oben/unten ---
        p.lineTo(mid.dx - tabSize * 0.45, mid.dy);
        p.cubicTo(
          mid.dx - tabSize * 0.25,
          mid.dy,
          mid.dx - tabSize * 0.25,
          mid.dy + knob,
          mid.dx,
          mid.dy + knob,
        );
        p.cubicTo(
          mid.dx + tabSize * 0.25,
          mid.dy + knob,
          mid.dx + tabSize * 0.25,
          mid.dy,
          mid.dx + tabSize * 0.45,
          mid.dy,
        );
        p.lineTo(to.dx, to.dy);
      } else {
        // --- vertikaler Rand: Welle nach links/rechts ---
        p.lineTo(mid.dx, mid.dy - tabSize * 0.45);
        p.cubicTo(
          mid.dx,
          mid.dy - tabSize * 0.25,
          mid.dx + knob,
          mid.dy - tabSize * 0.25,
          mid.dx + knob,
          mid.dy,
        );
        p.cubicTo(
          mid.dx + knob,
          mid.dy + tabSize * 0.25,
          mid.dx,
          mid.dy + tabSize * 0.25,
          mid.dx,
          mid.dy + tabSize * 0.45,
        );
        p.lineTo(to.dx, to.dy);
      }
      return p;
    }

    final path = Path();

    // Start oben links mit Rundung
    path.addRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
    );
    // Wir ersetzen die geraden Kanten mit Tabs/Holes:
    // Vorgehen: Kontur neu aufbauen
    final p = Path();

    // Top edge
    p.addPath(edgePath(Offset(r, 0), Offset(w - r, 0), top, true), Offset.zero);
    // Right edge
    p.addPath(
      edgePath(Offset(w, r), Offset(w, h - r), right, false),
      Offset.zero,
    );
    // Bottom edge
    p.addPath(
      edgePath(Offset(w - r, h), Offset(r, h), bottom, true),
      Offset.zero,
    );
    // Left edge
    p.addPath(
      edgePath(Offset(0, h - r), Offset(0, r), left, false),
      Offset.zero,
    );

    // Ecken abrunden & schließen
    final rounded = Path()
      ..moveTo(r, 0)
      ..addPath(p, Offset.zero)
      ..close();

    // Vereinen mit unsichtbarem RRect (für runde Ecken an Segmentenden)
    return Path.combine(
      PathOperation.union,
      Path()..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(r)),
      ),
      rounded,
    );
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _PuzzlePainter old) =>
      old.progress != progress || old.color != color;
}

enum _Edge { flat, tab, hole }
