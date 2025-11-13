import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// All = alles einfärben, One = jeweils nur ein Element
enum PaletteScope { all, one }

/// Welche Eigenschaft soll die Palette bearbeiten?
enum PaletteTool {
  stroke,         // 1. Rahmen
  fill,           // 2. Hintergrund Button/Kachel
  text,           // 3. Schrift
  hubBackground,  // 4. Word Hub Background + Top
  glow,           // 5. Glow an/aus + Farbe
  icon,           // 6. Icon-Farbe
  image,          // 7. Bild in Kachel
}

/// Ein stylbares Element in Word Hub (Titel, Button, Kachel usw.)
class PaletteTarget {
  final String id;          // z.B. "wordHub.title", "wordHub.unlockButton", "wordHub.tile:$index"
  final GlobalKey key;      // fürs spätere Highlighting
  PaletteTarget(this.id, this.key);
}

class RadialPaletteState {
  final PaletteScope scope;
  final PaletteTool? activeTool;    // null = nur Farbrad ohne Tool
  final int focusedIndex;          // Index im Target-Array
  final List<PaletteTarget> targets;
  final bool overlayVisible;

  const RadialPaletteState({
    this.scope = PaletteScope.all,
    this.activeTool,
    this.focusedIndex = 0,
    this.targets = const [],
    this.overlayVisible = true,
  });

  RadialPaletteState copyWith({
    PaletteScope? scope,
    PaletteTool? activeTool,
    int? focusedIndex,
    List<PaletteTarget>? targets,
    bool? overlayVisible,
    bool clearActiveTool = false, // 🔹 Flag um explizit auf null zu setzen
  }) {
    return RadialPaletteState(
      scope: scope ?? this.scope,
      activeTool: clearActiveTool ? null : (activeTool ?? this.activeTool),
      focusedIndex: focusedIndex ?? this.focusedIndex,
      targets: targets ?? this.targets,
      overlayVisible: overlayVisible ?? this.overlayVisible,
    );
  }
}

class RadialPaletteController extends StateNotifier<RadialPaletteState> {
  RadialPaletteController() : super(const RadialPaletteState());

  // Center-Button: All <-> One
  void toggleScope() {
    final next = state.scope == PaletteScope.all ? PaletteScope.one : PaletteScope.all;
    state = state.copyWith(scope: next);
  }

  // Longpress auf Center: alles auf Werkseinstellung
  void resetAll() {
    // hier später: Farben im Theme / Overrides zurücksetzen
    state = const RadialPaletteState();
  }

  // 7 Tool-Buttons
  void selectTool(PaletteTool tool) {
    // Tool togglen
    final isSame = state.activeTool == tool;
    if (isSame) {
      // Tool wieder schließen → alle 7 Buttons sichtbar
      state = state.copyWith(clearActiveTool: true, overlayVisible: true);
    } else {
      // Neues Tool aktiv → andere 6 verschwinden, Overlay für Fokus ausblenden
      state = state.copyWith(activeTool: tool, overlayVisible: false);
    }
  }

  // WordHub kann seine stylbaren Elemente registrieren
  void registerTargets(List<PaletteTarget> targets) {
    state = state.copyWith(
      targets: targets,
      focusedIndex: targets.isEmpty ? 0 : state.focusedIndex.clamp(0, targets.length - 1),
    );
  }

  // Wird aufgerufen, wenn du das Rad oder die Scroll-Fläche drehst
  void moveFocus(int delta) {
    if (state.targets.isEmpty) return;
    var next = state.focusedIndex + delta;
    if (next < 0) next = 0;
    if (next >= state.targets.length) next = state.targets.length - 1;
    state = state.copyWith(focusedIndex: next);
  }
}

final radialPaletteProvider =
    StateNotifierProvider<RadialPaletteController, RadialPaletteState>(
  (ref) => RadialPaletteController(),
);
