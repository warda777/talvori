import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/home/application/application.dart';

class ProgressPill extends ConsumerStatefulWidget {
  final int selected;          // z.B. 1
  final int max;               // z.B. 5 (später 1–20)
  final double barWidth;       // Breite des Balkens
  final VoidCallback? onTap;   // öffnet später dein Einstellungs-Sheet
  final Widget? leading;       // optional eigenes Icon/SVG
  final GlobalKey? counterKey; // <-- NEU: Key für den Counter-Text
  final VoidCallback? onAnimationStart; // Callback wenn Animation startet
  final VoidCallback? onAnimationComplete; // Callback wenn Animation fertig ist

  const ProgressPill({
    super.key,
    required this.selected,
    required this.max,
    this.barWidth = 140,
    this.onTap,
    this.leading,
    this.counterKey, // <-- NEU
    this.onAnimationStart,
    this.onAnimationComplete,
  });

  @override
  ConsumerState<ProgressPill> createState() => _ProgressPillState();
}

class _ProgressPillState extends ConsumerState<ProgressPill>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _colorController;
  late Animation<double> _progressAnimation;
  late Animation<Color?> _colorAnimation;

  double _previousValue = 0.0;
  bool _isAnimating = false;
  bool _hasReachedTarget = false;
  int _displayedSelected = 0; // Angezeigter Counter-Wert (wird verzögert aktualisiert)

  @override
  void initState() {
    super.initState();
    
    // Controller für Progress-Animation
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Controller für Farb-Animation - langsam für smooth Verglühen
    _colorController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Progress-Animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: (widget.selected / widget.max).clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOutCubic,
    ));

    // Farb-Animation: Orange (glühend) zu Blau - sehr smooth und langsam
    const wheelBlue = Color(0xFFB0CCFE);
    const glowingOrange = Color(0xFFFF9639); // Glühendes Orange
    _colorAnimation = ColorTween(
      begin: glowingOrange,
      end: wheelBlue,
    ).animate(CurvedAnimation(
      parent: _colorController,
      curve: Curves.easeInOutCubic, // Langsamer, smoother Übergang
    ));

    // Initialisiere mit aktuellem Wert
    _previousValue = (widget.selected / widget.max).clamp(0.0, 1.0);
    _progressController.value = _previousValue;
    _displayedSelected = widget.selected; // Initialisiere angezeigten Counter
    
    // Wenn bereits am Ziel, starte mit Blau
    if (_previousValue >= 1.0) {
      _colorController.value = 1.0; // Blau
      _hasReachedTarget = true;
    } else if (_previousValue > 0.0) {
      // Wenn bereits ein Wert vorhanden ist, starte mit Orange
      _colorController.value = 0.0; // Orange
    } else {
      // Beim ersten Mal (selected == 0) starte mit Blau, damit Glow langsam aufglühen kann
      _colorController.value = 1.0; // Blau (kein Glow)
    }

    // Listener für Progress-Animation
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _isAnimating) {
        // Progress-Animation fertig, jetzt Farbe zu Blau animieren
        _hasReachedTarget = true;
        _isAnimating = false;
        
        // Wenn bereits bei 1.0, rufe Callback verzögert auf
        final currentValue = (widget.selected / widget.max).clamp(0.0, 1.0);
        if (currentValue >= 1.0 && _colorController.value >= 1.0) {
          // Bereits am Ziel und Farbe bereits Blau, rufe Callback verzögert auf
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onAnimationComplete?.call();
          });
        } else {
          // Starte Farb-Animation von Orange (0.0) zu Blau (1.0)
          // Stelle sicher, dass wir bei Orange starten
          if (_colorController.value > 0.0) {
            _colorController.value = 0.0;
          }
          _colorController.forward();
        }
      }
    });

    // Listener für Farb-Animation - wenn fertig, rufe Callback auf
    _colorController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _hasReachedTarget) {
        debugPrint('🎨 PROGRESS-PILL: Farb-Animation fertig, rufe onAnimationComplete auf (selected: ${widget.selected}, max: ${widget.max})');
        // Beide Animationen fertig (Progress + Farbe)
        // Verzögere den Callback, damit er nicht während des Builds aufgerufen wird
        WidgetsBinding.instance.addPostFrameCallback((_) {
          debugPrint('📞 PROGRESS-PILL: Rufe onAnimationComplete Callback auf');
          widget.onAnimationComplete?.call();
        });
      } else if (status == AnimationStatus.completed) {
        debugPrint('⚠️ PROGRESS-PILL: Farb-Animation fertig, aber _hasReachedTarget = false (selected: ${widget.selected}, max: ${widget.max})');
      }
    });
  }

  @override
  void didUpdateWidget(ProgressPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.selected != widget.selected || oldWidget.max != widget.max) {
      final newValue = (widget.selected / widget.max).clamp(0.0, 1.0);
      final oldValue = (oldWidget.selected / oldWidget.max).clamp(0.0, 1.0);
      
      // Wenn sich der Wert erhöht hat, starte Animation
      if (newValue > oldValue) {
        _previousValue = _progressAnimation.value; // Aktueller animierter Wert
        _hasReachedTarget = false;
        _isAnimating = true;
        
        // Counter wird erst nach 800ms aktualisiert (wenn Pfeil die Pill erreicht hat)
        // Der Counter bleibt auf dem alten Wert, bis der Zauberpulver-Effekt startet
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() {
              _displayedSelected = widget.selected;
            });
          }
        });
        
        // Stoppe laufende Farb-Animation falls vorhanden
        if (_colorController.isAnimating) {
          _colorController.stop();
        }
        
        // Langsam von Blau zu Orange anglühen während der Pfeil-Flug-Animation (2300ms)
        // Stelle sicher, dass wir von Blau (1.0) starten, damit Glow langsam aufglüht
        if (_colorController.value < 1.0) {
          // Wenn nicht bei Blau, setze auf Blau, damit Animation von Blau zu Orange startet
          _colorController.value = 1.0;
        }
        // Starte Animation von Blau zu Orange während der Verzögerung
        // Passe die Dauer an, damit sie genau während der 2300ms Verzögerung läuft
        _colorController.duration = const Duration(milliseconds: 2300);
        _colorController.reverse(); // Von Blau (1.0) zu Orange (0.0) - Glow glüht langsam auf
        _startProgressAnimation(newValue);
      } else if (newValue < oldValue) {
        // Wert wurde reduziert, sofort aktualisieren
        _previousValue = newValue;
        _progressController.value = newValue;
        _displayedSelected = widget.selected; // Counter sofort aktualisieren
        if (newValue < 1.0) {
          _hasReachedTarget = false;
          _colorController.value = 0.0; // Zurück zu Orange
        }
      } else if (newValue == oldValue && newValue > 0) {
        // Gleicher Wert, aber sicherstellen dass Animation korrekt ist
        _progressController.value = newValue;
      }
    }
  }

  void _startProgressAnimation(double targetValue) {
    // Stoppe laufende Animation falls vorhanden
    if (_progressController.isAnimating) {
      _progressController.stop();
    }
    
    // Aktualisiere den Startwert mit dem aktuellen animierten Wert
    _previousValue = _progressAnimation.value;
    
    // Signalisiere dass Animation startet (wichtig wenn count == max)
    // Verzögere den Callback, damit er nicht während des Builds aufgerufen wird
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAnimationStart?.call();
    });
    
    // Warte bis Pfeil-Flug (800ms) und Zauber-Effekt (1500ms) fertig sind = 2300ms
    // Die Progressbar-Animation soll erst starten, wenn beide Animationen abgeschlossen sind
    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;
      
      // Setze die Dauer der Farb-Animation zurück auf 2500ms für die Animation von Orange zu Blau
      _colorController.duration = const Duration(milliseconds: 2500);
      
      // Starte Progress-Animation
      _progressAnimation = Tween<double>(
        begin: _previousValue,
        end: targetValue,
      ).animate(CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ));
      _progressController.forward(from: 0.0);
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glowEnabled = ref.watch(homeControllerProvider.select((s) => s.glowEnabled));
    const wheelBlue = Color(0xFFB0CCFE); // Blau aus Word Wheel
    const buttonColor = Color(0xFF2D2D2E); // Button-Hintergrundfarbe
    const gold = Color(0xFFF1C86B); // Gold für Progress Pill
    const glowingOrange = Color(0xFFFF9639); // Glühendes Orange

    return AnimatedBuilder(
      animation: Listenable.merge([_progressAnimation, _colorAnimation, _colorController]),
      builder: (context, _) {
        final progressValue = _progressAnimation.value;
        final barColor = _colorAnimation.value ?? glowingOrange;
        
        // Berechne Glow-Intensität: synchron mit Farb-Animation
        // Wenn Farbe von Blau zu Orange wechselt (reverse), Glow wird stärker
        // Wenn Farbe von Orange zu Blau wechselt (forward), Glow wird schwächer
        // Glow nur anzeigen, wenn Counter > 0
        final shouldShowGlow = widget.selected > 0;
        final colorProgress = _colorController.value; // 0.0 = Orange, 1.0 = Blau
        // Glow-Intensität basiert auf Farb-Progress: bei Orange (0.0) maximal, bei Blau (1.0) minimal
        final glowIntensity = shouldShowGlow ? (1.0 - colorProgress) : 0.0; // 1.0 = maximaler Glow bei Orange, 0.0 = kein Glow bei Blau
        final glowOpacity = glowIntensity * 0.9; // Maximal 90% Opacity für starken Glow

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: gold, width: 2), // Goldener Rand
        boxShadow: glowEnabled ? [
          // Durchgehender goldener Glow
          BoxShadow(
            color: gold.withValues(alpha: 0.55),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
              widget.leading ?? const Icon(Icons.system_update_alt_rounded,
              size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
                key: widget.counterKey, // <-- NEU: Key für den Counter
                '$_displayedSelected/${widget.max}',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
                width: widget.barWidth,
            height: 10,
                child: Stack(
                  children: [
                    // Hintergrund
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    // Progress-Bar mit abgerundetem vorderem Ende und Glow
                    FractionallySizedBox(
                      widthFactor: progressValue,
                      child: Container(
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(5),
                            bottomLeft: const Radius.circular(5),
                            topRight: const Radius.circular(5), // Immer abgerundet vorne
                            bottomRight: const Radius.circular(5), // Immer abgerundet vorne
                          ),
                          // Starker Glow, synchron mit Farb-Animation
                          boxShadow: glowIntensity > 0.01 ? [
                            BoxShadow(
                              color: glowingOrange.withValues(alpha: glowOpacity),
                              blurRadius: 20 * glowIntensity, // Starker Blur bei maximalem Glow
                              spreadRadius: 4 * glowIntensity, // Spread für mehr Intensität
                            ),
                            BoxShadow(
                              color: glowingOrange.withValues(alpha: glowOpacity * 0.6),
                              blurRadius: 40 * glowIntensity, // Zusätzlicher äußerer Glow
                              spreadRadius: 2 * glowIntensity,
                            ),
                          ] : null,
                        ),
                      ),
                    ),
                  ],
            ),
          ),
        ],
      ),
    );

        return widget.onTap == null
        ? pill
            : InkWell(borderRadius: BorderRadius.circular(20), onTap: widget.onTap, child: pill);
      },
    );
  }
}
