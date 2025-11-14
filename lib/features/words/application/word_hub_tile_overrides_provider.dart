import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Override-Farben für eine einzelne Kachel
class TileColorOverrides {
  final Color? titleColor;
  final Color? countColor;
  final Color? strokeColor;
  final Color? fillColor;

  const TileColorOverrides({
    this.titleColor,
    this.countColor,
    this.strokeColor,
    this.fillColor,
  });

  TileColorOverrides copyWith({
    Color? titleColor,
    Color? countColor,
    Color? strokeColor,
    Color? fillColor,
  }) {
    return TileColorOverrides(
      titleColor: titleColor ?? this.titleColor,
      countColor: countColor ?? this.countColor,
      strokeColor: strokeColor ?? this.strokeColor,
      fillColor: fillColor ?? this.fillColor,
    );
  }
}

/// State für alle Tile-Overrides
class WordHubTileOverridesState {
  final Map<String, TileColorOverrides> overrides;

  const WordHubTileOverridesState({
    this.overrides = const {},
  });

  WordHubTileOverridesState copyWith({
    Map<String, TileColorOverrides>? overrides,
  }) {
    return WordHubTileOverridesState(
      overrides: overrides ?? this.overrides,
    );
  }

  TileColorOverrides? operator [](String paletteId) => overrides[paletteId];
}

/// Controller für Tile-Overrides
class WordHubTileOverridesController
    extends StateNotifier<WordHubTileOverridesState> {
  WordHubTileOverridesController()
      : super(const WordHubTileOverridesState());

  /// Setzt Text-Farben für eine Kachel
  void setTextColors(String paletteId, Color color) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(
      titleColor: color,
      countColor: color,
    );
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
  }

  /// Setzt nur Titel-Farbe
  void setTitleColor(String paletteId, Color color) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(titleColor: color);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
  }

  /// Setzt nur Counter-Farbe
  void setCountColor(String paletteId, Color color) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(countColor: color);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
  }

  /// Setzt Stroke-Farbe für eine Kachel
  void setStrokeColor(String paletteId, Color color) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(strokeColor: color);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
  }

  /// Setzt Fill-Farbe für eine Kachel
  void setFillColor(String paletteId, Color color) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(fillColor: color);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
  }

  /// Entfernt Overrides für eine Kachel
  void clearOverrides(String paletteId) {
    final updated = Map<String, TileColorOverrides>.from(state.overrides);
    updated.remove(paletteId);
    state = state.copyWith(overrides: updated);
  }
}

/// Provider für Tile-Overrides
final wordHubTileOverridesProvider =
    StateNotifierProvider<WordHubTileOverridesController,
        WordHubTileOverridesState>(
  (ref) => WordHubTileOverridesController(),
);

