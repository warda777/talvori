import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';
import 'package:talvori/features/words/ui/widgets/learning_mode_selector.dart';

void main() {
  testWidgets('learning_mode_selector_view_shows_modes_and_selects_mode', (
    tester,
  ) async {
    SrsSystem? selectedMode;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LearningModeSelectorView(
            selectedMode: SrsSystem.time,
            onModeSelected: (mode) => selectedMode = mode,
          ),
        ),
      ),
    );

    expect(find.text('Zeitplan'), findsOneWidget);
    expect(find.text('Limitlos'), findsOneWidget);
    expect(find.text('Kombiniert'), findsOneWidget);

    await tester.tap(find.text('Limitlos'));

    expect(selectedMode, SrsSystem.adaptive);
  });
}
