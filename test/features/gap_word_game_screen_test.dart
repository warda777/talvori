import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/gap_word_game_screen.dart';

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
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
        ],
        child: const MaterialApp(home: GapWordGameScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  test(
    'buildGapWordRoundWords keeps only words with at least four letters',
    () {
      final words = buildGapWordRoundWords([
        word(id: 'cat', term: 'cat'),
        word(id: 'haus', term: 'Haus'),
        word(id: 'same', term: 'haus'),
        word(id: 'archived', term: 'rescue', isArchived: true),
      ]);

      expect(words.map((word) => word.id), ['haus']);
    },
  );

  test('buildGapWordPattern keeps first letter visible and creates gaps', () {
    final pattern = buildGapWordPattern('Haus');

    expect(pattern.startsWith('H'), isTrue);
    expect(pattern.contains('_'), isTrue);
    expect(pattern.replaceAll(' ', ''), isNot('Haus'));
  });

  test('normalizes simple answer comparison', () {
    expect(normalizeGapWordAnswer('  Hello   World  '), 'hello world');
  });

  testWidgets('shows empty state when no matching words are available', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [
        word(id: 'cat', term: 'cat'),
        word(id: 'sun', term: 'sun'),
      ],
    );

    expect(find.text('Noch keine passenden Wörter'), findsOneWidget);
    expect(
      find.text(
        'Füge Wörter mit mindestens vier Buchstaben hinzu, um Lückenwort zu spielen.',
      ),
      findsOneWidget,
    );
    expect(find.text('Zurück'), findsOneWidget);
  });

  testWidgets('shows gap word without revealing full term first', (
    tester,
  ) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    expect(find.byKey(const ValueKey('gap-word-pattern-text')), findsOneWidget);
    expect(find.text('emergency'), findsNothing);
    expect(find.text('Hinweis: Notfall'), findsOneWidget);
  });

  testWidgets('correct answer is accepted and reveals word', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    await tester.enterText(
      find.byKey(const ValueKey('gap-word-answer-field')),
      '  EMERGENCY  ',
    );
    await tester.tap(find.byKey(const ValueKey('gap-word-check-button')));
    await tester.pump();

    expect(find.text('Richtig!'), findsOneWidget);
    expect(find.text('Vollständiges Wort'), findsOneWidget);
    expect(find.text('emergency'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('wrong answer shows neutral feedback', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    await tester.enterText(
      find.byKey(const ValueKey('gap-word-answer-field')),
      'rescue',
    );
    await tester.tap(find.byKey(const ValueKey('gap-word-check-button')));
    await tester.pump();

    expect(find.text('Fast. Versuch es nochmal.'), findsOneWidget);
    expect(find.text('emergency'), findsNothing);
  });

  testWidgets('reveal shows full word', (tester) async {
    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    await tester.tap(find.byKey(const ValueKey('gap-word-reveal-button')));
    await tester.pump();

    expect(find.text('Aufgelöst: emergency'), findsOneWidget);
    expect(find.text('Vollständiges Wort'), findsOneWidget);
    expect(find.text('Nächstes Wort'), findsOneWidget);
  });

  testWidgets('finishes after the last word', (tester) async {
    tester.view.physicalSize = const Size(800, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpGame(
      tester,
      words: [word(id: 'emergency', term: 'emergency')],
    );

    await tester.enterText(
      find.byKey(const ValueKey('gap-word-answer-field')),
      'emergency',
    );
    await tester.tap(find.byKey(const ValueKey('gap-word-check-button')));
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('gap-word-next-button')));
    await tester.pump();

    expect(find.text('Runde beendet'), findsOneWidget);
    expect(
      find.text('Du hast 1 von 1 Wörtern richtig ergänzt.'),
      findsOneWidget,
    );
    expect(find.text('Nochmal spielen'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
  });
}
