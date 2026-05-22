import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/word_match_game_screen.dart';

void main() {
  LocalWord word({
    required String id,
    required String term,
    required String translation,
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
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
        ],
        child: const MaterialApp(home: WordMatchGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  List<LocalWord> sampleWords() {
    return [
      word(id: 'emergency', term: 'emergency', translation: 'Notfall'),
      word(id: 'shelter', term: 'shelter', translation: 'Schutz'),
      word(id: 'rescue', term: 'rescue', translation: 'Rettung'),
    ];
  }

  test('buildWordMatchPairs keeps only complete unique pairs', () {
    final pairs = buildWordMatchPairs([
      word(id: 'one', term: 'one', translation: 'eins'),
      word(id: 'duplicate-translation', term: 'single', translation: 'eins'),
      word(id: 'missing-translation', term: 'empty', translation: ''),
      word(
        id: 'archived',
        term: 'archived',
        translation: 'archiviert',
        isArchived: true,
      ),
      word(id: 'two', term: 'two', translation: 'zwei'),
    ]);

    expect(pairs.map((pair) => pair.id), ['one', 'two']);
  });

  testWidgets('shows empty state with fewer than three pairs', (tester) async {
    await pumpGame(
      tester,
      words: [
        word(id: 'emergency', term: 'emergency', translation: 'Notfall'),
        word(id: 'shelter', term: 'shelter', translation: 'Schutz'),
      ],
    );

    expect(find.text('Noch nicht genug Wörter'), findsOneWidget);
    expect(
      find.text(
        'Füge mindestens drei Wörter mit Übersetzung hinzu, um Wort-Match zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('correct pair is accepted and marked as matched', (tester) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('word-match-term-emergency')));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('word-match-translation-emergency')),
    );
    await tester.pump();

    expect(find.text('Passt!'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(2));
  });

  testWidgets('wrong pair shows neutral feedback and keeps cards active', (
    tester,
  ) async {
    await pumpGame(tester, words: sampleWords());

    await tester.tap(find.byKey(const ValueKey('word-match-term-emergency')));
    await tester.pump();
    await tester.tap(
      find.byKey(const ValueKey('word-match-translation-shelter')),
    );
    await tester.pump();

    expect(find.text('Nicht ganz. Versuch es nochmal.'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    expect(
      find.byKey(const ValueKey('word-match-term-emergency')),
      findsOneWidget,
    );
  });

  testWidgets('finishes after all pairs are matched', (tester) async {
    await pumpGame(tester, words: sampleWords());

    for (final id in ['emergency', 'shelter', 'rescue']) {
      await tester.tap(find.byKey(ValueKey('word-match-term-$id')));
      await tester.pump();
      await tester.tap(find.byKey(ValueKey('word-match-translation-$id')));
      await tester.pump();
    }

    expect(find.text('Runde geschafft'), findsOneWidget);
    expect(find.text('Du hast alle 3 Wortpaare gefunden.'), findsOneWidget);
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
