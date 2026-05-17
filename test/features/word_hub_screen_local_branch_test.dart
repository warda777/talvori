import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  List<LocalCategoryDetailGroupItem> localItemsFor(String wordHubKey) {
    return const LocalCategoryDetailGroupResolver()
        .resolve(wordHubKey)
        .map(
          (item) => item.copyWith(
            vocabsCount: item.wordHubKey == 'health_fitness'
                ? 3
                : item.wordHubKey == 'travel'
                ? 4
                : 0,
          ),
        )
        .toList(growable: false);
  }

  testWidgets('word_hub_screen_local_mode_shows_taxonomy_categories', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoryDetailGroupItemsProvider.overrideWith(
            (ref, wordHubKey) async => localItemsFor(wordHubKey),
          ),
        ],
        child: const MaterialApp(
          home: WordHubScreen(useLocalOfflineFlow: true),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Wortwelten'), findsOneWidget);
    expect(find.text('Word Hub'), findsNothing);
    expect(find.text('Life & Daily Flow'), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Home & Living'), findsOneWidget);
    expect(find.text('Basics'), findsNothing);
    expect(find.text('seed-category-basics'), findsNothing);
    expect(find.text('3'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Travel'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets(
    'word_hub_screen_local_mode_uses_resolver_and_opens_local_category_detail_screen',
    (tester) async {
      usePhoneViewport(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoryDetailGroupItemsProvider.overrideWith(
              (ref, wordHubKey) async => localItemsFor(wordHubKey),
            ),
          ],
          child: const MaterialApp(
            home: WordHubScreen(useLocalOfflineFlow: true),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Health & Fitness'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<CategoryDetailScreen>(
        find.byType(CategoryDetailScreen),
      );

      expect(screen.useLocalOfflineFlow, isTrue);
      expect(screen.localCategoryId, 'seed-category-basics');
      expect(screen.localCategoryIds, [
        'seed-category-basics',
        'seed-category-travel',
      ]);
      expect(screen.localSelectedWordHubKey, 'health_fitness');
      expect(screen.localCategoryItems!.length, greaterThan(30));
      expect(screen.localCategoryItems!.map((item) => item.displayLabel), [
        'Health & Fitness',
        'Home & Living',
        'Food & Cooking',
        'Style & Fashion',
        'Money & Shopping',
        'Productivity',
        'Personality',
        'Feelings',
        'Relationships',
        'Thoughts',
        'Tech & Innovation',
        'Work & Careers',
        'School & Studies',
        'Media & News',
        'Law & Politics',
        'Environment',
        'Animals',
        'Nature',
        'Space',
        'Science',
        'Sports',
        'Travel',
        'Gaming',
        'Transport',
        'Music & Entertainment',
        'Art & Literature',
        'Top 500 Words',
        'Phrases & Idioms',
        'Irregular Verbs',
        'Grammar & Syntax',
        'A1',
        'A2',
        'B1',
        'B2',
        'C1',
        'C2',
      ]);
      expect(screen.categoryId, 'seed-category-basics');
      expect(find.text('Health & Fitness'), findsWidgets);
      expect(find.text('Basics'), findsNothing);
      expect(find.text('seed-category-basics'), findsNothing);
      expect(find.text('Lokale Kategorie'), findsNothing);
      expect(find.text('Lernmodus'), findsOneWidget);
      expect(find.text('Wiederholungsauswahl'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Keine aktive lokale Session'), findsNothing);
    },
  );

  testWidgets(
    'word_hub_screen_local_mode_unmapped_category_shows_snackbar_without_basics_fallback',
    (tester) async {
      usePhoneViewport(tester);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoryDetailGroupItemsProvider.overrideWith(
              (ref, wordHubKey) async => localItemsFor(wordHubKey),
            ),
          ],
          child: const MaterialApp(
            home: WordHubScreen(useLocalOfflineFlow: true),
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Home & Living'));
      await tester.pump();

      expect(find.text('Noch nicht lokal verfügbar'), findsOneWidget);
      expect(find.byType(CategoryDetailScreen), findsNothing);
      expect(find.text('Keine aktive lokale Session'), findsNothing);
    },
  );
}
