import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/models/local_category.dart';
import 'package:talvori/core/local_database/providers/local_categories_provider.dart';
import 'package:talvori/features/words/ui/screens/word_hub_screen.dart';

void main() {
  testWidgets('word_hub_screen_local_mode_shows_local_categories', (
    tester,
  ) async {
    final fixedNow = DateTime(2026, 1, 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoriesProvider.overrideWith(
            (ref) async => [
              LocalCategory(
                id: 'basics',
                name: 'Basics',
                sortOrder: 0,
                isArchived: false,
                createdAt: fixedNow,
                updatedAt: fixedNow,
              ),
            ],
          ),
        ],
        child: const MaterialApp(
          home: WordHubScreen(useLocalOfflineFlow: true),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Word Hub'), findsOneWidget);
    expect(find.text('Lokale Kategorien'), findsOneWidget);
    expect(find.text('Basics'), findsOneWidget);
  });

  testWidgets('word_hub_screen_local_mode_opens_local_category_detail_screen', (
    tester,
  ) async {
    final fixedNow = DateTime(2026, 1, 1);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoriesProvider.overrideWith(
            (ref) async => [
              LocalCategory(
                id: 'basics',
                name: 'Basics',
                sortOrder: 0,
                isArchived: false,
                createdAt: fixedNow,
                updatedAt: fixedNow,
              ),
            ],
          ),
        ],
        child: const MaterialApp(
          home: WordHubScreen(useLocalOfflineFlow: true),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Basics'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Lokale Kategorie'), findsOneWidget);
    expect(find.text('basics'), findsWidgets);
    expect(find.text('Start'), findsOneWidget);
    expect(find.text('Keine aktive lokale Session'), findsNothing);
  });
}
