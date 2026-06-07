import 'dart:math' as math;

import 'package:flutter/material.dart';

const _surfaceBackground = Color(0xFF050811);
const _surfacePanel = Color(0xFF0E1724);
const _surfaceOceanTop = Color(0xFF0B3147);
const _surfaceOceanBottom = Color(0xFF06111D);
const _surfaceLand = Color(0xFF23372D);
const _surfaceLandEdge = Color(0xFF9FF7D5);
const _surfaceCyan = Color(0xFF5DDCFF);
const _surfaceMint = Color(0xFF9FF7D5);
const _surfaceGold = Color(0xFFFFD980);
const _surfaceViolet = Color(0xFFB36BFF);

class CompactLocalWorldSurfacePreview extends StatefulWidget {
  const CompactLocalWorldSurfacePreview({super.key});

  @override
  State<CompactLocalWorldSurfacePreview> createState() =>
      _CompactLocalWorldSurfacePreviewState();
}

class _CompactLocalWorldSurfacePreviewState
    extends State<CompactLocalWorldSurfacePreview> {
  bool _isMarkerSelected = false;
  bool _isInfoOpen = false;

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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 430),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SurfaceNotice(),
                      const SizedBox(height: 12),
                      _SurfacePreviewCard(
                        isMarkerSelected: _isMarkerSelected,
                        isInfoOpen: _isInfoOpen,
                        onMarkerTap: _toggleMarkerSelection,
                        onInfoTap: _toggleInfo,
                        onResetTap: _resetPreview,
                      ),
                      const SizedBox(height: 10),
                      _SurfaceGuardrailPanel(
                        isMarkerSelected: _isMarkerSelected,
                      ),
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

  void _toggleMarkerSelection() {
    setState(() {
      _isMarkerSelected = !_isMarkerSelected;
      if (!_isMarkerSelected) {
        _isInfoOpen = false;
      }
    });
  }

  void _toggleInfo() {
    setState(() {
      _isInfoOpen = !_isInfoOpen;
    });
  }

  void _resetPreview() {
    setState(() {
      _isMarkerSelected = false;
      _isInfoOpen = false;
    });
  }
}

class _SurfaceNotice extends StatelessWidget {
  const _SurfaceNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-surface-notice'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _surfaceViolet.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _surfaceViolet.withValues(alpha: 0.34)),
      ),
      child: const Text(
        'Lokale World-Fläche / keine Route / keine Speicherung',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          height: 1.25,
          fontWeight: FontWeight.w800,
          letterSpacing: 0,
        ),
      ),
    );
  }
}

class _SurfacePreviewCard extends StatelessWidget {
  const _SurfacePreviewCard({
    required this.isMarkerSelected,
    required this.isInfoOpen,
    required this.onMarkerTap,
    required this.onInfoTap,
    required this.onResetTap,
  });

  final bool isMarkerSelected;
  final bool isInfoOpen;
  final VoidCallback onMarkerTap;
  final VoidCallback onInfoTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Kompakte lokale World Flaeche. Moeglicher Lernplatz. Noch kein Gebaeude. Keine Speicherung. Keine Platzierung.',
      child: Container(
        key: const Key('compact-local-world-surface-card'),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 13),
        decoration: BoxDecoration(
          color: _surfacePanel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _surfaceCyan.withValues(alpha: 0.26)),
          boxShadow: [
            BoxShadow(
              color: _surfaceCyan.withValues(alpha: 0.08),
              blurRadius: 26,
              spreadRadius: -12,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _SurfaceHeader(),
            const SizedBox(height: 11),
            AspectRatio(
              aspectRatio: 1.03,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const CustomPaint(painter: _WorldSurfacePainter()),
                    const Positioned(
                      top: 12,
                      left: 12,
                      child: _SurfaceStatusPill(
                        text: 'neutral',
                        color: _surfaceMint,
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      right: 12,
                      child: _SurfaceStatusPill(
                        text: 'lokal',
                        color: _surfaceCyan,
                      ),
                    ),
                    if (isMarkerSelected)
                      const Align(
                        alignment: Alignment(-0.18, 0.2),
                        child: _GhostPreviewSurface(),
                      ),
                    Align(
                      alignment: const Alignment(0.12, -0.06),
                      child: _CompactPlotMarker(
                        isSelected: isMarkerSelected,
                        onTap: onMarkerTap,
                      ),
                    ),
                    const Positioned(
                      left: 14,
                      right: 14,
                      bottom: 14,
                      child: _SurfaceLegend(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            _MarkerSelectionPanel(isMarkerSelected: isMarkerSelected),
            if (isMarkerSelected) ...[
              const SizedBox(height: 9),
              _PreviewActionRow(
                isInfoOpen: isInfoOpen,
                onInfoTap: onInfoTap,
                onResetTap: onResetTap,
              ),
              if (isInfoOpen) ...[
                const SizedBox(height: 9),
                const _PreviewInfoPanel(),
              ],
            ],
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
          'Kleine World-Fläche',
          style: TextStyle(
            color: Colors.white,
            fontSize: 19,
            height: 1.15,
            fontWeight: FontWeight.w900,
            letterSpacing: 0,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Ein neutraler Lernplatz in einer lokalen Vorschau. Noch kein Gebäude.',
          style: TextStyle(
            color: Color(0xB8FFFFFF),
            fontSize: 12,
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
  const _CompactPlotMarker({required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final markerAccent = isSelected ? _surfaceGold : _surfaceMint;
    final markerLabel = isSelected ? 'Lokal markiert' : 'Möglicher Lernplatz';

    return Semantics(
      button: true,
      toggled: isSelected,
      label:
          '$markerLabel. Nur Vorschau. Keine Speicherung. Keine Platzierung.',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              key: const Key('compact-local-world-plot-marker'),
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: markerAccent.withValues(alpha: isSelected ? 0.2 : 0.14),
                border: Border.all(
                  color: markerAccent,
                  width: isSelected ? 3.4 : 2.4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: markerAccent.withValues(
                      alpha: isSelected ? 0.42 : 0.28,
                    ),
                    blurRadius: isSelected ? 30 : 22,
                    spreadRadius: isSelected ? -1 : -4,
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.36),
                      ),
                    ),
                  ),
                  Icon(
                    isSelected
                        ? Icons.check_circle_outline_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: Colors.white,
                    size: isSelected ? 36 : 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 7),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF07101A).withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: markerAccent.withValues(alpha: 0.42)),
              ),
              child: Text(
                markerLabel,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarkerSelectionPanel extends StatelessWidget {
  const _MarkerSelectionPanel({required this.isMarkerSelected});

  final bool isMarkerSelected;

  @override
  Widget build(BuildContext context) {
    final color = isMarkerSelected ? _surfaceGold : _surfaceCyan;
    final title = isMarkerSelected
        ? 'Preview-Auswahl aktiv'
        : 'Marker antippen';
    final body = isMarkerSelected
        ? 'Nur lokal markiert. Vorschaufläche sichtbar. Keine Speicherung. Keine Platzierung.'
        : 'Tippe den neutralen Platz an, um ihn nur für diese Vorschau hervorzuheben.';

    return Container(
      key: const Key('compact-local-world-marker-info-panel'),
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.34)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isMarkerSelected
                ? Icons.check_circle_outline_rounded
                : Icons.touch_app_outlined,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xCFFFFFFF),
                    fontSize: 11,
                    height: 1.28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewActionRow extends StatelessWidget {
  const _PreviewActionRow({
    required this.isInfoOpen,
    required this.onInfoTap,
    required this.onResetTap,
  });

  final bool isInfoOpen;
  final VoidCallback onInfoTap;
  final VoidCallback onResetTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      key: const Key('compact-local-world-preview-actions'),
      spacing: 7,
      runSpacing: 7,
      alignment: WrapAlignment.center,
      children: [
        _PreviewActionChip(
          icon: isInfoOpen ? Icons.expand_less_rounded : Icons.info_outline,
          label: 'Mehr erfahren',
          color: _surfaceCyan,
          onTap: onInfoTap,
        ),
        _PreviewActionChip(
          icon: Icons.restart_alt_rounded,
          label: 'Vorschau zurücksetzen',
          color: _surfaceViolet,
          onTap: onResetTap,
        ),
      ],
    );
  }
}

class _PreviewActionChip extends StatelessWidget {
  const _PreviewActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label. Nur Vorschau. Keine Speicherung. Keine Platzierung.',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: color.withValues(alpha: 0.38)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewInfoPanel extends StatelessWidget {
  const _PreviewInfoPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-preview-info-panel'),
      padding: const EdgeInsets.fromLTRB(11, 10, 11, 10),
      decoration: BoxDecoration(
        color: _surfaceCyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _surfaceCyan.withValues(alpha: 0.28)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_outline_rounded, color: _surfaceCyan, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Nur Vorschau: Später könnte hier ein Lernbereich vorgeschlagen werden. Keine Speicherung. Keine Platzierung.',
              style: TextStyle(
                color: Color(0xD9FFFFFF),
                fontSize: 11,
                height: 1.28,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GhostPreviewSurface extends StatelessWidget {
  const _GhostPreviewSurface();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        key: const Key('compact-local-world-ghost-preview-surface'),
        width: 132,
        padding: const EdgeInsets.fromLTRB(10, 9, 10, 8),
        decoration: BoxDecoration(
          color: _surfaceCyan.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _surfaceCyan.withValues(alpha: 0.5),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: _surfaceCyan.withValues(alpha: 0.18),
              blurRadius: 20,
              spreadRadius: -7,
            ),
          ],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grid_view_rounded, color: Colors.white, size: 17),
            SizedBox(height: 4),
            Text(
              'Vorschaufläche',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                height: 1.12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Nur Vorschau',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xCFFFFFFF),
                fontSize: 9,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurfaceLegend extends StatelessWidget {
  const _SurfaceLegend();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-surface-legend'),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF06101B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: const Wrap(
        alignment: WrapAlignment.center,
        spacing: 6,
        runSpacing: 6,
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
  const _SurfaceGuardrailPanel({required this.isMarkerSelected});

  final bool isMarkerSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('compact-local-world-surface-guardrails'),
      padding: const EdgeInsets.fromLTRB(12, 11, 12, 11),
      decoration: BoxDecoration(
        color: _surfacePanel.withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _GuardrailRow(
            icon: isMarkerSelected
                ? Icons.check_circle_outline_rounded
                : Icons.radio_button_unchecked_rounded,
            text: isMarkerSelected
                ? 'Lokal markiert, nur Vorschau'
                : 'Antippbar, nur Vorschau',
          ),
          const SizedBox(height: 8),
          const _GuardrailRow(
            icon: Icons.landscape_rounded,
            text: 'Abstrakte Fläche, kein Asset',
          ),
          const SizedBox(height: 8),
          const _GuardrailRow(
            icon: Icons.domain_disabled_rounded,
            text: 'Noch kein Gebäude',
          ),
          const SizedBox(height: 8),
          const _GuardrailRow(
            icon: Icons.place_outlined,
            text: 'Keine Platzierung',
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
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.06);
    for (var i = 0; i < 5; i += 1) {
      final y = size.height * (0.18 + i * 0.13);
      final path = Path()..moveTo(size.width * 0.08, y);
      for (var step = 0; step <= 6; step += 1) {
        final x = size.width * (0.08 + step * 0.15);
        final waveY = y + math.sin(step + i * 0.7) * 4;
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
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawPath(islandPath.shift(const Offset(0, 10)), islandShadow);

    final islandPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFB8FFE0), _surfaceLandEdge, _surfaceLand],
        stops: [0, 0.46, 1],
      ).createShader(oceanRect);
    canvas.drawPath(islandPath, islandPaint);

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = _surfaceLandEdge.withValues(alpha: 0.42);
    canvas.drawPath(islandPath, edgePaint);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.53, size.height * 0.48),
        width: size.width * 0.34,
        height: size.height * 0.2,
      ),
      innerPaint,
    );

    final meadowPaint = Paint()
      ..color = const Color(0xFF7BEFB9).withValues(alpha: 0.16);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.42, size.height * 0.45),
        width: size.width * 0.2,
        height: size.height * 0.11,
      ),
      meadowPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.62, size.height * 0.54),
        width: size.width * 0.16,
        height: size.height * 0.09,
      ),
      meadowPaint,
    );

    final lightDotPaint = Paint()..color = Colors.white.withValues(alpha: 0.12);
    for (final point in [
      Offset(size.width * 0.36, size.height * 0.34),
      Offset(size.width * 0.69, size.height * 0.42),
      Offset(size.width * 0.3, size.height * 0.58),
    ]) {
      canvas.drawCircle(point, 2.2, lightDotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
