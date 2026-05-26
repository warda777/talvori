import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/local_database_schema.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/words/data/word_world_display_names.dart';
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
        .where(
          (item) =>
              LocalDatabaseSchema.isThematicWordWorldName(item.displayLabel),
        )
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

  List<LocalCategoryDetailGroupItem> resolvedLocalItemsFor(String wordHubKey) {
    return const LocalCategoryDetailGroupResolver()
        .resolve(wordHubKey)
        .where(
          (item) =>
              LocalDatabaseSchema.isThematicWordWorldName(item.displayLabel),
        )
        .map(
          (item) => item.copyWith(
            localCategoryId: 'word-world-${item.wordHubKey}',
            vocabsCount: item.wordHubKey == 'home_living' ? 123 : 1,
          ),
        )
        .toList(growable: false);
  }

  testWidgets('word_hub_screen_local_mode_shows_taxonomy_categories', (
    tester,
  ) async {
    usePhoneViewport(tester);
    SharedPreferences.setMockInitialValues({});

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
    expect(find.text('Alltag & Leben'), findsOneWidget);
    expect(find.text('Life & Daily Flow'), findsNothing);
    expect(find.text('Gesundheit & Fitness'), findsOneWidget);
    expect(find.text('Zuhause & Alltag'), findsOneWidget);
    expect(find.text('Essen & Kochen'), findsOneWidget);
    expect(find.text('Produktivität'), findsOneWidget);
    expect(find.text('Health & Fitness'), findsNothing);
    expect(find.text('Basics'), findsNothing);
    expect(find.text('seed-category-basics'), findsNothing);
    expect(find.text('3'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Menschen & Persönlichkeit'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Menschen & Persönlichkeit'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Gesellschaft & Systeme'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Gesellschaft & Systeme'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Reisen'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Reisen'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    expect(find.text('Sprachwerkzeuge'), findsNothing);
    expect(find.text('Top 500 Wörter'), findsNothing);
    expect(find.text('Redewendung'), findsNothing);
    expect(find.text('Redewendungen'), findsNothing);
    expect(find.text('Unregelmäßige Verben'), findsNothing);
    expect(find.text('Grammatik & Satzbau'), findsNothing);
    expect(find.text('top_500'), findsNothing);
    expect(find.text('phrases_idioms'), findsNothing);
    expect(find.text('irregular_verbs'), findsNothing);
    expect(find.text('grammar_syntax'), findsNothing);

    expect(find.text('Level & Fortschritt'), findsNothing);
    expect(find.text('Levels & Progress'), findsNothing);
    expect(find.text('A1'), findsNothing);
    expect(find.text('A2'), findsNothing);
    expect(find.text('B1'), findsNothing);
    expect(find.text('B2'), findsNothing);
    expect(find.text('C1'), findsNothing);
    expect(find.text('C2'), findsNothing);
    expect(find.text('a1'), findsNothing);
    expect(find.text('a2'), findsNothing);
  });

  test('word_hub_display_names_keep_tool_and_level_labels_clean', () {
    expect(
      wordHubItemDisplayName(
        'phrases_idioms',
        fallbackName: 'Phrases & Idioms',
        nativeLanguage: 'Deutsch',
      ),
      'Redewendung',
    );
    expect(
      wordHubItemDisplayName(
        'phrases_idioms',
        fallbackName: 'Phrases & Idioms',
        nativeLanguage: 'Englisch',
      ),
      'Phrases & Idioms',
    );
    expect(wordHubItemDisplayName('a1', nativeLanguage: 'Deutsch'), 'A1');
    expect(
      wordHubItemDisplayName('top_500', nativeLanguage: 'Deutsch'),
      'Top 500 Wörter',
    );
  });

  testWidgets('word_hub_screen_can_show_english_word_world_names', (
    tester,
  ) async {
    usePhoneViewport(tester);
    SharedPreferences.setMockInitialValues({
      'talvori_profile_native_language_v1': 'Englisch',
    });

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

    expect(find.text('Life & Daily Flow'), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Home & Living'), findsOneWidget);
    expect(find.text('Productivity'), findsOneWidget);
    expect(find.text('Produktivität'), findsNothing);

    expect(find.text('Language Tools'), findsNothing);
    expect(find.text('Levels & Progress'), findsNothing);
    expect(find.text('Top 500 Words'), findsNothing);
    expect(find.text('Phrases & Idioms'), findsNothing);
    expect(find.text('top_500'), findsNothing);
  });

  testWidgets(
    'word_hub_screen_local_mode_uses_resolver_and_opens_local_category_detail_screen',
    (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});

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

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Gesundheit & Fitness'));
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
      expect(screen.localCategoryItems!.length, 26);
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
      ]);
      expect(screen.categoryId, 'seed-category-basics');
      expect(find.text('Gesundheit & Fitness'), findsWidgets);
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
    'word_hub_screen_local_mode_shows_resolved_local_counts_without_pending',
    (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoryDetailGroupItemsProvider.overrideWith(
              (ref, wordHubKey) async => resolvedLocalItemsFor(wordHubKey),
            ),
          ],
          child: const MaterialApp(
            home: WordHubScreen(useLocalOfflineFlow: true),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Zuhause & Alltag'), findsOneWidget);
      expect(find.text('123'), findsOneWidget);
      expect(find.text('local pending'), findsNothing);

      await tester.tap(find.text('Zuhause & Alltag'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final screen = tester.widget<CategoryDetailScreen>(
        find.byType(CategoryDetailScreen),
      );
      expect(screen.localCategoryId, 'word-world-home_living');
      expect(screen.localSelectedWordHubKey, 'home_living');
    },
  );

  testWidgets(
    'word_hub_category_chat_icon_sits_bottom_left_without_rect_background',
    (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_word_hub_category_chat_icon',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localCategoryDetailGroupItemsProvider.overrideWith(
              (ref, wordHubKey) async => localItemsFor(wordHubKey),
            ),
            impulseInboxRepositoryProvider.overrideWithValue(repository),
            impulseInboxAiChatClientProvider.overrideWithValue(
              const _FakeAiChatClient(),
            ),
          ],
          child: const MaterialApp(
            home: WordHubScreen(useLocalOfflineFlow: true),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      final buttonKey = const Key(
        'word_hub_category_chat_button_seed-category-basics',
      );
      final circleKey = const Key(
        'word_hub_category_chat_circle_seed-category-basics',
      );
      final cardKey = const Key('word_hub_category_card_health_fitness');

      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(cardKey), findsOneWidget);
      final circle = tester.widget<DecoratedBox>(find.byKey(circleKey));
      final decoration = circle.decoration as BoxDecoration;
      expect(decoration.shape, BoxShape.circle);
      final cardRect = tester.getRect(find.byKey(cardKey));
      final circleRect = tester.getRect(find.byKey(circleKey));
      expect(circleRect.center.dx, lessThan(cardRect.center.dx));
      expect(circleRect.center.dy, greaterThan(cardRect.center.dy));

      final button = tester.widget<IconButton>(
        find.descendant(
          of: find.byKey(buttonKey),
          matching: find.byType(IconButton),
        ),
      );
      expect(button.onPressed, isNotNull);

      final chat = await repository.ensureCategoryChat(
        'seed-category-basics',
        'Health & Fitness',
      );
      expect(chat.sourceId, 'seed-category-basics');
    },
  );

  testWidgets(
    'word_hub_screen_local_mode_unmapped_category_shows_snackbar_without_basics_fallback',
    (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});

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
      await tester.tap(find.text('Zuhause & Alltag'));
      await tester.pump();

      expect(find.text('Noch nicht lokal verfügbar'), findsOneWidget);
      expect(find.byType(CategoryDetailScreen), findsNothing);
      expect(find.text('Keine aktive lokale Session'), findsNothing);
    },
  );
}

class _FakeAiChatClient implements AiChatClient {
  const _FakeAiChatClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    return const AiChatResult(reply: 'Okay.');
  }
}
