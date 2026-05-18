import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_review_history_timeline_item.dart';
import 'package:talvori/core/local_database/models/local_review_visual_feedback.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_word_detail_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_edit_controller_provider.dart';
import 'package:talvori/core/local_database/providers/local_word_review_history_provider.dart';
import 'package:talvori/core/srs/models/learning_mode.dart';
import 'package:talvori/core/srs/models/review_answer.dart';
import 'package:talvori/core/srs/models/srs_stage.dart';
import 'package:talvori/core/srs/models/word_progress.dart';
import 'package:talvori/features/words/ui/screens/local_word_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_edit_screen.dart';

class _FakeLocalWordEditController extends LocalWordEditController {
  static LocalWord? currentWord;

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
    final updatedWord = LocalWord(
      id: wordId,
      categoryId: categoryId,
      term: term,
      translation: translation,
      sortOrder: currentWord?.sortOrder ?? 0,
      isArchived: currentWord?.isArchived ?? false,
      createdAt: currentWord?.createdAt ?? DateTime(2026, 1, 1),
      updatedAt: updatedAt,
    );
    currentWord = updatedWord;
    return updatedWord;
  }
}

void main() {
  final now = DateTime(2026, 1, 1);

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 20,
  }) async {
    for (var i = 0; i < maxPumps; i += 1) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
  }

  Future<void> pumpUntilNotFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 20,
  }) async {
    for (var i = 0; i < maxPumps; i += 1) {
      await tester.pump(const Duration(milliseconds: 50));
      if (finder.evaluate().isEmpty) {
        return;
      }
    }
  }

  LocalWord word({String term = 'hello', String translation = 'hallo'}) {
    return LocalWord(
      id: 'seed-basics-hello',
      categoryId: 'seed-category-basics',
      term: term,
      translation: translation,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpDetail(
    WidgetTester tester, {
    required LocalWordDetailData? detail,
    List<LocalReviewHistoryTimelineItem> history = const [],
  }) async {
    _FakeLocalWordEditController.currentWord = detail?.word;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordDetailProvider.overrideWith((ref, request) async {
            final currentWord = _FakeLocalWordEditController.currentWord;
            if (currentWord == null) return null;
            return LocalWordDetailData(
              word: currentWord,
              progress: detail?.progress,
            );
          }),
          localWordReviewHistoryProvider.overrideWith(
            (ref, request) async => history,
          ),
          localWordEditControllerProvider.overrideWith(
            _FakeLocalWordEditController.new,
          ),
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
    expect(find.text('Noch kein Lernverlauf vorhanden'), findsOneWidget);
  });

  testWidgets('local_word_detail_screen_shows_review_history_items', (
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
          stage: SrsStage.s2,
          passCount: 1,
          wrongCount: 1,
        ),
      ),
      history: [
        LocalReviewHistoryTimelineItem(
          id: 'history-2',
          wordId: 'seed-basics-hello',
          categoryId: 'seed-category-basics',
          reviewedAt: DateTime(2026, 1, 2, 9, 15),
          answer: ReviewAnswer.wrong,
          sourceStage: SrsStage.s3,
          targetStage: SrsStage.s2,
          outcomeType: LocalReviewOutcomeType.demoted,
          repeatIndex: 0,
          description: 'Falsch: S3 -> S2',
          colorValue: 0xFFFF4B6E,
        ),
        LocalReviewHistoryTimelineItem(
          id: 'history-1',
          wordId: 'seed-basics-hello',
          categoryId: 'seed-category-basics',
          reviewedAt: DateTime(2026, 1, 1, 10),
          answer: ReviewAnswer.correct,
          sourceStage: SrsStage.s0,
          targetStage: SrsStage.s1,
          outcomeType: LocalReviewOutcomeType.promoted,
          repeatIndex: 0,
          description: 'Richtig: S0 -> S1',
          colorValue: 0xFF36F58A,
        ),
      ],
    );

    expect(find.text('Verlauf'), findsOneWidget);
    expect(find.text('Insgesamt richtig'), findsOneWidget);
    expect(find.text('Insgesamt falsch'), findsOneWidget);
    expect(find.text('Reviews gesamt'), findsOneWidget);
    expect(find.text('Aktuelle Merkstufe'), findsOneWidget);
    expect(find.text('S2'), findsOneWidget);
    expect(find.text('Falsch: S3 -> S2'), findsOneWidget);
    expect(find.text('Richtig: S0 -> S1'), findsOneWidget);
    expect(find.text('S3 -> S2'), findsOneWidget);
    expect(find.text('S0 -> S1'), findsOneWidget);
    expect(find.text('02.01.2026 09:15'), findsOneWidget);
    expect(find.text('01.01.2026 10:00'), findsOneWidget);
  });

  testWidgets('local_word_detail_screen_shows_missing_state', (tester) async {
    await pumpDetail(tester, detail: null);

    expect(find.text('Lokales Wort nicht gefunden'), findsOneWidget);
  });

  testWidgets('local_word_detail_screen_opens_edit_screen', (tester) async {
    await pumpDetail(
      tester,
      detail: LocalWordDetailData(word: word(), progress: null),
    );

    await tester.tap(find.byTooltip('Bearbeiten'));
    await pumpUntilFound(tester, find.byType(LocalWordEditScreen));

    expect(find.byType(LocalWordEditScreen), findsOneWidget);
  });

  testWidgets('local_word_detail_screen_shows_updated_values_after_save', (
    tester,
  ) async {
    await pumpDetail(
      tester,
      detail: LocalWordDetailData(word: word(), progress: null),
    );

    await tester.tap(find.byTooltip('Bearbeiten'));
    await pumpUntilFound(tester, find.byType(LocalWordEditScreen));
    await tester.enterText(find.widgetWithText(TextFormField, 'Wort'), 'hi');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Übersetzung'),
      'servus',
    );
    await tester.tap(find.text('Speichern'));
    await pumpUntilNotFound(tester, find.byType(LocalWordEditScreen));
    await pumpUntilFound(tester, find.text('hi'));

    expect(find.byType(LocalWordEditScreen), findsNothing);
    expect(find.text('hi'), findsOneWidget);
    expect(find.text('servus'), findsOneWidget);
    expect(find.text('hello'), findsNothing);
    expect(find.text('hallo'), findsNothing);
  });
}
