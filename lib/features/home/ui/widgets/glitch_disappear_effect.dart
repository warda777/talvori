import 'dart:math' as math;
import 'package:flutter/material.dart';

enum GlitchType {
  glitchTransition,
  digitalGlitchOut,
  distortionFade,
  pixelDisintegration,
}

/// Widget, das verschiedene Glitch-Effekte zeigt, bevor es verschwindet
class GlitchDisappearEffect extends StatefulWidget {
  final Widget child;
  final VoidCallback? onComplete;
  final Duration duration;
  final GlitchType? glitchType; // Wenn null, wird zufällig ausgewählt

  const GlitchDisappearEffect({
    super.key,
    required this.child,
    this.onComplete,
    this.duration = const Duration(milliseconds: 800),
    this.glitchType,
  });

  @override
  State<GlitchDisappearEffect> createState() => _GlitchDisappearEffectState();
}

class _GlitchDisappearEffectState extends State<GlitchDisappearEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late GlitchType _selectedType;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    // Wähle zufälligen Glitch-Typ, wenn nicht spezifiziert
    _selectedType = widget.glitchType ?? 
        GlitchType.values[_random.nextInt(GlitchType.values.length)];
    
    // Debug: Zeige welcher Effekt ausgewählt wurde
    debugPrint('🎬 GLITCH-EFFEKT: ${_selectedType.name} wurde ausgewählt');
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..forward().then((_) {
        debugPrint('✅ GLITCH-EFFEKT: ${_selectedType.name} ist fertig');
        widget.onComplete?.call();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (_selectedType) {
          case GlitchType.glitchTransition:
            return _buildGlitchTransition();
          case GlitchType.digitalGlitchOut:
            return _buildDigitalGlitchOut();
          case GlitchType.distortionFade:
            return _buildDistortionFade();
          case GlitchType.pixelDisintegration:
            return _buildPixelDisintegration();
        }
      },
    );
  }

  // Glitch Transition: Horizontaler Versatz mit RGB-Split
  Widget _buildGlitchTransition() {
    final t = _controller.value;
    final offset = (1.0 - t) * 20.0 * math.sin(t * 20);
    final opacity = 1.0 - t;
    
    return Stack(
      children: [
        // Rot-Kanal
        Transform.translate(
          offset: Offset(offset, 0),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              1, 0, 0, 0, 0,
              0, 0, 0, 0, 0,
              0, 0, 0, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: Opacity(
              opacity: opacity,
              child: widget.child,
            ),
          ),
        ),
        // Grün-Kanal
        Transform.translate(
          offset: Offset(-offset * 0.5, 0),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0, 0, 0, 0, 0,
              0, 1, 0, 0, 0,
              0, 0, 0, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: Opacity(
              opacity: opacity,
              child: widget.child,
            ),
          ),
        ),
        // Blau-Kanal
        Transform.translate(
          offset: Offset(offset * 0.5, 0),
          child: ColorFiltered(
            colorFilter: const ColorFilter.matrix([
              0, 0, 0, 0, 0,
              0, 0, 0, 0, 0,
              0, 0, 1, 0, 0,
              0, 0, 0, 1, 0,
            ]),
            child: Opacity(
              opacity: opacity,
              child: widget.child,
            ),
          ),
        ),
      ],
    );
  }

  // Digital Glitch Out: Zufällige horizontale Streifen mit Versatz
  Widget _buildDigitalGlitchOut() {
    final t = _controller.value;
    final opacity = 1.0 - t;
    final glitchIntensity = (1.0 - t) * 15.0;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Stack(
          children: [
            // Haupt-Widget mit Opacity
            Opacity(
              opacity: opacity,
              child: widget.child,
            ),
            // Glitch-Streifen
            ...List.generate(5, (i) {
              final y = _random.nextDouble() * 200;
              final offset = (math.sin(t * 30 + i) * glitchIntensity);
              final stripOpacity = (1.0 - t) * 0.6 * (1.0 - (i * 0.15));
              
              return Positioned(
                top: y,
                left: offset,
                right: -offset,
                child: Opacity(
                  opacity: stripOpacity,
                  child: ClipRect(
                    child: Transform.translate(
                      offset: Offset(offset, 0),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.matrix([
                          1, 0, 0, 0, 0,
                          0, 1, 0, 0, 0,
                          0, 0, 1, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
    );
  }

  // Distortion Fade: Verzerrung mit Fade-Out
  Widget _buildDistortionFade() {
    final t = _controller.value;
    final opacity = 1.0 - t;
    final distortion = (1.0 - t) * 0.1;
    
    return Opacity(
      opacity: opacity,
      child: Transform(
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(distortion * math.sin(t * 10))
          ..rotateY(distortion * math.cos(t * 10)),
        alignment: FractionalOffset.center,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix([
            1 + distortion, 0, 0, 0, 0,
            0, 1 - distortion, 0, 0, 0,
            0, 0, 1 + distortion, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: widget.child,
        ),
      ),
    );
  }

  // Pixel Disintegration: Pixel-artiges Auflösen
  Widget _buildPixelDisintegration() {
    final t = _controller.value;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return ClipPath(
          clipper: _PixelDisintegrationClipper(
            progress: t,
            random: _random,
          ),
          child: Opacity(
            opacity: 1.0 - (t * 0.2), // Leichtes Fade, aber hauptsächlich durch ClipPath
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _PixelDisintegrationClipper extends CustomClipper<Path> {
  final double progress;
  final math.Random random;

  _PixelDisintegrationClipper({
    required this.progress,
    required this.random,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    
    if (progress >= 1.0) {
      // Alles entfernt - leerer Path
      return path;
    }

    if (progress <= 0.0) {
      // Alles sichtbar - vollständiger Path
      path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return path;
    }

    final pixelSize = 8.0; // Größere Pixel für bessere Sichtbarkeit
    final cols = (size.width / pixelSize).ceil();
    final rows = (size.height / pixelSize).ceil();

    // Verwende deterministischen Seed für konsistente Animation
    // Erstelle eine Liste aller Pixel mit ihren "Zufallswerten"
    final pixels = <({int x, int y, double randomValue})>[];
    for (var y = 0; y < rows; y++) {
      for (var x = 0; x < cols; x++) {
        // Verwende deterministischen Seed basierend auf Position
        final seed = (x * 1000 + y) % 1000;
        final randomValue = (seed * 0.01) % 1.0;
        pixels.add((x: x, y: y, randomValue: randomValue));
      }
    }
    
    // Sortiere Pixel nach ihrem Zufallswert (deterministisch)
    pixels.sort((a, b) => a.randomValue.compareTo(b.randomValue));
    
    // Berechne wie viele Pixel noch sichtbar sein sollen
    final visibleCount = ((1.0 - progress) * pixels.length).round();
    
    // Füge nur die sichtbaren Pixel zum Path hinzu
    for (var i = 0; i < visibleCount && i < pixels.length; i++) {
      final pixel = pixels[i];
      final offsetX = pixel.x * pixelSize;
      final offsetY = pixel.y * pixelSize;
      
      path.addRect(
        Rect.fromLTWH(
          offsetX.clamp(0, size.width),
          offsetY.clamp(0, size.height),
          pixelSize.clamp(0, size.width - offsetX),
          pixelSize.clamp(0, size.height - offsetY),
        ),
      );
    }

    return path;
  }

  @override
  bool shouldReclip(covariant _PixelDisintegrationClipper oldClipper) {
    return oldClipper.progress != progress;
  }
}

