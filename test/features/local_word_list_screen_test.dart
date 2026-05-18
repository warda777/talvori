import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_edit_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
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
  }) {
    final now = DateTime(2026, 1, 1);
    return LocalWord(
      id: id,
      categoryId: 'seed-category-basics',
      term: term,
      translation: translation,
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
        ],
        child: MaterialApp(
          home: LocalWordListScreen(
            categoryId: 'seed-category-basics',
            title: title,
          ),
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

  testWidgets('local_word_list_screen_shows_empty_state', (tester) async {
    await pumpLocalWordList(tester, words: const [], title: 'Empty Local');

    expect(find.text('Empty Local'), findsOneWidget);
    expect(find.text('Keine lokalen Wörter verfügbar'), findsOneWidget);
    expect(find.text('empty-local'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_finds_term', (tester) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'ticket');
    await tester.pump();

    expect(find.widgetWithText(ListTile, 'ticket'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Fahrkarte'), findsOneWidget);
    expect(find.text('water'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_finds_translation', (
    tester,
  ) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'Wasser');
    await tester.pump();

    expect(find.widgetWithText(ListTile, 'water'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Wasser'), findsOneWidget);
    expect(find.text('ticket'), findsNothing);
  });

  testWidgets('local_word_list_screen_search_is_case_insensitive', (
    tester,
  ) async {
    await pumpLocalWordList(tester, words: sampleWords());

    await tester.enterText(find.byType(TextField), 'WAS');
    await tester.pump();

    expect(find.widgetWithText(ListTile, 'water'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Wasser'), findsOneWidget);
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

    await tester.tap(find.widgetWithText(ListTile, 'hello'));
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

    expect(find.widgetWithText(ListTile, 'hello'), findsOneWidget);

    words[0] = localWord(
      id: 'seed-basics-hello',
      term: 'hi',
      translation: 'servus',
    );
    await pumpLocalWordList(tester, words: words);

    expect(find.widgetWithText(ListTile, 'hi'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'servus'), findsOneWidget);
    expect(find.text('hello'), findsNothing);
  });
}
