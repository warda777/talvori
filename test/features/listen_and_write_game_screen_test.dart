import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_service.dart';
import 'package:talvori/features/home/ui/screens/listen_and_write_game_screen.dart';

class _FakePronunciationService implements WordPronunciationService {
  String? spokenWord;
  String? languageCode;

  @override
  Future<WordPronunciationResult> speakWord(
    String word, {
    String? languageCode,
  }) async {
    spokenWord = word;
    this.languageCode = languageCode;
    return const WordPronunciationResult(WordPronunciationStatus.spoken);
  }

  @override
  Future<void> stop() async {}
}

void main() {
  LocalWord word({
    required String id,
    required String term,
    String translation = 'Notfall',
    bool isArchived = false,
  }) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalWord(
      id: id,
      categoryId: LocalLearningSource.myWords.id,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: isArchived,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpGame(
    WidgetTester tester, {
    required List<LocalWord> words,
    WordPronunciationService? pronunciationService,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
          if (pronunciationService != null)
            wordPronunciationServiceProvider.overrideWithValue(
              pronunciationService,
            ),
        ],
        child: const MaterialApp(home: ListenAndWriteGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    final startButton = find.byKey(const ValueKey('listen-write-start-button'));
    if (startButton.evaluate().isNotEmpty) {
      await tester.drag(find.byType(ListView).first, const Offset(0, -520));
      await tester.pumpAndSettle();
      await tester.tap(startButton);
      await tester.pump();
    }
  }

  test('normalizes answers for simple comparison', () {
    expect(normalizeListenAndWriteAnswer('  Hello   World  '), 'hello world');
  });

  testWidgets('shows empty state when no local words are available', (
    tester,
  ) async {
    await pumpGame(tester, words: const <LocalWord>[]);

    expect(find.text('Noch keine Wörter verfügbar'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortquelle braucht Wörter mit einem abfragbaren Begriff, um Hör & Schreib zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('listen button speaks the current local word', (tester) async {
    final pronunciation = _FakePronunciationService();
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
      pronunciationService: pronunciation,
    );

    await tester.tap(find.byKey(const ValueKey('listen-write-listen-button')));
    await tester.pump();

    expect(pronunciation.spokenWord, 'emergency');
    expect(pronunciation.languageCode, 'en');
  });

  testWidgets('correct answer is accepted and reveals the word', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    expect(find.text('emergency'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('listen-write-answer-field')),
      '  EMERGENCY  ',
    );
    await tester.tap(find.byKey(const ValueKey('listen-write-check-button')));
    await tester.pump();

    expect(find.text('Richtig!'), findsOneWidget);
    expect(find.text('Gesuchtes Wort'), findsOneWidget);
    expect(find.text('emergency'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback without progressing', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    await tester.enterText(
      find.byKey(const ValueKey('listen-write-answer-field')),
      'rescue',
    );
    await tester.tap(find.byKey(const ValueKey('listen-write-check-button')));
    await tester.pump();

    expect(find.text('Fast. Versuch es noch einmal.'), findsOneWidget);
    expect(find.text('emergency'), findsNothing);
    expect(find.text('Nächstes Wort'), findsNothing);
  });

  testWidgets('reveal shows the word and allows moving on', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    await tester.tap(find.byKey(const ValueKey('listen-write-reveal-button')));
    await tester.pump();

    expect(find.text('Aufgelöst: emergency'), findsOneWidget);
    expect(find.text('Gesuchtes Wort'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });
}
