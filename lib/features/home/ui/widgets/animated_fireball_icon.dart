import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

/// Animiertes Fireball-Icon mit periodischer Färbung und Flammen-Animation
class AnimatedFireballIcon extends StatefulWidget {
  final double size;
  final Color baseColor; // Ursprungsfarbe (z.B. gold)
  final Color animationColor; // Farbe während der Animation (#A05260)
  final Duration animationInterval; // Intervall zwischen Animationen (z.B. 2 Sekunden)
  final Duration animationDuration; // Dauer der Animation

  const AnimatedFireballIcon({
    super.key,
    required this.size,
    required this.baseColor,
    this.animationColor = const Color(0xFFA05260), // #A05260
    this.animationInterval = const Duration(seconds: 2),
    this.animationDuration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedFireballIcon> createState() => _AnimatedFireballIconState();
}

class _AnimatedFireballIconState extends State<AnimatedFireballIcon>
    with TickerProviderStateMixin {
  late AnimationController _colorController;
  late AnimationController _flameController;
  late AnimationController _wobbleController; // Controller für Wackeln
  late AnimationController _repaintController; // Controller für kontinuierliches Repaint
  late Animation<Color?> _colorAnimation;
  late Animation<double> _flameAnimation;
  late Animation<double> _wobbleAnimation; // Animation für Hin-und-Her-Wackeln

  @override
  void initState() {
    super.initState();

    // Controller für Farb-Animation
    _colorController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Controller für Flammen-Animation
    _flameController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Controller für Wackeln (läuft kontinuierlich während der Flammen sichtbar sind)
    _wobbleController = AnimationController(
      duration: const Duration(milliseconds: 800), // Langsameres Wackeln
      vsync: this,
    );

    // Controller für kontinuierliches Repaint (für Zeit-basierte Animation)
    _repaintController = AnimationController(
      duration: const Duration(milliseconds: 50), // Sehr schnell für flüssige Animation
      vsync: this,
    );
    _repaintController.repeat(); // Läuft kontinuierlich

    // Farb-Animation: Einfärben → 5 Sekunden halten → Ausfärben
    _colorAnimation = TweenSequence<Color?>([
      // Einfärben (0.5 Sekunden)
      TweenSequenceItem(
        tween: ColorTween(begin: widget.baseColor, end: widget.animationColor)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.1, // 10% der Zeit = 0.5 Sekunden
      ),
      // Halten bei animationColor (4 Sekunden)
      TweenSequenceItem(
        tween: ConstantTween<Color?>(widget.animationColor),
        weight: 0.8, // 80% der Zeit = 4 Sekunden
      ),
      // Ausfärben (0.5 Sekunden)
      TweenSequenceItem(
        tween: ColorTween(begin: widget.animationColor, end: widget.baseColor)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.1, // 10% der Zeit = 0.5 Sekunden
      ),
    ]).animate(_colorController);

    // Flammen-Animation: Erscheinen → 5 Sekunden sichtbar → Verschwinden
    _flameAnimation = TweenSequence<double>([
      // Erscheinen (0.3 Sekunden)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 0.06, // 6% der Zeit = 0.3 Sekunden
      ),
      // Sichtbar bleiben (4.4 Sekunden)
      TweenSequenceItem(
        tween: ConstantTween<double>(1.0),
        weight: 0.88, // 88% der Zeit = 4.4 Sekunden
      ),
      // Verschwinden (0.3 Sekunden)
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 0.06, // 6% der Zeit = 0.3 Sekunden
      ),
    ]).animate(_flameController);

    // Wackel-Animation: Hin und Her während Flammen sichtbar sind
    _wobbleAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _wobbleController,
        curve: Curves.easeInOut,
      ),
    );

    // Starte periodische Animation
    _startPeriodicAnimation();
  }

  void _startPeriodicAnimation() {
    Future.delayed(widget.animationInterval, () {
      if (!mounted) return;
      
      // Starte beide Animationen gleichzeitig - beide laufen forward und bleiben dann 5 Sekunden
      _colorController.forward().then((_) {
        if (mounted) {
          _colorController.reset();
          // Starte die nächste Animation nach dem Intervall
          _startPeriodicAnimation();
        }
      });
      
      _flameController.forward().then((_) {
        if (mounted) {
          _flameController.reset();
          _wobbleController.stop();
        }
      });
      
      // Starte Wackeln wenn Flammen erscheinen
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted && _flameController.isAnimating) {
          _wobbleController.repeat(reverse: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _colorController.dispose();
    _flameController.dispose();
    _wobbleController.dispose();
    _repaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Fireball Icon mit Farb-Animation
        AnimatedBuilder(
          animation: _colorAnimation,
          builder: (context, child) {
            return SvgPicture.asset(
              'assets/icons/fireball_black.svg',
              width: widget.size,
              height: widget.size,
              colorFilter: ColorFilter.mode(
                _colorAnimation.value ?? widget.baseColor,
                BlendMode.srcIn,
              ),
            );
          },
        ),
        
        // Flammen-Animation (mehrere Partikel um das Icon)
        AnimatedBuilder(
          animation: Listenable.merge([
            _flameAnimation, 
            _wobbleAnimation,
            _repaintController, // Für kontinuierliches Repaint
          ]),
          builder: (context, child) {
            if (_flameAnimation.value <= 0) return const SizedBox.shrink();
            
            return CustomPaint(
              size: Size(widget.size * 2.5, widget.size * 2.5), // Größer, geht über Button hinaus
              painter: _FlamePainter(
                opacity: _flameAnimation.value,
                wobble: _wobbleAnimation.value,
                color: widget.animationColor,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Custom Painter für die Flammen-Animation
class _FlamePainter extends CustomPainter {
  final double opacity;
  final double wobble; // -1.0 bis 1.0 für Hin-und-Her-Wackeln
  final Color color;

  _FlamePainter({
    required this.opacity,
    required this.wobble,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Zeit-basierte Variation für dynamischere Flammen
    final time = DateTime.now().millisecondsSinceEpoch / 100.0;

    // Zeichne mehrere Flammen-Partikel um das Icon mit verschiedenen Bewegungen
    for (int i = 0; i < 12; i++) {
      final baseAngle = (i * 2 * math.pi) / 12;
      
      // Wackeln: Jede Flamme bewegt sich leicht hin und her
      final wobbleOffset = wobble * 8.0 * math.sin(baseAngle * 2); // Mehr Wackeln
      final angle = baseAngle + wobbleOffset * 0.1;
      
      // Dynamische Distanz (Flammen bewegen sich raus und rein) - langsamer
      final baseDistance = size.width * 0.35;
      final dynamicDistance = baseDistance + 
          math.sin(time * 0.5 + i * 0.5) * size.width * 0.1; // Langsamer: time * 0.5
      
      final x = center.dx + math.cos(angle) * dynamicDistance;
      final y = center.dy + math.sin(angle) * dynamicDistance;
      
      // Dynamische Größe (Flammen pulsieren) - langsamer
      final baseWidth = size.width * 0.12;
      final baseHeight = size.width * 0.2;
      final pulse = 1.0 + math.sin(time + i) * 0.3; // Langsamer: time statt time * 2
      final flameWidth = baseWidth * opacity * pulse;
      final flameHeight = baseHeight * opacity * pulse;
      
      // Gradient für Flammen-Effekt
      final gradient = RadialGradient(
        colors: [
          color.withOpacity(opacity * 0.9),
          color.withOpacity(opacity * 0.6),
          color.withOpacity(opacity * 0.3),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      );
      
      final paint = Paint()
        ..shader = gradient.createShader(
          Rect.fromCenter(
            center: Offset(x, y),
            width: flameWidth,
            height: flameHeight,
          ),
        )
        ..style = PaintingStyle.fill;
      
      // Flammenform (ovales Partikel)
      final flamePath = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: flameWidth,
            height: flameHeight,
          ),
        );
      
      canvas.drawPath(flamePath, paint);
      
      // Zusätzliche kleine Partikel für mehr Dynamik
      if (i % 2 == 0) {
        final smallX = x + math.cos(angle + math.pi / 4) * flameWidth * 0.3;
        final smallY = y + math.sin(angle + math.pi / 4) * flameHeight * 0.3;
        
        final smallPaint = Paint()
          ..color = color.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(smallX, smallY),
          flameWidth * 0.15,
          smallPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_FlamePainter oldDelegate) {
    // Immer repaint, damit die Zeit-basierte Animation funktioniert
    return true;
  }
}

