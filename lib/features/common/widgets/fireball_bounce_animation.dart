import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Fireball fällt nach Down-Swipe vom verknüpften Anchor (z. B. rechter Button),
/// prallt mehrfach und rollt nach links raus. Danach respawn oben am Anchor.
/// Farbe kann optional erzwungen werden (z. B. rot).
class FireballBounceAnimation extends StatefulWidget {
  const FireballBounceAnimation({
    super.key,
    required this.child,
    required this.anchorKey,                 // <-- GlobalKey des rechten Buttons
    this.practiceKey,                        // <-- NEU: GlobalKey des Practice-Buttons
    this.forceColor,                         // <-- z.B. Colors.red
    this.iconSize = 44,
    this.swipeVelocityMin = 400.0,
    this.swipeDistanceMin = 24.0,            // minimale Wischstrecke
    this.anchorOffset = const Offset(0, 0),  // feintuning relativ zum Anchor
  });

  final Widget child;
  final GlobalKey anchorKey;
  final GlobalKey? practiceKey;              // <-- NEU
  final Color? forceColor;
  final double iconSize;
  final double swipeVelocityMin;
  final double swipeDistanceMin;
  final Offset anchorOffset;

  @override
  State<FireballBounceAnimation> createState() => FireballBounceAnimationState();
}

class FireballBounceAnimationState extends State<FireballBounceAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  Animation<double>? _y;
  Animation<double>? _x;
  Animation<double>? _r;

  bool _animating = false;
  Offset _spawn = const Offset(12, 12); // Startposition (wird aus Anchor berechnet)
  Offset? _dragStartLocal;
  bool _spawnComputed = false;
  Rect? _practiceRect;                      // <-- NEU: Practice-Button Geometrie

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000)) // Länger für natürlichere Bewegung
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          setState(() => _animating = false);
          _c.reset(); // respawn am Anchor (Position wird in build neu berechnet)
        }
      });
    // Position einmal nach dem ersten Frame berechnen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_spawnComputed) {
        _recomputeSpawnInStack();
        _spawnComputed = true;
      }
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }


  void _start(Animation<double> master, double fallDistance, double rollDistance) {
    // ---- Physik-Parameter (gefühlt realistisch, leicht anpassbar) ----
    const double tFall0 = 0.55;          // Sekunden für den ersten freien Fall (0 -> Boden)
    final double gPx = 2 * fallDistance / (tFall0 * tFall0); // "g" in Pixel/s^2
    const double e = 0.65;               // COR (Energieverlust pro Aufprall)
    const double mu = 0.88;              // seitliche Reibung pro Bounce (vx *= mu)
    double vx = -(widget.iconSize * 2.2); // Start-vx (Pixel/s) nach erstem Aufprall, links langsam

    // ---- Zeit-/Segmentbau: Fall + n Bounces + Ausrollen ----
    final List<TweenSequenceItem<double>> xItems = [];
    final List<TweenSequenceItem<double>> yItems = [];

    double currentX = 0.0;
    double tWeight(double seconds) => seconds * 1000.0; // Gewichte ~ reale Dauer

    // 1) Freier Fall von oben
    yItems.add(TweenSequenceItem(
      tween: Tween<double>(begin: 0.0, end: fallDistance).chain(CurveTween(curve: Curves.easeIn)),
      weight: tWeight(tFall0),
    ));
    xItems.add(TweenSequenceItem(tween: ConstantTween<double>(0.0), weight: tWeight(tFall0)));

    // Geschwindigkeit beim Aufprall (vor dem ersten Bounce)
    final double vImpact0 = gPx * tFall0;

    // 2) Mehrere Bounces (parabolisch), Höhe nimmt mit e^2 ab, vx bremst mit mu
    const int bounces = 5;
    double vUp = e * vImpact0; // vertikale Startgeschw. nach 1. Aufprall
    for (int i = 0; i < bounces; i++) {
      // Auf-/Ab- Zeiten der Parabel
      final double tUp   = vUp / gPx;
      final double tDown = tUp;
      final double tSeg  = tUp + tDown;

      // x: gleichmäßiges Rollen während des ganzen Sprungs
      final double dx = vx * tSeg;
      final double nextX = currentX + dx;

      // y: hoch (easeOut) bis Scheitel, dann runter (easeIn) bis Boden
      final double topY = fallDistance - (vUp * vUp) / (2 * gPx); // h = v^2/(2g)
      yItems.addAll([
        TweenSequenceItem(
          tween: Tween<double>(begin: fallDistance, end: topY)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: tWeight(tUp),
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: topY, end: fallDistance)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: tWeight(tDown),
        ),
      ]);

      xItems.add(
        TweenSequenceItem(
          tween: Tween<double>(begin: currentX, end: nextX)
              .chain(CurveTween(curve: Curves.linear)),
          weight: tWeight(tSeg),
        ),
      );
      currentX = nextX;

      // Dämpfung für nächsten Bounce
      vUp *= e;   // kleinerer Sprung
      vx *= mu;   // langsameres Rollen
    }

    // 3) Statt sofort ausrollen: weiter nach links bis zum linken Radius, dann entlang des Radius runter
    if (_practiceRect != null) {
      // _practiceRect ist bereits in Stack-Koordinaten
      // Radius des Practice Buttons (BorderRadius.circular(999) = sehr rund)
      final double radius = 26.0; // halbe Höhe des Buttons (52/2) für sehr runde Ecken

      // a) Weiter nach links rollen bis zum linken Radius des Practice Buttons
      // Ziel: linke Seite des Buttons, wo der Radius beginnt (practiceLeft + radius)
      final double tRollToLeft = 0.4;
      final double leftEdgeX = _practiceRect!.left + radius - widget.iconSize * 0.5;
      xItems.add(TweenSequenceItem(
        tween: Tween<double>(begin: currentX, end: leftEdgeX).chain(CurveTween(curve: Curves.easeOut)),
        weight: tWeight(tRollToLeft),
      ));
      yItems.add(TweenSequenceItem(
        tween: ConstantTween<double>(fallDistance),
        weight: tWeight(tRollToLeft),
      ));
      currentX = leftEdgeX;

      // b) Entlang des linken oberen Radius nach unten rollen (Kurvenbewegung)
      // Der Radius ist ein Viertelkreis von oben links
      // Radius-Mittelpunkt: (practiceLeft + radius, practiceTop + radius)
      final double tRadiusRoll = 0.45;
      final double radiusCenterX = _practiceRect!.left + radius;
      final double radiusCenterY = _practiceRect!.top + radius;
      
      // Start- und Endwinkel für den Kreisbogen (in Radians)
      // Start: oben am Radius (Winkel 270° = 3π/2) - dort wo der Ball ankommt
      // End: links am Radius (Winkel 180° = π) - dort wo der Ball den Radius verlässt
      final double startAngle = 3 * math.pi / 2; // 270°
      final double endAngle = math.pi; // 180°
      
      // Start- und Endpositionen auf dem Kreisbogen (in Stack-Koordinaten)
      final double radiusStartX = radiusCenterX + radius * math.cos(startAngle);
      final double radiusStartY = radiusCenterY + radius * math.sin(startAngle);
      final double radiusEndX = radiusCenterX + radius * math.cos(endAngle);
      final double radiusEndY = radiusCenterY + radius * math.sin(endAngle);
      
      // Kurvenbewegung: Kreisbogen mit easeInOut für natürliche Bewegung
      xItems.add(TweenSequenceItem(
        tween: Tween<double>(begin: currentX, end: radiusEndX - widget.iconSize * 0.5)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: tWeight(tRadiusRoll),
      ));
      yItems.add(TweenSequenceItem(
        tween: Tween<double>(begin: fallDistance, end: radiusEndY - widget.iconSize * 0.5)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: tWeight(tRadiusRoll),
      ));
      currentX = radiusEndX - widget.iconSize * 0.5;

      // c) Linear weiter nach unten fallen
      final double tLinearFall = 0.6;
      final double finalY = radiusEndY - widget.iconSize * 0.5 + (widget.iconSize * 2.0); // weiter nach unten
      xItems.add(TweenSequenceItem(
        tween: ConstantTween<double>(currentX),
        weight: tWeight(tLinearFall),
      ));
      yItems.add(TweenSequenceItem(
        tween: Tween<double>(begin: radiusEndY - widget.iconSize * 0.5, end: finalY)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: tWeight(tLinearFall),
      ));
    } else {
      // Fallback: wie bisher ausrollen
      final double tRoll = 0.8;
      final double endX  = -rollDistance;
      xItems.add(TweenSequenceItem(
        tween: Tween<double>(begin: currentX, end: endX).chain(CurveTween(curve: Curves.easeOut)),
        weight: tWeight(tRoll),
      ));
      yItems.add(TweenSequenceItem(
        tween: ConstantTween<double>(fallDistance),
        weight: tWeight(tRoll),
      ));
    }

    // Zuweisung an Animations
    _x = TweenSequence<double>(xItems).animate(master);
    _y = TweenSequence<double>(yItems).animate(master);

    // Rotation proportional zur Weglänge (≈ Rollrad): grob 1 Umdr./iconSize*π
    final double turns = ( (rollDistance.abs() / (widget.iconSize * math.pi)) ).clamp(1.5, 6.0);
    _r = Tween<double>(begin: 0.0, end: -2 * math.pi * turns)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

    setState(() => _animating = true);
    _c.forward(from: 0.0);
  }

  void _recomputeSpawnInStack() {
    final stackBox  = context.findRenderObject() as RenderBox?;
    final anchorCtx = widget.anchorKey.currentContext;
    final anchorBox = anchorCtx?.findRenderObject() as RenderBox?;
    if (stackBox == null || anchorBox == null) return;

    final stackTopLeft   = stackBox.localToGlobal(Offset.zero);
    final anchorTopLeft  = anchorBox.localToGlobal(Offset.zero);
    final anchorSize     = anchorBox.size;

    final rightEdgeX = anchorTopLeft.dx + anchorSize.width - widget.iconSize;
    final topY       = anchorTopLeft.dy;

    final newSpawn = Offset(
      (rightEdgeX - stackTopLeft.dx) + widget.anchorOffset.dx,
      (topY       - stackTopLeft.dy) + widget.anchorOffset.dy,
    );

    // Practice-Rect (in Stack-Koordinaten)
    if (widget.practiceKey != null) {
      final pCtx  = widget.practiceKey!.currentContext;
      final pBox  = pCtx?.findRenderObject() as RenderBox?;
      if (pBox != null) {
        final pTopLeft = pBox.localToGlobal(Offset.zero) - stackTopLeft;
        _practiceRect = pTopLeft & pBox.size;
      }
    }

    if (newSpawn != _spawn) {
      setState(() {
        _spawn = newSpawn;
      });
    } else {
      _spawn = newSpawn;
    }
  }

  void triggerFromAnchor() {
    if (_animating) return;
    _recomputeSpawnInStack();
    final box = context.findRenderObject() as RenderBox?;
    final size = box?.constraints.biggest ?? const Size(400, 800);
    final fallDistance = (size.height - _spawn.dy - widget.iconSize - 8.0).clamp(0.0, size.height) as double;
    final rollDistance = size.width + widget.iconSize + 40.0;
    final master = CurvedAnimation(parent: _c, curve: Curves.linear);
    _start(master, fallDistance, rollDistance);
  }

  @override
  Widget build(BuildContext context) {
    // Position wird bereits in initState() berechnet, hier nichts mehr tun

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = c.maxWidth;
        final maxH = c.maxHeight;

        final fallDistance = (maxH - _spawn.dy - widget.iconSize - 8.0).clamp(0.0, maxH) as double;
        final rollDistance = maxW + widget.iconSize + 40.0;
        final master = CurvedAnimation(parent: _c, curve: Curves.linear);

        _y ??= const AlwaysStoppedAnimation<double>(0.0);
        _x ??= const AlwaysStoppedAnimation<double>(0.0);
        _r ??= const AlwaysStoppedAnimation<double>(0.0);

        final fireball = SizedBox(
          width: widget.iconSize,
          height: widget.iconSize,
          child: widget.forceColor == null
              ? widget.child
              : ColorFiltered(
                  colorFilter: ColorFilter.mode(widget.forceColor!, BlendMode.srcIn),
                  child: widget.child,
                ),
        );

        return Stack(
          children: [
            Positioned(
              left: _spawn.dx,
              top: _spawn.dy,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: (d) {
                  _dragStartLocal = d.localPosition;
                },
                onVerticalDragEnd: (details) {
                  final v = details.primaryVelocity ?? 0.0;
                  final movedEnough = (_dragStartLocal != null);
                  // nur DOWN-SWIPE akzeptieren
                  if (v > widget.swipeVelocityMin && !_animating && movedEnough) {
                    _start(master, fallDistance, rollDistance);
                  }
                  _dragStartLocal = null;
                },
                onVerticalDragUpdate: (d) {
                  // Falls Nutzer sehr langsam wischt: ab bestimmter Distanz trotzdem auslösen
                  if (_dragStartLocal != null && !_animating) {
                    final dy = d.localPosition.dy - _dragStartLocal!.dy;
                    if (dy > widget.swipeDistanceMin) {
                      _start(master, fallDistance, rollDistance);
                      _dragStartLocal = null;
                    }
                  }
                },
                child: AnimatedBuilder(
                  animation: _c,
                  builder: (context, _) {
                    final dy = _animating ? _y!.value : 0.0;
                    final dx = _animating ? _x!.value : 0.0;
                    final rot = _animating ? _r!.value : 0.0;

                    return Transform.translate(
                      offset: Offset(dx, dy),
                      child: Transform.rotate(angle: rot, child: fireball),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
