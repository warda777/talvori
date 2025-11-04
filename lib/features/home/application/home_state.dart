import 'package:flutter/foundation.dart';

@immutable
class HomeState {
  final bool imageExpanded;
  final bool imageIsDark;
  final bool categoriesActive;
  final int myWordsCount;
  final bool glowEnabled;

  const HomeState({
    this.imageExpanded = false,
    this.imageIsDark = false,
    this.categoriesActive = false,
    this.myWordsCount = 0,
    this.glowEnabled = true, // Default: Glow ist aktiviert
  });

  HomeState copyWith({
    bool? imageExpanded,
    bool? imageIsDark,
    bool? categoriesActive,
    int? myWordsCount,
    bool? glowEnabled,
  }) {
    return HomeState(
      imageExpanded: imageExpanded ?? this.imageExpanded,
      imageIsDark: imageIsDark ?? this.imageIsDark,
      categoriesActive: categoriesActive ?? this.categoriesActive,
      myWordsCount: myWordsCount ?? this.myWordsCount,
      glowEnabled: glowEnabled ?? this.glowEnabled,
    );
  }
}
