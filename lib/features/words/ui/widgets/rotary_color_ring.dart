import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'icon_picker_dialog.dart';

class RotaryColorRing extends StatefulWidget {
  const RotaryColorRing({
    super.key,
    required this.onPick,
    required this.onActiveColorChanged,
    this.onPickEnd,
    this.onPickIcon, // Callback für Icon-Auswahl
    this.onPickEmoji, // Callback für Emoji-Auswahl
    this.onClearIconEmoji, // Callback zum Löschen von Icons/Emojis
    this.isLocked = false, // 🔴 Nur wenn true, kann Farbe gepickt werden
    this.count = 36,
    this.bubbleSize = 22,
    required this.absoluteRadius,
    this.ringLift = 0.0,
    this.hitPadInner = 0.0,
    this.hitPadOuter = 0.0,
    this.customColor, // Custom-Farbe für Verlauf
    this.selectedIcon, // Ausgewähltes Icon
    this.selectedEmoji, // Ausgewähltes Emoji
  });

  final ValueChanged<Color> onPick;
  final ValueChanged<Color> onActiveColorChanged;
  final VoidCallback? onPickEnd;
  final ValueChanged<IconData>? onPickIcon; // Callback für Icon-Auswahl
  final ValueChanged<String>? onPickEmoji; // Callback für Emoji-Auswahl
  final VoidCallback? onClearIconEmoji; // Callback zum Löschen von Icons/Emojis
  final bool isLocked;
  final int count;
  final double bubbleSize;
  final double absoluteRadius;
  final double ringLift;
  final double hitPadInner;
  final double hitPadOuter;
  final Color? customColor; // Custom-Farbe für Verlauf
  final IconData? selectedIcon; // Ausgewähltes Icon
  final String? selectedEmoji; // Ausgewähltes Emoji

  @override
  State<RotaryColorRing> createState() => RotaryColorRingState();
}

class RotaryColorRingState extends State<RotaryColorRing>
    with TickerProviderStateMixin {
  double _angle = 0.0;
  double _dragStartAngle = 0.0;
  Offset _center = Offset.zero;
  String? _lastSelectedEmoji;
  IconData? _lastSelectedIcon;

  int _paletteIndex = 0;
  double _hueShift = 0.0;
  int _activeIndex = -1;
  int? _selectedIndex;

  bool _picking = false;
  Color? _dragColor;
  Offset? _dragPos;

  final GlobalKey _stackKey = GlobalKey();

  late final AnimationController _momentum;
  Animation<double>? _fling;

  // 🔴 Animation für Welle über Farbkeile
  late final AnimationController _waveController;
  late final Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _momentum = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Welle-Animation: einmal um den Kreis in 2 Sekunden
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController, curve: Curves.linear));

    // Welle starten wenn gelockt, stoppen wenn nicht gelockt
    if (widget.isLocked) {
      _waveController.repeat();
    }
  }

  @override
  void didUpdateWidget(RotaryColorRing oldWidget) {
    super.didUpdateWidget(oldWidget);

    // State zurücksetzen, wenn sich isLocked ändert (Fokuswechsel)
    if (widget.isLocked != oldWidget.isLocked) {
      setState(() {
        _picking = false;
        _selectedIndex = null;
        _dragColor = null;
      });
    }

    // Welle starten/stoppen basierend auf isLocked
    if (widget.isLocked && !oldWidget.isLocked) {
      // Nur starten wenn nicht gerade gepickt wird
      if (!_picking) {
        _waveController.repeat();
      }
    } else if (!widget.isLocked && oldWidget.isLocked) {
      _waveController.stop();
      _waveController.reset();
    }
  }

  @override
  void dispose() {
    _momentum.dispose();
    _waveController.dispose();
    super.dispose();
  }

  static const List<
    ({
      double saturation,
      double lightness,
      double satJitter,
      double lightJitter,
      double hueOffset,
    })
  >
  _paletteModes = [
    (
      saturation: .92,
      lightness: .52,
      satJitter: .06,
      lightJitter: .05,
      hueOffset: 0,
    ),
    (
      saturation: .72,
      lightness: .66,
      satJitter: .04,
      lightJitter: .08,
      hueOffset: 10,
    ),
    (
      saturation: .64,
      lightness: .44,
      satJitter: .05,
      lightJitter: .06,
      hueOffset: 18,
    ),
    (
      saturation: .48,
      lightness: .76,
      satJitter: .05,
      lightJitter: .07,
      hueOffset: 28,
    ),
  ];

  // 🔴 Feste Farbpaletten (eine pro Paint-Kugel)
  static final List<List<Color>> _fixedPalettes = [
    // Palette 0: Teal-Palette (unverändert)
    [
      const Color(0xFF05181A), // sehr dunkles Teal
      const Color(0xFF072E33), // dunkles Teal
      const Color(0xFF0C7075), // mittel-dunkles Teal
      const Color(0xFF0F969C), // vibrantes Teal
      const Color(0xFF6DA5C0), // helles Blau-Grau
      const Color(0xFF294D61), // dunkles Blau-Grau
    ],
    // Palette 1: Lila/Blau zu Teal (5 Farben)
    [
      const Color(0xFF4A2C4A), // dunkles Lila/Aubergine
      const Color(0xFF3D2C5C), // dunkles Indigo/blau-violett
      const Color(0xFF2C3A4F), // dunkles, gedämpftes Marineblau
      const Color(0xFF5A7A8C), // mittleres, etwas entsättigtes Blau
      const Color(0xFF4ECDC4), // helles, mittleres Teal/Aqua-Blau
    ],
    // Palette 2: Erdige Töne
    [
      const Color(0xFF2D4354), // dunkles, gedämpftes Blau
      const Color(0xFF73766A), // gedämpftes, graugrünes Olivgrau
      const Color(0xFFFED7A5), // helles, cremiges Beige
      const Color(0xFF9E6752), // mittleres, gedämpftes rötlich-braun
      const Color(0xFF534145), // dunkles, gedämpftes Pflaume
      const Color(0xFF20212B), // sehr dunkles, fast schwarzes, gedämpftes Blau
    ],
    // Palette 3: Pastellige Töne
    [
      const Color(0xFF99CDD8), // helles, gedämpftes Pastellblau
      const Color(0xFFDABEB3), // sehr helles, entsättigtes Beige
      const Color(0xFFFDEBD3), // weiches, blasses Pfirsich
      const Color(0xFFF3CBB2), // gedämpftes, etwas dunkleres Rosen
      const Color(0xFFC7D8C4), // helles, entsättigtes Salbeigrün
      const Color(0xFF657166), // dunkleres, gedämpftes Olivgrün
    ],
    // Palette 4: Blau/Pink Töne
    [
      const Color(0xFF0D1E4C), // sehr dunkles Marineblau
      const Color(0xFFC48CB3), // gedämpftes, staubiges Rosen/Mauve-Pink
      const Color(
        0xFFFFE5E5,
      ), // sehr helles, blasses Pink (korrigiert von #E5C907)
      const Color(0xFF83A6CE), // mittleres, etwas entsättigtes Himmelblau
      const Color(0xFF26415E), // dunkles Schieferblau
      const Color(0xFF0B1B32), // sehr dunkles Marineblau
    ],
    // Palette 5: Blau/Grau Töne (Interior)
    [
      const Color(0xFF050B10), // sehr dunkles, fast schwarzes Marineblau
      const Color(0xFF3F5B69), // mittleres, gedämpftes Blau-Grau
      const Color(0xFF46779B), // mittleres Blau
      const Color(0xFF618FA1), // helleres, entsättigtes Blau-Grau
      const Color(0xFFB29876), // warmes, mittleres Tan/Beige
    ],
    // Palette 6: Lila/Grau Gradient
    [
      const Color(0xFF190019), // sehr dunkles, tiefes Lila-Schwarz
      const Color(0xFF2B124C), // dunkles, gedämpftes Indigo/tiefes Pflaume
      const Color(0xFF522B5B), // mittel-dunkles, entsättigtes Lila-Grau/Taupe
      const Color(
        0xFF854F6C,
      ), // mittleres, entsättigtes rosig-braun/warmes Grau
      const Color(
        0xFFDFB6B2,
      ), // helles, entsättigtes Lavendel-Grau/blasses Taupe
      const Color(0xFFFBE4D8), // sehr helles, warmes Off-White/Creme
    ],
    // Palette 7: Warme/Erdige Töne
    [
      const Color(0xFF5C3D2E), // tiefes, reiches Schokoladenbraun
      const Color(0xFFC97D60), // warmes, erdiges Terrakotta/verbranntes Orange
      const Color(0xFFF5E6D3), // helles, cremiges Beige/Off-White
      const Color(0xFFFFD4C4), // weiches, gedämpftes Pfirsich/helles Lachs-Pink
      const Color(
        0xFFB8B8C8,
      ), // kühles, mittleres Grau mit leichtem Lavendel/Blau-Unterton
      const Color(0xFF1A4D5E), // dunkles Teal/tiefes Blau-Grün
    ],
    // Palette 8: Teal zu Rot-Braun
    [
      const Color(0xFF1F313B), // sehr dunkles Teal/Schieferblau
      const Color(0xFF383852), // gedämpftes Indigo/dunkles Lila
      const Color(
        0xFF7B4259,
      ), // staubiges Rosen/Mauve, tendiert zu gedämpftem rötlich-Lila
      const Color(0xFFB94E56), // gedämpftes Korallen/Lachs-Pink
      const Color(0xFFBE4039), // verbranntes Orange/Terrakotta-Rot
      const Color(0xFF8B3B3B), // tiefes rötlich-Braun/Maroon
    ],
  ];

  List<Color> _paletteColors(int n) {
    // Wenn Custom-Farbe gesetzt ist, erstelle Verlauf basierend auf dieser Farbe
    if (widget.customColor != null) {
      final customColor = widget.customColor!;
      final hsl = HSLColor.fromColor(customColor);

      // Erstelle einen Verlauf um die Custom-Farbe herum
      return List<Color>.generate(n, (i) {
        final t = i / n;
        // Hue-Variation: ±60 Grad um die Custom-Farbe
        final hueVariation = (t - 0.5) * 120; // -60 bis +60
        final hue = (hsl.hue + hueVariation) % 360;

        // Saturation: von niedrig zu hoch und zurück
        final satVariation = math.sin(t * 2 * math.pi) * 0.3;
        final sat = (hsl.saturation + satVariation).clamp(0.1, 1.0);

        // Lightness: von hell zu dunkel und zurück
        final lightVariation = math.cos(t * 2 * math.pi) * 0.4;
        final light = (hsl.lightness + lightVariation).clamp(0.1, 0.9);

        return HSLColor.fromAHSL(1, hue, sat, light).toColor();
      });
    }

    // Wenn _paletteIndex >= _paletteModes.length, verwende feste Palette
    if (_paletteIndex >= _paletteModes.length &&
        _paletteIndex < _paletteModes.length + _fixedPalettes.length) {
      final fixedPaletteIndex = _paletteIndex - _paletteModes.length;
      final fixedPalette =
          _fixedPalettes[fixedPaletteIndex % _fixedPalettes.length];
      // Interpoliere die feste Palette auf n Farben
      return List<Color>.generate(n, (i) {
        final t = i / (n - 1);
        final paletteIndex = (t * (fixedPalette.length - 1))
            .clamp(0, fixedPalette.length - 1)
            .toInt();
        final nextIndex = (paletteIndex + 1).clamp(0, fixedPalette.length - 1);
        final localT = (t * (fixedPalette.length - 1)) - paletteIndex;
        // Interpoliere zwischen den beiden nächsten Farben
        return Color.lerp(
          fixedPalette[paletteIndex],
          fixedPalette[nextIndex],
          localT,
        )!;
      });
    }

    // Standard-Palette-Modus
    final mode = _paletteModes[_paletteIndex % _paletteModes.length];
    return List<Color>.generate(n, (i) {
      final t = i / n;
      final hue = ((i + _hueShift + mode.hueOffset) * 360 / n) % 360;
      final sat = (mode.saturation + mode.satJitter * math.sin(t * 2 * math.pi))
          .clamp(0.05, 1.0);
      final light =
          (mode.lightness + mode.lightJitter * math.cos(t * 2 * math.pi)).clamp(
            0.05,
            0.95,
          );
      return HSLColor.fromAHSL(1, hue.toDouble(), sat, light).toColor();
    });
  }

  /// Öffentliche Methode, um die aktuellen Palette-Farben zu erhalten
  List<Color> getCurrentPaletteColors(int n) {
    return _paletteColors(n);
  }

  /// Rotiert den Ring zu einem bestimmten Winkel
  void rotateToAngle(double targetAngle) {
    setState(() {
      _angle = targetAngle;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = _paletteColors(widget.count);
      final idx = (_activeIndex >= 0 && _activeIndex < colors.length)
          ? _activeIndex
          : 0;
      widget.onActiveColorChanged(colors[idx]);
    });
  }

  void switchPalette() {
    setState(() {
      _paletteIndex = (_paletteIndex + 1) % _paletteModes.length;
      _hueShift = (_hueShift + widget.count / 4) % widget.count;
      _selectedIndex = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = _paletteColors(widget.count);
      final idx = (_activeIndex >= 0 && _activeIndex < colors.length)
          ? _activeIndex
          : 0;
      widget.onActiveColorChanged(colors[idx]);
    });
    HapticFeedback.selectionClick();
  }

  /// Setzt die Palette direkt auf einen bestimmten Index
  void setPaletteIndex(int index) {
    final totalPalettes = _paletteModes.length + _fixedPalettes.length;
    if (index < 0 || index >= totalPalettes) return;
    setState(() {
      _paletteIndex = index;
      _hueShift = (_hueShift + widget.count / 4) % widget.count;
      _selectedIndex = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final colors = _paletteColors(widget.count);
      final idx = (_activeIndex >= 0 && _activeIndex < colors.length)
          ? _activeIndex
          : 0;
      widget.onActiveColorChanged(colors[idx]);
    });
    HapticFeedback.selectionClick();
  }

  /// Gibt die Anzahl der verfügbaren Paletten zurück
  int get paletteCount => _paletteModes.length + _fixedPalettes.length;

  /// Gibt den aktuellen Palette-Index zurück
  int get currentPaletteIndex => _paletteIndex;

  /// Gibt eine repräsentative Farbe für eine Palette zurück (z.B. für Kugeln)
  Color getPaletteColor(int paletteIndex) {
    if (paletteIndex < 0) paletteIndex = 0;

    // Feste Palette
    if (paletteIndex >= _paletteModes.length &&
        paletteIndex < _paletteModes.length + _fixedPalettes.length) {
      final fixedPaletteIndex = paletteIndex - _paletteModes.length;
      final fixedPalette =
          _fixedPalettes[fixedPaletteIndex % _fixedPalettes.length];
      // Hauptfarbe (erste Farbe) der Palette zurückgeben
      return fixedPalette[0];
    }

    // Standard-Palette
    if (paletteIndex >= _paletteModes.length) {
      paletteIndex = 0;
    }
    final mode = _paletteModes[paletteIndex];
    // Erste Farbe der Palette als Repräsentant verwenden
    final hue = (mode.hueOffset * 360 / widget.count) % 360;
    final sat = mode.saturation.clamp(0.05, 1.0);
    final light = mode.lightness.clamp(0.05, 0.95);
    return HSLColor.fromAHSL(1, hue, sat, light).toColor();
  }

  void _maybeTick(int idx, List<Color> colors) {
    if (idx != _activeIndex) {
      _activeIndex = idx;
      widget.onActiveColorChanged(colors[idx]);
      HapticFeedback.selectionClick();
    }
  }

  // ---------- Rotation ----------

  void _onPanStart(DragStartDetails d) {
    _momentum.stop();
    _dragStartAngle =
        math.atan2(
          d.localPosition.dy - _center.dy,
          d.localPosition.dx - _center.dx,
        ) -
        _angle;
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _angle =
          math.atan2(
            d.localPosition.dy - _center.dy,
            d.localPosition.dx - _center.dx,
          ) -
          _dragStartAngle;
    });
  }

  void _onPanEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.distance.clamp(0, 2600) / 2600;
    if (v < 0.05) return;
    final start = _angle;
    _fling =
        Tween(begin: 0.0, end: v * 2 * math.pi).animate(
          CurvedAnimation(parent: _momentum, curve: Curves.decelerate),
        )..addListener(() {
          if (!mounted) return;
          setState(() => _angle = start + _fling!.value);
        });
    _momentum
      ..reset()
      ..forward();
  }

  // Von außen drehbar (Buttons geben Pan weiter)

  void handleExternalPanStart(DragStartDetails d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    _onPanStart(
      DragStartDetails(
        globalPosition: d.globalPosition,
        localPosition: local,
        kind: d.kind,
      ),
    );
  }

  void handleExternalPanUpdate(DragUpdateDetails d) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;
    final local = box.globalToLocal(d.globalPosition);
    _onPanUpdate(
      DragUpdateDetails(
        globalPosition: d.globalPosition,
        localPosition: local,
        delta: d.delta,
        primaryDelta: d.primaryDelta,
        sourceTimeStamp: d.sourceTimeStamp,
      ),
    );
  }

  void handleExternalPanEnd(DragEndDetails d) => _onPanEnd(d);

  @override
  Widget build(BuildContext context) {
    // Prüfe, ob Icons/Emojis angezeigt werden sollen
    final bool showIcons = widget.selectedIcon != null;
    final bool showEmojis = widget.selectedEmoji != null;
    final bool showIconMode = showIcons || showEmojis;

    // State zurücksetzen, wenn sich das ausgewählte Emoji/Icon ändert
    if (showIconMode) {
      if (showEmojis && widget.selectedEmoji != _lastSelectedEmoji) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _picking = false;
              _selectedIndex = null;
              _dragColor = null;
              _lastSelectedEmoji = widget.selectedEmoji;
            });
          }
        });
      } else if (showIcons && widget.selectedIcon != _lastSelectedIcon) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _picking = false;
              _selectedIndex = null;
              _dragColor = null;
              _lastSelectedIcon = widget.selectedIcon;
            });
          }
        });
      }
    }

    // Liste der Icons/Emojis für den Ring
    List<dynamic> iconEmojiList = [];
    int selectedIndex = 0;

    if (showIconMode) {
      if (showEmojis) {
        iconEmojiList = IconPickerDialog.emojis;
        selectedIndex = iconEmojiList.indexOf(widget.selectedEmoji!);
      } else if (showIcons) {
        iconEmojiList = IconPickerDialog.icons;
        selectedIndex = iconEmojiList.indexOf(widget.selectedIcon!);
      }

      // Wenn nicht gefunden, auf 0 setzen
      if (selectedIndex < 0) selectedIndex = 0;
    }

    final colors = showIconMode
        ? List<Color>.generate(widget.count, (_) => Colors.transparent)
        : _paletteColors(widget.count);

    return LayoutBuilder(
      builder: (_, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          constraints.maxHeight / 2,
        );
        _center = center;

        const double trapezDepth = 34.0;

        final double innerR = widget.absoluteRadius;
        final double outerR = innerR + trapezDepth;

        // Wie weit die Drehzone nach innen in Richtung Tool-Buttons reichen soll.
        // 20–30 px ist ein guter Startwert.
        const double grabBandWidth = 24.0;

        // Hit-Zone beginnt weiter innen als der sichtbare Ring:
        final double hitInnerR = (innerR - grabBandWidth).clamp(0.0, innerR);
        final double hitOuterR = outerR;

        final step = (2 * math.pi) / colors.length;

        // Berechne die Icons/Emojis für den Ring
        List<dynamic> ringItems = [];
        final int ringCount = widget.count;
        final int halfCount = ringCount ~/ 2;

        // Spezielles "X" Symbol zum Löschen (wird als spezielles Objekt markiert)
        const String clearSymbol = '__CLEAR__';
        // Feste Position für das "X" im Ring (z.B. Position 0, was 6 Uhr entspricht)
        const int clearPosition = 0; // Feste Position im Ring

        if (showIconMode && iconEmojiList.isNotEmpty) {
          // Das ausgewählte Icon/Emoji soll auf 12 Uhr sein
          // Berechne die Nachbarn um das ausgewählte Icon/Emoji
          // Reduziere die Anzahl um 1, um Platz für das "X" zu schaffen

          // Starte mit dem ausgewählten Item und füge Nachbarn hinzu
          // Wir nehmen einen weniger, damit Platz für das "X" ist
          for (int i = -halfCount + 1; i <= halfCount - 1; i++) {
            int listIndex = (selectedIndex + i) % iconEmojiList.length;
            if (listIndex < 0) listIndex += iconEmojiList.length;
            ringItems.add(iconEmojiList[listIndex]);
          }

          // Füge das "X" an fester Position ein
          ringItems.insert(clearPosition, clearSymbol);
        }

        final children = <Widget>[];

        // Für Icon-Modus: Berechne Winkel-Offset, damit das ausgewählte Icon/Emoji auf 12 Uhr ist
        double iconModeAngleOffset = 0.0;
        if (showIconMode && iconEmojiList.isNotEmpty) {
          // Das ausgewählte Icon/Emoji ist auf Index halfCount-1 in ringItems (Mitte des Rings, da wir ein Element weniger haben)
          // Wir wollen, dass dieser Index auf 12 Uhr (-pi/2) ist
          const targetAngle = -math.pi / 2; // 12 Uhr
          // Aktueller Winkel von Index halfCount-1 ohne Offset (da wir ein Element weniger haben)
          final adjustedHalfCount = halfCount - 1;
          final currentAngleOfSelected = _angle + adjustedHalfCount * step;
          // Offset berechnen, damit es auf 12 Uhr landet
          iconModeAngleOffset = targetAngle - currentAngleOfSelected;
        }

        // Für Icon-Modus: Icons/Emojis ZUERST hinzufügen (damit sie unter den GestureDetector-Bereichen liegen)
        if (showIconMode && ringItems.isNotEmpty) {
          for (int i = 0; i < ringItems.length && i < colors.length; i++) {
            final adjustedAngle = _angle + i * step + iconModeAngleOffset;
            final angleWidth = step;
            final midAngle = adjustedAngle + angleWidth / 2;
            final midRadius = (innerR + outerR) / 2;

            // Position relativ zum Stack
            final iconX = midRadius * math.cos(midAngle);
            final iconY = midRadius * math.sin(midAngle);

            final item = ringItems[i];
            final isClearSymbol = item == clearSymbol;
            final isEmoji = item is String && !isClearSymbol;
            final isIcon = item is IconData;

            children.add(
              Positioned(
                left: center.dx + iconX - 20,
                top: center.dy + iconY - 20,
                width: 40,
                height: 40,
                child: IgnorePointer(
                  ignoring: true,
                  child: Center(
                    child: isClearSymbol
                        ? Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          )
                        : isEmoji
                        ? Text(
                            item,
                            style: const TextStyle(fontSize: 28),
                            textAlign: TextAlign.center,
                          )
                        : isIcon
                        ? Icon(item, color: Colors.white, size: 28)
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          }
        }

        // Dann die GestureDetector-Bereiche hinzufügen (für Drehung) - diese liegen ÜBER den Icons
        for (int i = 0; i < colors.length; i++) {
          final adjustedAngle = _angle + i * step + iconModeAngleOffset;
          final angleWidth = step;
          final finalAngle = adjustedAngle;

          children.add(
            Positioned.fill(
              child: ClipPath(
                clipper: _WedgeClipper(
                  baseAngle: finalAngle,
                  angleWidth: angleWidth,
                  innerR: hitInnerR,
                  outerR: hitOuterR,
                ),
                child: Container(
                  color: showIconMode
                      ? Colors.white.withOpacity(0.01)
                      : Colors.transparent,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) {
                      final box =
                          _stackKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (box == null) return;
                      final localPos = box.globalToLocal(d.globalPosition);

                      // Wenn Icon-Modus aktiv, Icon/Emoji picken statt Farbe
                      if (showIconMode && ringItems.isNotEmpty) {
                        // Verwende die tatsächliche Tap-Position, um das nächste Item zu finden
                        final dx = localPos.dx - _center.dx;
                        final dy = localPos.dy - _center.dy;
                        final distance = math.sqrt(dx * dx + dy * dy);

                        // Prüfe, ob der Tap innerhalb des Rings ist
                        if (distance < innerR - 10 || distance > outerR + 10) {
                          // Außerhalb des Rings, ignoriere
                          return;
                        }

                        // Berechne den Winkel des getappten Punktes
                        double tapAngle = math.atan2(dy, dx);
                        // Normalisiere auf 0..2π
                        if (tapAngle < 0) tapAngle += 2 * math.pi;

                        // Finde das nächste Item basierend auf dem Winkel
                        int ringItemIndex = -1;
                        double minAngleDiff = double.infinity;

                        for (int j = 0; j < ringItems.length; j++) {
                          // Berechne den Winkel für jedes Item im Ring
                          final itemAngle =
                              _angle + j * step + iconModeAngleOffset;
                          final itemMidAngle = itemAngle + step / 2;
                          // Normalisiere auf 0..2π
                          double normalizedItemAngle =
                              itemMidAngle % (2 * math.pi);
                          if (normalizedItemAngle < 0)
                            normalizedItemAngle += 2 * math.pi;

                          // Berechne die Winkeldifferenz (berücksichtige Wraparound)
                          double angleDiff = (tapAngle - normalizedItemAngle)
                              .abs();
                          if (angleDiff > math.pi) {
                            angleDiff = 2 * math.pi - angleDiff;
                          }

                          if (angleDiff < minAngleDiff) {
                            minAngleDiff = angleDiff;
                            ringItemIndex = j;
                          }
                        }

                        if (ringItemIndex >= 0 &&
                            ringItemIndex < ringItems.length) {
                          final item = ringItems[ringItemIndex];

                          // Prüfe, ob das "X" zum Löschen getappt wurde
                          // Das "X" funktioniert immer, wenn Icon-Modus aktiv ist (auch ohne Lock)
                          if (item == clearSymbol) {
                            widget.onClearIconEmoji?.call();
                            HapticFeedback.lightImpact();
                            return;
                          }

                          // Für normale Icons/Emojis: Nur picken, wenn Kugel gelockt ist
                          if (!widget.isLocked) return;

                          // State zurücksetzen, bevor neues Item gepickt wird
                          setState(() {
                            _picking = false;
                            _selectedIndex = null;
                            _dragColor = null;
                          });

                          setState(() {
                            _picking = true;
                            _selectedIndex = i;
                            _dragPos = localPos;
                          });
                          _waveController.stop();

                          if (item is String) {
                            // Emoji
                            widget.onPickEmoji?.call(item);
                          } else if (item is IconData) {
                            // Icon
                            widget.onPickIcon?.call(item);
                          }
                          HapticFeedback.lightImpact();
                          return;
                        }
                      }

                      // Für Farben: Nur picken, wenn Kugel gelockt ist
                      if (!widget.isLocked) return;

                      if (_picking && _selectedIndex != i) return;

                      setState(() {
                        _picking = true;
                        _selectedIndex = i;
                        _dragColor = colors[i];
                        _dragPos = localPos;
                      });
                      // 🔴 Welle sofort stoppen wenn Farbe gepickt wird
                      _waveController.stop();
                      widget.onPick(colors[i]);
                      HapticFeedback.lightImpact();
                    },
                    onPanStart: (d) {
                      final box =
                          _stackKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (box == null) return;
                      final localPos = box.globalToLocal(d.globalPosition);

                      if (_picking && _selectedIndex == i) {
                        setState(() {
                          _dragPos = localPos;
                        });
                        return;
                      }

                      _onPanStart(
                        DragStartDetails(
                          globalPosition: d.globalPosition,
                          localPosition: localPos,
                          kind: d.kind,
                        ),
                      );
                    },
                    onPanUpdate: (d) {
                      final box =
                          _stackKey.currentContext?.findRenderObject()
                              as RenderBox?;
                      if (box == null) return;
                      final localPos = box.globalToLocal(d.globalPosition);

                      if (_picking && _selectedIndex == i) {
                        setState(() {
                          _dragPos = localPos;
                        });
                      } else {
                        _onPanUpdate(
                          DragUpdateDetails(
                            globalPosition: d.globalPosition,
                            localPosition: localPos,
                            delta: d.delta,
                            primaryDelta: d.primaryDelta,
                            sourceTimeStamp: d.sourceTimeStamp,
                          ),
                        );
                      }
                    },
                    onPanEnd: (d) {
                      if (_picking && _selectedIndex == i) {
                        setState(() {
                          _picking = false;
                          _dragColor = null;
                          _dragPos = null;
                        });
                        // 🔴 Welle wieder starten wenn Pick beendet ist (nur wenn noch gelockt)
                        if (widget.isLocked && !_waveController.isAnimating) {
                          _waveController.repeat();
                        }
                        // 🔴 Callback für Pick-Ende (Finger losgelassen)
                        widget.onPickEnd?.call();
                      } else {
                        _onPanEnd(d);
                      }
                    },
                    onPanCancel: () {
                      if (_picking && _selectedIndex == i) {
                        setState(() {
                          _picking = false;
                          _dragColor = null;
                          _dragPos = null;
                        });
                        // 🔴 Welle wieder starten wenn Pick beendet ist (nur wenn noch gelockt)
                        if (widget.isLocked && !_waveController.isAnimating) {
                          _waveController.repeat();
                        }
                        // 🔴 Callback für Pick-Ende (auch bei Cancel)
                        widget.onPickEnd?.call();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _waveAnimation,
                      builder: (context, _) {
                        // Welle-Position neu berechnen für jeden Frame
                        final currentWaveAngle = widget.isLocked
                            ? _waveAnimation.value
                            : null;
                        bool currentIsInWave = false;
                        if (currentWaveAngle != null) {
                          var normalizedWedgeAngle = finalAngle % (2 * math.pi);
                          if (normalizedWedgeAngle < 0)
                            normalizedWedgeAngle += 2 * math.pi;
                          var normalizedWaveAngle =
                              currentWaveAngle % (2 * math.pi);
                          if (normalizedWaveAngle < 0)
                            normalizedWaveAngle += 2 * math.pi;

                          const waveWidth = math.pi / 3;
                          var angleDiff =
                              (normalizedWedgeAngle - normalizedWaveAngle)
                                  .abs();
                          if (angleDiff > math.pi)
                            angleDiff = 2 * math.pi - angleDiff;

                          currentIsInWave = angleDiff < waveWidth / 2;
                        }

                        // Wenn Icon-Modus aktiv, zeige transparenten Hintergrund statt Farbkeil
                        // (die GestureDetector funktionieren auch mit transparenten Bereichen)
                        if (showIconMode) {
                          return CustomPaint(
                            painter: _WedgePainter(
                              baseAngle: finalAngle,
                              angleWidth: angleWidth,
                              innerR: innerR,
                              outerR: outerR,
                              color: Colors.transparent,
                              shadow: 0,
                              waveAngle: null,
                              isInWave: false,
                            ),
                          );
                        }

                        return CustomPaint(
                          painter: _WedgePainter(
                            baseAngle: finalAngle,
                            angleWidth: angleWidth,
                            innerR: innerR,
                            outerR: outerR,
                            color: colors[i],
                            shadow: 10,
                            waveAngle: currentWaveAngle,
                            isInWave: currentIsInWave,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        if (!_picking) {
          const twelve = -math.pi / 2;
          int active = 0;
          double minDelta = double.infinity;
          for (int i = 0; i < colors.length; i++) {
            final a = _angle + i * step + iconModeAngleOffset;
            var delta = (a - twelve) % (2 * math.pi);
            if (delta > math.pi) delta -= 2 * math.pi;
            final d = delta.abs();
            if (d < minDelta) {
              minDelta = d;
              active = i;
            }
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _maybeTick(active, colors);
          });
        }

        if (_dragColor != null && _dragPos != null) {
          final v = (_dragPos! - center);
          final len = v.distance == 0 ? 1.0 : v.distance;
          final dir = v / len;
          const ahead = 50.0;
          final p = _dragPos! + dir * ahead;

          children.add(
            Positioned(
              left: p.dx - 18,
              top: p.dy - 18,
              width: 36,
              height: 36,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [_dragColor!, _dragColor!.withOpacity(.65)],
                    ),
                    border: Border.all(color: Colors.white70, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: _dragColor!.withOpacity(.45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return Stack(
          key: _stackKey,
          clipBehavior: Clip.none,
          children: children,
        );
      },
    );
  }
}

class _WedgePainter extends CustomPainter {
  _WedgePainter({
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
    required this.color,
    required this.shadow,
    this.waveAngle,
    this.isInWave = false,
  });

  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;
  final Color color;
  final double shadow;
  final double? waveAngle;
  final bool isInWave;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final a0 = baseAngle - angleWidth / 2;
    final a1 = baseAngle + angleWidth / 2;

    final rectInner = Rect.fromCircle(center: c, radius: innerR);
    final rectOuter = Rect.fromCircle(center: c, radius: outerR);

    final path = Path()
      ..moveTo(c.dx + innerR * math.cos(a0), c.dy + innerR * math.sin(a0))
      ..arcTo(rectInner, a0, angleWidth, false)
      ..lineTo(c.dx + outerR * math.cos(a1), c.dy + outerR * math.sin(a1))
      ..arcTo(rectOuter, a1, -angleWidth, false)
      ..close();

    if (shadow > 0) {
      final shadowPaint = Paint()
        ..color = color.withOpacity(0.35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadow);
      canvas.drawPath(path, shadowPaint);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // 🔴 Welle-Effekt: Glow wenn von Welle getroffen
    if (isInWave && waveAngle != null) {
      // Intensität basierend auf Entfernung zur Wellenmitte
      var normalizedWedgeAngle = baseAngle % (2 * math.pi);
      if (normalizedWedgeAngle < 0) normalizedWedgeAngle += 2 * math.pi;
      final waveAngleValue = waveAngle!; // Null-Check bereits oben
      var normalizedWaveAngle = waveAngleValue % (2 * math.pi);
      if (normalizedWaveAngle < 0) normalizedWaveAngle += 2 * math.pi;

      var angleDiff = (normalizedWedgeAngle - normalizedWaveAngle).abs();
      if (angleDiff > math.pi) angleDiff = 2 * math.pi - angleDiff;

      const waveWidth = math.pi / 3; // ~60 Grad
      final intensity = 1.0 - (angleDiff / (waveWidth / 2)).clamp(0.0, 1.0);

      // Goldener Glow für die Welle
      final wavePaint = Paint()
        ..color = const Color(0xFFFFC66A).withOpacity(0.6 * intensity)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15 * intensity);
      canvas.drawPath(path, wavePaint);

      // Heller Rand
      final waveStroke = Paint()
        ..color = const Color(0xFFFFC66A).withOpacity(0.9 * intensity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * intensity;
      canvas.drawPath(path, waveStroke);
    }

    final stroke = Paint()
      ..color = Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant _WedgePainter old) =>
      old.baseAngle != baseAngle ||
      old.angleWidth != angleWidth ||
      old.innerR != innerR ||
      old.outerR != outerR ||
      old.color != color ||
      old.waveAngle != waveAngle ||
      old.isInWave != isInWave;
}

class _WedgeClipper extends CustomClipper<Path> {
  _WedgeClipper({
    required this.baseAngle,
    required this.angleWidth,
    required this.innerR,
    required this.outerR,
  });

  final double baseAngle;
  final double angleWidth;
  final double innerR;
  final double outerR;

  @override
  Path getClip(Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final a0 = baseAngle - angleWidth / 2;
    final a1 = baseAngle + angleWidth / 2;

    final rectInner = Rect.fromCircle(center: center, radius: innerR);
    final rectOuter = Rect.fromCircle(center: center, radius: outerR);

    final p0 = center + Offset(innerR * math.cos(a0), innerR * math.sin(a0));
    final p2 = center + Offset(outerR * math.cos(a1), outerR * math.sin(a1));

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..arcTo(rectInner, a0, angleWidth, false)
      ..lineTo(p2.dx, p2.dy)
      ..arcTo(rectOuter, a1, -angleWidth, false)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(_WedgeClipper old) =>
      old.baseAngle != baseAngle ||
      old.angleWidth != angleWidth ||
      old.innerR != innerR ||
      old.outerR != outerR;
}
