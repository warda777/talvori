import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/local_learning_debug/ui/local_learn_mode_header.dart';

void main() {
  group('LocalLearnModeHeader', () {
    testWidgets('local_learnmode_header_shows_category_and_mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LocalLearnModeHeader(
              categoryId: 'basics',
              title: 'Basics',
              modeLabel: 'Intensiv lernen',
            ),
          ),
        ),
      );

      expect(find.text('Basics'), findsOneWidget);
      expect(find.text('Intensiv lernen'), findsOneWidget);
    });
  });
}
