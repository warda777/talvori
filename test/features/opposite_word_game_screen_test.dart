import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/home/ui/screens/odd_word_game_screen.dart';

import 'word_game_arcade_test_support.dart';

void main() {
  testWidgets('Gegenwort offers valid KI language directions only', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const OddWordGameScreen());

    expect(find.text('Gegenwort'), findsWidgets);
    expect(find.text('Englisch → Deutsch'), findsOneWidget);
    expect(find.text('Deutsch → Englisch'), findsOneWidget);
    expect(find.text('Englisch → Englisch'), findsOneWidget);
    expect(find.text('Deutsch → Deutsch'), findsNothing);
    expect(find.byKey(const ValueKey('arcade-language-swap')), findsOneWidget);
  });

  testWidgets('Gegenwort swap passes Deutsch Englisch to KI request', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const OddWordGameScreen());

    await tester.tap(find.byKey(const ValueKey('arcade-language-swap')));
    await tester.pump();
    await startArcadeGame(tester, 'odd-word');
    await tester.pumpAndSettle();

    expect(
      ArcadeFakeAiChatClient.lastContext?['languagePair'],
      'Deutsch → Englisch',
    );
    expect(ArcadeFakeAiChatClient.lastContext?['sourceLanguage'], 'de');
    expect(ArcadeFakeAiChatClient.lastContext?['answerLanguage'], 'en');
  });

  testWidgets('Gegenwort handles KI errors without crashing', (tester) async {
    await pumpArcadeGame(
      tester,
      const OddWordGameScreen(),
      aiClient: const ArcadeFailingAiChatClient(),
    );

    await startArcadeGame(tester, 'odd-word');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('KI-Spiel momentan nicht verfügbar'),
      findsWidgets,
    );
  });
}
