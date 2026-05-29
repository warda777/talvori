import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class TalvoriSpiritMascot extends StatefulWidget {
  const TalvoriSpiritMascot({
    super.key,
    required this.assetPath,
    this.size,
    this.isActive = false,
    this.glowIntensity = 1,
    this.compactMode = false,
    this.semanticLabel = 'Talvori Maskottchen',
  });

  final String assetPath;
  final double? size;
  final bool isActive;
  final double glowIntensity;
  final bool compactMode;
  final String semanticLabel;

  @override
  State<TalvoriSpiritMascot> createState() => _TalvoriSpiritMascotState();
}

class _TalvoriSpiritMascotState extends State<TalvoriSpiritMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _idleController.stop();
      _idleController.value = 0.5;
    } else if (!_idleController.isAnimating) {
      _idleController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        final boundedWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : widget.size ?? 120;
        final boundedHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : widget.size ?? 120;
        final width = widget.size ?? boundedWidth;
        final height = widget.size ?? boundedHeight;
        final glowIntensity = widget.glowIntensity.clamp(0.0, 1.4);
        final activeBoost = widget.isActive ? 1.14 : 1.0;
        final particleOpacity = widget.compactMode ? 0.48 : 0.68;

        return AnimatedBuilder(
          animation: _idleController,
          builder: (context, child) {
            final wave = math.sin(_idleController.value * math.pi * 2);
            final driftY = wave * (widget.compactMode ? 2.0 : 4.5);
            final breath = 1.0 + (wave * (widget.compactMode ? 0.008 : 0.014));

            return SizedBox(
              width: width,
              height: height,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpiritGlowPainter(
                        intensity: glowIntensity * activeBoost,
                        progress: _idleController.value,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpiritParticlePainter(
                        progress: _idleController.value,
                        opacity: particleOpacity,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(0, driftY),
                    child: Transform.scale(scale: breath, child: child),
                  ),
                ],
              ),
            );
          },
          child: RepaintBoundary(
            child: Image.asset(
              widget.assetPath,
              key: const Key('talvori-companion-mascot-image'),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              semanticLabel: widget.semanticLabel,
            ),
          ),
        );
      },
    );

    if (widget.size == null) return content;

    return SizedBox(width: widget.size, height: widget.size, child: content);
  }
}

class _SpiritGlowPainter extends CustomPainter {
  const _SpiritGlowPainter({required this.intensity, required this.progress});

  final double intensity;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final pulse = 0.92 + math.sin(progress * math.pi * 2) * 0.08;
    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = shortest * 0.43 * pulse;
    final glowRect = Rect.fromCircle(center: center, radius: radius);

    final glowPaint = Paint()
      ..shader = ui.Gradient.radial(
        center,
        radius,
        [
          const Color(0xFF9EF6FF).withValues(alpha: 0.18 * intensity),
          const Color(0xFF54C8FF).withValues(alpha: 0.10 * intensity),
          const Color(0xFF8A5CFF).withValues(alpha: 0.06 * intensity),
          Colors.transparent,
        ],
        const [0.0, 0.38, 0.68, 1.0],
      );
    canvas.drawOval(glowRect, glowPaint);

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = shortest * 0.012
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 8)
      ..color = const Color(0xFF80F7FF).withValues(alpha: 0.12 * intensity);
    canvas.drawOval(
      Rect.fromCenter(
        center: center.translate(0, shortest * 0.03),
        width: shortest * 0.78,
        height: shortest * 0.88,
      ),
      rimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _SpiritGlowPainter oldDelegate) {
    return oldDelegate.intensity != intensity ||
        oldDelegate.progress != progress;
  }
}

class _SpiritParticlePainter extends CustomPainter {
  const _SpiritParticlePainter({required this.progress, required this.opacity});

  final double progress;
  final double opacity;

  static const _particles = <_SpiritParticle>[
    _SpiritParticle(0.18, 0.28, 2.1, 0.0),
    _SpiritParticle(0.78, 0.22, 1.8, 0.3),
    _SpiritParticle(0.83, 0.43, 1.3, 0.6),
    _SpiritParticle(0.24, 0.66, 1.5, 0.8),
    _SpiritParticle(0.70, 0.76, 2.0, 0.2),
    _SpiritParticle(0.38, 0.84, 1.2, 0.5),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    for (final particle in _particles) {
      final phase = (progress + particle.phase) % 1.0;
      final twinkle = 0.45 + math.sin(phase * math.pi * 2) * 0.35;
      final offset = Offset(
        size.width * particle.dx,
        size.height * particle.dy + math.sin(phase * math.pi * 2) * 2.4,
      );
      final radius = shortest * 0.012 * particle.scale;
      final haloPaint = Paint()
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5)
        ..color = const Color(
          0xFF79F8FF,
        ).withValues(alpha: opacity * twinkle * 0.22);
      final corePaint = Paint()
        ..color = Colors.white.withValues(alpha: opacity * twinkle * 0.75);

      canvas.drawCircle(offset, radius * 2.4, haloPaint);
      canvas.drawCircle(offset, radius, corePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SpiritParticlePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.opacity != opacity;
  }
}

class _SpiritParticle {
  const _SpiritParticle(this.dx, this.dy, this.scale, this.phase);

  final double dx;
  final double dy;
  final double scale;
  final double phase;
}
