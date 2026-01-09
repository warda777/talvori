import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider für die Hauptsprache (Englisch oder Deutsch)
final primaryLanguageProvider = StateNotifierProvider<PrimaryLanguageNotifier, PrimaryLanguage>((ref) {
  return PrimaryLanguageNotifier();
});

enum PrimaryLanguage {
  english, // Englisch ist die Hauptsprache (frontText = englisch, backText = deutsch)
  german,  // Deutsch ist die Hauptsprache (frontText = deutsch, backText = englisch)
}

class PrimaryLanguageNotifier extends StateNotifier<PrimaryLanguage> {
  static const String _key = 'primary_language';

  PrimaryLanguageNotifier() : super(PrimaryLanguage.english) {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final langString = prefs.getString(_key);
      if (langString != null) {
        state = langString == 'german' 
            ? PrimaryLanguage.german 
            : PrimaryLanguage.english;
      }
    } catch (_) {
      // Bei Fehler: Default (Englisch) verwenden
    }
  }

  Future<void> setLanguage(PrimaryLanguage language) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, language == PrimaryLanguage.german ? 'german' : 'english');
      state = language;
    } catch (_) {
      // Bei Fehler: State trotzdem aktualisieren
      state = language;
    }
  }
}

