import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/syllable_rain_game_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  LocalWord word({
    required String id,
    required String term,
    String translation = 'Übersetzung',
    String categoryId = 'seed-category-travel',
  }) {
    final now = DateTime(2026, 5, 23, 12);
    return LocalWord(
      id: id,
      categoryId: categoryId,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  LocalCategory category(String id, String name) {
    final now = DateTime(2026, 5, 23, 12);
    return LocalCategory(
      id: id,
      name: name,
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  const categories = <LocalCategory>[];

  Future<void> pumpRain(
    WidgetTester tester,
    List<LocalWord> words, {
    Random? random,
  }) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final localCategories = [
      category('seed-category-travel', 'Travel'),
      ...categories,
    ];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return words;
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return words
                .where((word) => word.categoryId == categoryId)
                .toList(growable: false);
          }),
          localCategoriesProvider.overrideWith((ref) async => localCategories),
        ],
        child: MaterialApp(
          home: SyllableRainGameScreen(random: random ?? Random(1)),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
    await tester.tap(finder);
    await tester.pump();
  }

  void tapBubbleText(WidgetTester tester, String text) {
    tester
        .widget<InkWell>(
          find.ancestor(of: find.text(text), matching: find.byType(InkWell)),
        )
        .onTap!
        .call();
  }

  void tapBubbleKey(WidgetTester tester, int id) {
    tester
        .widget<InkWell>(
          find.descendant(
            of: find.byKey(ValueKey('syllable-rain-bubble-$id')),
            matching: find.byType(InkWell),
          ),
        )
        .onTap!
        .call();
  }

  List<Rect> visibleBubbleRects(WidgetTester tester) {
    final fieldRect = tester.getRect(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    final elements = tester.elementList(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('syllable-rain-bubble-');
      }),
    );
    return [
          for (final element in elements)
            if (element.renderObject case final RenderBox box)
              Rect.fromLTWH(
                box.localToGlobal(Offset.zero).dx,
                box.localToGlobal(Offset.zero).dy,
                box.size.width,
                box.size.height,
              ),
        ]
        .where((rect) {
          return rect.bottom > fieldRect.top + 4 &&
              rect.top < fieldRect.bottom - 4;
        })
        .toList(growable: false);
  }

  void expectNoVisibleBubbleOverlap(WidgetTester tester) {
    final rects = visibleBubbleRects(tester);
    for (var i = 0; i < rects.length; i += 1) {
      for (var j = i + 1; j < rects.length; j += 1) {
        expect(rects[i].inflate(-4).overlaps(rects[j].inflate(-4)), isFalse);
      }
    }
  }

  Rect bubbleRectForText(WidgetTester tester, String text) {
    return tester.getRect(
      find.ancestor(of: find.text(text), matching: find.byType(InkWell)),
    );
  }

  test('splits words into robust word parts', () {
    expect(buildSyllableRainParts('travel'), ['tra', 'vel']);
    expect(buildSyllableRainParts('wonderful'), hasLength(2));
    expect(
      buildSyllableRainWords([
        word(id: '1', term: 'train'),
        word(id: '2', term: 'ice-cream'),
        word(id: '3', term: 'go'),
      ]).map((word) => word.id),
      ['1'],
    );
  });

  testWidgets('Silben-Regen opens from the hub', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byKey(const ValueKey('word-game-syllable_rain')),
    );
    await tester.tap(find.byKey(const ValueKey('word-game-syllable_rain')));
    await tester.pumpAndSettle();

    expect(find.byType(SyllableRainGameScreen), findsOneWidget);
    expect(find.text('Silben-Regen'), findsWidgets);
  });

  testWidgets('startscreen shows picker and speed options', (tester) async {
    await pumpRain(tester, [word(id: 'travel', term: 'travel')]);

    expect(find.text('Du spielst mit'), findsOneWidget);
    expect(find.text('Wörter pro Runde'), findsOneWidget);
    expect(find.text('Geschwindigkeit'), findsOneWidget);
    expect(find.text('Mittel'), findsOneWidget);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-speed-slow')),
    );

    expect(find.text('Langsam'), findsOneWidget);
  });

  testWidgets('falling bubbles show several buildable word parts', (
    tester,
  ) async {
    await pumpRain(tester, [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
    ]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.byKey(const ValueKey('syllable-rain-field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('syllable-rain-bubble-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('syllable-rain-bubble-5')),
      findsOneWidget,
    );
    expect(find.text('tra'), findsOneWidget);
    expect(find.text('vel'), findsOneWidget);
    expect(find.text('tic'), findsOneWidget);
    expect(find.text('ket'), findsOneWidget);
    expect(find.textContaining('Gebildet: 0 / 3'), findsOneWidget);
  });

  testWidgets('paired word parts are visible but spatially separated', (
    tester,
  ) async {
    await pumpRain(tester, [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
    ]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 5000));

    final firstPart = bubbleRectForText(tester, 'tra');
    final secondPart = bubbleRectForText(tester, 'vel');
    expect(firstPart.overlaps(secondPart), isFalse);
    expect((firstPart.center.dx - secondPart.center.dx).abs(), greaterThan(80));
    expect((firstPart.center.dy - secondPart.center.dy).abs(), greaterThan(45));
    expectNoVisibleBubbleOverlap(tester);
  });

  testWidgets('uses the selected words-per-round amount as round set', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'talvori_word_game_progress_v1.syllable-rain.words_per_round': 35,
    });
    await pumpRain(tester, [
      for (var i = 0; i < 35; i += 1)
        word(
          id: 'word-$i',
          term:
              'word${String.fromCharCode('a'.codeUnitAt(0) + (i ~/ 26))}${String.fromCharCode('a'.codeUnitAt(0) + (i % 26))}',
        ),
    ]);
    await tester.pump();

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(find.textContaining('Gebildet: 0 / 35'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('syllable-rain-bubble-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('syllable-rain-bubble-5')),
      findsOneWidget,
    );
  });

  testWidgets(
    'correct part selection forms one word and wrong selection resets',
    (tester) async {
      await pumpRain(tester, [
        word(id: 'travel', term: 'travel'),
        word(id: 'ticket', term: 'ticket'),
      ]);

      await tapVisible(
        tester,
        find.byKey(const ValueKey('syllable-rain-start-button')),
      );
      await tester.ensureVisible(
        find.byKey(const ValueKey('syllable-rain-field')),
      );
      await tester.pump(const Duration(milliseconds: 900));

      tapBubbleText(tester, 'tra');
      await tester.pump();
      tapBubbleText(tester, 'tic');
      await tester.pump();

      expect(find.text('Falsch'), findsOneWidget);
      expect(find.textContaining('Gebildet: 0 / 2'), findsOneWidget);
      expect(find.text('tra'), findsOneWidget);
      expect(find.text('vel'), findsOneWidget);
      expect(find.text('tic'), findsOneWidget);
      expect(find.text('ket'), findsOneWidget);

      tapBubbleText(tester, 'tra');
      await tester.pump();
      tapBubbleText(tester, 'vel');
      await tester.pump();

      expect(find.text('Gebildet: travel'), findsOneWidget);
      expect(find.textContaining('Gebildet: 1 / 2'), findsOneWidget);
      expect(find.text('tra'), findsNothing);
      expect(find.text('vel'), findsNothing);
      expect(find.text('tic'), findsOneWidget);
      expect(find.text('ket'), findsOneWidget);
    },
  );

  testWidgets('formed word is replaced by another open word pair', (
    tester,
  ) async {
    await pumpRain(tester, [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
      word(id: 'beach', term: 'beach'),
    ]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 900));

    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('syllable-rain-bubble-');
      }),
      findsNWidgets(6),
    );

    tapBubbleKey(tester, 0);
    await tester.pump();
    tapBubbleKey(tester, 1);
    await tester.pump();

    expect(find.textContaining('Gebildet: 1 / 4'), findsOneWidget);
    expect(
      find.byWidgetPredicate((widget) {
        final key = widget.key;
        return key is ValueKey<String> &&
            key.value.startsWith('syllable-rain-bubble-');
      }),
      findsNWidgets(6),
    );
    expectNoVisibleBubbleOverlap(tester);
  });

  testWidgets('round can finish after all visible words are built', (
    tester,
  ) async {
    await pumpRain(tester, [word(id: 'travel', term: 'travel')]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 900));

    tester
        .widget<InkWell>(
          find.descendant(
            of: find.byKey(const ValueKey('syllable-rain-bubble-0')),
            matching: find.byType(InkWell),
          ),
        )
        .onTap!
        .call();
    await tester.pump();
    expect(find.text('Regen beendet'), findsNothing);

    tester
        .widget<InkWell>(
          find.descendant(
            of: find.byKey(const ValueKey('syllable-rain-bubble-1')),
            matching: find.byType(InkWell),
          ),
        )
        .onTap!
        .call();
    await tester.pump();

    expect(find.text('Regen beendet'), findsOneWidget);
    expect(find.textContaining('Noch offen: 0'), findsOneWidget);
  });

  testWidgets('falling bubbles keep readable distance', (tester) async {
    await pumpRain(tester, [
      word(id: 'travel', term: 'travel'),
      word(id: 'ticket', term: 'ticket'),
      word(id: 'hotel', term: 'hotel'),
      word(id: 'beach', term: 'beach'),
    ]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 3000));

    expectNoVisibleBubbleOverlap(tester);
  });

  testWidgets('missed target bubbles respawn instead of ending the game', (
    tester,
  ) async {
    await pumpRain(tester, [word(id: 'travel', term: 'travel')]);

    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-speed-fast')),
    );
    await tapVisible(
      tester,
      find.byKey(const ValueKey('syllable-rain-start-button')),
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('syllable-rain-field')),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(seconds: 11));
    await tester.pump();

    expect(find.text('Regen beendet'), findsNothing);
    expect(find.byKey(const ValueKey('syllable-rain-field')), findsOneWidget);
    expect(find.text('Verpasst.'), findsOneWidget);
    expect(find.textContaining('Verpasst: 1'), findsOneWidget);
    expect(find.text('tra'), findsOneWidget);
    expect(find.text('vel'), findsOneWidget);
  });
}
