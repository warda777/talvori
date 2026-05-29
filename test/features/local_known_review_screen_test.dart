import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/features/words/application/local_known_review_controller.dart';
import 'package:talvori/features/words/ui/screens/local_known_review_screen.dart';

void main() {
  final now = DateTime(2026, 5, 29, 11);

  LocalWord word({
    required String id,
    required String term,
    required String translation,
  }) {
    return LocalWord(
      id: id,
      categoryId: 'category-travel-review',
      term: term,
      translation: translation,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpScreen(
    WidgetTester tester,
    LocalKnownReviewState state,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(
            () => _FakeLocalKnownReviewController(state),
          ),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('review screen shows old sort title and category wheel', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      LocalKnownReviewState.empty(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 2,
          ),
        ],
      ),
    );

    expect(find.text('Wörter prüfen'), findsOneWidget);
    expect(find.text('Kennst du sie schon?'), findsOneWidget);
    expect(
      find.byKey(const Key('local-known-review-category-wheel')),
      findsOneWidget,
    );
    expect(find.text('Reisen'), findsOneWidget);
  });

  testWidgets('selected category shows local word wheel', (tester) async {
    await pumpScreen(
      tester,
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 2,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        knownCount: 12345,
        keepLearningCount: 20000,
        words: [
          word(
            id: 'word-ticket-review',
            term: 'ticket',
            translation: 'Fahrkarte',
          ),
          word(id: 'word-hotel-review', term: 'hotel', translation: 'Hotel'),
        ],
        currentIndex: 0,
      ),
    );

    expect(
      find.byKey(const Key('local-known-review-word-wheel')),
      findsOneWidget,
    );
    expect(find.text('ticket'), findsOneWidget);
    expect(find.text('hotel'), findsOneWidget);
  });

  testWidgets('counter filter buttons and source switch are visible', (
    tester,
  ) async {
    await pumpScreen(
      tester,
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 2,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        knownCount: 12345,
        keepLearningCount: 20000,
        words: [
          word(
            id: 'word-ticket-review',
            term: 'ticket',
            translation: 'Fahrkarte',
          ),
        ],
        currentIndex: 0,
      ),
    );

    expect(find.text('Noch lernen'), findsOneWidget);
    expect(find.text('Kenn ich'), findsOneWidget);
    expect(find.text('20.000'), findsOneWidget);
    expect(find.text('12.345'), findsOneWidget);
    expect(
      find.byKey(const Key('local-known-review-keep-learning-count')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('local-known-review-known-count')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('local-known-review-keep-learning-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('local-known-review-known-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('local-known-review-source-menu')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('source switch exposes the three review wheels', (tester) async {
    await pumpScreen(
      tester,
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 2,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: [
          word(
            id: 'word-ticket-review',
            term: 'ticket',
            translation: 'Fahrkarte',
          ),
        ],
        currentIndex: 0,
      ),
    );

    await tester.tap(find.byKey(const Key('local-known-review-source-menu')));
    await tester.pumpAndSettle();

    expect(find.text('Wortwelten'), findsWidgets);
    expect(find.text('Lernlevel'), findsOneWidget);
    expect(find.text('Sprachwerkzeuge'), findsOneWidget);
  });

  testWidgets('mark known records current word without undo snackbar', (
    tester,
  ) async {
    final controller = _FakeLocalKnownReviewController(
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 2,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: [
          word(
            id: 'word-ticket-review',
            term: 'ticket',
            translation: 'Fahrkarte',
          ),
          word(id: 'word-hotel-review', term: 'hotel', translation: 'Hotel'),
        ],
        currentIndex: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('local-known-review-mark-known-button')),
    );
    await tester.pump();

    expect(controller.markedKnownIds, ['word-ticket-review']);
    expect(find.text('hotel'), findsOneWidget);
    expect(find.text('Rückgängig'), findsNothing);
  });

  testWidgets('mark known uses the current centered wheel word', (
    tester,
  ) async {
    final controller = _FakeLocalKnownReviewController(
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 4,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: [
          word(id: 'word-heart-review', term: 'heart', translation: 'Herz'),
          word(id: 'word-sport-review', term: 'sport', translation: 'Sport'),
          word(id: 'word-walk-review', term: 'walk', translation: 'gehen'),
          word(id: 'word-rest-review', term: 'rest', translation: 'Ruhe'),
        ],
        currentIndex: 3,
        keepLearningCount: 4,
        knownCount: 21,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(
      find.byKey(const Key('local-known-review-mark-known-button')),
    );
    await tester.pump();

    expect(controller.markedKnownIds, ['word-rest-review']);
    expect(find.text('rest'), findsNothing);
    expect(find.text('walk'), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('local-known-review-keep-learning-count')),
          )
          .data,
      '4',
    );
  });

  testWidgets('slow wheel movement marks passed word as keep learning', (
    tester,
  ) async {
    final controller = _FakeLocalKnownReviewController(
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 4,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: [
          word(id: 'word-heart-review', term: 'heart', translation: 'Herz'),
          word(id: 'word-sport-review', term: 'sport', translation: 'Sport'),
          word(id: 'word-walk-review', term: 'walk', translation: 'gehen'),
          word(id: 'word-rest-review', term: 'rest', translation: 'Ruhe'),
        ],
        currentIndex: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();

    await tester.drag(
      find.byKey(const Key('local-known-review-word-wheel')),
      const Offset(0, -52),
    );
    await tester.pumpAndSettle();

    expect(controller.keepLearningIds, contains('word-heart-review'));
    expect(controller.centeredWordIds, contains('word-sport-review'));
    expect(
      tester
          .widget<Text>(
            find.byKey(const Key('local-known-review-keep-learning-count')),
          )
          .data,
      '1',
    );
  });

  testWidgets('last wheel word can be completed as keep learning', (
    tester,
  ) async {
    final controller = _FakeLocalKnownReviewController(
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 1,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: [
          word(id: 'word-rest-review', term: 'rest', translation: 'Ruhe'),
        ],
        currentIndex: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();

    await tester.drag(
      find.byKey(const Key('local-known-review-word-wheel')),
      const Offset(0, -52),
    );
    await tester.pumpAndSettle();

    expect(controller.keepLearningIds, contains('word-rest-review'));
    expect(controller.completedCalls, 1);
    expect(find.text('Alles geprüft.'), findsOneWidget);
    expect(
      find.text(
        'Diese Wortwelt hat aktuell keine weiteren aktiven Wörter zum Prüfen.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('category reset button confirms before resetting', (
    tester,
  ) async {
    final controller = _FakeLocalKnownReviewController(
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 0,
            reviewedCount: 1,
            knownCount: 1,
            totalCount: 2,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: const <LocalWord>[],
        currentIndex: 0,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('local-known-review-reset-category-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('local-known-review-restart-category-button')),
      findsNothing,
    );

    await tester.tap(
      find.byKey(const Key('local-known-review-reset-category-button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kategorie zurücksetzen?'), findsOneWidget);
    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();
    expect(controller.resetCalls, 0);

    await tester.tap(
      find.byKey(const Key('local-known-review-reset-category-button')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zurücksetzen'));
    await tester.pumpAndSettle();

    expect(controller.resetCalls, 1);
  });

  testWidgets('undo button restores last known word', (tester) async {
    final controller = _FakeLocalKnownReviewController(
      LocalKnownReviewState(
        categories: const [
          LocalKnownReviewCategory(
            id: 'category-travel-review',
            name: 'Reisen',
            remainingCount: 2,
          ),
        ],
        selectedCategoryId: 'category-travel-review',
        selectedCategoryName: 'Reisen',
        words: [
          word(
            id: 'word-ticket-review',
            term: 'ticket',
            translation: 'Fahrkarte',
          ),
          word(id: 'word-hotel-review', term: 'hotel', translation: 'Hotel'),
        ],
        currentIndex: 0,
        undoDepth: 1,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localKnownReviewControllerProvider.overrideWith(() => controller),
        ],
        child: const MaterialApp(home: LocalKnownReviewScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('local-known-review-undo-button')));
    await tester.pump();

    expect(controller.undoCalls, 1);
  });
}

class _FakeLocalKnownReviewController extends LocalKnownReviewController {
  _FakeLocalKnownReviewController(this.initialState);

  final LocalKnownReviewState initialState;
  final markedKnownIds = <String>[];
  final keepLearningIds = <String>[];
  final centeredWordIds = <String>[];
  int undoCalls = 0;
  int completedCalls = 0;
  int resetCalls = 0;

  @override
  Future<LocalKnownReviewState> build() async => initialState;

  @override
  Future<void> selectCategory(LocalKnownReviewCategory category) async {
    state = AsyncData(
      LocalKnownReviewState(
        categories: initialState.categories,
        selectedCategoryId: category.id,
        selectedCategoryName: category.name,
        words: [
          _word(
            id: 'word-ticket-review',
            term: 'ticket',
            translation: 'Fahrkarte',
          ),
          _word(id: 'word-hotel-review', term: 'hotel', translation: 'Hotel'),
        ],
        currentIndex: 0,
      ),
    );
  }

  @override
  Future<LocalWord?> markCurrentKnown() async {
    final currentState = state.valueOrNull;
    final word = currentState?.currentWord;
    if (currentState == null || word == null) return null;
    markedKnownIds.add(word.id);
    final nextWords = [...currentState.words]
      ..removeAt(currentState.currentIndex);
    state = AsyncData(
      currentState.copyWith(
        words: nextWords,
        currentIndex: currentState.currentIndex.clamp(
          0,
          (nextWords.length - 1).clamp(0, 1 << 30),
        ),
        knownCount: currentState.knownCount + 1,
        undoDepth: currentState.undoDepth + 1,
      ),
    );
    return word;
  }

  @override
  Future<void> markKeepLearning(LocalWord word) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    if (!keepLearningIds.contains(word.id)) {
      keepLearningIds.add(word.id);
    }
    state = AsyncData(
      currentState.copyWith(keepLearningCount: keepLearningIds.length),
    );
  }

  @override
  Future<void> unmarkKeepLearning(LocalWord word) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    keepLearningIds.remove(word.id);
    state = AsyncData(
      currentState.copyWith(keepLearningCount: keepLearningIds.length),
    );
  }

  @override
  void setCurrentWord(LocalWord word) {
    centeredWordIds.add(word.id);
    super.setCurrentWord(word);
  }

  @override
  void completeCurrentCategoryReview() {
    completedCalls += 1;
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    state = AsyncData(
      currentState.copyWith(currentIndex: currentState.words.length),
    );
  }

  @override
  Future<void> resetSelectedCategoryReview() async {
    resetCalls += 1;
  }

  @override
  Future<void> undoLastKnown() async {
    undoCalls += 1;
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    state = AsyncData(
      currentState.copyWith(
        knownCount: currentState.knownCount > 0
            ? currentState.knownCount - 1
            : 0,
        undoDepth: currentState.undoDepth > 0 ? currentState.undoDepth - 1 : 0,
      ),
    );
  }

  @override
  Future<void> setReviewSource(LocalKnownReviewSource source) async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    state = AsyncData(currentState.copyWith(source: source));
  }

  static LocalWord _word({
    required String id,
    required String term,
    required String translation,
  }) {
    final now = DateTime(2026, 5, 29, 11);
    return LocalWord(
      id: id,
      categoryId: 'category-travel-review',
      term: term,
      translation: translation,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }
}
