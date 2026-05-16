import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

void main() {
  testWidgets('word_hub_screen_local_mode_shows_taxonomy_categories', (
    tester,
  ) async {
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

  testWidgets('word_hub_screen_local_mode_opens_local_category_detail_screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WordHubScreen(useLocalOfflineFlow: true)),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Health & Fitness'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lokale Kategorie'), findsOneWidget);
    expect(find.text('basics'), findsWidgets);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Keine aktive lokale Session'), findsNothing);
  });

  testWidgets('word_hub_screen_local_mode_unmapped_category_shows_snackbar', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: WordHubScreen(useLocalOfflineFlow: true)),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Home & Living'));
    await tester.pump();

    expect(find.text('Noch nicht lokal verfügbar'), findsOneWidget);
    expect(find.text('Keine aktive lokale Session'), findsNothing);
  });
}
