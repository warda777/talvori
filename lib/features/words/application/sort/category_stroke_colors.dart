import 'package:flutter/material.dart';
import 'package:talvori/core/local_database/models/local_word_package_definition.dart';

/// Zuweistung von Stroke-Farben zu Kategorien
/// Jede Kategorie erhält eine eindeutige Farbe
class CategoryStrokeColors {
  static const wordWorlds = Color(0xFF4EEAFF);
  static const learningLevels = Color(0xFF78B9FF);
  static const myWords = Color(0xFFB36BFF);
  static const favorites = Color(0xFFFF4B9A);
  static const knownWords = Color(0xFF36F58A);
  static const myMix = Color(0xFFFFD45D);
  static const languageTools = Color(0xFFFF9A4D);
  static const allWords = Color(0xFFE7F3FF);

  static const List<Color> _levelPackageContrastPalette = [
    Color(0xFF35E7FF), // Cyan / Türkis
    Color(0xFF4F8DFF), // Blau
    Color(0xFF44F28B), // Grün
    Color(0xFFFFD45D), // Gold / Gelb
    Color(0xFFFF8A3D), // Orange
    Color(0xFFB56CFF), // Violett
    Color(0xFFFF5DA8), // Pink / Rosa
  ];

  static const Map<String, int> _levelPackagePaletteOffsets = {
    'A1': 0,
    'A2': 2,
    'B1': 4,
    'B2': 1,
    'C1': 3,
    'C2': 6,
  };

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

  static Color getWheelStrokeColor(String categoryLabel) {
    return colorForLevelPackage(categoryLabel) ??
        getLearningLevelColor(categoryLabel) ??
        getStrokeColor(categoryLabel);
  }

  static Color colorForMainWordSource(String sourceKey) {
    return switch (sourceKey) {
      'word_worlds' => wordWorlds,
      'learning_levels' => learningLevels,
      'my_words' => myWords,
      'favorites' => favorites,
      'known_words' => knownWords,
      'my_mix' => myMix,
      'language_tools' => languageTools,
      'all_words' => allWords,
      _ => getStrokeColor(sourceKey),
    };
  }

  static Color colorForLevel(String level) {
    return getLearningLevelColor(level) ?? learningLevels;
  }

  static Color? colorForLevelPackage(String packageLabelOrLevel) {
    final normalized = packageLabelOrLevel.trim().toLowerCase();
    for (final group in localLevelPackageGroups) {
      for (var index = 0; index < group.packages.length; index++) {
        final package = group.packages[index];
        if (package.key.toLowerCase() == normalized ||
            package.label.toLowerCase() == normalized) {
          return _levelPackageVariant(group.level, index);
        }
      }
    }
    return null;
  }

  static Color? getLearningLevelColor(String categoryLabel) {
    final normalized = categoryLabel.trim().toUpperCase();
    if (normalized.startsWith('A1')) {
      return const Color(0xFF65DFFF);
    }
    if (normalized.startsWith('A2')) {
      return const Color(0xFF5DFF9A);
    }
    if (normalized.startsWith('B1')) {
      return const Color(0xFFFFD45D);
    }
    if (normalized.startsWith('B2')) {
      return const Color(0xFFFF9A4D);
    }
    if (normalized.startsWith('C1')) {
      return const Color(0xFFC77DFF);
    }
    if (normalized.startsWith('C2')) {
      return const Color(0xFFFF5DA8);
    }
    return null;
  }

  static Color _levelPackageVariant(String level, int packageIndex) {
    final offset = _levelPackagePaletteOffsets[level.toUpperCase()] ?? 0;
    final index = (packageIndex + offset) % _levelPackageContrastPalette.length;
    return _levelPackageContrastPalette[index];
  }

  /// Gibt die Stroke-Farbe für eine Kategorie anhand des Index zurück
  /// Nützlich, wenn Kategorien in einer festen Reihenfolge sind
  static Color getStrokeColorByIndex(int index) {
    return _colorPalette[index % _colorPalette.length];
  }
}
