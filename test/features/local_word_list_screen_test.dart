import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

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

  testWidgets('local_word_list_screen_shows_words_and_translations', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return [
              localWord(
                id: 'seed-basics-hello',
                term: 'hello',
                translation: 'hallo',
              ),
              localWord(
                id: 'seed-basics-water',
                term: 'water',
                translation: 'Wasser',
              ),
            ];
          }),
        ],
        child: const MaterialApp(
          home: LocalWordListScreen(
            categoryId: 'seed-category-basics',
            title: 'Health & Fitness',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('seed-category-basics'), findsNothing);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('water'), findsOneWidget);
    expect(find.text('Wasser'), findsOneWidget);
  });

  testWidgets('local_word_list_screen_shows_empty_state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForCategoryProvider.overrideWith(
            (ref, categoryId) async => const [],
          ),
        ],
        child: const MaterialApp(
          home: LocalWordListScreen(
            categoryId: 'empty-local',
            title: 'Empty Local',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Empty Local'), findsOneWidget);
    expect(find.text('Keine lokalen Wörter verfügbar'), findsOneWidget);
    expect(find.text('empty-local'), findsNothing);
  });
}
