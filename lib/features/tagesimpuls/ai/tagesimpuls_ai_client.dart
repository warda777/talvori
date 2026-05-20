class TagesimpulsGenerateWord {
  const TagesimpulsGenerateWord({required this.word, this.translation});

  final String word;
  final String? translation;

  Map<String, Object?> toJson() {
    return {
      'word': word,
      if ((translation ?? '').trim().isNotEmpty)
        'translation': translation!.trim(),
    };
  }
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
