import 'package:flutter/material.dart';

enum ApplyScope { single, all }

enum PaletteTarget { stroke, glow, tileBg, hubBg, icons, text, image }

class PaletteState {
  const PaletteState({
    required this.selectedColor,
    required this.scope,
    required this.isDragging,
    required this.hoveredCategoryId,
    required this.overridesByCategory, // categoryId -> Color
    required this.globalColor, // wenn scope==all
    this.target = PaletteTarget.stroke,
  });

  final Color selectedColor;
  final ApplyScope scope;
  final bool isDragging;
  final String? hoveredCategoryId;
  final Map<String, Color> overridesByCategory;
  final Color? globalColor;
  final PaletteTarget target;

  PaletteState copyWith({
    Color? selectedColor,
    ApplyScope? scope,
    bool? isDragging,
    String? hoveredCategoryId,
    Map<String, Color>? overridesByCategory,
    Color? globalColor,
    PaletteTarget? target,
  }) {
    return PaletteState(
      selectedColor: selectedColor ?? this.selectedColor,
      scope: scope ?? this.scope,
      isDragging: isDragging ?? this.isDragging,
      hoveredCategoryId: hoveredCategoryId,
      overridesByCategory: overridesByCategory ?? this.overridesByCategory,
      globalColor: globalColor,
      target: target ?? this.target,
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
