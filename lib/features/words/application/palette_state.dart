import 'package:flutter/material.dart';

enum ApplyScope { single, all }

class PaletteState {
  const PaletteState({
    required this.selectedColor,
    required this.scope,
    required this.isDragging,
    required this.hoveredCategoryId,
    required this.overridesByCategory, // categoryId -> Color
    required this.globalColor,         // wenn scope==all
  });

  final Color selectedColor;
  final ApplyScope scope;
  final bool isDragging;
  final String? hoveredCategoryId;
  final Map<String, Color> overridesByCategory;
  final Color? globalColor;

  PaletteState copyWith({
    Color? selectedColor,
    ApplyScope? scope,
    bool? isDragging,
    String? hoveredCategoryId,
    Map<String, Color>? overridesByCategory,
    Color? globalColor,
  }) {
    return PaletteState(
      selectedColor: selectedColor ?? this.selectedColor,
      scope: scope ?? this.scope,
      isDragging: isDragging ?? this.isDragging,
      hoveredCategoryId: hoveredCategoryId,
      overridesByCategory: overridesByCategory ?? this.overridesByCategory,
      globalColor: globalColor,
    );
  }

  factory PaletteState.initial() => PaletteState(
        selectedColor: const Color(0xFFFFC66A), // Gold als Default
        scope: ApplyScope.single,
        isDragging: false,
        hoveredCategoryId: null,
        overridesByCategory: <String, Color>{},
        globalColor: null,
      );
}
