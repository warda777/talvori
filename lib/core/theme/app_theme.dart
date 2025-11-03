import 'package:flutter/material.dart';
import 'package:talvori/features/words/ui/theme/theme.dart';

class AppTheme {
  static ThemeData get dark {
    const seed = Color(0xFF7BB1AA);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ).copyWith(
      // Farben für .tonal Buttons (IconButton.filledTonal, FilledButton.tonal)
      secondaryContainer: const Color(0xFF2F2F3A), // Dunkles Grau für Button-Hintergründe
      onSecondaryContainer: Colors.white,
      // Farben für normale FilledButtons
      primary: const Color(0xFFB0CCFE), // Blau aus Word Wheel
      onPrimary: Colors.white,
    );

    return ThemeData(
      brightness: Brightness.dark,
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
        leadingWidth: 56, // Standard Breite für Back-Button
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
          // Kein backgroundColor für normale IconButtons - nur Icon, große Tapfläche
          foregroundColor: scheme.onSecondaryContainer,
        ),
      ),
      
      // WordsColors ThemeExtension
      extensions: const [
        WordsColors(
          surfaceBg: Colors.black, // Gleiche Farbe wie scaffoldBackgroundColor
          cardBg: Color(0xFF2D2D2F),
        ),
      ],
    );
  }
}