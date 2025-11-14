import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';

/// Custom-Farbwähler-Dialog ähnlich Figma/Design-Tools
class CustomColorPickerDialog extends StatefulWidget {
  const CustomColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
  });

  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  @override
  State<CustomColorPickerDialog> createState() => _CustomColorPickerDialogState();
}

enum ColorFormat {
  hex,
  rgb,
  css,
  hsl,
  hsb,
}

class _CustomColorPickerDialogState extends State<CustomColorPickerDialog> {
  late Color _currentColor;
  late double _hue; // 0-360
  late double _saturation; // 0-1
  late double _lightness; // 0-1
  late double _alpha; // 0-1
  Color? _selectedSwatchColor; // Ausgewählte Farbe aus der Palette
  final ScrollController _scrollController = ScrollController(); // ScrollController für Farbpalette
  ColorFormat _colorFormat = ColorFormat.hex; // Aktuelles Farbformat
  final TextEditingController _colorInputController = TextEditingController();
  final TextEditingController _opacityInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
    // Initialisierung ohne Provider-Modifikation
    final hsl = HSLColor.fromColor(_currentColor);
    _hue = hsl.hue;
    _saturation = hsl.saturation;
    _lightness = hsl.lightness;
    _alpha = _currentColor.alpha / 255.0;
    _updateColorInputs();
  }

  void _updateColorInputs() {
    _colorInputController.text = _getColorString(_currentColor);
    _opacityInputController.text = '${(_alpha * 100).round()}';
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _colorInputController.dispose();
    _opacityInputController.dispose();
    super.dispose();
  }

  void _updateFromColor(Color color) {
    final hsl = HSLColor.fromColor(color);
    setState(() {
      _hue = hsl.hue;
      _saturation = hsl.saturation;
      _lightness = hsl.lightness;
      _alpha = color.alpha / 255.0;
      _currentColor = color;
      _selectedSwatchColor = color; // Markiere die ausgewählte Farbe
      _updateColorInputs();
    });
    // Provider-Modifikation verzögern, um Fehler während Build zu vermeiden
    Future.microtask(() {
      widget.onColorChanged(_currentColor);
    });
  }

  void _updateColor() {
    final newColor = HSLColor.fromAHSL(_alpha, _hue, _saturation, _lightness).toColor();
    setState(() {
      _currentColor = newColor;
      _updateColorInputs();
    });
    // Provider-Modifikation verzögern, um Fehler während Build zu vermeiden
    Future.microtask(() {
      widget.onColorChanged(_currentColor);
    });
  }

  String _colorToHex(Color color) {
    final hex = color.value.toRadixString(16).toUpperCase();
    // Stelle sicher, dass wir mindestens 6 Zeichen haben (ohne Alpha)
    // Wenn der String kürzer ist, füge führende Nullen hinzu
    final hexWithoutAlpha = hex.length >= 8 
        ? hex.substring(2) 
        : hex.padLeft(6, '0');
    return hexWithoutAlpha;
  }

  String _colorToRgb(Color color) {
    return '${color.red}, ${color.green}, ${color.blue}';
  }

  String _colorToCss(Color color) {
    return 'rgb(${color.red}, ${color.green}, ${color.blue})';
  }

  String _colorToHsl(Color color) {
    final hsl = HSLColor.fromColor(color);
    return '${hsl.hue.round()}, ${(hsl.saturation * 100).round()}%, ${(hsl.lightness * 100).round()}%';
  }

  String _colorToHsb(Color color) {
    final hsl = HSLColor.fromColor(color);
    // HSB ist ähnlich zu HSL, aber mit Brightness statt Lightness
    final brightness = hsl.lightness;
    final saturation = hsl.saturation;
    return '${hsl.hue.round()}, ${(saturation * 100).round()}%, ${(brightness * 100).round()}%';
  }

  String _getColorString(Color color) {
    switch (_colorFormat) {
      case ColorFormat.hex:
        return _colorToHex(color);
      case ColorFormat.rgb:
        return _colorToRgb(color);
      case ColorFormat.css:
        return _colorToCss(color);
      case ColorFormat.hsl:
        return _colorToHsl(color);
      case ColorFormat.hsb:
        return _colorToHsb(color);
    }
  }

  Color? _parseColorString(String value) {
    try {
      switch (_colorFormat) {
        case ColorFormat.hex:
          return _hexToColor(value);
        case ColorFormat.rgb:
          return _rgbToColor(value);
        case ColorFormat.css:
          return _cssToColor(value);
        case ColorFormat.hsl:
          return _hslToColor(value);
        case ColorFormat.hsb:
          return _hsbToColor(value);
      }
    } catch (e) {
      return null;
    }
  }

  Color? _rgbToColor(String rgb) {
    final parts = rgb.split(',').map((e) => e.trim()).toList();
    if (parts.length == 3) {
      final r = int.tryParse(parts[0]);
      final g = int.tryParse(parts[1]);
      final b = int.tryParse(parts[2]);
      if (r != null && g != null && b != null) {
        return Color.fromRGBO(r.clamp(0, 255), g.clamp(0, 255), b.clamp(0, 255), _alpha);
      }
    }
    return null;
  }

  Color? _cssToColor(String css) {
    // Entferne "rgb(" und ")"
    final cleaned = css.replaceAll('rgb(', '').replaceAll(')', '').trim();
    return _rgbToColor(cleaned);
  }

  Color? _hslToColor(String hsl) {
    final parts = hsl.split(',').map((e) => e.trim().replaceAll('%', '').replaceAll('°', '')).toList();
    if (parts.length == 3) {
      final h = double.tryParse(parts[0]);
      final s = double.tryParse(parts[1])?.clamp(0, 100) ?? 0.0;
      final l = double.tryParse(parts[2])?.clamp(0, 100) ?? 0.0;
      if (h != null) {
        return HSLColor.fromAHSL(_alpha, h, s / 100, l / 100).toColor();
      }
    }
    return null;
  }

  Color? _hsbToColor(String hsb) {
    final parts = hsb.split(',').map((e) => e.trim().replaceAll('%', '').replaceAll('°', '')).toList();
    if (parts.length == 3) {
      final h = double.tryParse(parts[0]);
      final s = double.tryParse(parts[1])?.clamp(0, 100) ?? 0.0;
      final b = double.tryParse(parts[2])?.clamp(0, 100) ?? 0.0;
      if (h != null) {
        // HSB zu HSL konvertieren (vereinfacht)
        final lightness = b / 100;
        final saturation = s / 100;
        return HSLColor.fromAHSL(_alpha, h, saturation, lightness).toColor();
      }
    }
    return null;
  }

  List<Widget> _buildColorSwatches() {
    // Farbpalette basierend auf den Bildern - 8 Spalten pro Reihe
    // Alle doppelten Farben entfernt
    final allColors = [
      // Basis-Farben
      Colors.white,
      Colors.black,
      Colors.grey,
      Colors.transparent,
      Colors.blue,
      Colors.red,
      Colors.pink,
      
      // Bild 1 - erste Reihe
      const Color(0xFFFFD700), // Gold
      
      // Bild 1 - zweite Reihe
      const Color(0xFF2D4354), // Dunkles Blau-Grau
      const Color(0xFF73766A), // Olivgrau
      const Color(0xFFFED7A5), // Cremiges Beige
      const Color(0xFF9E6752), // Rötlich-Braun
      const Color(0xFF534145), // Dunkles Pflaume
      const Color(0xFF20212B), // Sehr dunkles Blau
      const Color(0xFF99CDD8), // Pastellblau
      const Color(0xFFDABEB3), // Beige
      
      // Bild 1 - dritte Reihe
      const Color(0xFFFDEBD3), // Pfirsich
      const Color(0xFFF3CBB2), // Rosen
      const Color(0xFFC7D8C4), // Salbeigrün
      const Color(0xFF657166), // Olivgrün
      const Color(0xFF0D1E4C), // Marineblau
      const Color(0xFFC48CB3), // Rosen/Mauve-Pink
      const Color(0xFFFFE5E5), // Blasses Pink
      const Color(0xFF83A6CE), // Himmelblau
      
      // Bild 1 - vierte Reihe
      const Color(0xFF26415E), // Schieferblau
      const Color(0xFF0B1B32), // Marineblau
      const Color(0xFF050B10), // Sehr dunkles Marineblau
      const Color(0xFF3F5B69), // Blau-Grau
      const Color(0xFF46779B), // Mittelblau
      const Color(0xFF618FA1), // Blau-Grau
      const Color(0xFFB29876), // Tan/Beige
      const Color(0xFF190019), // Dunkles Lila-Schwarz
      
      // Bild 2 - erste Reihe
      const Color(0xFFFF7F00), // Orange
      const Color(0xFFFF00FF), // Magenta/Violett
      const Color(0xFFFF0000), // Rot
      
      // Bild 2 - zweite Reihe
      const Color(0xFFFFCCCB), // Light Peach
      const Color(0xFFFFB6C1), // Pink
      const Color(0xFF8B4513), // Braun
      const Color(0xFF87CEEB), // Himmelblau
      
      // Bild 2 - dritte Reihe
      const Color(0xFFC0C0C0), // Hellgrau
      const Color(0xFF20B2AA), // Hellgrün/Teal
      const Color(0xFF808080), // Grau
      
      // Bild 2 - vierte Reihe
      const Color(0xFF800080), // Lila
      
      // Bild 3 - erste Reihe
      const Color(0xFF2F2F2F), // Dunkelgrau
      const Color(0xFF4169E1), // Royalblau
      const Color(0xFF1C1C1C), // Sehr dunkelgrau
      const Color(0xFF006400), // Dunkelgrün
      const Color(0xFF00FF00), // Hellgrün
      
      // Bild 3 - zweite Reihe
      const Color(0xFFFFFDD0), // Creme/Off-White
      const Color(0xFFFFA500), // Orange/Tan
      const Color(0xFFFF8C00), // Mittelorange
      const Color(0xFFFFC0CB), // Hellpink
      const Color(0xFFFFA07A), // Lachs/Peach
      
      // Bild 3 - dritte Reihe
      const Color(0xFFCD853F), // Gold/Braun
      const Color(0xFFFF1493), // Hellpink/Violett
      const Color(0xFFA0522D), // Rötlich-Braun/Terracotta
      const Color(0xFF8B0000), // Dunkelrot/Braun
      
      // Bild 4 - erste Reihe
      const Color(0xFFBC8F8F), // Muted Rose/Reddish-Brown
      const Color(0xFFB0E0E6), // Light Teal/Mint Green
      const Color(0xFFADD8E6), // Light Blue/Cyan
      const Color(0xFFFFFACD), // Pale Yellow/Cream
      const Color(0xFFFFFEF0), // Off-White/Very Pale Yellow
      
      // Bild 4 - zweite Reihe
      const Color(0xFF505050), // Dark Grey
      const Color(0xFFDAA520), // Muted Yellow/Mustard
      const Color(0xFFCCCCFF), // Light Blue/Periwinkle
      const Color(0xFF708090), // Muted Blue/Slate Blue
      
      // Bild 4 - dritte Reihe
      const Color(0xFFFF7F50), // Light Coral/Salmon Pink
      const Color(0xFF4B0082), // Dark Blue/Indigo
      
      // Bild 4 - vierte Reihe
      const Color(0xFF0000FF), // Bright Blue
      const Color(0xFF0000CD), // Medium Blue
      const Color(0xFFD2B48C), // Light Brown/Tan
      const Color(0xFFFF6347), // Orange/Terracotta
    ];
    
    // Doppelte entfernen (basierend auf Farbwert)
    final uniqueColors = <int, Color>{};
    for (final color in allColors) {
      uniqueColors[color.value] = color;
    }
    
    final colors = uniqueColors.values.toList();

    return colors.map((color) {
      return _ColorSwatch(
        color: color,
        isSelected: _selectedSwatchColor != null && 
            _selectedSwatchColor!.value == color.value,
        onTap: (selectedColor) => _updateFromColor(selectedColor),
      );
    }).toList();
  }

  Color? _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // Alpha hinzufügen
    }
    if (hex.length == 8) {
      try {
        return Color(int.parse(hex, radix: 16));
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        width: 320,
        constraints: const BoxConstraints(maxHeight: 700), // Höhe erhöht für mehr Scroll-Platz
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header mit Close-Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Custom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Hauptbereich
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Großes Gradient-Feld
                    _ColorGradientField(
                      hue: _hue,
                      saturation: _saturation,
                      lightness: _lightness,
                      onChanged: (values) {
                        setState(() {
                          _saturation = values.$1;
                          _lightness = values.$2;
                        });
                        _updateColor();
                      },
                    ),

                    const SizedBox(height: 12),

                    // Slider
                    Column(
                      children: [
                        // Hue-Slider (Regenbogen)
                        _HueSlider(
                          hue: _hue,
                          onChanged: (hue) {
                            setState(() {
                              _hue = hue;
                            });
                            _updateColor();
                          },
                        ),
                        const SizedBox(height: 8),
                        // Opacity-Slider
                        _OpacitySlider(
                          alpha: _alpha,
                          color: HSLColor.fromAHSL(1.0, _hue, _saturation, _lightness).toColor(),
                          onChanged: (alpha) {
                            setState(() {
                              _alpha = alpha;
                            });
                            _updateColor();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Farbformat-Dropdown und Input
                    Row(
                      children: [
                        // Format-Dropdown
                        Container(
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ColorFormat>(
                              value: _colorFormat,
                              isExpanded: true,
                              isDense: true,
                              dropdownColor: const Color(0xFF2A2A2A),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.white70,
                                size: 20,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: ColorFormat.hex,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text('Hex'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ColorFormat.rgb,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text('RGB'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ColorFormat.css,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text('CSS'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ColorFormat.hsl,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text('HSL'),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: ColorFormat.hsb,
                                  child: const Padding(
                                    padding: EdgeInsets.only(left: 4),
                                    child: Text('HSB'),
                                  ),
                                ),
                              ],
                              onChanged: (ColorFormat? newFormat) {
                                if (newFormat != null) {
                                  setState(() {
                                    _colorFormat = newFormat;
                                    _updateColorInputs();
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                          // Farbwert-Input
                          Expanded(
                            child: TextField(
                              controller: _colorInputController,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontFamily: _colorFormat == ColorFormat.hex ? 'monospace' : null,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                              ),
                              onChanged: (value) {
                                final color = _parseColorString(value);
                                if (color != null) {
                                  _updateFromColor(color);
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Opacity-Input
                          SizedBox(
                            width: 70,
                            child: TextField(
                              controller: _opacityInputController,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                              decoration: InputDecoration(
                                isDense: true,
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(
                                    color: Colors.white.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                suffixText: '%',
                                suffixStyle: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              onChanged: (value) {
                                final alpha = double.tryParse(value);
                                if (alpha != null) {
                                  setState(() {
                                    _alpha = (alpha.clamp(0, 100) / 100);
                                    _opacityInputController.text = '${(_alpha * 100).round()}';
                                  });
                                  _updateColor();
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 16),

                    // Color Palette Grid (scrollbar)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'On this page',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 104, // Genau 3 Reihen: (24px + 8px spacing) * 3 = 96px, plus 8px für bessere Sichtbarkeit
                          child: Scrollbar(
                            controller: _scrollController,
                            thumbVisibility: false, // Scrollbar nur beim Scrollen sichtbar
                            thickness: 6,
                            radius: const Radius.circular(3),
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _buildColorSwatches(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorGradientField extends StatefulWidget {
  final double hue;
  final double saturation;
  final double lightness;
  final ValueChanged<(double, double)> onChanged;

  const _ColorGradientField({
    required this.hue,
    required this.saturation,
    required this.lightness,
    required this.onChanged,
  });

  @override
  State<_ColorGradientField> createState() => _ColorGradientFieldState();
}

class _ColorGradientFieldState extends State<_ColorGradientField> {
  bool _isDragging = false;
  final GlobalKey _containerKey = GlobalKey();
  double _containerWidth = 200.0; // Fallback-Breite
  double _containerHeight = 200.0; // Container-Höhe ist fest

  @override
  Widget build(BuildContext context) {
    final baseColor = HSLColor.fromAHSL(1.0, widget.hue, 1.0, 0.5).toColor();

    return GestureDetector(
      onPanStart: (details) {
        setState(() => _isDragging = true);
        _updateFromPosition(details.globalPosition);
      },
      onPanUpdate: (details) {
        _updateFromPosition(details.globalPosition);
      },
      onPanEnd: (_) {
        setState(() => _isDragging = false);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Aktualisiere die Container-Breite für Position-Berechnung
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final box = _containerKey.currentContext?.findRenderObject() as RenderBox?;
              if (box != null && box.size.width != _containerWidth) {
                setState(() {
                  _containerWidth = box.size.width;
                });
              }
            }
          });
          
          return Container(
            key: _containerKey,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Stack(
              children: [
                // Gradient: von weiß oben links zu baseColor oben rechts,
                // von baseColor unten rechts zu schwarz unten links
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        baseColor,
                        Colors.black,
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
                // Saturation/Lightness Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                      ],
                    ),
                  ),
                ),
                // Selector Circle - direkt im Stack
                Positioned(
                  left: (widget.saturation * _containerWidth - 10).clamp(0.0, _containerWidth - 20),
                  top: ((1 - widget.lightness) * _containerHeight - 10).clamp(0.0, _containerHeight - 20),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateFromPosition(Offset globalPosition) {
    final box = _containerKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPosition = box.globalToLocal(globalPosition);
    final width = box.size.width;
    final height = box.size.height;

    // Aktualisiere die Breite für die Position-Berechnung
    if (width != _containerWidth) {
      setState(() {
        _containerWidth = width;
      });
    }

    // Stelle sicher, dass die Position innerhalb der Grenzen liegt
    final saturation = (localPosition.dx / width).clamp(0.0, 1.0);
    final lightness = 1.0 - (localPosition.dy / height).clamp(0.0, 1.0);

    widget.onChanged((saturation, lightness));
  }
}

class _HueSlider extends StatefulWidget {
  final double hue;
  final ValueChanged<double> onChanged;

  const _HueSlider({
    required this.hue,
    required this.onChanged,
  });

  @override
  State<_HueSlider> createState() => _HueSliderState();
}

class _HueSliderState extends State<_HueSlider> {
  final GlobalKey _key = GlobalKey();
  double _sliderWidth = 200.0; // Fallback-Breite

  void _updateFromPosition(Offset localPosition) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final width = box.size.width;
    if (width != _sliderWidth && width.isFinite) {
      setState(() {
        _sliderWidth = width;
      });
    }
    
    final hue = ((localPosition.dx / width) * 360.0).clamp(0.0, 360.0);
    widget.onChanged(hue);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final box = _key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final localPosition = box.globalToLocal(details.globalPosition);
          _updateFromPosition(localPosition);
        }
      },
      onPanUpdate: (details) {
        final box = _key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final localPosition = box.globalToLocal(details.globalPosition);
          _updateFromPosition(localPosition);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Aktualisiere die Breite für Position-Berechnung
          if (constraints.maxWidth.isFinite && constraints.maxWidth != _sliderWidth) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _sliderWidth = constraints.maxWidth;
                });
              }
            });
          }
          
          return Container(
            key: _key,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF0000), // Rot
                  const Color(0xFFFF7F00), // Orange
                  const Color(0xFFFFFF00), // Gelb
                  const Color(0xFF00FF00), // Grün
                  const Color(0xFF00FFFF), // Cyan
                  const Color(0xFF0000FF), // Blau
                  const Color(0xFF7F00FF), // Violett
                  const Color(0xFFFF00FF), // Magenta
                  const Color(0xFFFF0000), // Zurück zu Rot
                ],
              ),
            ),
            child: Stack(
              children: [
                // Positioned muss direkt im Stack sein
                Positioned(
                  left: ((widget.hue / 360.0) * _sliderWidth - 12).clamp(0.0, _sliderWidth - 24),
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OpacitySlider extends StatefulWidget {
  final double alpha;
  final Color color;
  final ValueChanged<double> onChanged;

  const _OpacitySlider({
    required this.alpha,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_OpacitySlider> createState() => _OpacitySliderState();
}

class _OpacitySliderState extends State<_OpacitySlider> {
  final GlobalKey _key = GlobalKey();
  double _sliderWidth = 200.0; // Fallback-Breite

  void _updateFromPosition(Offset localPosition) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final width = box.size.width;
    if (width != _sliderWidth && width.isFinite) {
      setState(() {
        _sliderWidth = width;
      });
    }
    
    final alpha = 1.0 - (localPosition.dx / width).clamp(0.0, 1.0);
    widget.onChanged(alpha);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        final box = _key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final localPosition = box.globalToLocal(details.globalPosition);
          _updateFromPosition(localPosition);
        }
      },
      onPanUpdate: (details) {
        final box = _key.currentContext?.findRenderObject() as RenderBox?;
        if (box != null) {
          final localPosition = box.globalToLocal(details.globalPosition);
          _updateFromPosition(localPosition);
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Aktualisiere die Breite für Position-Berechnung
          if (constraints.maxWidth.isFinite && constraints.maxWidth != _sliderWidth) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _sliderWidth = constraints.maxWidth;
                });
              }
            });
          }
          
          return Container(
            key: _key,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const _CheckerboardWidget(),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        widget.color.withOpacity(1.0),
                        widget.color.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
                // Positioned muss direkt im Stack sein
                Positioned(
                  left: ((1 - widget.alpha) * _sliderWidth - 12).clamp(0.0, _sliderWidth - 24),
                  top: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Einfaches Checkerboard-Pattern als CustomPainter
class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 8.0;
    final white = Paint()..color = Colors.white;
    final gray = Paint()..color = const Color(0xFFCCCCCC);

    for (var y = 0.0; y < size.height; y += squareSize) {
      for (var x = 0.0; x < size.width; x += squareSize) {
        final paint = ((x / squareSize).floor() + (y / squareSize).floor()) % 2 == 0
            ? white
            : gray;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CheckerboardWidget extends StatelessWidget {
  const _CheckerboardWidget();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(),
      size: Size.infinite,
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final ValueChanged<Color>? onTap;

  const _ColorSwatch({
    required this.color,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTransparent = color == Colors.transparent;
    final isWhite = color == Colors.white;
    
    // Rahmen-Farbe: Weiß wenn ausgewählt (außer bei weiß), Schwarz bei weiß wenn ausgewählt
    final borderColor = isSelected
        ? (isWhite ? Colors.black : Colors.white)
        : Colors.white.withOpacity(0.3);
    
    final borderWidth = isSelected ? 2.5 : 1.0;
    
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(color) : null,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isTransparent ? Colors.white : color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: borderColor,
            width: borderWidth,
          ),
        ),
        child: isTransparent
            ? ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const _CheckerboardWidget(),
              )
            : null,
      ),
    );
  }
}

