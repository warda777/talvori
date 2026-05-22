import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/repositories/category_repository.dart';
import 'package:talvori/core/local_database/repositories/word_repository.dart';
import 'package:talvori/core/local_database/repositories/word_source_repository.dart';
import 'package:talvori/core/local_database/services/incoming_shared_text_import_controller.dart';
import 'package:talvori/core/local_database/services/pending_translation_processor.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';

void main() {
  sqfliteFfiInit();

  final now = DateTime(2026, 5, 18, 12);

  test('imports_initial_shared_text', () async {
    final receiver = _FakeSharedTextPlatformReceiver(initialText: 'Umbrella');
    final imported = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        imported.add(rawText);
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final result = await controller.importInitialSharedText();

    expect(result?.status, SharedTextImportStatus.imported);
    expect(imported, ['Umbrella']);
  });

  test('ignores_missing_initial_shared_text', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    var calls = 0;
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        calls++;
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final result = await controller.importInitialSharedText();

    expect(result, isNull);
    expect(calls, 0);
  });

  test('imports_warm_shared_text_events', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    final imported = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        imported.add(rawText);
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final results = <SharedTextImportResult>[];
    final sub = controller.watchIncomingSharedText().listen(results.add);
    receiver.add('river');
    receiver.add('house');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(imported, ['river', 'house']);
    expect(results.map((result) => result.status), [
      SharedTextImportStatus.imported,
      SharedTextImportStatus.imported,
    ]);
  });

  test('ignores_same_ios_share_id_but_accepts_same_text_with_new_id', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    final imported = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        imported.add(rawText);
        return const SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
        );
      },
    );

    final results = <SharedTextImportResult>[];
    final sub = controller.watchIncomingSharedText().listen(results.add);
    receiver.addPayload(const SharedTextPayload(id: 'share-1', text: 'river'));
    receiver.addPayload(const SharedTextPayload(id: 'share-1', text: 'river'));
    receiver.addPayload(const SharedTextPayload(id: 'share-2', text: 'river'));
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(imported, ['river', 'river']);
    expect(results, hasLength(2));
  });

  test('surfaces_duplicate_and_invalid_import_results', () async {
    final receiver = _FakeSharedTextPlatformReceiver(
      initialText: 'hello world',
    );
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        if (rawText.contains(' ')) {
          return const SharedTextImportResult(
            status: SharedTextImportStatus.invalid,
            message: 'invalid',
          );
        }
        return const SharedTextImportResult(
          status: SharedTextImportStatus.duplicate,
          message: 'duplicate',
        );
      },
    );

    final initial = await controller.importInitialSharedText();
    expect(initial?.status, SharedTextImportStatus.invalid);

    final results = <SharedTextImportResult>[];
    final sub = controller.watchIncomingSharedText().listen(results.add);
    receiver.add('house');
    await Future<void>.delayed(Duration.zero);
    await sub.cancel();

    expect(results.single.status, SharedTextImportStatus.duplicate);
  });

  test('imports_android_style_shared_text_with_word_and_url', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await LocalDatabaseSchema.createV1(db);
    final service = SharedTextImportService(
      categoryRepository: CategoryRepository(database: db),
      wordRepository: WordRepository(database: db),
    );
    final receiver = _FakeSharedTextPlatformReceiver(
      initialText: 'hello\nhttps://example.com/article',
    );
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: service.importRawText,
    );

    final result = await controller.importInitialSharedText();

    expect(result?.status, SharedTextImportStatus.imported);
    expect(result?.word?.term, 'hello');
  });

  test(
    'url_only_share_keeps_text_import_result_without_browser_return',
    () async {
      final receiver = _FakeSharedTextPlatformReceiver(
        initialText: 'https://example.com/article',
      );
      final controller = IncomingSharedTextImportController(
        receiver: receiver,
        now: () => now,
        importText: ({required rawText, required now}) async {
          return const SharedTextImportResult(
            status: SharedTextImportStatus.empty,
            message: 'Kein Wort zum Importieren gefunden.',
          );
        },
      );

      final result = await controller.importInitialSharedText();

      expect(result?.status, SharedTextImportStatus.empty);
      expect(result?.message, 'Kein Wort zum Importieren gefunden.');
    },
  );

  test('starts_auto_translation_after_imported_word', () async {
    final receiver = _FakeSharedTextPlatformReceiver(initialText: 'river');
    final translatedWordIds = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        return SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
          word: _word(
            id: 'word-river',
            term: rawText,
            status: TranslationStatus.pending,
          ),
        );
      },
      translateWord: ({required wordId}) async {
        translatedWordIds.add(wordId);
        return const PendingTranslationProcessorResult(
          processed: 1,
          translated: 1,
          failed: 0,
        );
      },
    );

    final result = await controller.importInitialSharedText();
    await Future<void>.delayed(Duration.zero);

    expect(result?.status, SharedTextImportStatus.imported);
    expect(translatedWordIds, ['word-river']);
  });

  test('saves_hidden_source_url_metadata_after_imported_word', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    final savedPayloads = <SharedTextPayload>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        return SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
          word: _word(
            id: 'word-emergency',
            term: rawText,
            status: TranslationStatus.pending,
          ),
        );
      },
      saveWordSource: ({required word, required payload, required now}) async {
        savedPayloads.add(payload);
      },
    );

    await controller.importSharedPayload(
      const SharedTextPayload(
        id: 'share-source-1',
        text: 'emergency',
        sourceUrl: 'https://example.com/article',
        sourceTitle: 'Example',
        sourceApp: 'Safari',
        sharedTextPreview: 'emergency',
      ),
    );

    expect(savedPayloads, hasLength(1));
    expect(savedPayloads.single.sourceUrl, 'https://example.com/article');
  });

  test('does_not_call_source_saver_without_source_url', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    var sourceSaves = 0;
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        return SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
          word: _word(
            id: 'word-river',
            term: rawText,
            status: TranslationStatus.pending,
          ),
        );
      },
      saveWordSource: ({required word, required payload, required now}) async {
        sourceSaves++;
      },
    );

    await controller.importSharedPayload(
      const SharedTextPayload(id: 'share-no-source', text: 'river'),
    );

    expect(sourceSaves, 0);
  });

  test(
    'source_save_failure_does_not_block_word_import_or_translation',
    () async {
      final receiver = _FakeSharedTextPlatformReceiver();
      final translatedWordIds = <String>[];
      final controller = IncomingSharedTextImportController(
        receiver: receiver,
        now: () => now,
        importText: ({required rawText, required now}) async {
          return SharedTextImportResult(
            status: SharedTextImportStatus.imported,
            message: 'ok',
            word: _word(
              id: 'word-river',
              term: rawText,
              status: TranslationStatus.pending,
            ),
          );
        },
        saveWordSource:
            ({required word, required payload, required now}) async {
              throw StateError('source storage unavailable');
            },
        translateWord: ({required wordId}) async {
          translatedWordIds.add(wordId);
          return const PendingTranslationProcessorResult(
            processed: 1,
            translated: 1,
            failed: 0,
          );
        },
      );

      final result = await controller.importSharedPayload(
        const SharedTextPayload(
          id: 'share-source-error',
          text: 'river',
          sourceUrl: 'https://example.com/river',
        ),
      );
      await Future<void>.delayed(Duration.zero);

      expect(result?.status, SharedTextImportStatus.imported);
      expect(translatedWordIds, ['word-river']);
    },
  );

  test('duplicate_word_with_new_source_url_saves_second_source', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    await LocalDatabaseSchema.createV1(db);
    final importService = SharedTextImportService(
      categoryRepository: CategoryRepository(database: db),
      wordRepository: WordRepository(database: db),
    );
    final sourceRepository = WordSourceRepository(database: db);
    final controller = IncomingSharedTextImportController(
      receiver: _FakeSharedTextPlatformReceiver(),
      now: () => now,
      importText: importService.importRawText,
      saveWordSource: ({required word, required payload, required now}) async {
        await sourceRepository.saveSource(
          wordId: word.id,
          sourceUrl: payload.sourceUrl!,
          sourceTitle: payload.sourceTitle,
          sourceApp: payload.sourceApp,
          sharedTextPreview: payload.sharedTextPreview,
          createdAt: payload.createdAt ?? now,
        );
      },
    );

    await controller.importSharedPayload(
      SharedTextPayload(
        id: 'share-a',
        text: 'emergency',
        sourceUrl: 'https://example.com/a',
        createdAt: DateTime(2026, 5, 18, 12),
      ),
    );
    await controller.importSharedPayload(
      SharedTextPayload(
        id: 'share-b',
        text: 'emergency',
        sourceUrl: 'https://example.com/b',
        createdAt: DateTime(2026, 5, 18, 12, 1),
      ),
    );
    await controller.importSharedPayload(
      SharedTextPayload(
        id: 'share-c',
        text: 'emergency',
        sourceUrl: 'https://example.com/a',
        createdAt: DateTime(2026, 5, 18, 12, 2),
      ),
    );

    final sources = await sourceRepository.loadSourcesForWord(
      'local-my-words-emergency',
    );
    expect(sources.map((source) => source.sourceUrl), [
      'https://example.com/b',
      'https://example.com/a',
    ]);
  });

  test('skips_auto_translation_for_already_translated_duplicate', () async {
    final receiver = _FakeSharedTextPlatformReceiver(initialText: 'house');
    var translationCalls = 0;
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        return SharedTextImportResult(
          status: SharedTextImportStatus.duplicate,
          message: 'duplicate',
          word: _word(
            id: 'word-house',
            term: rawText,
            status: TranslationStatus.translated,
            translation: 'Haus',
          ),
        );
      },
      translateWord: ({required wordId}) async {
        translationCalls++;
        return const PendingTranslationProcessorResult(
          processed: 0,
          translated: 0,
          failed: 0,
        );
      },
    );

    final result = await controller.importInitialSharedText();
    await Future<void>.delayed(Duration.zero);

    expect(result?.status, SharedTextImportStatus.duplicate);
    expect(translationCalls, 0);
  });

  test('does_not_start_parallel_auto_translation_for_same_word', () async {
    final receiver = _FakeSharedTextPlatformReceiver();
    final completer = Completer<PendingTranslationProcessorResult>();
    var translationCalls = 0;
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      now: () => now,
      importText: ({required rawText, required now}) async {
        return SharedTextImportResult(
          status: SharedTextImportStatus.duplicate,
          message: 'duplicate',
          word: _word(
            id: 'word-river',
            term: rawText,
            status: TranslationStatus.pending,
          ),
        );
      },
      translateWord: ({required wordId}) {
        translationCalls++;
        return completer.future;
      },
    );

    final first = controller.importSharedText('river');
    final second = controller.importSharedText('river');
    await Future.wait([first, second]);
    await Future<void>.delayed(Duration.zero);
    completer.complete(
      const PendingTranslationProcessorResult(
        processed: 1,
        translated: 1,
        failed: 0,
      ),
    );
    await Future<void>.delayed(Duration.zero);

    expect(translationCalls, 1);
  });
}

class _FakeSharedTextPlatformReceiver implements SharedTextPlatformReceiver {
  _FakeSharedTextPlatformReceiver({this.initialText});

  final String? initialText;
  final _events = StreamController<SharedTextPayload>.broadcast();

  void add(String text) {
    _events.add(SharedTextPayload(id: 'legacy:${text.hashCode}', text: text));
  }

  void addPayload(SharedTextPayload payload) => _events.add(payload);

  @override
  Future<SharedTextPayload?> getInitialSharedPayload() async {
    final text = initialText;
    if (text == null) return null;
    return SharedTextPayload(id: 'initial-1', text: text);
  }

  @override
  Future<String?> getInitialSharedText() async => initialText;

  @override
  Stream<SharedTextPayload> watchSharedPayload() => _events.stream;

  @override
  Stream<String> watchSharedText() {
    return _events.stream.map((payload) => payload.text);
  }
}

LocalWord _word({
  required String id,
  required String term,
  required TranslationStatus status,
  String translation = '',
}) {
  final now = DateTime(2026, 5, 18, 12);
  return LocalWord(
    id: id,
    categoryId: localMyWordsCategoryId,
    term: term,
    translation: translation,
    translationStatus: status,
    sourceLanguage: 'en',
    targetLanguage: 'de',
    translationError: null,
    sortOrder: 0,
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );
}
