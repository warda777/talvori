import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get dark {
    const seed = Color(0xFF7BB1AA);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      // Farben für .tonal Buttons (IconButton.filledTonal, FilledButton.tonal)
      secondaryContainer: const Color(0xFF2E335A),
      onSecondaryContainer: Colors.white,
      // Farben für normale FilledButtons
      primary: const Color(0xFF7C4DFF),
      onPrimary: Colors.white,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0F0F10),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      chipTheme: const ChipThemeData(side: BorderSide(color: Colors.transparent)),

      // Optional: Standard-Styles
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,        // wirkt auf FilledButton()
          foregroundColor: scheme.onPrimary,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          backgroundColor: scheme.secondaryContainer,   // wirkt auf IconButton.filledTonal
          foregroundColor: scheme.onSecondaryContainer,
        ),
      ),
    );
  }
}