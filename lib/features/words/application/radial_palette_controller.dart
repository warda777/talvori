import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart'; // For debugPrint

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

  PaletteTarget({
    required this.id,
    required this.key,
    required this.kind,
    required this.tools,
    this.onApply,
  });
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

    debugPrint(
      '[RadialPalette] registerTargets: +${targets.length}, total=${merged.length}',
    );
  }

  // Welche Indizes in state.targets sind "sichtbar" für das aktuelle Tool?
  // Wenn du Tools noch nicht pro Target hinterlegt hast:
  //   → erstmal ALLE Targets sichtbar lassen.
  List<int> _visibleIndices() {
    // TODO: später hier nach activeTool + Target-Typ filtern
    return List<int>.generate(state.targets.length, (i) => i);
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
    final indices = _visibleIndices();
    if (indices.isEmpty) return;

    final currentPos = currentVisibleIndex;
    var nextPos = currentPos + delta;
    if (nextPos < 0) nextPos = 0;
    if (nextPos >= indices.length) nextPos = indices.length - 1;

    final newGlobalIndex = indices[nextPos];
    state = state.copyWith(focusedIndex: newGlobalIndex);

    debugPrint(
      '[RadialPalette] Fokus (step) → vis=$nextPos / ${indices.length - 1} (global=$newGlobalIndex)',
    );
  }

  // Direkter Sprung auf einen "sichtbaren" Index vom Ring aus
  void moveFocusToVisibleIndex(int visibleIndex) {
    final indices = _visibleIndices();
    if (indices.isEmpty) return;

    var pos = visibleIndex;
    if (pos < 0) pos = 0;
    if (pos >= indices.length) pos = indices.length - 1;

    final newGlobalIndex = indices[pos];
    state = state.copyWith(focusedIndex: newGlobalIndex);

    debugPrint(
      '[RadialPalette] Fokus (ring) → vis=$pos / ${indices.length - 1} (global=$newGlobalIndex)',
    );
  }

  /// Wird vom Farbring aufgerufen, um die aktuelle Farbe auf das/alle Targets anzuwenden.
  void applyColorToCurrentTarget(Color color) {
    final tool = state.activeTool;
    if (tool == null) {
      // Kein Tool aktiv → wir machen hier (noch) nichts.
      // (Dein bisheriger globaler Theme-Change bleibt separat über onPickColor.)
      return;
    }

    // Nichts registriert → raus
    if (state.targets.isEmpty) return;

    if (state.scope == PaletteScope.all) {
      // ALL → auf alle Targets anwenden, die einen Callback haben
      for (final t in state.targets) {
        t.onApply?.call(tool, color, state.scope);
      }
    } else {
      // ONE → nur auf das aktuell fokussierte Target anwenden
      final idx = state.focusedIndex.clamp(0, state.targets.length - 1);
      final t = state.targets[idx];
      t.onApply?.call(tool, color, state.scope);
    }
  }
}

final radialPaletteProvider =
    StateNotifierProvider<RadialPaletteController, RadialPaletteState>(
  (ref) => RadialPaletteController(),
);
