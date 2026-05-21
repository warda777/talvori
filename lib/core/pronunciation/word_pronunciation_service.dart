import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum WordPronunciationStatus { spoken, empty, unavailable, failed }

class WordPronunciationResult {
  const WordPronunciationResult(this.status, {this.message});

  final WordPronunciationStatus status;
  final String? message;

  bool get isSuccess => status == WordPronunciationStatus.spoken;
}

abstract class WordPronunciationService {
  Future<WordPronunciationResult> speakWord(
    String word, {
    String? languageCode,
  });

  Future<void> stop();
}

abstract class TalvoriTtsEngine {
  Future<dynamic> setLanguage(String language);
  Future<dynamic> setPitch(double pitch);
  Future<dynamic> setSpeechRate(double rate);
  Future<dynamic> setVolume(double volume);
  Future<dynamic> speak(String text);
  Future<dynamic> stop();
  Future<dynamic> isLanguageAvailable(String language);
}

class FlutterTtsEngine implements TalvoriTtsEngine {
  FlutterTtsEngine({FlutterTts? tts}) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;

  @override
  Future<dynamic> isLanguageAvailable(String language) {
    return _tts.isLanguageAvailable(language);
  }

  @override
  Future<dynamic> setLanguage(String language) {
    return _tts.setLanguage(language);
  }

  @override
  Future<dynamic> setPitch(double pitch) {
    return _tts.setPitch(pitch);
  }

  @override
  Future<dynamic> setSpeechRate(double rate) {
    return _tts.setSpeechRate(rate);
  }

  @override
  Future<dynamic> setVolume(double volume) {
    return _tts.setVolume(volume);
  }

  @override
  Future<dynamic> speak(String text) {
    return _tts.speak(text);
  }

  @override
  Future<dynamic> stop() {
    return _tts.stop();
  }
}

class FlutterWordPronunciationService implements WordPronunciationService {
  FlutterWordPronunciationService({TalvoriTtsEngine? engine})
    : _engine = engine ?? FlutterTtsEngine();

  final TalvoriTtsEngine _engine;

  @visibleForTesting
  static String localeForLanguage(String? languageCode) {
    final normalized = (languageCode ?? '').trim().toLowerCase();
    if (normalized.isEmpty) return 'en-US';

    final compact = normalized.replaceAll('_', '-');
    if (compact.startsWith('en')) return 'en-US';
    if (compact.startsWith('de')) return 'de-DE';
    if (compact.startsWith('es')) return 'es-ES';
    if (compact.startsWith('fr')) return 'fr-FR';

    switch (compact) {
      case 'english':
      case 'englisch':
        return 'en-US';
      case 'german':
      case 'deutsch':
        return 'de-DE';
      case 'spanish':
      case 'spanisch':
        return 'es-ES';
      case 'french':
      case 'franzoesisch':
      case 'französisch':
        return 'fr-FR';
    }

    return 'en-US';
  }

  @override
  Future<WordPronunciationResult> speakWord(
    String word, {
    String? languageCode,
  }) async {
    final trimmed = word.trim();
    if (trimmed.isEmpty) {
      return const WordPronunciationResult(
        WordPronunciationStatus.empty,
        message: 'Kein Wort zum Vorlesen.',
      );
    }

    final locale = localeForLanguage(languageCode);
    try {
      await _engine.stop();
      var selectedLocale = locale;
      final available = await _engine.isLanguageAvailable(locale);
      if (available == false && locale != 'en-US') {
        final fallbackAvailable = await _engine.isLanguageAvailable('en-US');
        if (fallbackAvailable == false) {
          return const WordPronunciationResult(
            WordPronunciationStatus.unavailable,
            message: 'Aussprache für diese Sprache nicht verfügbar.',
          );
        }
        selectedLocale = 'en-US';
      }

      await _engine.setLanguage(selectedLocale);
      await _engine.setSpeechRate(0.46);
      await _engine.setPitch(1.0);
      await _engine.setVolume(1.0);
      await _engine.speak(trimmed);
      return const WordPronunciationResult(WordPronunciationStatus.spoken);
    } catch (error) {
      debugPrint('Talvori pronunciation failed: $error');
      return const WordPronunciationResult(
        WordPronunciationStatus.failed,
        message: 'Aussprache konnte nicht gestartet werden.',
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _engine.stop();
    } catch (error) {
      debugPrint('Talvori pronunciation stop failed: $error');
    }
  }
}
