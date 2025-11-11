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

  /// Drop: wendet die aktuell gewählte Farbe an
  Future<void> dropOn({String? categoryId}) async {
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
