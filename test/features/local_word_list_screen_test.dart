import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_translation_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_edit_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/services/pending_translation_processor.dart';
import 'package:talvori/core/local_database/services/shared_text_import_service.dart';
import 'package:talvori/features/words/ui/screens/local_word_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

class _FakeLocalWordEditController extends LocalWordEditController {
  static List<LocalWord> words = const <LocalWord>[];

  @override
  LocalWordEditControllerState build() {
    return const LocalWordEditControllerState();
  }

  @override
  Future<LocalWord?> updateWord({
    required String wordId,
    required String categoryId,
    required String term,
    required String translation,
    required DateTime updatedAt,
  }) async {
    for (var i = 0; i < words.length; i += 1) {
      final word = words[i];
      if (word.id == wordId) {
        final updatedWord = LocalWord(
          id: word.id,
          categoryId: word.categoryId,
          term: term,
          translation: translation,
          translationStatus: translation.trim().isEmpty
              ? TranslationStatus.pending
              : TranslationStatus.translated,
          sourceLanguage: word.sourceLanguage,
          targetLanguage: word.targetLanguage,
          translationError: null,
          sortOrder: word.sortOrder,
          isArchived: word.isArchived,
          createdAt: word.createdAt,
          updatedAt: updatedAt,
        );
        words[i] = updatedWord;
        return updatedWord;
      }
    }

    return null;
  }
}

void main() {
  LocalWord localWord({
    required String id,
    required String term,
    required String translation,
    TranslationStatus translationStatus = TranslationStatus.translated,
    String? translationError,
  }) {
    final now = DateTime(2026, 1, 1);
    return LocalWord(
      id: id,
      categoryId: 'seed-category-basics',
      term: term,
      translation: translation,
      translationStatus: translationStatus,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      translationError: translationError,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpLocalWordList(
    WidgetTester tester, {
    required List<LocalWord> words,
    String title = 'Health & Fitness',
    PendingTranslationRunner? translationRunner,
    String categoryId = 'seed-category-basics',
  }) async {
    _FakeLocalWordEditController.words = words;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForCategoryProvider.overrideWith(
            (ref, categoryId) async => words,
          ),
          localWordDetailProvider.overrideWith((ref, request) async {
            LocalWord? selectedWord;
            for (final word in words) {
              if (word.id == request.wordId) {
                selectedWord = word;
                break;
              }
            }
            final word = selectedWord;
            if (word == null) return null;
            return LocalWordDetailData(word: word, progress: null);
          }),
          localWordEditControllerProvider.overrideWith(
            _FakeLocalWordEditController.new,
          ),
          if (translationRunner != null)
            pendingTranslationRunnerProvider.overrideWith(
              (ref) async => translationRunner,
            ),
        ],
        child: MaterialApp(
          home: LocalWordListScreen(categoryId: categoryId, title: title),
        ),
      ),
    );

    await tester.pump();
  }

  List<LocalWord> sampleWords() {
    return [
      localWord(id: 'seed-basics-water', term: 'water', translation: 'Wasser'),
      localWord(id: 'seed-basics-apple', term: 'apple', translation: 'Apfel'),
      localWord(
        id: 'seed-basics-ticket',
        term: 'ticket',
        translation: 'Fahrkarte',
      ),
    ];
  }

  double topOf(String text, WidgetTester tester) {
    return tester.getTopLeft(find.text(text)).dy;
  }

  testWidgets('local_word_list_screen_shows_words_and_translations', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: [
        localWord(id: 'seed-basics-hello', term: 'hello', translation: 'hallo'),
        localWord(
          id: 'seed-basics-water',
          term: 'water',
          translation: 'Wasser',
        ),
      ],
    );

    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('seed-category-basics'), findsNothing);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Sortierung'), findsOneWidget);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('water'), findsOneWidget);
    expect(find.text('Wasser'), findsOneWidget);
  });

  testWidgets('local_word_list_screen_shows_pending_translation_status', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: [
        localWord(
          id: 'word-pending',
          term: 'umbrella',
          translation: '',
          translationStatus: TranslationStatus.pending,
        ),
      ],
    );

    expect(find.text('umbrella'), findsWidgets);
    expect(find.text('Noch keine Übersetzung'), findsOneWidget);
    expect(find.text('Übersetzung ausstehend'), findsOneWidget);
  });

  testWidgets(
    'local_word_list_screen_shows_manual_translation_button_for_pending_words',
    (tester) async {
      await pumpLocalWordList(
        tester,
        words: [
          localWord(
            id: 'word-pending',
            term: 'umbrella',
            translation: '',
            translationStatus: TranslationStatus.pending,
          ),
        ],
      );

      expect(
        find.text('Ausstehende Übersetzungen verarbeiten (1)'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'local_word_list_screen_hides_manual_translation_button_without_pending_words',
    (tester) async {
      await pumpLocalWordList(
        tester,
        words: [
          localWord(id: 'word-translated', term: 'hello', translation: 'hallo'),
        ],
      );

      expect(
        find.textContaining('Ausstehende Übersetzungen verarbeiten'),
        findsNothing,
      );
    },
  );

  testWidgets(
    'local_word_list_screen_manual_translation_trigger_refreshes_words',
    (tester) async {
      final words = [
        localWord(
          id: 'word-pending',
          term: 'umbrella',
          translation: '',
          translationStatus: TranslationStatus.pending,
        ),
      ];
      var wasTriggered = false;

      await pumpLocalWordList(
        tester,
        words: words,
        translationRunner: ({String? categoryId}) async {
          wasTriggered = true;
          expect(categoryId, 'seed-category-basics');
          words[0] = localWord(
            id: 'word-pending',
            term: 'umbrella',
            translation: 'Regenschirm',
            translationStatus: TranslationStatus.translated,
          );
          return const PendingTranslationProcessorResult(
            processed: 1,
            translated: 1,
            failed: 0,
          );
        },
      );

      await tester.tap(find.text('Ausstehende Übersetzungen verarbeiten (1)'));
      await tester.pumpAndSettle();

      expect(wasTriggered, isTrue);
      expect(find.text('Regenschirm'), findsOneWidget);
      expect(find.text('Übersetzung ausstehend'), findsNothing);
      expect(
        find.text('Übersetzungen verarbeitet: 1 erfolgreich.'),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'local_word_list_screen_manual_translation_error_does_not_crash',
    (tester) async {
      await pumpLocalWordList(
        tester,
        words: [
          localWord(
            id: 'word-pending',
            term: 'umbrella',
            translation: '',
            translationStatus: TranslationStatus.pending,
          ),
        ],
        translationRunner: ({String? categoryId}) async {
          throw StateError('translation unavailable');
        },
      );

      await tester.tap(find.text('Ausstehende Übersetzungen verarbeiten (1)'));
      await tester.pumpAndSettle();

      expect(
        find.text('Übersetzungen konnten nicht verarbeitet werden.'),
        findsOneWidget,
      );
      expect(find.text('Übersetzung ausstehend'), findsOneWidget);
    },
  );

  testWidgets('local_word_list_screen_shows_failed_translation_status', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: [
        localWord(
          id: 'word-failed',
          term: 'umbrella',
          translation: '',
          translationStatus: TranslationStatus.failed,
          translationError: 'offline',
        ),
      ],
    );

    expect(find.text('umbrella'), findsWidgets);
    expect(find.text('Noch keine Übersetzung'), findsOneWidget);
    expect(find.text('Übersetzung fehlgeschlagen'), findsOneWidget);
  });

  testWidgets('local_word_list_screen_shows_translated_word_without_badge', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: [
        localWord(id: 'word-translated', term: 'hello', translation: 'hallo'),
      ],
    );

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('Übersetzung ausstehend'), findsNothing);
    expect(find.text('Übersetzung fehlgeschlagen'), findsNothing);
  });

  testWidgets('local_word_list_screen_shows_empty_state', (tester) async {
    await pumpLocalWordList(tester, words: const [], title: 'Empty Local');

    expect(find.text('Empty Local'), findsOneWidget);
    expect(find.text('Keine lokalen Wörter verfügbar'), findsOneWidget);
    expect(find.text('empty-local'), findsNothing);
  });

  testWidgets('local_word_list_screen_shows_my_words_empty_state', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: const [],
      title: localMyWordsCategoryLabel,
      categoryId: localMyWordsCategoryId,
    );

    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Noch keine eigenen Wörter'), findsOneWidget);
    expect(find.text('Geteilte Wörter erscheinen hier.'), findsOneWidget);
    expect(
      find.text('Lokale Wörter konnten nicht geladen werden'),
      findsNothing,
    );
    expect(find.text('local-category-my-words'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_finds_term', (tester) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'ticket');
    await tester.pump();

    expect(find.text('ticket'), findsWidgets);
    expect(find.text('Fahrkarte'), findsOneWidget);
    expect(find.text('water'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_keeps_pending_status_visible', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: [
        localWord(
          id: 'word-pending',
          term: 'umbrella',
          translation: '',
          translationStatus: TranslationStatus.pending,
        ),
        localWord(id: 'word-water', term: 'water', translation: 'Wasser'),
      ],
    );

    await tester.enterText(find.byType(TextField), 'umbrella');
    await tester.pump();

    expect(find.text('umbrella'), findsWidgets);
    expect(find.text('Übersetzung ausstehend'), findsOneWidget);
    expect(find.text('water'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_finds_translation', (
    tester,
  ) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'Wasser');
    await tester.pump();

    expect(find.text('water'), findsOneWidget);
    expect(find.text('Wasser'), findsWidgets);
    expect(find.text('ticket'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_is_case_insensitive', (
    tester,
  ) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'WAS');
    await tester.pump();

    expect(find.text('water'), findsOneWidget);
    expect(find.text('Wasser'), findsOneWidget);
  });

  testWidgets('local_word_list_screen_search_empty_result_state', (
    tester,
  ) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump();

    expect(find.text('Keine passenden Wörter gefunden'), findsOneWidget);
    expect(find.text('Keine lokalen Wörter verfügbar'), findsNothing);
  });

  testWidgets('local_word_list_screen_sorts_term_az_by_default', (
    tester,
  ) async {
    await pumpLocalWordList(tester, words: sampleWords());

    expect(topOf('apple', tester), lessThan(topOf('ticket', tester)));
    expect(topOf('ticket', tester), lessThan(topOf('water', tester)));
  });

  testWidgets('local_word_list_screen_sorts_term_za', (tester) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.tap(find.text('A–Z nach Wort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z–A nach Wort').last);
    await tester.pumpAndSettle();

    expect(topOf('water', tester), lessThan(topOf('ticket', tester)));
    expect(topOf('ticket', tester), lessThan(topOf('apple', tester)));
  });

  testWidgets('local_word_list_screen_sorts_by_translation', (tester) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.tap(find.text('A–Z nach Wort'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Z–A nach Übersetzung').last);
    await tester.pumpAndSettle();

    expect(topOf('Wasser', tester), lessThan(topOf('Fahrkarte', tester)));
    expect(topOf('Fahrkarte', tester), lessThan(topOf('Apfel', tester)));
  });

  testWidgets('local_word_list_screen_opens_detail_on_word_tap', (
    tester,
  ) async {
    await pumpLocalWordList(
      tester,
      words: [
        localWord(id: 'seed-basics-hello', term: 'hello', translation: 'hallo'),
      ],
    );

    await tester.tap(find.text('hello'));
    await tester.pumpAndSettle();

    expect(find.byType(LocalWordDetailScreen), findsOneWidget);
    expect(find.text('Health & Fitness'), findsWidgets);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('Noch kein Lernfortschritt'), findsOneWidget);
    expect(find.text('seed-category-basics'), findsNothing);
  });

  testWidgets('local_word_list_screen_shows_updated_provider_data', (
    tester,
  ) async {
    final words = [
      localWord(id: 'seed-basics-hello', term: 'hello', translation: 'hallo'),
    ];

    await pumpLocalWordList(tester, words: words);

    expect(find.text('hello'), findsOneWidget);

    words[0] = localWord(
      id: 'seed-basics-hello',
      term: 'hi',
      translation: 'servus',
    );
    await pumpLocalWordList(tester, words: words);

    expect(find.text('hi'), findsOneWidget);
    expect(find.text('servus'), findsOneWidget);
    expect(find.text('hello'), findsNothing);
  });
}
