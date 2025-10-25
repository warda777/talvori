import 'package:flutter/material.dart';

/// Zentrale Layout- und Spacing-Definitionen für Words-UI.
class WordsLayout {
  /// Header / Top-Kachel
  static const double topCapsuleH = 260.0;
  static const EdgeInsets topPadding = EdgeInsets.fromLTRB(14, 12, 14, 12);

  /// Abstände zwischen Blöcken
  static const double gapBelowTop = 16.0;
  static const double gapAboveBottom = 40.0;
  static const double pageBottomPadding = 24.0;

  /// Mittelteil (Progress/Stats)
  static const double midPaddingH = 25.0;

  /// Levels-Card
  static const double levelsCardH = 260.0;
  static const EdgeInsets levelsOuterPadding =
      EdgeInsets.fromLTRB(20, 8, 20, 0);

  /// Header-Row (Vocabs + Buttons) Offsets
  static const double rowOffsetX = 0.0;
  static const double rowOffsetY = 0.0;
  static const double vocabsTileOffsetX = 0.0;
  static const double vocabsTileOffsetY = 0.0;
  static const double rightBtnsOffsetX = 0.0;
  static const double rightBtnsOffsetY = 0.0;

  /// Wheel im Header
  static const double wheelOffsetX = 0.0;
  static const double wheelOffsetY = 0.0;
  static const double wheelHeight = 72.0;
  static const double wheelBottomGap = 28.0;

  /// Stage-Switches
  static const double switchGap = 12.0;
  static const double switchesOffsetX = 0.0;
  static const double switchesOffsetY = -12.0;

  /// Start-Button
  static const double startBtnOffsetX = 0.0;
  static const double startBtnOffsetY = 0.0;
}
