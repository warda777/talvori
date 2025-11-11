import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'palette_controller.dart';
import 'palette_state.dart';

part 'palette_providers.g.dart';

// Hilfs-Selector: Farbe für eine bestimmte Kachel (Override > Global > null)
@riverpod
Color? categoryTint(CategoryTintRef ref, String categoryId) {
  final s = ref.watch(paletteControllerProvider);
  final local = s.overridesByCategory[categoryId];
  if (local != null) return local;
  return s.globalColor;
}

// Optional: UI-Helpers
@riverpod
bool isApplyAll(IsApplyAllRef ref) => ref.watch(
  paletteControllerProvider.select((s) => s.scope == ApplyScope.all),
);
