import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class AppearancePrefsRepository {
  Future<Map<String, Color>> loadCategoryOverrides();
  Future<void> saveCategoryOverrides(Map<String, Color> map);

  Future<Color?> loadGlobalColor();
  Future<void> saveGlobalColor(Color? color);
}

/// Vorläufig: In-Memory (kein IO-Jank). Später SharedPreferences / Supabase.
class InMemoryAppearancePrefsRepository implements AppearancePrefsRepository {
  Map<String, Color> _overrides = {};
  Color? _global;

  @override
  Future<Map<String, Color>> loadCategoryOverrides() async =>
      Map.of(_overrides);

  @override
  Future<void> saveCategoryOverrides(Map<String, Color> map) async {
    _overrides = Map.of(map);
  }

  @override
  Future<Color?> loadGlobalColor() async => _global;

  @override
  Future<void> saveGlobalColor(Color? color) async {
    _global = color;
  }
}

/// Global Provider, kann später durch Persistenz-gestützte Implementierung ersetzt werden.
final appearancePrefsRepositoryProvider = Provider<AppearancePrefsRepository>(
  (ref) => InMemoryAppearancePrefsRepository(),
);
