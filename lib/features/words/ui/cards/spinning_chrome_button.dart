import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/gestures.dart';
import 'chrome_spin_controller.dart';
import 'rotating_chrome_icon.dart';
import 'chrome_sparks.dart';

/// Button-View: vereint Gesten (Down-Swipe), Spin-Burst, Funken-Overlay
/// und bewahrt deine bestehende Farbrotation (RotatingChromeIcon).
class SpinningChromeButton extends StatefulWidget {
  final String svgAsset;      // z.B. 'assets/icons/line_chrome.svg'
  final double size;          // z.B. 56
  final Duration baseRotationDuration; // z.B. 3000 ms
  final bool loop;
  final ColorFilter? colorFilter; // aus WordCard übergeben
  final VoidCallback? onTap;      // bestehendes onChromeButtonTap

  const SpinningChromeButton({
    super.key,
    required this.svgAsset,
    this.size = 56,
    this.baseRotationDuration = const Duration(milliseconds: 3000),
    this.loop = true,
    this.colorFilter,
    this.onTap,
  });

  @override
  State<SpinningChromeButton> createState() => _SpinningChromeButtonState();
}

class _SpinningChromeButtonState extends State<SpinningChromeButton>
    with TickerProviderStateMixin {
  final _spin = ChromeSpinController();
  final _sparks = ChromeSparks(); // Partikel-Emitter

  late final RotatingChromeIconController _colorRotController;
  double _burstRotation = 0.0; // zusätzliche Rotation (in Umdrehungen)
  Offset? _lastDragPos;
  double _swipeAccumulator = 0.0; // aufsummierter Down-Swipe
  double _ringOpacity = 0.0; // Opacity für Ring (0.0 bis 1.0)
  bool _rotationGlow = false; // Glow während Rotation
  double _omegaLP = 0.0;     // gefilterte Drehzahl (U/s)
  double _ringPulse = 0.0;   // kurzer Anfangs-Puls (0..1), decayed separat

  @override
  void initState() {
    super.initState();
    _colorRotController = RotatingChromeIconController();
    _colorRotController.init(
      vsync: this,
      rotationDuration: widget.baseRotationDuration,
      loop: widget.loop,
    );

    _spin.attachTicker(this, (dt) {
      final addRot = _spin.step(dt); // Umdrehungen im dt
      if (addRot != 0) {
        setState(() => _burstRotation += addRot);
      }

      // Partikel
      if (_sparks.tick(dt)) setState(() {});

      // Gefilterte Drehzahl (Umdrehungen/Sekunde):
      final double instOmega = (dt > 0) ? (addRot.abs() / dt) : 0.0;
      // Low-Pass Filter: träge Reaktion -> natürlicher Fade-Start
      _omegaLP = _omegaLP * 0.90 + instOmega * 0.10;
      // deutlich schnellerer Abklinger (Tau ≈ 0.2 s) + Hard-Zero wenn nichts mehr rotiert
      _omegaLP *= math.exp(-dt / 0.2);
      if (!_spin.isActive && instOmega == 0.0) _omegaLP = 0.0;

      // Rotation Glow bleibt an/aus wie gehabt
      final rotationActive = _spin.isActive;
      if (_rotationGlow != rotationActive) {
        setState(() => _rotationGlow = rotationActive);
      }

      // Ring: kurzer Puls + geschwindigkeitsgekoppelter Fade
      // - Pulse decayed schnell (≈120ms)
      // - Fade-Faktor fällt proportional zur Drehzahl (startet deutlich VOR Stillstand)
      if (_ringPulse > 0.0) {
        _ringPulse = (_ringPulse - dt / 0.01).clamp(0.0, 1.0);
      }
      // Schwellwert für "Fade beginnt während er noch dreht":
      // z.B. 2.0 U/s -> darunter Blend-Out, darüber volle Helligkeit
      const double fadeStartOmega = 3.0;
      final double velFactor = (_omegaLP / fadeStartOmega).clamp(0.0, 1.0);
      final double targetOpacity = (_ringPulse > 0 ? _ringPulse : velFactor);

      // Wenn Ziel <= aktueller Wert → hartes Abklingen (ca. 100–150 ms)
      if (targetOpacity <= _ringOpacity) {
        _ringOpacity = (_ringOpacity - dt / 0.12).clamp(0.0, 1.0);
      } else {
        // kurzes Ansteigen erlaubt, aber gedämpft
        _ringOpacity += (targetOpacity - _ringOpacity) * 0.35;
      }

      setState(() {});
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _colorRotController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails d) {
    _ringPulse = 1.0;   // kurzer Aufleucht-Puls
    _ringOpacity = 1.0; // einmalig für den ersten Frame ok
    _lastDragPos = d.localPosition;
    _swipeAccumulator = 0.0;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_lastDragPos == null) return;
    final dy = d.delta.dy; // >0 = nach unten
    _swipeAccumulator += dy;
    _lastDragPos = d.localPosition;

    // Leichte Glühfunken schon während der Geste:
    if (dy > 0) {
      _sparks.emitWheelBurst(
        center: Offset(widget.size / 2, widget.size / 2),
        radius: widget.size * 0.46,
        count: (16 + dy.clamp(0, 10)).round(),
        baseSpeed: 420,
        radialBias: 1.0,
        tangentialBias: 0.3,
        gravity: 500,
        life: const Duration(milliseconds: 700),
      );
    }
  }

  void _onPanEnd(DragEndDetails d) {
    // Schwellwert: swipe nach unten => Impuls auf Spin
    // vx/vy in px/s; wir nutzen nur vy (nach unten positiv)
    final vy = d.velocity.pixelsPerSecond.dy;
    // Kombiniere Gestenweg + Geschwindigkeit zu einem Impuls
    final gestureScore = (_swipeAccumulator.clamp(0.0, 300.0) / 300.0) +
        (vy.clamp(0.0, 2500.0) / 2500.0);

    if (gestureScore > 0.15) {
      // Impuls in Umdrehungen/Sekunde (skaliert)
      final impulse = (gestureScore * 6.0).clamp(0.6, 6.0);
      _spin.addImpulse(impulse);

      // kräftiger Funken-Burst beim Loslassen:
      _sparks.emitWheelBurst(
        center: Offset(widget.size / 2, widget.size / 2),
        radius: widget.size * 0.46,
        count: (200 + impulse * 60).round(),
        baseSpeed: 520 + impulse * 80,
        radialBias: 1.0,
        tangentialBias: 0.35,   // 0.25–0.45 je nach gewünschter Krümmung
        gravity: 500,
        life: const Duration(milliseconds: 1050),
      );
      setState(() {});
    }

    _lastDragPos = null;
    _swipeAccumulator = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    // Grundrotation (dein Farbwechsel) + Burstrotation (schnell)
    final baseRot = _colorRotController.rotationAnimation.value * 2 * math.pi;
    final addRot = _burstRotation * 2 * math.pi;

    // Icon als Kind vorbereiten (mit optionalem Filter)
    Widget icon = SvgPicture.asset(
      widget.svgAsset,
      width: widget.size,
      height: widget.size,
      colorFilter: widget.colorFilter,
    );

    // Wir wollen weiterhin die Farb-Interpolation deines RotatingChromeIcon nutzen.
    // Darum rendern wir das RotatingChromeIcon "unsichtbar" und holen uns nur dessen
    // Farb-Interpolation via ColorFiltered im Child (wie gehabt).
    final coloredIcon = RotatingChromeIcon(
      controller: _colorRotController,
      duration: widget.baseRotationDuration,
      loop: widget.loop,
      icon: icon,
    );

    return RepaintBoundary(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glühender Außenring (unter dem Icon) - mit Fade-Out
              if (_ringOpacity > 0.0)
                Opacity(
                  opacity: _ringOpacity,
                  child: CustomPaint(
                    size: Size(widget.size, widget.size),
                    painter: _RingGlowPainter(
                      core: const Color(0xFFFF7A2A),              // sattes Orange
                      halo: const Color(0xFFFF6A00).withOpacity(0.22),
                    ),
                  ),
                ),
              // Rotation Glow (um das Icon während Rotation)
              if (_rotationGlow)
                CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: _RotationGlowPainter(),
                ),
              // Gesamtdrehung = Basis + Burst
              Transform.rotate(
                angle: baseRot + addRot,
                child: coloredIcon,
              ),
              // Funken-Overlay
              IgnorePointer(
                child: CustomPaint(
                  size: Size(widget.size, widget.size),
                  painter: ChromeSparksPainter(_sparks.particles),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingGlowPainter extends CustomPainter {
  final Color core, halo;
  const _RingGlowPainter({required this.core, required this.halo});

  @override
  void paint(Canvas c, Size s) {
    final r = s.width * 0.46;
    final ctr = Offset(s.width/2, s.height/2);
    final pHalo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..color = halo;
    final pCore = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..color = core;
    c.drawCircle(ctr, r, pHalo);
    c.drawCircle(ctr, r, pCore);
  }
  @override
  bool shouldRepaint(_) => false;
}

class _RotationGlowPainter extends CustomPainter {
  @override
  void paint(Canvas c, Size s) {
    final center = Offset(s.width / 2, s.height / 2);
    final radius = s.width * 0.5; // Etwas größer als das Icon
    
    // Äußerer Halo (weicher Glow)
    final haloPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFFF7A2A).withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    c.drawCircle(center, radius, haloPaint);
    
    // Mittlerer Ring
    final midPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = const Color(0xFFFF6A00).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    c.drawCircle(center, radius * 0.85, midPaint);
    
    // Innerer Core
    final corePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFF7A2A).withOpacity(0.4);
    c.drawCircle(center, radius * 0.85, corePaint);
  }
  
  @override
  bool shouldRepaint(_) => false;
}
