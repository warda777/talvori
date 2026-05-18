import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/features/words/ui/screens/local_word_detail_screen.dart';

void main() {
  final now = DateTime(2026, 1, 1);

  LocalWord word() {
    return LocalWord(
      id: 'seed-basics-hello',
      categoryId: 'seed-category-basics',
      term: 'hello',
      translation: 'hallo',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    required LocalWordDetailData? detail,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordDetailProvider.overrideWith((ref, request) async => detail),
        ],
        child: const MaterialApp(
          home: LocalWordDetailScreen(
            wordId: 'seed-basics-hello',
            categoryId: 'seed-category-basics',
            title: 'Health & Fitness',
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('local_word_detail_screen_shows_word_and_progress', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      detail: LocalWordDetailData(
        word: word(),
        progress: WordProgress(
          wordId: 'seed-basics-hello',
          categoryId: 'seed-category-basics',
          mode: LearningMode.adaptive,
          stage: SrsStage.s3,
          passCount: 4,
          wrongCount: 1,
          lastReviewedAt: DateTime(2026, 1, 2, 10, 30),
          nextDueAt: DateTime(2026, 1, 3, 11),
        ),
      ),
    );

    expect(find.text('Health & Fitness'), findsWidgets);
    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('Lernstatus'), findsOneWidget);
    expect(find.text('Merkstufe'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Richtig-Serie'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('Fehler'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('seed-category-basics'), findsNothing);
  });

  testWidgets('local_word_detail_screen_shows_fallback_without_progress', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      detail: LocalWordDetailData(word: word(), progress: null),
    );

    expect(find.text('hello'), findsOneWidget);
    expect(find.text('hallo'), findsOneWidget);
    expect(find.text('Noch kein Lernfortschritt'), findsOneWidget);
  });

  testWidgets('local_word_detail_screen_shows_missing_state', (tester) async {
    await pumpDetail(tester, detail: null);

    expect(find.text('Lokales Wort nicht gefunden'), findsOneWidget);
  });
}
