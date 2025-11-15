import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'radial_palette_controller.dart' show PaletteTool;

/// Override-Farben für eine einzelne Kachel
class TileColorOverrides {
  final Color? titleColor;
  final Color? countColor;
  final Color? strokeColor;
  final Color? fillColor;
  final IconData? icon; // Icon für die Kachel
  final String? emoji; // Emoji für die Kachel
  final Color? iconColor; // NEU: Farbe für Icon/Emoji

  const TileColorOverrides({
    this.titleColor,
    this.countColor,
    this.strokeColor,
    this.fillColor,
    this.icon,
    this.emoji,
    this.iconColor, // NEU
  });

  TileColorOverrides copyWith({
    Color? titleColor,
    Color? countColor,
    Color? strokeColor,
    Color? fillColor,
    IconData? icon,
    String? emoji,
    Color? iconColor, // NEU
    bool clearIcon = false,
    bool clearEmoji = false,
    bool clearTitleColor = false,
    bool clearCountColor = false,
    bool clearStrokeColor = false,
    bool clearFillColor = false,
    bool clearIconColor = false, // NEU
  }) {
    return TileColorOverrides(
      titleColor: clearTitleColor ? null : (titleColor ?? this.titleColor),
      countColor: clearCountColor ? null : (countColor ?? this.countColor),
      strokeColor: clearStrokeColor ? null : (strokeColor ?? this.strokeColor),
      fillColor: clearFillColor ? null : (fillColor ?? this.fillColor),
      icon: clearIcon ? null : (icon ?? this.icon),
      emoji: clearEmoji ? null : (emoji ?? this.emoji),
      iconColor: clearIconColor ? null : (iconColor ?? this.iconColor), // NEU
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
      : super(const WordHubTileOverridesState()) {
    _loadOverrides();
  }

  static const String _overridesKey = 'word_hub_tile_overrides';

  /// Lädt die gespeicherten Overrides aus SharedPreferences
  Future<void> _loadOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final overridesJson = prefs.getString(_overridesKey);
      
      if (overridesJson != null) {
        final Map<String, dynamic> overridesMap = json.decode(overridesJson);
        final Map<String, TileColorOverrides> loadedOverrides = {};
        
        overridesMap.forEach((paletteId, value) {
          if (value is Map<String, dynamic>) {
            loadedOverrides[paletteId] = TileColorOverrides(
              titleColor: value['titleColor'] != null 
                  ? Color(int.parse(value['titleColor'] as String))
                  : null,
              countColor: value['countColor'] != null
                  ? Color(int.parse(value['countColor'] as String))
                  : null,
              strokeColor: value['strokeColor'] != null
                  ? Color(int.parse(value['strokeColor'] as String))
                  : null,
              fillColor: value['fillColor'] != null
                  ? Color(int.parse(value['fillColor'] as String))
                  : null,
              icon: value['icon'] != null
                  ? IconData(int.parse(value['icon'] as String))
                  : null,
              emoji: value['emoji'] as String?,
              iconColor: value['iconColor'] != null // NEU
                  ? Color(int.parse(value['iconColor'] as String))
                  : null,
            );
          }
        });
        
        if (loadedOverrides.isNotEmpty) {
          state = WordHubTileOverridesState(overrides: loadedOverrides);
        }
      }
    } catch (e) {
      // Fehler ignorieren
    }
  }

  /// Speichert die Overrides in SharedPreferences
  Future<void> _saveOverrides() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> overridesMap = {};
      
      state.overrides.forEach((paletteId, overrides) {
        final Map<String, dynamic> overrideMap = {};
        if (overrides.titleColor != null) {
          overrideMap['titleColor'] = overrides.titleColor!.value.toString();
        }
        if (overrides.countColor != null) {
          overrideMap['countColor'] = overrides.countColor!.value.toString();
        }
        if (overrides.strokeColor != null) {
          overrideMap['strokeColor'] = overrides.strokeColor!.value.toString();
        }
        if (overrides.fillColor != null) {
          overrideMap['fillColor'] = overrides.fillColor!.value.toString();
        }
        if (overrides.icon != null) {
          overrideMap['icon'] = overrides.icon!.codePoint.toString();
        }
        if (overrides.emoji != null) {
          overrideMap['emoji'] = overrides.emoji!;
        }
        if (overrides.iconColor != null) { // NEU
          overrideMap['iconColor'] = overrides.iconColor!.value.toString();
        }
        overridesMap[paletteId] = overrideMap;
      });
      
      final overridesJson = json.encode(overridesMap);
      await prefs.setString(_overridesKey, overridesJson);
    } catch (e) {
      // Fehler ignorieren
    }
  }

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
    _saveOverrides();
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
    _saveOverrides();
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
    _saveOverrides();
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
    _saveOverrides();
  }

  /// Setzt Icon für eine Kachel
  void setIcon(String paletteId, IconData icon) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(icon: icon, clearEmoji: true);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
    _saveOverrides();
  }

  /// Setzt Emoji für eine Kachel
  void setEmoji(String paletteId, String emoji) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(emoji: emoji, clearIcon: true);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
    _saveOverrides();
  }

  /// Setzt Icon-Farbe für eine Kachel
  void setIconColor(String paletteId, Color color) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(iconColor: color);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
    _saveOverrides();
  }

  /// Entfernt Icon/Emoji von einer Kachel
  void clearIconEmoji(String paletteId) {
    final current = state.overrides[paletteId] ?? const TileColorOverrides();
    final updated = current.copyWith(clearIcon: true, clearEmoji: true);
    state = state.copyWith(
      overrides: {
        ...state.overrides,
        paletteId: updated,
      },
    );
    _saveOverrides();
  }

  /// Entfernt Overrides für eine Kachel
  void clearOverrides(String paletteId) {
    final updated = Map<String, TileColorOverrides>.from(state.overrides);
    updated.remove(paletteId);
    state = state.copyWith(overrides: updated);
    _saveOverrides();
  }

  /// Entfernt alle Icons/Emojis von allen Kacheln
  void clearAllIconsEmojis() {
    final updated = <String, TileColorOverrides>{};
    for (final entry in state.overrides.entries) {
      updated[entry.key] = entry.value.copyWith(clearIcon: true, clearEmoji: true);
    }
    state = state.copyWith(overrides: updated);
  }

  /// Setzt alle Overrides für ein bestimmtes Tool zurück
  void resetToolOverrides(PaletteTool tool) {
    final updated = <String, TileColorOverrides>{};
    for (final entry in state.overrides.entries) {
      TileColorOverrides cleared = entry.value;
      switch (tool) {
        case PaletteTool.stroke:
          cleared = cleared.copyWith(clearStrokeColor: true);
          break;
        case PaletteTool.fill:
          cleared = cleared.copyWith(clearFillColor: true);
          break;
        case PaletteTool.text:
          cleared = cleared.copyWith(clearTitleColor: true, clearCountColor: true);
          break;
        case PaletteTool.icon:
          cleared = cleared.copyWith(clearIcon: true, clearEmoji: true, clearIconColor: true);
          break;
        case PaletteTool.hubBackground:
        case PaletteTool.paint:
        case PaletteTool.image:
          // Diese Tools haben keine direkten Tile-Overrides
          break;
      }
      // Nur hinzufügen, wenn noch andere Overrides vorhanden sind
      if (cleared.titleColor != null || 
          cleared.countColor != null || 
          cleared.strokeColor != null || 
          cleared.fillColor != null ||
          cleared.icon != null ||
          cleared.emoji != null ||
          cleared.iconColor != null) { // NEU
        updated[entry.key] = cleared;
      }
    }
    state = state.copyWith(overrides: updated);
    _saveOverrides();
  }

  /// Setzt alle Overrides für alle Tools zurück (kompletter Reset)
  void resetAllOverrides() {
    state = const WordHubTileOverridesState();
    _saveOverrides();
  }
}

/// Provider für Tile-Overrides
final wordHubTileOverridesProvider =
    StateNotifierProvider<WordHubTileOverridesController,
        WordHubTileOverridesState>(
  (ref) => WordHubTileOverridesController(),
);

