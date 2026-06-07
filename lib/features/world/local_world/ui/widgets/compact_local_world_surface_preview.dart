import 'dart:math' as math;

import 'package:flutter/material.dart';

const _surfaceBackground = Color(0xFF060A12);
const _surfacePanel = Color(0xFF101927);
const _surfaceOceanTop = Color(0xFF0A273B);
const _surfaceOceanBottom = Color(0xFF07121E);
const _surfaceLand = Color(0xFF243A2F);
const _surfaceLandEdge = Color(0xFF9FF7D5);
const _surfaceCyan = Color(0xFF5DDCFF);
const _surfaceMint = Color(0xFF9FF7D5);
const _surfaceGold = Color(0xFFFFD980);
const _surfaceViolet = Color(0xFFB36BFF);

class CompactLocalWorldSurfacePreview extends StatelessWidget {
  const CompactLocalWorldSurfacePreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: _surfaceBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _surfaceMint,
        brightness: Brightness.dark,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: theme,
        child: Material(
          color: _surfaceBackground,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SurfaceNotice(),
                      SizedBox(height: 14),
                      _SurfacePreviewCard(),
                      SizedBox(height: 12),
                      _SurfaceGuardrailPanel(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SurfaceNotice extends StatelessWidget {
  const _SurfaceNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-surface-notice'),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
      decoration: BoxDecoration(
        color: _surfaceViolet.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: _surfaceViolet.withValues(alpha: 0.4)),
      ),
      child: const Text(
        'Lokale World-Fläche / keine Route / keine Speicherung',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.25,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SurfacePreviewCard extends StatelessWidget {
  const _SurfacePreviewCard();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Kompakte lokale World Flaeche. Moeglicher Lernplatz. Noch kein Gebaeude. Keine Speicherung. Keine Platzierung.',
      child: Container(
        key: const Key('compact-local-world-surface-card'),
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 14),
        decoration: BoxDecoration(
          color: _surfacePanel,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: _surfaceCyan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: _surfaceCyan.withValues(alpha: 0.1),
              blurRadius: 30,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SurfaceHeader(),
            const SizedBox(height: 13),
            AspectRatio(
              aspectRatio: 1.08,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: const Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: _WorldSurfacePainter()),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: _SurfaceStatusPill(
                        text: 'neutral',
                        color: _surfaceMint,
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: _SurfaceStatusPill(
                        text: 'lokal',
                        color: _surfaceCyan,
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.12, -0.06),
                      child: _CompactPlotMarker(),
                    ),
                    Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: _SurfaceLegend(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceHeader extends StatelessWidget {
  const _SurfaceHeader();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kompakte lokale World-Fläche',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1.15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Ein sichtbarer Inselbereich mit einem neutralen Lernplatz. Noch kein Gebäude und keine echte Platzierung.',
          style: TextStyle(
            color: Color(0xB8FFFFFF),
            fontSize: 13,
            height: 1.32,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _CompactPlotMarker extends StatelessWidget {
  const _CompactPlotMarker();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          key: const Key('compact-local-world-plot-marker'),
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _surfaceMint.withValues(alpha: 0.14),
            border: Border.all(color: _surfaceMint, width: 2.4),
            boxShadow: [
              BoxShadow(
                color: _surfaceMint.withValues(alpha: 0.28),
                blurRadius: 24,
                spreadRadius: -4,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.36),
                  ),
                ),
              ),
              const Icon(
                Icons.radio_button_unchecked_rounded,
                color: Colors.white,
                size: 34,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF07101A).withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _surfaceMint.withValues(alpha: 0.38)),
          ),
          child: const Text(
            'Möglicher Lernplatz',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.15,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _SurfaceLegend extends StatelessWidget {
  const _SurfaceLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-surface-legend'),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFF06101B).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: const Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          _SurfaceStatusPill(text: 'Noch kein Gebäude', color: _surfaceGold),
          _SurfaceStatusPill(text: 'Keine Speicherung', color: _surfaceCyan),
          _SurfaceStatusPill(text: 'Keine Platzierung', color: _surfaceMint),
        ],
      ),
    );
  }
}

class _SurfaceGuardrailPanel extends StatelessWidget {
  const _SurfaceGuardrailPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-surface-guardrails'),
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        color: _surfacePanel,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GuardrailRow(
            icon: Icons.landscape_rounded,
            text: 'Abstrakte Fläche, kein Inselasset',
          ),
          SizedBox(height: 9),
          _GuardrailRow(
            icon: Icons.domain_disabled_rounded,
            text: 'Kein Gebäude und kein Bauzustand',
          ),
          SizedBox(height: 9),
          _GuardrailRow(
            icon: Icons.place_outlined,
            text: 'Keine Koordinaten und keine Platzierungslogik',
          ),
        ],
      ),
    );
  }
}

class _SurfaceStatusPill extends StatelessWidget {
  const _SurfaceStatusPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1.1,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _GuardrailRow extends StatelessWidget {
  const _GuardrailRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _surfaceCyan, size: 18),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xCCFFFFFF),
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
        ),
      ],
    );
  }
}

class _WorldSurfacePainter extends CustomPainter {
  const _WorldSurfacePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final oceanRect = Offset.zero & size;
    final oceanPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_surfaceOceanTop, _surfaceOceanBottom],
      ).createShader(oceanRect);

    canvas.drawRect(oceanRect, oceanPaint);

    final ripplePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.07);
    for (var i = 0; i < 5; i += 1) {
      final y = size.height * (0.18 + i * 0.13);
      final path = Path()..moveTo(size.width * 0.08, y);
      for (var step = 0; step <= 6; step += 1) {
        final x = size.width * (0.08 + step * 0.15);
        final waveY = y + math.sin(step + i * 0.7) * 5;
        path.lineTo(x, waveY);
      }
      canvas.drawPath(path, ripplePaint);
    }

    final islandPath = Path()
      ..moveTo(size.width * 0.2, size.height * 0.48)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.28,
        size.width * 0.39,
        size.height * 0.17,
        size.width * 0.58,
        size.height * 0.21,
      )
      ..cubicTo(
        size.width * 0.8,
        size.height * 0.25,
        size.width * 0.86,
        size.height * 0.46,
        size.width * 0.76,
        size.height * 0.61,
      )
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.78,
        size.width * 0.37,
        size.height * 0.76,
        size.width * 0.25,
        size.height * 0.62,
      )
      ..cubicTo(
        size.width * 0.21,
        size.height * 0.58,
        size.width * 0.2,
        size.height * 0.53,
        size.width * 0.2,
        size.height * 0.48,
      )
      ..close();

    final islandShadow = Paint()
      ..color = Colors.black.withValues(alpha: 0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawPath(islandPath.shift(const Offset(0, 10)), islandShadow);

    final islandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [_surfaceLandEdge, _surfaceLand],
      ).createShader(oceanRect);
    canvas.drawPath(islandPath, islandPaint);

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _surfaceLandEdge.withValues(alpha: 0.46);
    canvas.drawPath(islandPath, edgePaint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.53, size.height * 0.48),
        width: size.width * 0.36,
        height: size.height * 0.22,
      ),
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
