// lib/features/words/ui/ui_constants.dart
import 'package:flutter/material.dart';

/// UI-Konstanten für den Words-Feature
class WordsUIConstants {
  // ---- Farben ----
  
  /// Karten-Hintergrund
  static const Color cardBackground = Color(0xFF2D2C2C);
  
  /// Stage-Switch Farben
  static const Color stageOuter = Color(0xFFE4B866);
  static const Color stageInner = Color(0xFF2D2C2C);
  static const Color stageInnerRed = Color(0xFFA05260);
  static const Color stageInnerDark = Color(0xFF2D2D2F);
  
  /// Inaktive Stage-Switch Farbe
  static Color get stageInactive => Colors.grey.shade400;
  
  /// Loading-Indikator Farbe
  static const Color loadingIndicator = Colors.white54;

  // ---- Abstände ----
  
  /// Abstand zwischen Stage-Switches
  static const double switchGap = 8.0;
  
  /// Standard-Padding für Screens
  static const EdgeInsets screenPadding = EdgeInsets.fromLTRB(18, 10, 18, 5);
  static const EdgeInsets bottomControlsPadding = EdgeInsets.fromLTRB(18, 8, 18, 24);
  
  /// Abstände zwischen UI-Elementen
  static const double smallSpacing = 8.0;
  static const double mediumSpacing = 12.0;
  static const double largeSpacing = 80.0;
  static const double sectionSpacing = 20.0; // Abstand zwischen Hauptbereichen

  // ---- Offsets ----
  
  /// Stage-Switch Offsets
  static const Offset switchOffset = Offset(0.0, 0.0);
  
  /// Header-Offset
  static const Offset headerOffset = Offset(0.0, 0.0);

  // ---- Größen ----
  
  /// Header-Höhe
  static const double headerHeight = 72.0;
  
  /// Icon-Größen
  static const double iconSize = 44.0;
  static const double smallIconSize = 22.0;
  
  /// Stage-Switch Größen
  static const double stageSwitchWidth = 42.0;
  static const double stageSwitchHeight = 75.0; // Zurück auf 75px
  static const double stageSwitchRadius = 21.0;
  
  /// Loading-Indikator Größen
  static const Size loadingSize = Size(280.0, 72.0);
  
  /// Border-Radius
  static const double borderRadius = 22.0;
  
  /// Card-Shadow
  static const List<BoxShadow> cardShadow = [
    BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 12)),
  ];

  // ---- Stage-Switch spezifische Konstanten ----
  
  /// Ziel-Anzahl für Stage-Completion
  static const int stageGoal = 100;
  
  /// Highlight-Schwellenwert
  static const int highlightThreshold = 100;
}
