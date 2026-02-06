// lib/features/words/ui/widgets/frozen_stage_switch_overlay.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/application.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

/// Overlay-Widget, das eine einzelne Stage-Switch optisch "einfriert" (Eis/Schnee-Effekt).
/// Wird pro Switch verwendet, nicht für die gesamte Row.
class FrozenStageSwitchOverlay extends StatefulWidget {
  final Widget child; // Die einzelne Switch
  final bool isFrozen; // Ob diese Switch eingefroren sein soll
  final int stageIndex; // Stage-Index (0-5) für unterschiedliche Schneeflocken-Verteilung

  const FrozenStageSwitchOverlay({
    super.key,
    required this.child,
    required this.isFrozen,
    this.stageIndex = 0, // Default für Rückwärtskompatibilität
  });

  @override
  State<FrozenStageSwitchOverlay> createState() => _FrozenStageSwitchOverlayState();
}

class _FrozenStageSwitchOverlayState extends State<FrozenStageSwitchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    // AnimationController für kontinuierliche Schneeflocken-Animationen
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30), // 30 Sekunden für eine komplette Animation (deutlicher sichtbar)
    )..repeat(); // Kontinuierlich wiederholen
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFrozen) {
      return widget.child;
    }

    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        // Original-Switch (Column mit Container + Label)
        widget.child,
        
        // Eis/Schnee-Overlay (nur über der Switch-Form, nicht über dem Label)
        // Die Switch-Form ist 75px hoch (stageSwitchHeight)
        // Problem: Die Column hat mainAxisAlignment.end, daher ist die Switch am unteren Ende
        // der Column positioniert. Das Label ist darunter (mit 8px Abstand).
        // Wir müssen die Position relativ zur Column-Höhe berechnen.
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Die Column-Höhe ist variabel, aber die Switch ist immer 75px hoch
                // und das Label ist ~20px hoch (12px Text + 8px Abstand)
                // Mit mainAxisAlignment.end ist die Switch am unteren Ende der Column
                // Wir müssen das Overlay genau über der Switch positionieren
                final columnHeight = constraints.maxHeight;
                final switchHeight = 75.0;
                final labelHeight = 20.0; // 12px Text + 8px SizedBox
                
                // Die Switch beginnt bei: columnHeight - switchHeight - labelHeight
                // Wir wollen das Overlay genau über der Switch, also:
                // Reduziere den Offset stärker (um 5-6px), um sicherzustellen, dass oben nichts fehlt
                // Wenn die Column-Höhe kleiner ist als erwartet, verwende top: 0
                final switchTop = columnHeight >= switchHeight + labelHeight
                    ? (columnHeight - switchHeight - labelHeight - 5.0).clamp(0.0, columnHeight - switchHeight)
                    : 0.0;
                
                // Verwende Align mit Transform.translate statt Positioned innerhalb LayoutBuilder
                return Align(
                  alignment: Alignment.topCenter,
                  child: Transform.translate(
                    offset: Offset(0, switchTop),
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: switchHeight,
                      child: _buildFrozenOverlay(),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFrozenOverlay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return CustomPaint(
          painter: _IceCubePainter(
            stageIndex: widget.stageIndex,
            animationValue: _animationController.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

/// Custom Painter für Eiswürfel-Effekt mit animierten Schneeflocken
class _IceCubePainter extends CustomPainter {
  final int stageIndex; // Stage-Index für unterschiedliche Schneeflocken-Verteilung
  final double animationValue; // Animation-Wert (0.0 - 1.0) für kontinuierliche Animation

  _IceCubePainter({
    this.stageIndex = 0,
    this.animationValue = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    // Unterschiedlicher Seed für jede Stage, damit jede Stage anders aussieht
    final random = math.Random(42 + stageIndex * 100); // Jede Stage bekommt einen anderen Seed

    // 1. Eiswürfel-Grundschicht: Kühle Blautöne wie im Bild (verstärkt)
    final iceBasePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFB0D4E8).withOpacity(0.6), // Helles kühles Blau (verstärkt)
          const Color(0xFF7FB3D3).withOpacity(0.55), // Mittleres Blau (verstärkt)
          const Color(0xFF5A9FC7).withOpacity(0.5), // Tiefes Blau (verstärkt)
          const Color(0xFFB0D4E8).withOpacity(0.55), // Zurück zu hellem Blau
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.multiply; // Stärkerer Effekt

    canvas.drawRRect(rrect, iceBasePaint);

    // 2. Eiswürfel-Oberfläche: Kühles Blau mit Transparenz (verstärkt)
    final iceSurfacePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFC8E3F0).withOpacity(0.6), // Sehr helles Blau oben (verstärkt)
          const Color(0xFF8FC4D9).withOpacity(0.5), // Mittleres Blau unten (verstärkt)
        ],
      ).createShader(rect)
      ..blendMode = BlendMode.multiply; // Stärkerer Effekt

    canvas.drawRRect(rrect, iceSurfacePaint);
    
    // Zusätzliche blaue Tönung für mehr Tiefe (verstärkt)
    final blueTintPaint = Paint()
      ..color = const Color(0xFF7FB3D3).withOpacity(0.35)
      ..blendMode = BlendMode.multiply;

    canvas.drawRRect(rrect, blueTintPaint);
    
    // 3. Frostfilm-Effekt: Milchiges Weiß über dem Eis (VERSTÄRKT, damit es sichtbar ist)
    // Erste Schicht: Starker Frostfilm
    final frostPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.45), // Milchiges Weiß (VERSTÄRKT)
          Colors.white.withOpacity(0.35), // Weniger milchig
          Colors.white.withOpacity(0.25), // Noch weniger milchig
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.overlay;

    canvas.drawRRect(rrect, frostPaint);
    
    // Zweite Schicht: Radialer Frostfilm für mehr Tiefe
    final frostRadialPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.topCenter,
        radius: 1.5,
        colors: [
          Colors.white.withOpacity(0.4), // Milchiges Weiß in der Mitte (VERSTÄRKT)
          Colors.white.withOpacity(0.25), // Weniger milchig am Rand
          Colors.transparent,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect)
      ..blendMode = BlendMode.softLight;

    canvas.drawRRect(rrect, frostRadialPaint);
    
    // Dritte Schicht: Frostfilm mit Textur-Effekt (VERSTÄRKT)
    final frostTexturePaint = Paint()
      ..color = Colors.white.withOpacity(0.35) // VERSTÄRKT
      ..blendMode = BlendMode.overlay;

    // Mehr Frostpunkte für stärkere Textur
    for (int i = 0; i < 25; i++) { // Mehr Punkte
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final radius = 1.5 + random.nextDouble() * 3.0; // Größere Punkte
      canvas.drawCircle(Offset(x, y), radius, frostTexturePaint);
    }
    
    // Vierte Schicht: Subtiler weißer Schleier über alles
    final frostVeilPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..blendMode = BlendMode.overlay;

    canvas.drawRRect(rrect, frostVeilPaint);

    // 4. Animierte Schneeflocken auf dem Eiswürfel - 16 feste Positionen, 5-8 gleichzeitig sichtbar
    // Jede Schneeflocke hat eine feste Position und eine eigene Animation mit unterschiedlicher Dauer
    
    // Generiere 16 feste Positionen für jede Stage basierend auf dem stageIndex-Seed
    final snowflakeData = <_SnowflakeData>[];
    final animationOffsets = <double>[]; // Offset für jede Schneeflocke (0.0 - 1.0)
    final animationDurations = <double>[]; // Dauer-Multiplikator für jede Schneeflocke (langsam bis schnell)
    
    for (int i = 0; i < 16; i++) {
      // Feste Position für diese Schneeflocke
      final x = 0.05 + random.nextDouble() * 0.9; // 5% - 95% der Breite
      final y = 0.05 + random.nextDouble() * 0.9; // 5% - 95% der Höhe
      final position = Offset(size.width * x, size.height * y);
      
      // Unterschiedliche Größen (klein, mittel, groß)
      final sizeMultiplier = random.nextDouble();
      final flakeSize = sizeMultiplier < 0.33
          ? 1.5 + random.nextDouble() * 0.5  // Klein: 1.5-2px
          : sizeMultiplier < 0.66
              ? 2.0 + random.nextDouble() * 1.0  // Mittel: 2-3px
              : 3.0 + random.nextDouble() * 1.5; // Groß: 3-4.5px
      
      snowflakeData.add(_SnowflakeData(
        position: position,
        size: flakeSize,
      ));
      
      // Unterschiedlicher Animation-Offset für jede Schneeflocke
      // Verteile die Offsets gleichmäßig über 0.0-1.0, damit immer 5-8 sichtbar sind
      animationOffsets.add(i / 16.0); // Gleichmäßig verteilt: 0.0, 0.0625, 0.125, ...
      
      // Unterschiedliche Animationsdauer für jede Schneeflocke (langsam bis schnell)
      // Langsamere Schneeflocken bleiben länger sichtbar
      animationDurations.add(0.8 + random.nextDouble() * 0.7); // 0.8x - 1.5x der Basis-Dauer
    }

    // Zeichne jede Schneeflocke mit ihrer eigenen Animation
    for (int i = 0; i < snowflakeData.length; i++) {
      final data = snowflakeData[i];
      final animOffset = animationOffsets[i];
      final animDuration = animationDurations[i];
      
      // Berechne den aktuellen Animation-Wert für diese Schneeflocke
      // Jede Schneeflocke hat einen eigenen Offset und eine eigene Geschwindigkeit
      final localAnimValue = ((animationValue + animOffset) * animDuration) % 1.0;
      
      // Fade in/out: Opacity ändert sich von 0 -> 1 -> 0
      // Schneeflocke erscheint langsam, bleibt kurz sichtbar, verschwindet langsam
      // Timing so angepasst, dass immer 5-8 Schneeflocken gleichzeitig sichtbar sind
      final fadeInDuration = 0.2; // 20% der Animation für Fade-In (6 Sekunden bei 30s)
      final fadeOutDuration = 0.2; // 20% der Animation für Fade-Out (6 Sekunden bei 30s)
      final visibleDuration = 0.6; // 60% der Animation vollständig sichtbar (18 Sekunden bei 30s)
      
      // Berechne Fade-Progress: 0.0 = unsichtbar, 1.0 = vollständig sichtbar
      final fadeProgress = localAnimValue < fadeInDuration
          ? localAnimValue / fadeInDuration // Fade in (0.0 -> 1.0)
          : localAnimValue > (1.0 - fadeOutDuration)
              ? (1.0 - localAnimValue) / fadeOutDuration // Fade out (1.0 -> 0.0)
              : 1.0; // Vollständig sichtbar
      
      // Finale Opacity: zwischen 0.0 und 1.0, mit Minimum von 0.0 für vollständiges Verschwinden
      final finalOpacity = fadeProgress.clamp(0.0, 1.0);
      
      // Nur zeichnen, wenn Opacity > 0 (um Performance zu sparen)
      if (finalOpacity > 0.01) {
        // Erhöhte Opacity für bessere Sichtbarkeit
        final baseOpacity = finalOpacity * 0.9; // Max Opacity 0.9 (statt 0.7)
        final snowflakePaint = Paint()
          ..color = Colors.white.withOpacity(baseOpacity)
          ..style = PaintingStyle.fill;
        
        // Schneeflocke als kleines Kreuz
        canvas.drawCircle(data.position, data.size / 2, snowflakePaint);
        
        final linePaint = Paint()
          ..color = Colors.white.withOpacity(baseOpacity)
          ..strokeWidth = 1.0; // Etwas dicker für bessere Sichtbarkeit
        
        // Horizontale Linie
        canvas.drawLine(
          Offset(data.position.dx - data.size, data.position.dy),
          Offset(data.position.dx + data.size, data.position.dy),
          linePaint,
        );
        // Vertikale Linie
        canvas.drawLine(
          Offset(data.position.dx, data.position.dy - data.size),
          Offset(data.position.dx, data.position.dy + data.size),
          linePaint,
        );
        
        // Diagonale Linien für mehr Details
        final diagPaint = Paint()
          ..color = Colors.white.withOpacity(baseOpacity * 0.6) // Konsistent mit baseOpacity
          ..strokeWidth = 0.6;
        
        final diagSize = data.size * 0.7;
        canvas.drawLine(
          Offset(data.position.dx - diagSize * 0.7, data.position.dy - diagSize * 0.7),
          Offset(data.position.dx + diagSize * 0.7, data.position.dy + diagSize * 0.7),
          diagPaint,
        );
        canvas.drawLine(
          Offset(data.position.dx + diagSize * 0.7, data.position.dy - diagSize * 0.7),
          Offset(data.position.dx - diagSize * 0.7, data.position.dy + diagSize * 0.7),
          diagPaint,
        );
      }
    }

    // 6. Subtile Eisstruktur (Eiskristalle im Eis)
    final crystalPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.4;

    // Kleine Eiskristall-Linien
    for (int i = 0; i < 8; i++) {
      final x1 = random.nextDouble() * size.width;
      final y1 = random.nextDouble() * size.height;
      final length = 2 + random.nextDouble() * 3;
      final angle = random.nextDouble() * math.pi * 2;
      final x2 = x1 + math.cos(angle) * length;
      final y2 = y1 + math.sin(angle) * length;
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), crystalPaint);
    }
  }

  @override
  bool shouldRepaint(_IceCubePainter oldDelegate) {
    // Repaint bei jeder Animation-Änderung
    return oldDelegate.animationValue != animationValue;
  }
}

/// Datenstruktur für eine animierte Schneeflocke
class _SnowflakeData {
  final Offset position; // Feste Position der Schneeflocke
  final double size; // Größe der Schneeflocke

  _SnowflakeData({
    required this.position,
    required this.size,
  });
}

