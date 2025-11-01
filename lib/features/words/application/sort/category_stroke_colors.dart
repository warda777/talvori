import 'package:flutter/material.dart';

/// Zuweistung von Stroke-Farben zu Kategorien
/// Jede Kategorie erhält eine eindeutige Farbe
class CategoryStrokeColors {
  // Farbpalette für verschiedene Kategorien
  static const List<Color> _colorPalette = [
    Color(0xFFB1CCFE), // Blau
    Color(0xFF6FD3FF), // Hellblau
    Color(0xFFF1C86B), // Gold
    Color(0xFFFFB84D), // Orange
    Color(0xFFFF6B9D), // Pink
    Color(0xFFC77DFF), // Lila
    Color(0xFF4ECDC4), // Türkis
    Color(0xFFFFE66D), // Gelb
    Color(0xFF95E1D3), // Mint
    Color(0xFFFFA07A), // Lachs
    Color(0xFF98D8C8), // Aquamarin
    Color(0xFFFFB6C1), // Hellrosa
    Color(0xFF87CEEB), // Himmelblau
    Color(0xFFDDA0DD), // Pflaume
    Color(0xFFF0E68C), // Khaki
    Color(0xFFFFDAB9), // Pfirsich
    Color(0xFFE0BBE4), // Lavendel
    Color(0xFFFFCCCB), // Blassrosa
    Color(0xFFB0E0E6), // Pulverblau
    Color(0xFFFFEFD5), // Papayacreme
    Color(0xFFADD8E6), // Helles Blau
    Color(0xFFD8BFD8), // Distel
    Color(0xFFFFE4E1), // Muschel
    Color(0xFFE6E6FA), // Lavendel
    Color(0xFFFFF0F5), // Lavendelrosa
    Color(0xFFF5FFFA), // Minzcreme
    Color(0xFFFFFACD), // Zitronenchiffon
    Color(0xFFFFE4B5), // Moccasin
    Color(0xFFFFF8DC), // Mais
    Color(0xFFF0FFF0), // Honigtau
  ];

  /// Gibt die Stroke-Farbe für eine Kategorie zurück
  /// Verwendet einen Hash-basierten Ansatz für konsistente Farbzuweisung
  static Color getStrokeColor(String categoryLabel) {
    // Erstelle einen Hash aus dem Label
    int hash = categoryLabel.hashCode;
    
    // Verwende den absoluten Hash-Wert für die Palette
    int index = hash.abs() % _colorPalette.length;
    
    return _colorPalette[index];
  }

  /// Gibt die Stroke-Farbe für eine Kategorie anhand des Index zurück
  /// Nützlich, wenn Kategorien in einer festen Reihenfolge sind
  static Color getStrokeColorByIndex(int index) {
    return _colorPalette[index % _colorPalette.length];
  }
}

