import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/home/ui/screens/synonym_riddle_game_screen.dart';

import 'word_game_arcade_test_support.dart';

void main() {
  testWidgets('Synonym-Rätsel offers valid KI language directions only', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const SynonymRiddleGameScreen());

    expect(find.text('Synonym-Rätsel'), findsWidgets);
    expect(find.text('Englisch → Deutsch'), findsOneWidget);
    expect(find.text('Deutsch → Englisch'), findsOneWidget);
    expect(find.text('Englisch → Englisch'), findsOneWidget);
    expect(find.text('Deutsch → Deutsch'), findsNothing);
  });

  testWidgets('Synonym-Rätsel swap passes Deutsch Englisch to KI request', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const SynonymRiddleGameScreen());

    await tester.tap(find.byKey(const ValueKey('arcade-language-swap')));
    await tester.pump();
    await startArcadeGame(tester, 'synonym-riddle');
    await tester.pumpAndSettle();

    expect(
      ArcadeFakeAiChatClient.lastContext?['languagePair'],
      'Deutsch → Englisch',
    );
    expect(ArcadeFakeAiChatClient.lastContext?['sourceLanguage'], 'de');
    expect(ArcadeFakeAiChatClient.lastContext?['answerLanguage'], 'en');
  });

  testWidgets('Synonym-Rätsel accepts the matching English option', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const SynonymRiddleGameScreen());

    await tester.tap(find.byKey(const ValueKey('arcade-language-en-en')));
    await tester.pump();
    await startArcadeGame(tester, 'synonym-riddle');
    await tester.pumpAndSettle();

    final targetWord = ArcadeFakeAiChatClient.lastSynonymWord;
    expect(targetWord, isNotNull);
    await tester.tap(
      find
          .ancestor(of: find.text(targetWord!), matching: find.byType(InkWell))
          .first,
    );
    await tester.pump();

    expect(find.text('Richtig'), findsOneWidget);
  });
}
