import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/words/ui/screens/category_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('word_hub_screen_local_mode_shows_taxonomy_categories', (
    tester,
  ) async {
    usePhoneViewport(tester);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WordHubScreen(useLocalOfflineFlow: true)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Word Hub'), findsOneWidget);
    expect(find.text('Life & Daily Flow'), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Home & Living'), findsOneWidget);
    expect(find.text('Basics'), findsNothing);
  });

  testWidgets(
    'word_hub_screen_local_mode_uses_resolver_and_opens_local_category_detail_screen',
    (tester) async {
      usePhoneViewport(tester);

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(home: WordHubScreen(useLocalOfflineFlow: true)),
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
      expect(screen.localCategoryIds, ['seed-category-basics']);
      expect(screen.categoryId, 'seed-category-basics');
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
        const ProviderScope(
          child: MaterialApp(home: WordHubScreen(useLocalOfflineFlow: true)),
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
