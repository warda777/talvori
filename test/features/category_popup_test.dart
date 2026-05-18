import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/providers/local_word_count_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/features/home/ui/widgets/category_popup.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

void main() {
  testWidgets(
    'category popup uses german dark-neon labels without power button',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return TextButton(
                    onPressed: () {
                      showCategoryPopup(
                        context: context,
                        onRefreshMyWords: () async {},
                        onTodo: (_) {},
                      );
                    },
                    child: const Text('Open'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('Kategorie'), findsOneWidget);
      expect(find.text('Alle Wörter'), findsOneWidget);
      expect(find.text('Meine Wörter'), findsOneWidget);
      expect(find.text('Favoriten'), findsOneWidget);
      expect(find.text('Wörter, die ich kenne'), findsOneWidget);
      expect(find.text('Wortwelten'), findsOneWidget);
      expect(find.text('Mix erstellen'), findsOneWidget);

      expect(find.text('Category'), findsNothing);
      expect(find.text('All words'), findsNothing);
      expect(find.text('My words'), findsNothing);
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Words I know'), findsNothing);
      expect(find.text('Word hub'), findsNothing);
      expect(find.text('Make your own mix'), findsNothing);
      expect(find.text('Eigenen Mix erstellen'), findsNothing);
      expect(find.byIcon(Icons.power_settings_new_rounded), findsNothing);
    },
  );

  testWidgets('category popup opens local word list for my words', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordCountProvider.overrideWith((ref, categoryId) async => 0),
          localWordsForCategoryProvider.overrideWith(
            (ref, categoryId) async => const [],
          ),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () {
                    showCategoryPopup(
                      context: context,
                      onRefreshMyWords: () async {},
                      onTodo: (_) {},
                    );
                  },
                  child: const Text('Open'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    await tester.tap(find.byKey(const Key('category-popup-my-words-tile')));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.byType(LocalWordListScreen), findsOneWidget);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('local-category-my-words'), findsNothing);
  });
}
