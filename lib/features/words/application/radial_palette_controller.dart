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
  final Set<String> focusedIds;   // IDs der aktuell fokussierten Targets

  // 🔴 NEU: Kugel-Lock-State
  final bool isBallLocked;          // Kugel „eingerastet"?
  final int? lockedIndex;           // auf welches Target ist sie gelockt?
  final Color? lastPickedColor;     // zuletzt gepickte Farbe (für Kugel-Fill)

  const RadialPaletteState({
    this.scope = PaletteScope.all,
    this.activeTool,
    this.focusedIndex = 0,
    this.targets = const [],
    this.overlayVisible = true,
    this.focusedIds = const {},
    this.isBallLocked = false,
    this.lockedIndex,
    this.lastPickedColor,
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
    Color? lastPickedColor,
    bool clearLastPickedColor = false,
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
      lastPickedColor:
          clearLastPickedColor ? null : (lastPickedColor ?? this.lastPickedColor),
    );
  }
}

class RadialPaletteController extends StateNotifier<RadialPaletteState> {
  RadialPaletteController() : super(const RadialPaletteState());

  int _lastFocusVis = -1; // neu
  
  /// Callback, der die aktuell fokussierten Target-IDs meldet
  void Function(Set<String> ids)? onFocusChange;

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
      debugPrint('[RadialPalette] Ball locked on index=$idx');
    } else {
      // Lock lösen
      state = state.copyWith(
        isBallLocked: false,
        clearLockedIndex: true,
        clearLastPickedColor: true,
      );
      debugPrint('[RadialPalette] Ball unlocked');
    }
  }

  // 🔴 Farbe für Kugel anzeigen, während gepickt wird
  void setBallColor(Color color) {
    state = state.copyWith(lastPickedColor: color);
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
      state = state.copyWith(
        isBallLocked: false,
        clearLockedIndex: true,
        clearLastPickedColor: true,
      );
      debugPrint('[RadialPalette] Finger losgelassen, ball released');
    }
  }

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

  // 7 Tool-Buttons
  void selectTool(PaletteTool tool) {
    // Tool togglen
    final isSame = state.activeTool == tool;
    if (isSame) {
      // Tool wieder schließen → alle 7 Buttons sichtbar
      state = state.copyWith(clearActiveTool: true, overlayVisible: true, focusedIds: {});
      onFocusChange?.call({});
    } else {
      // Neues Tool aktiv → andere 6 verschwinden, Overlay für Fokus ausblenden
      state = state.copyWith(activeTool: tool, overlayVisible: false);
      // Fokus-IDs aktualisieren
      if (state.targets.isNotEmpty) {
        _updateFocusedIds(state.focusedIndex);
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
    // Nur funktionieren, wenn ein Tool aktiv ist
    if (state.activeTool == null) return;

    final indices = _visibleIndices();
    if (indices.isEmpty) return;

    final currentPos = currentVisibleIndex;
    var nextPos = currentPos + delta;
    if (nextPos < 0) nextPos = 0;
    if (nextPos >= indices.length) nextPos = indices.length - 1;

    final newGlobalIndex = indices[nextPos];
    _updateFocusedIds(newGlobalIndex);

    debugPrint(
      '[RadialPalette] Fokus (step) → vis=$nextPos / ${indices.length - 1} (global=$newGlobalIndex)',
    );
  }

  // Direkter Sprung auf einen "sichtbaren" Index vom Ring aus
  void moveFocusToVisibleIndex(int visibleIndex) {
    // Nur funktionieren, wenn ein Tool aktiv ist
    if (state.activeTool == null) return;

    final indices = _visibleIndices();
    if (indices.isEmpty) return;

    var pos = visibleIndex;
    if (pos < 0) pos = 0;
    if (pos >= indices.length) pos = indices.length - 1;

    final newGlobalIndex = indices[pos];
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
      debugPrint('[RadialPalette] Fokus (ring) voll sichtbar: $vis / $total');
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
      // ALL → alle Targets einfärben
      for (final t in state.targets) {
        t.onApply?.call(tool, color, state.scope);
      }
    } else {
      // ONE → nur aktuelles/gelocktes Target
      final idx = _effectiveIndex();
      final t = state.targets[idx];
      t.onApply?.call(tool, color, state.scope);
    }

    // ❌ KEIN Auto-Unlock mehr hier - wird erst beim Loslassen gelöst
  }
}

final radialPaletteProvider =
    StateNotifierProvider<RadialPaletteController, RadialPaletteState>(
  (ref) => RadialPaletteController(),
);
