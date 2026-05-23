import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/home/ui/screens/audio_catch_game_screen.dart';

import 'word_game_arcade_test_support.dart';

void main() {
  testWidgets('Hör-Fang shows the default instruction as task title', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');

    expect(find.text('Tippe das Wort, das du hörst'), findsOneWidget);
  });

  testWidgets('Hör-Fang keeps falling words clipped inside the play field', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');

    final card = find.byKey(const ValueKey('arcade-answer-0'));
    final topBefore = tester.getTopLeft(card).dy;
    await tester.pump(const Duration(milliseconds: 650));
    final topAfter = tester.getTopLeft(card).dy;

    expect(topAfter, greaterThan(topBefore));
    expect(find.byKey(const ValueKey('audio-catch-field')), findsOneWidget);
  });

  testWidgets('Hör-Fang replaces the title with miss feedback', (tester) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');
    await tester.pump(const Duration(milliseconds: 5600));

    final fieldTop = tester
        .getTopLeft(find.byKey(const ValueKey('audio-catch-field')))
        .dy;
    final feedbackTop = tester.getTopLeft(find.text('Verpasst')).dy;

    expect(feedbackTop, lessThan(fieldTop));
    expect(find.text('Verpasst: 1'), findsOneWidget);
    expect(
      ArcadeFakeWordPronunciationService.spokenWords.length,
      greaterThan(1),
    );

    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('Tippe das Wort, das du hörst'), findsNothing);
  });

  testWidgets('Hör-Fang replaces the title on wrong tap', (tester) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');

    final heardWord = ArcadeFakeWordPronunciationService.lastSpokenWord;
    expect(heardWord, isNotNull);
    final wrongWord = arcadeTestWords()
        .map((word) => word.term)
        .firstWhere(
          (word) => word != heardWord && find.text(word).evaluate().isNotEmpty,
        );
    await tester.tap(
      find
          .ancestor(of: find.text(wrongWord), matching: find.byType(InkWell))
          .first,
    );
    await tester.pump();

    expect(find.text('Falsch'), findsOneWidget);
    expect(find.text('Gefangen'), findsNothing);

    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('Tippe das Wort, das du hörst'), findsNothing);
  });

  testWidgets('Hör-Fang counts a correct tap as caught and updates title', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');

    final heardWord = ArcadeFakeWordPronunciationService.lastSpokenWord;
    expect(heardWord, isNotNull);
    await tester.tap(
      find
          .ancestor(of: find.text(heardWord!), matching: find.byType(InkWell))
          .first,
    );
    await tester.pump();

    expect(find.text('Gefangen'), findsOneWidget);
    expect(find.text('Treffer: 1'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    expect(find.text('Tippe das Wort, das du hörst'), findsNothing);
  });

  testWidgets(
    'Hör-Fang keeps unrelated falling words moving after target swap',
    (tester) async {
      await pumpArcadeGame(tester, const AudioCatchGameScreen());
      await startArcadeGame(tester, 'audio-catch');

      final heardWord = ArcadeFakeWordPronunciationService.lastSpokenWord;
      expect(heardWord, isNotNull);
      final stableWord = arcadeTestWords()
          .map((word) => word.term)
          .firstWhere(
            (word) =>
                word != heardWord && find.text(word).evaluate().isNotEmpty,
          );
      final stableCard = find
          .ancestor(of: find.text(stableWord), matching: find.byType(InkWell))
          .first;
      final topBefore = tester.getTopLeft(stableCard).dy;

      await tester.tap(
        find
            .ancestor(of: find.text(heardWord!), matching: find.byType(InkWell))
            .first,
      );
      await tester.pump(const Duration(milliseconds: 220));

      final topAfter = tester.getTopLeft(stableCard).dy;
      expect(topAfter, greaterThan(topBefore));
    },
  );

  testWidgets('Hör-Fang respawns the next target above the visible field', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');

    await tester.pump(const Duration(milliseconds: 5600));

    final nextWord = ArcadeFakeWordPronunciationService.lastSpokenWord;
    expect(nextWord, isNotNull);
    final fieldTop = tester
        .getTopLeft(find.byKey(const ValueKey('audio-catch-field')))
        .dy;
    final targetTop = tester.getTopLeft(find.text(nextWord!)).dy;

    expect(find.text('Verpasst'), findsOneWidget);
    expect(targetTop, lessThan(fieldTop));
  });

  testWidgets('Hör-Fang shows the initial instruction again after restart', (
    tester,
  ) async {
    await pumpArcadeGame(tester, const AudioCatchGameScreen());
    await startArcadeGame(tester, 'audio-catch');

    await tester.pump(const Duration(milliseconds: 36000));
    expect(find.text('Nochmal spielen'), findsOneWidget);

    await tester.tap(find.text('Nochmal spielen'));
    await tester.pump();

    expect(find.text('Tippe das Wort, das du hörst'), findsOneWidget);
  });
}
