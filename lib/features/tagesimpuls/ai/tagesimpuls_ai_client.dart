class TagesimpulsGenerateWord {
  const TagesimpulsGenerateWord({required this.word, this.translation});

  final String word;
  final String? translation;

  String get payloadWord => normalizeTagesimpulsPayloadWord(word);

  bool get hasPayloadWord => payloadWord.isNotEmpty;

  Map<String, Object?> toJson() {
    final normalizedWord = payloadWord;
    return {
      'word': normalizedWord,
      if ((translation ?? '').trim().isNotEmpty)
        'translation': translation!.trim(),
    };
  }
}

String normalizeTagesimpulsPayloadWord(String value) {
  final lines = value
      .split(RegExp(r'[\r\n]+'))
      .map(_stripUrlsAndNormalizeWhitespace)
      .where((line) => line.isNotEmpty);

  final firstLine = lines.isNotEmpty ? lines.first : '';
  if (firstLine.isNotEmpty) return firstLine;

  return _stripUrlsAndNormalizeWhitespace(value);
}

String _stripUrlsAndNormalizeWhitespace(String value) {
  return value
      .replaceAll(RegExp(r'https?:\/\/\S+', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'www\.\S+', caseSensitive: false), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

class TagesimpulsGenerateRequest {
  const TagesimpulsGenerateRequest({
    required this.words,
    this.count = 1,
    this.language = 'EN',
    this.style = 'natural_message',
  });

  final List<TagesimpulsGenerateWord> words;
  final int count;
  final String language;
  final String style;
}

class TagesimpulsGeneratedImpulse {
  const TagesimpulsGeneratedImpulse({
    required this.slot,
    required this.message,
    required this.usedWords,
  });

  final String slot;
  final String message;
  final List<String> usedWords;
}

class TagesimpulsGenerateResult {
  const TagesimpulsGenerateResult({required this.impulses});

  final List<TagesimpulsGeneratedImpulse> impulses;
}

enum TagesimpulsGenerationStatus {
  idle,
  aiClientNotConfigured,
  functionCallFailed,
  quotaExceeded,
  invalidAiResponse,
  noImpulsesReturned,
  notEnoughWords,
  wordsRequired,
  generationSucceeded,
}

class TagesimpulsAiException implements Exception {
  const TagesimpulsAiException(this.code);

  final String code;

  @override
  String toString() => 'TagesimpulsAiException: $code';
}

abstract interface class TagesimpulsAiClient {
  Future<TagesimpulsGenerateResult> generate(
    TagesimpulsGenerateRequest request,
  );
}
