import 'package:flutter/foundation.dart';

import '../models/translation_status.dart';
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

  Future<PendingTranslationProcessorResult> processWordTranslation({
    required String wordId,
  }) async {
    final word = await _wordRepository.loadWordById(wordId);
    if (word == null) {
      return const PendingTranslationProcessorResult(
        processed: 0,
        translated: 0,
        failed: 0,
      );
    }

    if (word.translationStatus == TranslationStatus.translated) {
      debugPrint(
        'Talvori auto translation skipped word=${word.term} '
        'reason=already_translated',
      );
      return const PendingTranslationProcessorResult(
        processed: 0,
        translated: 0,
        failed: 0,
      );
    }

    final sourceLanguage = word.sourceLanguage ?? 'en';
    final targetLanguage = word.targetLanguage ?? 'de';

    try {
      debugPrint(
        'Talvori auto translation started word=${word.term} '
        'provider=${_translationClient.runtimeType}',
      );
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
      debugPrint(
        'Talvori translation stored source=${_translationSourceLabel()} '
        'word=${word.term}',
      );
      return const PendingTranslationProcessorResult(
        processed: 1,
        translated: 1,
        failed: 0,
      );
    } catch (error) {
      debugPrint(
        'Talvori translation failed word=${word.term} '
        'reason=${error.runtimeType}',
      );
      await _wordRepository.markTranslationFailed(
        id: word.id,
        error: error.toString(),
        updatedAt: _now(),
      );
      return const PendingTranslationProcessorResult(
        processed: 1,
        translated: 0,
        failed: 1,
      );
    }
  }

  Future<PendingTranslationProcessorResult>
  processPendingAndRetryFailedTranslations({String? categoryId}) async {
    final resetFailed = await _wordRepository.resetFailedTranslationsToPending(
      categoryId: categoryId,
      updatedAt: _now(),
    );
    final result = await processPendingTranslations(categoryId: categoryId);

    return PendingTranslationProcessorResult(
      processed: result.processed,
      translated: result.translated,
      failed: result.failed,
      resetFailed: resetFailed,
    );
  }

  String _translationSourceLabel() {
    final type = _translationClient.runtimeType.toString();
    if (type.contains('Supabase')) return 'supabase';
    if (type.contains('Fake')) return 'test_fake';
    return type;
  }
}

class PendingTranslationProcessorResult {
  const PendingTranslationProcessorResult({
    required this.processed,
    required this.translated,
    required this.failed,
    this.resetFailed = 0,
  });

  final int processed;
  final int translated;
  final int failed;
  final int resetFailed;
}
