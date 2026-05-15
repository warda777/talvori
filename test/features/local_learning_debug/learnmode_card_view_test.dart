import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/learnmode_card_presenter.dart';
import 'package:talvori/features/local_learning_debug/ui/learnmode_card_view.dart';

void main() {
  group('LearnModeCardView', () {
    testWidgets('learnmode_card_view_shows_active_card', (tester) async {
      const state = LearnModeCardPresenterState(
        hasCard: true,
        frontText: 'hello',
        backText: 'hallo',
        exampleSentence: 'Hello, how are you?',
        notes: 'Common greeting.',
        stageLabel: 's0',
        progressLabel: '1 / 3',
        canSubmitAnswer: true,
        isCompleted: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearnModeCardView(state: state),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
      expect(find.text('hallo'), findsOneWidget);
      expect(find.text('Hello, how are you?'), findsOneWidget);
      expect(find.text('Common greeting.'), findsOneWidget);
      expect(find.text('s0'), findsOneWidget);
      expect(find.text('1 / 3'), findsOneWidget);
    });

    testWidgets('learnmode_card_view_hides_card_when_no_card', (tester) async {
      const state = LearnModeCardPresenterState(
        hasCard: false,
        progressLabel: '0 / 0',
        canSubmitAnswer: false,
        isCompleted: false,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LearnModeCardView(state: state),
          ),
        ),
      );

      expect(find.text('hello'), findsNothing);
      expect(find.text('hallo'), findsNothing);
      expect(find.text('Keine Karte'), findsNothing);
      expect(find.text('0 / 0'), findsNothing);
      expect(find.byType(LearnModeCardView), findsOneWidget);
    });
  });
}
