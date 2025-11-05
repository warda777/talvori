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
  final ValueNotifier<bool> _animatingNotifier = ValueNotifier<bool>(false);
  Offset _spawn = const Offset(12, 12); // Startposition (wird aus Anchor berechnet)
  Offset? _dragStartLocal;
  bool _spawnComputed = false;
  Rect? _practiceRect;                      // <-- NEU: Practice-Button Geometrie
  int _lastDirection = -1;                  // -1 = noch keine Richtung
  // Richtungen: 0=links, 1=rechts, 2=oben, 3=unten, 4=schräg links-oben, 5=schräg rechts-oben, 6=schräg links-unten, 7=schräg rechts-unten
  final math.Random _random = math.Random();
  
  // Öffentlicher Getter für Animationsstatus
  bool get isAnimating => _animating;
  ValueNotifier<bool> get animatingNotifier => _animatingNotifier;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 5000)) // Länger für natürlichere Bewegung
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          // Wichtig: Notifier ZUERST aktualisieren, dann setState
          _animatingNotifier.value = false; // Button wieder einblenden
          setState(() {
            _animating = false;
          });
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
    _animatingNotifier.dispose();
    _c.dispose();
    super.dispose();
  }


  void _start(Animation<double> master, double fallDistance, double rollDistance) {
    // ---- Zufällige Richtung wählen (nicht die letzte) ----
    // 0=links, 1=rechts, 2=oben, 3=unten, 4=schräg links-oben, 5=schräg rechts-oben, 6=schräg links-unten, 7=schräg rechts-unten
    int newDirection;
    do {
      newDirection = _random.nextInt(8); // 8 Richtungen (4 kardinal + 4 diagonal)
    } while (newDirection == _lastDirection && _lastDirection != -1);
    _lastDirection = newDirection;
    
    // ---- Physik-Parameter (gefühlt realistisch, leicht anpassbar) ----
    const double tFall0 = 0.55;          // Sekunden für den ersten freien Fall (0 -> Boden)
    final double gPx = 2 * fallDistance / (tFall0 * tFall0); // "g" in Pixel/s^2
    const double e = 0.65;               // COR (Energieverlust pro Aufprall)
    const double mu = 0.88;              // seitliche Reibung pro Bounce (vx *= mu)
    
    // Start-vx: IMMER nach links (negativ)
    double vx = -(widget.iconSize * 2.2);

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

    // 3) Ausrollen in zufällige Richtung basierend auf newDirection
    // Berechne die verfügbare Bewegungsdistanz (Stack-Größe)
    final box = context.findRenderObject() as RenderBox?;
    final screenSize = box?.constraints.biggest ?? const Size(400, 800);
    
    // Zielpositionen berechnen
    double finalX = currentX;
    double finalY = fallDistance;
    
    // Für konsistente Geschwindigkeit: gleiche Distanz für alle Richtungen
    // Verwende die maximale Distanz (diagonal) als Basis
    final double maxDiagonal = math.sqrt(
      math.pow(screenSize.width + widget.iconSize + 40.0, 2) +
      math.pow(screenSize.height + widget.iconSize + 40.0, 2)
    );
    
    // Basis-Geschwindigkeit (Pixel pro Sekunde) - gleiche Geschwindigkeit für alle Richtungen
    final double baseSpeed = maxDiagonal / 0.8; // 0.8 Sekunden für maximale Distanz
    
    if (newDirection == 0) {
      // Links: nach links verschwinden
      finalX = -rollDistance;
      finalY = fallDistance;
    } else if (newDirection == 1) {
      // Rechts: nach rechts verschwinden
      finalX = screenSize.width + widget.iconSize + 40.0;
      finalY = fallDistance;
    } else if (newDirection == 2) {
      // Oben: nach oben verschwinden
      finalX = currentX;
      finalY = -widget.iconSize - 40.0;
    } else if (newDirection == 3) {
      // Unten: nach unten verschwinden
      finalX = currentX;
      finalY = screenSize.height + widget.iconSize + 40.0;
    } else if (newDirection == 4) {
      // Schräg links-oben
      final double distance = math.min(screenSize.width + widget.iconSize + 40.0, screenSize.height + widget.iconSize + 40.0);
      finalX = currentX - distance;
      finalY = fallDistance - distance;
    } else if (newDirection == 5) {
      // Schräg rechts-oben
      final double distance = math.min(screenSize.width + widget.iconSize + 40.0, screenSize.height + widget.iconSize + 40.0);
      finalX = currentX + distance;
      finalY = fallDistance - distance;
    } else if (newDirection == 6) {
      // Schräg links-unten
      final double distance = math.min(screenSize.width + widget.iconSize + 40.0, screenSize.height + widget.iconSize + 40.0);
      finalX = currentX - distance;
      finalY = fallDistance + distance;
    } else {
      // Schräg rechts-unten (7)
      final double distance = math.min(screenSize.width + widget.iconSize + 40.0, screenSize.height + widget.iconSize + 40.0);
      finalX = currentX + distance;
      finalY = fallDistance + distance;
    }
    
    // Berechne tatsächliche Distanz und Zeit basierend auf Geschwindigkeit
    final double actualDistance = math.sqrt(
      math.pow(finalX - currentX, 2) + math.pow(finalY - fallDistance, 2)
    );
    final double tRoll = actualDistance / baseSpeed;
    
    // Füge Bewegungen hinzu
    xItems.add(TweenSequenceItem(
      tween: Tween<double>(begin: currentX, end: finalX).chain(CurveTween(curve: Curves.easeOut)),
      weight: tWeight(tRoll),
    ));
    yItems.add(TweenSequenceItem(
      tween: Tween<double>(begin: fallDistance, end: finalY).chain(CurveTween(curve: Curves.easeOut)),
      weight: tWeight(tRoll),
    ));

    // Zuweisung an Animations
    _x = TweenSequence<double>(xItems).animate(master);
    _y = TweenSequence<double>(yItems).animate(master);

    // Rotation proportional zur Weglänge und Richtung
    // Berechne Gesamtweg (X + Y)
    final double totalDistanceX = (finalX - currentX).abs();
    final double totalDistanceY = (finalY - fallDistance).abs();
    final double totalDistance = totalDistanceX + totalDistanceY;
    final double turns = (totalDistance / (widget.iconSize * math.pi)).clamp(1.5, 6.0);
    
    // Rotationsrichtung: 
    // - Bounces: immer nach links (negativ)
    // - Ausroll: basierend auf newDirection
    double rotationDirection;
    if (newDirection == 0 || newDirection == 4 || newDirection == 6) {
      // Links, schräg links-oben, schräg links-unten: negativ
      rotationDirection = -1.0;
    } else {
      // Rechts, oben, unten, schräg rechts-oben, schräg rechts-unten: positiv
      rotationDirection = 1.0;
    }
    _r = Tween<double>(begin: 0.0, end: rotationDirection * 2 * math.pi * turns)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

    setState(() => _animating = true);
    _animatingNotifier.value = true;
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

                    // Wenn Animation completed ist, sicherstellen dass _animating false ist
                    if (_c.status == AnimationStatus.completed && _animating) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          setState(() => _animating = false);
                          _animatingNotifier.value = false;
                        }
                      });
                    }

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
