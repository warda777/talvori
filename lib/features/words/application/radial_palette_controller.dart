import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// All = alles einfärben, One = jeweils nur ein Element
enum PaletteScope { all, one }

/// Welche Eigenschaft soll die Palette bearbeiten?
enum PaletteTool {
  stroke,         // 1. Rahmen
  fill,           // 2. Hintergrund Button/Kachel
  text,           // 3. Schrift
  hubBackground,  // 4. Word Hub Background + Top
  paint,          // 5. Paint - Farbpaletten wechseln
  icon,           // 6. Icon-Farbe
  image,          // 7. Bild in Kachel
}

enum TargetKind {
  tile,
  text,
  button,
  icon,
  header,
  sectionTitle,
  searchBar,
  hubBackground,
}

/// Ein stylbares Element in Word Hub (Titel, Button, Kachel usw.)
class PaletteTarget {
  final String id;          // z.B. "wordHub.title", "wordHub.unlockButton", "wordHub.tile:$index"
  final GlobalKey key;      // fürs spätere Scrollen / Messen
  final TargetKind kind;
  final Set<PaletteTool> tools;

  /// Callback, der die Farbe wirklich anwendet.
  /// Der Target selbst weiß, was er mit Stroke/Fill/Text usw. macht.
  final void Function(PaletteTool tool, Color color, PaletteScope scope)? onApply;
  
  /// Callback für Icon-Auswahl
  final void Function(IconData icon, PaletteScope scope)? onApplyIcon;
  
  /// Callback für Emoji-Auswahl
  final void Function(String emoji, PaletteScope scope)? onApplyEmoji;
  
  /// Callback zum Löschen von Icons/Emojis
  final void Function(PaletteScope scope)? onClearIconEmoji;

  PaletteTarget({
    required this.id,
    required this.key,
    required this.kind,
    required this.tools,
    this.onApply,
    this.onApplyIcon,
    this.onApplyEmoji,
    this.onClearIconEmoji,
  });
}

class RadialPaletteState {
  final PaletteScope scope;
  final PaletteTool? activeTool;    // null = nur Farbrad ohne Tool
  final int focusedIndex;          // Index im Target-Array
  final List<PaletteTarget> targets;
  final bool overlayVisible;
  final Set<String> focusedIds;   // IDs der aktuell fokussierten Targets

  // 🔴 NEU: Kugel-Lock-State
  final bool isBallLocked;          // Kugel „eingerastet"?
  final int? lockedIndex;           // auf welches Target ist sie gelockt?
  final int? iconToolLockedIndex;   // Gelockte Position für Icon-Tool (wird beim Tool-Wechsel gespeichert)
  final Color? lastPickedColor;     // zuletzt gepickte Farbe (für Kugel-Fill)
  final Map<int, Color> customColors; // Individuelle Custom-Farben für jeden Ball (Index -> Color)
  final int? activeCustomBallIndex;  // Index des aktuell aktiven Custom-Balls
  final bool isCustomPaletteActive;  // Ist Custom-Palette aktiv (Farbkreis zeigt Custom-Verlauf)?

  // 🔴 Glow-System: Dynamische Glow-Farbe basierend auf Palette-State
  final Color? selectionGlowColor;

  // 🔴 Icon/Emoji-Auswahl
  final IconData? selectedIcon;
  final String? selectedEmoji;

  const RadialPaletteState({
    this.scope = PaletteScope.all,
    this.activeTool,
    this.focusedIndex = 0,
    this.targets = const [],
    this.overlayVisible = true,
    this.focusedIds = const {},
    this.isBallLocked = false,
    this.lockedIndex,
    this.iconToolLockedIndex,
    this.lastPickedColor,
    this.customColors = const {},
    this.activeCustomBallIndex,
    this.isCustomPaletteActive = false,
    this.selectionGlowColor,
    this.selectedIcon,
    this.selectedEmoji,
  });

  RadialPaletteState copyWith({
    PaletteScope? scope,
    PaletteTool? activeTool,
    int? focusedIndex,
    List<PaletteTarget>? targets,
    bool? overlayVisible,
    bool clearActiveTool = false, // 🔹 Flag um explizit auf null zu setzen
    Set<String>? focusedIds,
    bool? isBallLocked,
    int? lockedIndex,
    bool clearLockedIndex = false,
    int? iconToolLockedIndex,
    bool clearIconToolLockedIndex = false,
    Color? lastPickedColor,
    bool clearLastPickedColor = false,
    Map<int, Color>? customColors,
    int? activeCustomBallIndex,
    bool clearActiveCustomBallIndex = false,
    bool? isCustomPaletteActive,
    Color? selectionGlowColor,
    bool clearSelectionGlow = false,
    IconData? selectedIcon,
    bool clearSelectedIcon = false,
    String? selectedEmoji,
    bool clearSelectedEmoji = false,
  }) {
    return RadialPaletteState(
      scope: scope ?? this.scope,
      activeTool: clearActiveTool ? null : (activeTool ?? this.activeTool),
      focusedIndex: focusedIndex ?? this.focusedIndex,
      targets: targets ?? this.targets,
      overlayVisible: overlayVisible ?? this.overlayVisible,
      focusedIds: focusedIds ?? this.focusedIds,
      isBallLocked: isBallLocked ?? this.isBallLocked,
      lockedIndex: clearLockedIndex ? null : (lockedIndex ?? this.lockedIndex),
      iconToolLockedIndex: clearIconToolLockedIndex ? null : (iconToolLockedIndex ?? this.iconToolLockedIndex),
      lastPickedColor:
          clearLastPickedColor ? null : (lastPickedColor ?? this.lastPickedColor),
      customColors: customColors ?? this.customColors,
      activeCustomBallIndex: clearActiveCustomBallIndex ? null : (activeCustomBallIndex ?? this.activeCustomBallIndex),
      isCustomPaletteActive: isCustomPaletteActive ?? this.isCustomPaletteActive,
      selectionGlowColor: clearSelectionGlow ? null : (selectionGlowColor ?? this.selectionGlowColor),
      selectedIcon: clearSelectedIcon ? null : (selectedIcon ?? this.selectedIcon),
      selectedEmoji: clearSelectedEmoji ? null : (selectedEmoji ?? this.selectedEmoji),
    );
  }
}

class RadialPaletteController extends StateNotifier<RadialPaletteState> {
  RadialPaletteController() : super(const RadialPaletteState()) {
    _loadSettings();
  }

  int _lastFocusVis = -1; // neu
  
  /// Callback, der die aktuell fokussierten Target-IDs meldet
  void Function(Set<String> ids)? onFocusChange;

  static const String _customColorsKey = 'radial_palette_custom_colors';
  static const String _paletteScopeKey = 'radial_palette_scope';

  /// Lädt die gespeicherten Einstellungen aus SharedPreferences
  Future<void> _loadSettings() async {
    await _loadCustomColors();
    await _loadPaletteScope();
  }

  /// Lädt den gespeicherten PaletteScope aus SharedPreferences
  Future<void> _loadPaletteScope() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final scopeString = prefs.getString(_paletteScopeKey);
      
      if (scopeString != null) {
        final scope = scopeString == 'all' ? PaletteScope.all : PaletteScope.one;
        state = state.copyWith(scope: scope);
      }
    } catch (e) {
    }
  }

  /// Speichert den PaletteScope in SharedPreferences
  Future<void> _savePaletteScope(PaletteScope scope) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_paletteScopeKey, scope == PaletteScope.all ? 'all' : 'one');
    } catch (e) {
    }
  }

  /// Lädt die gespeicherten Custom-Farben aus SharedPreferences
  Future<void> _loadCustomColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final colorsJson = prefs.getString(_customColorsKey);
      
      if (colorsJson != null) {
        final Map<String, dynamic> colorsMap = json.decode(colorsJson);
        final Map<int, Color> loadedColors = {};
        
        colorsMap.forEach((key, value) {
          final index = int.tryParse(key);
          if (index != null && value is String) {
            // Hex-String zu Color konvertieren
            final hexString = value.replaceFirst('#', '').padLeft(6, '0');
            final colorValue = int.tryParse(hexString, radix: 16);
            if (colorValue != null) {
              loadedColors[index] = Color(colorValue | 0xFF000000); // Alpha auf FF setzen
            }
          }
        });
        
        if (loadedColors.isNotEmpty) {
          state = state.copyWith(customColors: loadedColors);
        }
      }
    } catch (e) {
    }
  }

  /// Speichert die Custom-Farben in SharedPreferences
  Future<void> _saveCustomColors(Map<int, Color> colors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, String> colorsMap = {};
      
      colors.forEach((index, color) {
        // Color zu Hex-String konvertieren (ohne Alpha)
        final argb = color.toARGB32();
        final hex = (argb & 0x00FFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();
        colorsMap[index.toString()] = '#$hex';
      });
      
      final colorsJson = json.encode(colorsMap);
      await prefs.setString(_customColorsKey, colorsJson);
    } catch (e) {
    }
  }

  // 🔴 Kugel-Lock toggeln (Tap auf die Kugel)
  void toggleFocusLock() {
    if (state.targets.isEmpty) return;

    if (!state.isBallLocked) {
      // Lock aktivieren → aktuellen Fokus merken
      final idx = state.focusedIndex.clamp(0, state.targets.length - 1);
      state = state.copyWith(
        isBallLocked: true,
        lockedIndex: idx,
      );
    } else {
      // Lock lösen
      // WICHTIG: iconToolLockedIndex NICHT löschen, auch wenn Icon-Tool aktiv ist
      // Die Position soll erhalten bleiben, auch wenn der Lock gelöst wird
      state = state.copyWith(
        isBallLocked: false,
        clearLockedIndex: true,
        clearLastPickedColor: true,
        // clearIconToolLockedIndex: false, // Position BEHALTEN, auch wenn Lock gelöst wird
      );
    }
  }

  // 🔴 Farbe für Kugel anzeigen, während gepickt wird
  void setBallColor(Color color) {
    state = state.copyWith(lastPickedColor: color);
  }

  // 🔴 Custom-Farbe für einen spezifischen Ball speichern
  void setCustomColorForBall(int ballIndex, Color color) {
    final updatedColors = Map<int, Color>.from(state.customColors);
    updatedColors[ballIndex] = color;
    state = state.copyWith(
      customColors: updatedColors,
      activeCustomBallIndex: ballIndex,
      isCustomPaletteActive: true,
    );
    // Farben dauerhaft speichern
    _saveCustomColors(updatedColors);
  }

  // 🔴 Custom-Palette aktivieren/deaktivieren
  void setCustomPaletteActive(bool active, {int? ballIndex}) {
    state = state.copyWith(
      isCustomPaletteActive: active,
      activeCustomBallIndex: active ? (ballIndex ?? state.activeCustomBallIndex) : null,
    );
  }

  // 🔴 Icon auswählen und Icon Tool aktivieren
  void selectIcon(IconData icon) {
    state = state.copyWith(
      selectedIcon: icon,
      selectedEmoji: null,
      clearSelectedEmoji: true,
      activeTool: PaletteTool.icon,
      overlayVisible: false,
    );
    // Fokus auf erstes sichtbares Target setzen
    // Beim Icon Tool: Bevorzuge Tile-Targets (zum Platzieren), dann Icon-Targets (zum Einfärben)
    if (state.targets.isNotEmpty) {
      final visibleIndices = _visibleIndices();
      if (visibleIndices.isNotEmpty) {
        // Suche zuerst nach Tile-Targets (zum Platzieren von Icons)
        final tileTargetIndex = visibleIndices.firstWhere(
          (idx) => state.targets[idx].kind == TargetKind.tile,
          orElse: () => visibleIndices[0],
        );
        _updateFocusedIds(tileTargetIndex);
      }
    }
  }

  // 🔴 Emoji auswählen und Icon Tool aktivieren
  void selectEmoji(String emoji) {
    state = state.copyWith(
      selectedEmoji: emoji,
      selectedIcon: null,
      clearSelectedIcon: true,
      activeTool: PaletteTool.icon,
      overlayVisible: false,
    );
    // Fokus auf erstes sichtbares Target setzen
    // Beim Icon Tool: Bevorzuge Tile-Targets (zum Platzieren), dann Icon-Targets (zum Einfärben)
    if (state.targets.isNotEmpty) {
      final visibleIndices = _visibleIndices();
      if (visibleIndices.isNotEmpty) {
        // Suche zuerst nach Tile-Targets (zum Platzieren von Emojis)
        final tileTargetIndex = visibleIndices.firstWhere(
          (idx) => state.targets[idx].kind == TargetKind.tile,
          orElse: () {
            return visibleIndices[0];
          },
        );
        _updateFocusedIds(tileTargetIndex);
      } else {
      }
    } else {
    }
  }

  int _effectiveIndex() {
    if (state.targets.isEmpty) return 0;
    if (state.isBallLocked && state.lockedIndex != null) {
      return state.lockedIndex!.clamp(0, state.targets.length - 1);
    }
    return state.focusedIndex.clamp(0, state.targets.length - 1);
  }

  // 🔴 Lock lösen nach Farbanwendung (wird beim Loslassen aufgerufen)
  void releaseLockAfterColorPick() {
    if (state.isBallLocked) {
      // WICHTIG: Wenn Icon-Tool aktiv ist, Position speichern BEVOR der Lock gelöst wird
      int? savedIconToolLockedIndex;
      if (state.activeTool == PaletteTool.icon && state.lockedIndex != null) {
        savedIconToolLockedIndex = state.lockedIndex;
      }
      
      state = state.copyWith(
        isBallLocked: false,
        clearLockedIndex: true,
        clearLastPickedColor: true,
        iconToolLockedIndex: savedIconToolLockedIndex, // Position speichern BEVOR sie gelöscht wird
        clearIconToolLockedIndex: false, // Nicht löschen, sondern speichern!
      );
    }
  }

  // Center-Button: All <-> One
  void toggleScope() {
    final next = state.scope == PaletteScope.all ? PaletteScope.one : PaletteScope.all;
    
    // Scope speichern
    _savePaletteScope(next);
    
    // Wenn zu ALL gewechselt wird und ein Tool aktiv ist, alle passenden Targets selektieren
    if (next == PaletteScope.all && state.activeTool != null && state.targets.isNotEmpty) {
      final focusedIds = state.targets
          .where((t) => t.tools.contains(state.activeTool))
          .map((t) => t.id)
          .toSet();
      
      state = state.copyWith(scope: next, focusedIds: focusedIds);
      onFocusChange?.call(focusedIds);
    } else if (next == PaletteScope.one && state.activeTool != null) {
      // Bei ONE: nur aktuelles Target selektieren
      _updateFocusedIds(state.focusedIndex);
    } else {
      state = state.copyWith(scope: next);
    }
  }

  // Longpress auf Center: alles auf Werkseinstellung (außer Paint-Einstellungen)
  void resetAll() {
    // RadialPaletteState zurücksetzen, aber customColors und activeCustomBallIndex behalten
    final preservedCustomColors = state.customColors;
    final preservedActiveCustomBallIndex = state.activeCustomBallIndex;
    
    state = RadialPaletteState(
      customColors: preservedCustomColors,
      activeCustomBallIndex: preservedActiveCustomBallIndex,
    );
    // Die Overrides werden über wordHubTileOverridesProvider zurückgesetzt
    // (wird über Callback von word_hub_screen.dart aufgerufen)
  }

  /// Wird aufgerufen, wenn das Rad komplett geschlossen wird.
  /// Entfernt den Fokus von allen Targets.
  void clearFocus() {
    if (state.focusedIds.isEmpty && state.focusedIndex == 0) {
      return; // nichts zu tun
    }

    state = state.copyWith(
      focusedIndex: 0,
      focusedIds: {},
    );

    // UI (WordHubScreen etc.) informieren
    onFocusChange?.call({});
  }

  // NEU: Aktualisiert den Fokus für das aktive Tool (wird nach registerTargets aufgerufen)
  void refreshFocusForActiveTool() {
    if (state.activeTool == null || state.targets.isEmpty) return;
    
    final tool = state.activeTool!;
    final visibleIndices = _visibleIndices();
    if (visibleIndices.isEmpty) return;
    
    if (state.scope == PaletteScope.all) {
      // Bei ALL: alle passenden Targets selektieren
      final allMatchingTargets = state.targets
          .where((t) => t.tools.contains(tool))
          .toList();
      
      Set<String> focusedIds;
      if (tool == PaletteTool.icon) {
        // Beim Icon Tool: Nur Icon-Targets für das Einfärben (nicht Tile-Targets)
        // Tile-Targets werden nur für das Platzieren verwendet, nicht für das Einfärben
        focusedIds = allMatchingTargets
            .where((t) => t.id.endsWith('.icon') || t.kind == TargetKind.icon)
            .map((t) => t.id)
            .toSet();
      } else {
        focusedIds = allMatchingTargets.map((t) => t.id).toSet();
      }
      
      if (state.focusedIds != focusedIds) {
        state = state.copyWith(focusedIds: focusedIds);
        onFocusChange?.call(focusedIds);
      }
    } else {
      // Bei ONE: aktuelles Target beibehalten, wenn es noch sichtbar ist
      if (state.focusedIndex >= 0 && state.focusedIndex < state.targets.length) {
        if (visibleIndices.contains(state.focusedIndex)) {
          // Aktuelles Target ist noch sichtbar → Fokus beibehalten
          return;
        }
      }
      
      // Bei ONE: erstes sichtbares Target finden und fokussieren
      // Beim Icon Tool: Bevorzuge Tile-Targets (zum Platzieren), dann Icon-Targets (zum Einfärben)
      int targetIndex;
      if (tool == PaletteTool.icon) {
        // Suche zuerst nach Tile-Targets (zum Platzieren von Emojis/Icons)
        final tileTargetIndex = visibleIndices.firstWhere(
          (idx) => state.targets[idx].kind == TargetKind.tile,
          orElse: () => -1,
        );
        if (tileTargetIndex != -1) {
          targetIndex = tileTargetIndex;
        } else {
          // Kein Tile-Target gefunden → suche nach Icon-Targets
          final iconTargetIndex = visibleIndices.firstWhere(
            (idx) => state.targets[idx].id.endsWith('.icon') || state.targets[idx].kind == TargetKind.icon,
            orElse: () => visibleIndices[0],
          );
          targetIndex = iconTargetIndex;
        }
      } else {
        targetIndex = visibleIndices[0];
      }
      _updateFocusedIds(targetIndex);
    }
  }

  // 7 Tool-Buttons
  void selectTool(PaletteTool tool) {
    // Tool togglen
    final isSame = state.activeTool == tool;
    if (isSame) {
      // Tool wieder schließen → alle 7 Buttons sichtbar
      // Wenn Icon Tool aktiv ist und ein Icon/Emoji ausgewählt ist, löschen
      final clearIconEmoji = tool == PaletteTool.icon && 
          (state.selectedIcon != null || state.selectedEmoji != null);
      
      // WICHTIG: Wenn Icon-Tool deaktiviert wird und ein Lock aktiv ist, Position speichern
      int? savedIconToolLockedIndex;
      if (tool == PaletteTool.icon && state.isBallLocked && state.lockedIndex != null) {
        savedIconToolLockedIndex = state.lockedIndex;
      }
      
      state = state.copyWith(
        clearActiveTool: true,
        overlayVisible: true,
        focusedIds: {},
        clearSelectedIcon: clearIconEmoji,
        clearSelectedEmoji: clearIconEmoji,
        iconToolLockedIndex: savedIconToolLockedIndex, // Position speichern wenn Icon-Tool deaktiviert wird
      );
      onFocusChange?.call({});
    } else {
      // Anderes Tool auswählen → Icon/Emoji löschen wenn vorhanden
      final clearIconEmoji = state.selectedIcon != null || state.selectedEmoji != null;
      
      // WICHTIG: Wenn vom Icon-Tool weggewechselt wird und ein Lock aktiv ist, Position speichern
      int? savedIconToolLockedIndex;
      
      // Wenn bereits eine gespeicherte Position existiert, diese beibehalten
      if (state.iconToolLockedIndex != null) {
        savedIconToolLockedIndex = state.iconToolLockedIndex;
      } else if (state.activeTool == PaletteTool.icon && state.isBallLocked && state.lockedIndex != null) {
        // Icon-Tool ist aktiv und Lock ist aktiv → Position speichern
        savedIconToolLockedIndex = state.lockedIndex;
      } else if (state.activeTool == null && state.isBallLocked && state.lockedIndex != null && state.iconToolLockedIndex == null) {
        // Kein Tool aktiv, aber Lock ist aktiv → könnte sein, dass Icon-Tool gerade deaktiviert wurde
        // Prüfe, ob das Target ein Tile-Target ist (was beim Icon-Tool verwendet wird)
        if (state.lockedIndex! < state.targets.length) {
          final target = state.targets[state.lockedIndex!];
          if (target.kind == TargetKind.tile) {
            // Es ist ein Tile-Target → könnte vom Icon-Tool kommen, speichere es
            savedIconToolLockedIndex = state.lockedIndex;
          }
        }
      }
      
      // WICHTIG: iconToolLockedIndex muss VOR dem Tool-Wechsel gespeichert werden
      state = state.copyWith(
        clearSelectedIcon: clearIconEmoji,
        clearSelectedEmoji: clearIconEmoji,
        iconToolLockedIndex: savedIconToolLockedIndex, // Position speichern
      );
      // Neues Tool aktiv → andere 6 verschwinden, Overlay für Fokus ausblenden
      state = state.copyWith(activeTool: tool, overlayVisible: false);
      
      // Fokus-IDs aktualisieren basierend auf Scope
      if (state.targets.isNotEmpty) {
        if (state.scope == PaletteScope.all) {
          // Bei ALL: alle passenden Targets selektieren
          // NEU: Wenn Icon Tool aktiv, bevorzuge Icon-Targets (zum Einfärben) über Tile-Targets (zum Setzen)
          final allMatchingTargets = state.targets
              .where((t) => t.tools.contains(tool))
              .toList();
          
          Set<String> focusedIds;
          if (tool == PaletteTool.icon) {
            // Bevorzuge Icon-Targets (mit .icon ID) über Tile-Targets
            final iconTargets = allMatchingTargets
                .where((t) => t.id.endsWith('.icon'))
                .map((t) => t.id)
                .toSet();
            if (iconTargets.isNotEmpty) {
              focusedIds = iconTargets;
            } else {
              // Keine Icon-Targets vorhanden → normale Tile-Targets verwenden
              focusedIds = allMatchingTargets.map((t) => t.id).toSet();
            }
          } else {
            focusedIds = allMatchingTargets.map((t) => t.id).toSet();
          }
          
          state = state.copyWith(focusedIds: focusedIds);
          onFocusChange?.call(focusedIds);
        } else {
          // Bei ONE: erstes sichtbares Target finden und fokussieren
          // NEU: Wenn Icon Tool aktiv, bevorzuge Tile-Targets (zum Platzieren) über Icon-Targets (zum Einfärben)
          final visibleIndices = _visibleIndices();
          if (visibleIndices.isNotEmpty) {
            int targetIndex;
            if (tool == PaletteTool.icon) {
              // WICHTIG: Wenn zurück zum Icon-Tool gewechselt wird und eine gespeicherte Position existiert, diese wiederherstellen
              if (state.iconToolLockedIndex != null && visibleIndices.contains(state.iconToolLockedIndex!)) {
                targetIndex = state.iconToolLockedIndex!;
                // Lock wieder aktivieren und Fokus setzen
                final focusedTarget = state.targets[targetIndex];
                final focusedIds = {focusedTarget.id};
                state = state.copyWith(
                  focusedIndex: targetIndex,
                  isBallLocked: true,
                  lockedIndex: targetIndex,
                  focusedIds: focusedIds,
                );
                // Fokus-IDs aktualisieren (wichtig für Scrollen)
                // WICHTIG: Mehrfach mit Verzögerung aufrufen, um sicherzustellen, dass das Widget gerendert ist
                // Zuerst mit leeren IDs aufrufen, um _lastPrimaryId zurückzusetzen
                onFocusChange?.call({});
                // Dann nach kurzer Verzögerung die echten IDs senden
                Future.delayed(const Duration(milliseconds: 100), () {
                  onFocusChange?.call(focusedIds);
                });
                // Zusätzliche Versuche im PostFrameCallback
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  Future.delayed(const Duration(milliseconds: 200), () {
                    onFocusChange?.call(focusedIds);
                  });
                  Future.delayed(const Duration(milliseconds: 400), () {
                    onFocusChange?.call(focusedIds);
                  });
                });
                return; // Früh zurückkehren, da wir bereits alles gesetzt haben
              } else {
                // Suche zuerst nach Tile-Targets (zum Platzieren von Emojis/Icons)
                final tileTargetIndex = visibleIndices.firstWhere(
                  (idx) => state.targets[idx].kind == TargetKind.tile,
                  orElse: () => -1,
                );
                if (tileTargetIndex != -1) {
                  targetIndex = tileTargetIndex;
                } else {
                  // Kein Tile-Target gefunden → suche nach Icon-Targets
                  final iconTargetIndex = visibleIndices.firstWhere(
                    (idx) => state.targets[idx].id.endsWith('.icon') || state.targets[idx].kind == TargetKind.icon,
                    orElse: () => visibleIndices[0],
                  );
                  targetIndex = iconTargetIndex;
                }
              }
            } else {
              targetIndex = visibleIndices[0];
            }
            _updateFocusedIds(targetIndex);
          } else {
            // Kein sichtbares Target → Fokus zurücksetzen
            state = state.copyWith(focusedIndex: 0, focusedIds: {});
            onFocusChange?.call({});
          }
        }
      }
    }
  }

  // WordHub kann seine stylbaren Elemente registrieren
  // NEU: Targets werden gesammelt/aktualisiert, nicht ersetzt
  void registerTargets(List<PaletteTarget> targets) {
    // Bestehende Targets in Map nach ID
    final byId = <String, PaletteTarget>{
      for (final t in state.targets) t.id: t,
    };

    // Neue Targets einfügen/überschreiben
    for (final t in targets) {
      byId[t.id] = t;
    }

    final merged = byId.values.toList();

    final newFocused = merged.isEmpty
        ? 0
        : state.focusedIndex.clamp(0, merged.length - 1);

    state = state.copyWith(
      targets: merged,
      focusedIndex: newFocused,
    );

    // Fokus-IDs aktualisieren NUR wenn ein Tool aktiv ist
    if (state.activeTool != null && merged.isNotEmpty) {
      _updateFocusedIds(newFocused);
    } else {
      // Kein Tool aktiv → keine Fokus-IDs setzen
      if (state.focusedIds.isNotEmpty) {
        state = state.copyWith(focusedIds: {});
        onFocusChange?.call({});
      }
    }

  }

  // Welche Indizes in state.targets sind "sichtbar" für das aktuelle Tool?
  // Filtert nur Targets, die das aktive Tool unterstützen
  List<int> _visibleIndices() {
    if (state.activeTool == null) {
      // Kein Tool aktiv → alle Targets sichtbar
      return List<int>.generate(state.targets.length, (i) => i);
    }
    
    // Nur Targets zurückgeben, die das aktive Tool unterstützen
    final visible = <int>[];
    for (int i = 0; i < state.targets.length; i++) {
      final target = state.targets[i];
      if (state.activeTool == PaletteTool.icon) {
        // Beim Icon Tool: sowohl Tile-Targets (zum Platzieren) als auch Icon-Targets (zum Einfärben) sichtbar
        // Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie sollten trotzdem sichtbar sein für die Navigation
        if (target.tools.contains(state.activeTool) || target.kind == TargetKind.tile) {
          visible.add(i);
        }
      } else {
        // Bei anderen Tools: normale Logik
        if (target.tools.contains(state.activeTool)) {
          visible.add(i);
        }
      }
    }
    
    return visible;
  }

  List<PaletteTarget> get visibleTargets {
    final idx = _visibleIndices();
    return [for (final i in idx) state.targets[i]];
  }

  int get currentVisibleIndex {
    final indices = _visibleIndices();
    if (indices.isEmpty) return 0;
    final current = state.focusedIndex;
    final pos = indices.indexOf(current);
    if (pos == -1) return 0;
    return pos;
  }

  // Wird bei "Kugel schieben" in Steps benutzt (z.B. Pfeil-nach-oben/-unten)
  void moveFocus(int delta) {
    // Nur funktionieren, wenn ein Tool aktiv ist UND im ONE-Modus
    if (state.activeTool == null) return;
    if (state.scope == PaletteScope.all) return; // Navigation deaktiviert im ALL-Modus

    final indices = _visibleIndices();
    if (indices.isEmpty) return;

    final currentPos = currentVisibleIndex;
    var nextPos = currentPos + delta;
    if (nextPos < 0) nextPos = 0;
    if (nextPos >= indices.length) nextPos = indices.length - 1;

    final newGlobalIndex = indices[nextPos];
    _updateFocusedIds(newGlobalIndex);

  }

  // Direkter Sprung auf einen "sichtbaren" Index vom Ring aus
  void moveFocusToVisibleIndex(int visibleIndex) {
    // Nur funktionieren, wenn ein Tool aktiv ist UND im ONE-Modus
    if (state.activeTool == null) return;
    if (state.scope == PaletteScope.all) return; // Navigation deaktiviert im ALL-Modus

    final indices = _visibleIndices();
    if (indices.isEmpty) {
      return;
    }

    var pos = visibleIndex;
    if (pos < 0) pos = 0;
    if (pos >= indices.length) pos = indices.length - 1;

    final newGlobalIndex = indices[pos];
    final target = state.targets[newGlobalIndex];
    _updateFocusedIds(newGlobalIndex);

    final total = indices.length - 1;
    _onFocusChanged(pos, newGlobalIndex, total);
  }

  void _updateFocusedIds(int globalIndex) {
    // Nur fokussieren, wenn ein Tool aktiv ist
    if (state.activeTool == null) {
      // Kein Tool aktiv → keine Fokus-IDs setzen
      if (state.focusedIds.isNotEmpty) {
        state = state.copyWith(focusedIds: {});
        onFocusChange?.call({});
      }
      return;
    }

    if (state.targets.isEmpty) {
      if (state.focusedIds.isEmpty) return; // Keine Änderung
      state = state.copyWith(focusedIndex: globalIndex, focusedIds: {});
      onFocusChange?.call({});
      return;
    }

    final clampedIndex = globalIndex.clamp(0, state.targets.length - 1);
    final focusedTarget = state.targets[clampedIndex];
    
    // Prüfe, ob das Target das aktive Tool unterstützt
    // WICHTIG: Beim Icon Tool sind Tile-Targets auch erlaubt (zum Platzieren), auch wenn sie PaletteTool.icon nicht in ihren tools haben
    final isToolSupported = focusedTarget.tools.contains(state.activeTool) ||
        (state.activeTool == PaletteTool.icon && focusedTarget.kind == TargetKind.tile);
    if (!isToolSupported) {
      // Target unterstützt das Tool nicht → erstes sichtbares Target finden
      final visibleIndices = _visibleIndices();
      if (visibleIndices.isNotEmpty) {
        final firstVisibleIndex = visibleIndices[0];
        final firstVisibleTarget = state.targets[firstVisibleIndex];
        final focusedIds = {firstVisibleTarget.id};
        
        if (state.focusedIds != focusedIds || state.focusedIndex != firstVisibleIndex) {
          state = state.copyWith(
            focusedIndex: firstVisibleIndex,
            focusedIds: focusedIds,
          );
          onFocusChange?.call(focusedIds);
        }
        return;
      } else {
        // Kein sichtbares Target → Fokus zurücksetzen
        state = state.copyWith(focusedIndex: 0, focusedIds: {});
        onFocusChange?.call({});
        return;
      }
    }
    
    final focusedIds = {focusedTarget.id};

    // Nur updaten, wenn sich die IDs wirklich geändert haben
    if (state.focusedIds == focusedIds && state.focusedIndex == clampedIndex) {
      return; // Keine Änderung, kein Callback
    }

    state = state.copyWith(
      focusedIndex: clampedIndex,
      focusedIds: focusedIds,
    );

    onFocusChange?.call(focusedIds);
  }

  void _onFocusChanged(int vis, int global, int total) {
    // Nur loggen, wenn wir gerade von "nicht voll" -> "voll" wechseln
    if (vis == total && _lastFocusVis != total) {
    }

    _lastFocusVis = vis;
  }

  /// Wird vom Farbring aufgerufen, um die aktuelle Farbe auf das/alle Targets anzuwenden.
  void applyColorToCurrentTarget(Color color) {
    final tool = state.activeTool;
    if (tool == null) {
      // kein Tool → Farbrad wirkt nur global auf Theme, nicht auf Targets
      return;
    }

    if (state.targets.isEmpty) return;

    if (state.scope == PaletteScope.all) {
      // ALL → alle fokussierten Targets einfärben (die das Tool unterstützen)
      // Zusätzlich prüfen, dass das Target das aktive Tool auch wirklich unterstützt
      for (final id in state.focusedIds) {
        // WICHTIG: Beim Icon Tool nur Icon-Targets finden (nicht Tile-Targets)
        PaletteTarget? t;
        if (tool == PaletteTool.icon) {
          // Nur Icon-Targets finden (mit .icon ID oder kind == icon)
          try {
            t = state.targets.firstWhere(
              (target) => target.id == id && 
                          (target.id.endsWith('.icon') || target.kind == TargetKind.icon) &&
                          target.tools.contains(tool),
            );
          } catch (e) {
            // Kein Icon-Target gefunden → überspringen
            continue;
          }
        } else {
          // Bei anderen Tools: normale Logik
          try {
            t = state.targets.firstWhere(
              (target) => target.id == id && target.tools.contains(tool),
            );
          } catch (e) {
            // Target nicht gefunden oder unterstützt Tool nicht → überspringen
            continue;
          }
        }
        
        if (t != null && t.tools.contains(tool)) {
          t.onApply?.call(tool, color, state.scope);
        }
      }
    } else {
      // ONE → nur aktuelles/gelocktes Target
      final idx = _effectiveIndex();
      if (idx >= 0 && idx < state.targets.length) {
        final t = state.targets[idx];
        // NEU: Beim Icon Tool nur auf Icon-Targets anwenden (nicht auf Tile-Targets)
        if (tool == PaletteTool.icon) {
          // WICHTIG: Nur Icon-Targets einfärben, niemals Tile-Targets!
          if (t.id.endsWith('.icon') || t.kind == TargetKind.icon) {
            // Direktes Icon-Target (mit .icon ID oder kind == icon)
            if (t.tools.contains(tool)) {
              t.onApply?.call(tool, color, state.scope);
            }
          } else if (t.kind == TargetKind.tile) {
            // Wenn ein Tile-Target fokussiert ist, suche nach dem zugehörigen Icon-Target
            final iconTargetId = '${t.id}.icon';
            try {
              final iconTarget = state.targets.firstWhere(
                (target) => target.id == iconTargetId && target.tools.contains(tool),
              );
              // Nur anwenden, wenn es wirklich ein Icon-Target ist UND es existiert
              if (iconTarget.id == iconTargetId && 
                  (iconTarget.id.endsWith('.icon') || iconTarget.kind == TargetKind.icon) &&
                  iconTarget.tools.contains(tool)) {
                iconTarget.onApply?.call(tool, color, state.scope);
              } else {
              }
            } catch (e) {
              // Kein Icon-Target gefunden → mache NICHTS (Tile-Targets werden NICHT eingefärbt)
            }
          } else {
          }
          // Tile-Targets werden beim Icon Tool komplett ignoriert (nur zum Platzieren von Emojis/Icons)
        } else {
          // Bei anderen Tools: normale Logik
          if (t.tools.contains(tool)) {
            t.onApply?.call(tool, color, state.scope);
          }
        }
      }
    }

    // ❌ KEIN Auto-Unlock mehr hier - wird erst beim Loslassen gelöst
  }

  // 🔴 Icon auf aktuelles/gelocktes Target anwenden
  void applyIconToCurrentTarget(IconData icon) {
    final tool = state.activeTool;
    if (tool != PaletteTool.icon) return;

    if (state.targets.isEmpty) return;

    if (state.scope == PaletteScope.all) {
      // ALL → alle fokussierten Targets (die das Tool unterstützen)
      for (final id in state.focusedIds) {
        final t = state.targets.firstWhere(
          (target) => target.id == id,
          orElse: () => state.targets.first,
        );
        // WICHTIG: Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie haben onApplyIcon
        // Icon-Targets haben PaletteTool.icon in ihren tools
        if (t.onApplyIcon != null && (t.tools.contains(tool) || t.kind == TargetKind.tile)) {
          t.onApplyIcon?.call(icon, state.scope);
        }
      }
    } else {
      // ONE → nur aktuelles/gelocktes Target
      final idx = _effectiveIndex();
      if (idx >= 0 && idx < state.targets.length) {
        final t = state.targets[idx];
        // WICHTIG: Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie haben onApplyIcon
        // Icon-Targets haben PaletteTool.icon in ihren tools
        if (t.onApplyIcon != null && (t.tools.contains(tool) || t.kind == TargetKind.tile)) {
          t.onApplyIcon?.call(icon, state.scope);
        }
      }
    }
  }

  // 🔴 Emoji auf aktuelles/gelocktes Target anwenden
  void applyEmojiToCurrentTarget(String emoji) {
    final tool = state.activeTool;
    if (tool != PaletteTool.icon) return;

    if (state.targets.isEmpty) return;

    if (state.scope == PaletteScope.all) {
      // ALL → alle fokussierten Targets (die das Tool unterstützen)
      for (final id in state.focusedIds) {
        final t = state.targets.firstWhere(
          (target) => target.id == id,
          orElse: () => state.targets.first,
        );
        // WICHTIG: Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie haben onApplyEmoji
        // Icon-Targets haben PaletteTool.icon in ihren tools
        if (t.onApplyEmoji != null && (t.tools.contains(tool) || t.kind == TargetKind.tile)) {
          t.onApplyEmoji?.call(emoji, state.scope);
        }
      }
    } else {
      // ONE → nur aktuelles/gelocktes Target
      final idx = _effectiveIndex();
      if (idx >= 0 && idx < state.targets.length) {
        final t = state.targets[idx];
        // WICHTIG: Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie haben onApplyEmoji
        // Icon-Targets haben PaletteTool.icon in ihren tools
        if (t.onApplyEmoji != null && (t.tools.contains(tool) || t.kind == TargetKind.tile)) {
          t.onApplyEmoji?.call(emoji, state.scope);
        }
      }
    }
  }

  // 🔴 Icons/Emojis vom aktuellen/gelockten Target löschen
  void clearIconEmojiFromCurrentTarget() {
    final tool = state.activeTool;
    if (tool != PaletteTool.icon) return;

    if (state.targets.isEmpty) return;

    if (state.scope == PaletteScope.all) {
      // ALL → alle fokussierten Targets (die das Tool unterstützen)
      for (final id in state.focusedIds) {
        final t = state.targets.firstWhere(
          (target) => target.id == id,
          orElse: () => state.targets.first,
        );
        // WICHTIG: Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie haben onClearIconEmoji
        // Icon-Targets haben PaletteTool.icon in ihren tools
        if (t.onClearIconEmoji != null && (t.tools.contains(tool) || t.kind == TargetKind.tile)) {
          t.onClearIconEmoji?.call(state.scope);
        }
      }
    } else {
      // ONE → nur aktuelles/gelocktes Target
      final idx = _effectiveIndex();
      if (idx >= 0 && idx < state.targets.length) {
        final t = state.targets[idx];
        // WICHTIG: Tile-Targets haben PaletteTool.icon NICHT in ihren tools, aber sie haben onClearIconEmoji
        // Icon-Targets haben PaletteTool.icon in ihren tools
        if (t.onClearIconEmoji != null && (t.tools.contains(tool) || t.kind == TargetKind.tile)) {
          t.onClearIconEmoji?.call(state.scope);
        }
      }
    }
  }

  // 🔴 Reset aller Anwendungen eines Tools (wird bei Longpress auf zentralen Button aufgerufen)
  void resetTool(PaletteTool tool) {
    // Icons/Emojis zurücksetzen
    if (tool == PaletteTool.icon) {
      state = state.copyWith(
        selectedIcon: null,
        selectedEmoji: null,
        clearSelectedIcon: true,
        clearSelectedEmoji: true,
      );
    }
    // Paint-Einstellungen zurücksetzen (nur wenn Paint aktiv ist)
    if (tool == PaletteTool.paint) {
      state = state.copyWith(
        customColors: const {},
        activeCustomBallIndex: null,
        clearActiveCustomBallIndex: true,
        isCustomPaletteActive: false,
      );
      // Custom-Farben auch aus SharedPreferences löschen
      _saveCustomColors({});
    }
    // Die eigentlichen Overrides werden über wordHubTileOverridesProvider zurückgesetzt
  }
}

final radialPaletteProvider =
    StateNotifierProvider<RadialPaletteController, RadialPaletteState>(
  (ref) => RadialPaletteController(),
);
