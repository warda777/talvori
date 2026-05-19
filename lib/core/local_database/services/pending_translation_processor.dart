import '../repositories/word_repository.dart';
import '../translation/translation_client.dart';

typedef PendingTranslationNowFactory = DateTime Function();

class PendingTranslationProcessor {
  PendingTranslationProcessor({
    required WordRepository wordRepository,
    required TranslationClient translationClient,
    PendingTranslationNowFactory now = DateTime.now,
  }) : _wordRepository = wordRepository,
       _translationClient = translationClient,
       _now = now;

  final WordRepository _wordRepository;
  final TranslationClient _translationClient;
  final PendingTranslationNowFactory _now;

  Future<PendingTranslationProcessorResult> processPendingTranslations({
    String? categoryId,
  }) async {
    final words = await _wordRepository.loadPendingTranslations(
      categoryId: categoryId,
    );
    var translated = 0;
    var failed = 0;

    for (final word in words) {
      final sourceLanguage = word.sourceLanguage ?? 'en';
      final targetLanguage = word.targetLanguage ?? 'de';

      try {
        final result = await _translationClient.translate(
          TranslationRequest(
            text: word.term,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
          ),
        );
        await _wordRepository.updateTranslation(
          id: word.id,
          translation: result.translatedText,
          sourceLanguage: sourceLanguage,
          targetLanguage: targetLanguage,
          updatedAt: _now(),
        );
        translated++;
      } catch (error) {
        await _wordRepository.markTranslationFailed(
          id: word.id,
          error: error.toString(),
          updatedAt: _now(),
        );
        failed++;
      }
    }

    return PendingTranslationProcessorResult(
      processed: words.length,
      translated: translated,
      failed: failed,
    );
  }
}

class PendingTranslationProcessorResult {
  const PendingTranslationProcessorResult({
    required this.processed,
    required this.translated,
    required this.failed,
  });

  final int processed;
  final int translated;
  final int failed;
}
