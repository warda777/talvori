import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_service.dart';

class _FakeTtsEngine implements TalvoriTtsEngine {
  final List<String> calls = <String>[];
  bool languageAvailable = true;
  bool throwOnSpeak = false;
  String? language;
  String? spokenText;

  @override
  Future<dynamic> isLanguageAvailable(String language) async {
    calls.add('available:$language');
    return languageAvailable;
  }

  @override
  Future<dynamic> setLanguage(String language) async {
    calls.add('language:$language');
    this.language = language;
  }

  @override
  Future<dynamic> setPitch(double pitch) async {
    calls.add('pitch:$pitch');
  }

  @override
  Future<dynamic> setSpeechRate(double rate) async {
    calls.add('rate:$rate');
  }

  @override
  Future<dynamic> setVolume(double volume) async {
    calls.add('volume:$volume');
  }

  @override
  Future<dynamic> speak(String text) async {
    calls.add('speak:$text');
    if (throwOnSpeak) {
      throw StateError('tts failed');
    }
    spokenText = text;
  }

  @override
  Future<dynamic> stop() async {
    calls.add('stop');
  }
}

void main() {
  test('maps English to en-US and speaks the word', () async {
    final engine = _FakeTtsEngine();
    final service = FlutterWordPronunciationService(engine: engine);

    final result = await service.speakWord(' emergency ', languageCode: 'en');

    expect(result.isSuccess, isTrue);
    expect(engine.language, 'en-US');
    expect(engine.spokenText, 'emergency');
  });

  test('maps German to de-DE', () async {
    final engine = _FakeTtsEngine();
    final service = FlutterWordPronunciationService(engine: engine);

    await service.speakWord('Notfall', languageCode: 'de');

    expect(engine.language, 'de-DE');
  });

  test('falls back for unknown language codes', () async {
    expect(
      FlutterWordPronunciationService.localeForLanguage('klingon'),
      'en-US',
    );
  });

  test('does not throw when the engine fails', () async {
    final engine = _FakeTtsEngine()..throwOnSpeak = true;
    final service = FlutterWordPronunciationService(engine: engine);

    final result = await service.speakWord('hello', languageCode: 'en');

    expect(result.status, WordPronunciationStatus.failed);
    expect(engine.spokenText, isNull);
  });

  test('stop delegates to the engine', () async {
    final engine = _FakeTtsEngine();
    final service = FlutterWordPronunciationService(engine: engine);

    await service.stop();

    expect(engine.calls, contains('stop'));
  });
}
