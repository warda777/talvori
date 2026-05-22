import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../platform/shared_text_platform_receiver.dart';
import '../import/shared_text_import_result.dart';
import '../models/local_word.dart';
import '../models/translation_status.dart';
import 'pending_translation_processor.dart';

typedef SharedTextImporter =
    Future<SharedTextImportResult> Function({
      required String rawText,
      required DateTime now,
    });

typedef NowFactory = DateTime Function();
typedef SharedWordTranslator =
    Future<PendingTranslationProcessorResult> Function({
      required String wordId,
    });
typedef SharedWordTranslationSettled =
    void Function(String wordId, PendingTranslationProcessorResult result);
typedef SharedWordSourceSaver =
    Future<void> Function({
      required LocalWord word,
      required SharedTextPayload payload,
      required DateTime now,
    });

class IncomingSharedTextImportController {
  IncomingSharedTextImportController({
    required SharedTextPlatformReceiver receiver,
    required SharedTextImporter importText,
    SharedWordTranslator? translateWord,
    SharedWordTranslationSettled? onTranslationSettled,
    SharedWordSourceSaver? saveWordSource,
    NowFactory now = DateTime.now,
  }) : _receiver = receiver,
       _importText = importText,
       _translateWord = translateWord,
       _onTranslationSettled = onTranslationSettled,
       _saveWordSource = saveWordSource,
       _now = now;

  final SharedTextPlatformReceiver _receiver;
  final SharedTextImporter _importText;
  final SharedWordTranslator? _translateWord;
  final SharedWordTranslationSettled? _onTranslationSettled;
  final SharedWordSourceSaver? _saveWordSource;
  final NowFactory _now;
  final Set<String> _processedPayloadIds = <String>{};
  final Set<String> _activeTranslations = <String>{};

  Future<SharedTextImportResult?> importInitialSharedText() async {
    final payload = await _receiver.getInitialSharedPayload();
    if (payload == null) return null;
    return importSharedPayload(payload);
  }

  Stream<SharedTextImportResult> watchIncomingSharedText() {
    return _receiver
        .watchSharedPayload()
        .asyncMap(importSharedPayload)
        .where((result) => result != null)
        .cast<SharedTextImportResult>();
  }

  Future<SharedTextImportResult> importSharedText(String rawText) async {
    final result = await _importText(rawText: rawText, now: _now());
    _scheduleAutoTranslation(result.word);
    return result;
  }

  Future<SharedTextImportResult?> importSharedPayload(
    SharedTextPayload payload,
  ) async {
    if (!payload.id.startsWith('legacy:') &&
        !_processedPayloadIds.add(payload.id)) {
      debugPrint('Talvori Flutter ignored duplicate share id=${payload.id}');
      return null;
    }
    final now = _now();
    final result = await _importText(rawText: payload.text, now: now);
    await _saveSourceIfPresent(result.word, payload, now);
    _scheduleAutoTranslation(result.word);
    return result;
  }

  Future<void> _saveSourceIfPresent(
    LocalWord? word,
    SharedTextPayload payload,
    DateTime now,
  ) async {
    final saveWordSource = _saveWordSource;
    if (word == null || saveWordSource == null) return;
    if (payload.sourceUrl == null || payload.sourceUrl!.trim().isEmpty) {
      return;
    }
    try {
      await saveWordSource(word: word, payload: payload, now: now);
    } catch (error) {
      debugPrint(
        'Talvori shared word source save failed wordId=${word.id}: $error',
      );
    }
  }

  void _scheduleAutoTranslation(LocalWord? word) {
    final translateWord = _translateWord;
    if (word == null || translateWord == null) return;
    if (word.translationStatus == TranslationStatus.translated) return;
    if (!_activeTranslations.add(word.id)) return;

    unawaited(() async {
      try {
        final result = await translateWord(wordId: word.id);
        _onTranslationSettled?.call(word.id, result);
      } catch (error) {
        debugPrint('Talvori auto translation failed for ${word.id}: $error');
      } finally {
        _activeTranslations.remove(word.id);
      }
    }());
  }
}
