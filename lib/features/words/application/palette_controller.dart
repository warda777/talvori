import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/appearance_prefs_repository.dart';
import 'palette_state.dart';

part 'palette_controller.g.dart';

@riverpod
class PaletteController extends _$PaletteController {
  AppearancePrefsRepository get _repo =>
      ref.read(appearancePrefsRepositoryProvider);

  @override
  PaletteState build() {
    // Lazy-init, async Laden separat
    _hydrate();
    return PaletteState.initial();
  }

  Future<void> _hydrate() async {
    final overrides = await _repo.loadCategoryOverrides();
    final global = await _repo.loadGlobalColor();
    state = state.copyWith(overridesByCategory: overrides, globalColor: global);
  }

  // UI-Events
  void setSelectedColor(Color c) => state = state.copyWith(selectedColor: c);

  void setTarget(PaletteTarget t) => state = state.copyWith(target: t);

  void toggleScope() {
    final next = state.scope == ApplyScope.single
        ? ApplyScope.all
        : ApplyScope.single;
    state = state.copyWith(scope: next);
  }

  void startDrag() => state = state.copyWith(isDragging: true);
  void endDrag() =>
      state = state.copyWith(isDragging: false, hoveredCategoryId: null);

  void hoverCategory(String? categoryId) =>
      state = state.copyWith(hoveredCategoryId: categoryId);

  /// zentrale Stelle fürs Anwenden – später füllen wir die Fälle aus
  void applyColor(Color c) {
    switch (state.target) {
      case PaletteTarget.stroke:
        /* TODO: Rahmen/Kachel + ggf. Icon-Stroke */
        break;
      case PaletteTarget.glow:
        /* TODO */
        break;
      case PaletteTarget.tileBg:
        /* TODO */
        break;
      case PaletteTarget.hubBg:
        /* TODO: WordHub-Hintergrund */
        break;
      case PaletteTarget.icons:
        /* TODO */
        break;
      case PaletteTarget.text:
        /* TODO: Schriftfarben */
        break;
      case PaletteTarget.image:
        /* handled separat */
        break;
    }
  }

  /// Drop: wendet die aktuell gewählte Farbe an
  Future<void> dropOn({String? categoryId}) async {
    applyColor(state.selectedColor);

    final color = state.selectedColor;

    if (state.scope == ApplyScope.all) {
      await _repo.saveGlobalColor(color);
      state = state.copyWith(globalColor: color);
      return;
    }

    if (categoryId == null) return;
    final map = Map<String, Color>.of(state.overridesByCategory);
    map[categoryId] = color;
    await _repo.saveCategoryOverrides(map);
    state = state.copyWith(overridesByCategory: map);
  }

  /// Entfernt Override für eine Kachel (Kontextmenü-Option)
  Future<void> clearOverride(String categoryId) async {
    final map = Map<String, Color>.of(state.overridesByCategory);
    map.remove(categoryId);
    await _repo.saveCategoryOverrides(map);
    state = state.copyWith(overridesByCategory: map);
  }

  /// Global zurücksetzen
  Future<void> clearGlobal() async {
    await _repo.saveGlobalColor(null);
    state = state.copyWith(globalColor: null);
  }

  /// Setzt alle Einstellungen auf Werkzustand zurück.
  Future<void> resetToDefaults() async {
    await _repo.saveCategoryOverrides({});
    await _repo.saveGlobalColor(null);
    state = PaletteState.initial();
  }
}
