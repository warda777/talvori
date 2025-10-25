import 'package:flutter/material.dart';

@immutable
class WordsColors extends ThemeExtension<WordsColors> {
  final Color surfaceBg;
  final Color cardBg;

  const WordsColors({required this.surfaceBg, required this.cardBg});

  @override
  WordsColors copyWith({Color? surfaceBg, Color? cardBg}) =>
      WordsColors(surfaceBg: surfaceBg ?? this.surfaceBg, cardBg: cardBg ?? this.cardBg);

  @override
  ThemeExtension<WordsColors> lerp(ThemeExtension<WordsColors>? other, double t) {
    final o = other as WordsColors;
    return WordsColors(
      surfaceBg: Color.lerp(surfaceBg, o.surfaceBg, t)!,
      cardBg: Color.lerp(cardBg, o.cardBg, t)!,
    );
  }
}
