import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/import/shared_text_import_result.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/incoming_shared_text_import_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/services/incoming_shared_text_import_controller.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/core/platform/shared_text_platform_receiver.dart';
import 'package:talvori/features/words/ui/widgets/incoming_shared_text_import_listener.dart';

void main() {
  testWidgets('shows_compact_success_feedback_with_my_words_action', (
    tester,
  ) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.imported,
        message: 'ok',
      ),
    );

    expect(find.text('Wort importiert'), findsOneWidget);
    expect(find.text('Gespeichert in Meine Wörter'), findsOneWidget);
    expect(find.text('Meine Wörter öffnen'), findsOneWidget);
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 3));
    expect(
      find.byKey(const Key('incoming-share-open-my-words-action')),
      findsOneWidget,
    );
  });

  testWidgets('success_feedback_stays_visible_long_enough_to_read', (
    tester,
  ) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.imported,
        message: 'ok',
      ),
    );

    expect(find.text('Gespeichert in Meine Wörter'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2500));
    expect(find.text('Gespeichert in Meine Wörter'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.text('Gespeichert in Meine Wörter'), findsNothing);
  });

  testWidgets('shows_duplicate_feedback_with_my_words_action', (tester) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.duplicate,
        message: 'duplicate',
      ),
    );

    expect(find.text('Bereits vorhanden'), findsOneWidget);
    expect(
      find.text('Dieses Wort ist bereits in Meine Wörter.'),
      findsOneWidget,
    );
    expect(find.text('Meine Wörter öffnen'), findsOneWidget);
  });

  testWidgets('shows_invalid_feedback_without_my_words_action', (tester) async {
    await _pumpListener(
      tester,
      result: const SharedTextImportResult(
        status: SharedTextImportStatus.invalid,
        message: 'Bitte markiere für Phase 1 nur ein einzelnes Wort.',
      ),
    );

    expect(find.text('Import nicht möglich'), findsOneWidget);
    expect(
      find.text('Bitte markiere für Phase 1 nur ein einzelnes Wort.'),
      findsOneWidget,
    );
    expect(find.text('Meine Wörter öffnen'), findsNothing);
  });

  testWidgets('refreshes_my_words_after_successful_share_import', (
    tester,
  ) async {
    var words = <LocalWord>[_word(id: 'word-old', term: 'old')];
    final receiver = _FakeSharedTextPlatformReceiver(initialText: 'newword');
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        words = [...words, _word(id: 'word-new', term: rawText.toLowerCase())];
        return SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: 'ok',
          word: words.last,
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingSharedTextImportControllerProvider.overrideWith(
            (ref) async => controller,
          ),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            expect(categoryId, localMyWordsCategoryId);
            return words;
          }),
          localWordCountProvider.overrideWith((ref, categoryId) async {
            expect(categoryId, localMyWordsCategoryId);
            return words.length;
          }),
        ],
        child: MaterialApp(
          home: IncomingSharedTextImportListener(
            child: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final wordsAsync = ref.watch(
                    localWordsForCategoryProvider(localMyWordsCategoryId),
                  );
                  return Text(
                    wordsAsync.maybeWhen(
                      data: (items) => 'Wörter: ${items.length}',
                      orElse: () => 'Wörter: ...',
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    expect(find.text('Wörter: 1'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Wort importiert'), findsOneWidget);
    expect(find.text('Wörter: 2'), findsOneWidget);
  });

  testWidgets('handles_multiple_incoming_share_events_in_sequence', (
    tester,
  ) async {
    final receiver = _FakeSharedTextPlatformReceiver();
    final imported = <String>[];
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        imported.add(rawText);
        return SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: rawText,
          word: _word(id: 'word-$rawText', term: rawText),
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingSharedTextImportControllerProvider.overrideWith(
            (ref) async => controller,
          ),
          localWordsForCategoryProvider.overrideWith(
            (ref, categoryId) async => const <LocalWord>[],
          ),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        ],
        child: const MaterialApp(
          home: IncomingSharedTextImportListener(
            child: Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );
    await tester.pump();

    receiver.addPayload(const SharedTextPayload(id: 'share-1', text: 'river'));
    await tester.pump(const Duration(milliseconds: 350));
    receiver.addPayload(const SharedTextPayload(id: 'share-2', text: 'river'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(imported, ['river', 'river']);
    expect(find.text('Wort importiert'), findsOneWidget);
  });

  testWidgets('shows_summary_for_multiple_queued_initial_shares', (
    tester,
  ) async {
    final receiver = _FakeSharedTextPlatformReceiver(
      initialPayloads: const [
        SharedTextPayload(id: 'queued-1', text: 'river'),
        SharedTextPayload(id: 'queued-2', text: 'forest'),
        SharedTextPayload(id: 'queued-3', text: 'river'),
      ],
    );
    final seen = <String>{};
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        final isNew = seen.add(rawText);
        return SharedTextImportResult(
          status: isNew
              ? SharedTextImportStatus.imported
              : SharedTextImportStatus.duplicate,
          message: rawText,
          word: _word(id: 'word-$rawText', term: rawText),
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingSharedTextImportControllerProvider.overrideWith(
            (ref) async => controller,
          ),
          localWordsForCategoryProvider.overrideWith(
            (ref, categoryId) async => const <LocalWord>[],
          ),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        ],
        child: const MaterialApp(
          home: IncomingSharedTextImportListener(
            child: Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('2 Wörter gespeichert'), findsOneWidget);
    expect(
      find.text('1 bereits vorhanden · Übersetzung läuft im Hintergrund'),
      findsOneWidget,
    );
    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.duration, const Duration(seconds: 3));
  });

  testWidgets('multiple_all_new_initial_shares_show_saved_count', (
    tester,
  ) async {
    final receiver = _FakeSharedTextPlatformReceiver(
      initialPayloads: const [
        SharedTextPayload(id: 'queued-1', text: 'river'),
        SharedTextPayload(id: 'queued-2', text: 'forest'),
        SharedTextPayload(id: 'queued-3', text: 'mountain'),
      ],
    );
    final controller = IncomingSharedTextImportController(
      receiver: receiver,
      importText: ({required rawText, required now}) async {
        return SharedTextImportResult(
          status: SharedTextImportStatus.imported,
          message: rawText,
          word: _word(id: 'word-$rawText', term: rawText),
        );
      },
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          incomingSharedTextImportControllerProvider.overrideWith(
            (ref) async => controller,
          ),
          localWordsForCategoryProvider.overrideWith(
            (ref, categoryId) async => const <LocalWord>[],
          ),
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
        ],
        child: const MaterialApp(
          home: IncomingSharedTextImportListener(
            child: Scaffold(body: SizedBox.expand()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('3 Wörter gespeichert'), findsOneWidget);
    expect(
      find.text(
        'Gespeichert in Meine Wörter · Übersetzung läuft im Hintergrund',
      ),
      findsOneWidget,
    );
  });
}

Future<void> _pumpListener(
  WidgetTester tester, {
  required SharedTextImportResult result,
}) async {
  final receiver = _FakeSharedTextPlatformReceiver(initialText: 'hello');
  final controller = IncomingSharedTextImportController(
    receiver: receiver,
    importText: ({required rawText, required now}) async => result,
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        incomingSharedTextImportControllerProvider.overrideWith(
          (ref) async => controller,
        ),
      ],
      child: const MaterialApp(
        home: IncomingSharedTextImportListener(
          child: Scaffold(body: SizedBox.expand()),
        ),
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 350));
}

class _FakeSharedTextPlatformReceiver implements SharedTextPlatformReceiver {
  _FakeSharedTextPlatformReceiver({this.initialText, this.initialPayloads});

  final String? initialText;
  final List<SharedTextPayload>? initialPayloads;
  final _events = StreamController<List<SharedTextPayload>>.broadcast();

  void addPayload(SharedTextPayload payload) => _events.add([payload]);

  @override
  Future<List<SharedTextPayload>> getInitialSharedPayloads() async {
    final payloads = initialPayloads;
    if (payloads != null) return payloads;
    final text = initialText;
    if (text == null) return const [];
    return [SharedTextPayload(id: 'initial-1', text: text)];
  }

  @override
  Future<SharedTextPayload?> getInitialSharedPayload() async {
    final payloads = await getInitialSharedPayloads();
    return payloads.isEmpty ? null : payloads.first;
  }

  @override
  Future<String?> getInitialSharedText() async => initialText;

  @override
  Stream<SharedTextPayload> watchSharedPayload() {
    return watchSharedPayloads().expand((payloads) => payloads);
  }

  @override
  Stream<List<SharedTextPayload>> watchSharedPayloads() => _events.stream;

  @override
  Stream<String> watchSharedText() {
    return watchSharedPayload().map((payload) => payload.text);
  }
}

LocalWord _word({required String id, required String term}) {
  final now = DateTime(2026, 5, 19);
  return LocalWord(
    id: id,
    categoryId: localMyWordsCategoryId,
    term: term,
    translation: '',
    translationStatus: TranslationStatus.pending,
    sourceLanguage: 'en',
    targetLanguage: 'de',
    translationError: null,
    sortOrder: 0,
    isArchived: false,
    createdAt: now,
    updatedAt: now,
  );
}
