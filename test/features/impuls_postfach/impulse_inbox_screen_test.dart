import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/features/companion/domain/companion_chat_constants.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_controller.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_voice_input_service.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_router.dart';
import 'package:talvori/features/impuls_postfach/notifications/notification_tap_debug_state.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

const _healthWordWorldId = 'word-world-health-and-fitness';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    ImpulseInboxNotificationRouter.resetForTests();
    NotificationTapDebugStore.reset();
  });

  test('notification tap debug state starts empty', () {
    final state = NotificationTapDebugStore.value.value;

    expect(state.hasTap, isFalse);
    expect(state.lastParsedType, isNull);
    expect(state.lastRouteTarget, isNull);
  });

  testWidgets('chat list shows latest daily impulse message', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_list',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'You moved like a superstar.',
        usedWords: ['move'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impuls-Postfach'), findsOneWidget);
    expect(find.text('1 Verlauf'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Tagesimpuls'),
      ),
      findsOneWidget,
    );
    expect(find.text('You moved like a superstar.'), findsOneWidget);
    expect(find.byKey(const Key('impulse_inbox_unread_badge')), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
  });

  testWidgets('chat list shows polished empty state', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_empty',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Impuls-Postfach'), findsOneWidget);
    expect(find.text('Noch keine Chats'), findsOneWidget);
    expect(
      find.text(
        'Erstelle einen Kategorie-Chat oder starte mit deinem Tagesimpuls.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('chat list shows Talvori Companion thread when messages exist', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_companion_thread',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCompanionChat();
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Hallo Talvori',
        createdAt: DateTime(2026, 5, 20, 12, 1),
        source: ImpulseMessageSource.user,
        status: ImpulseMessageStatus.sent,
        readAt: DateTime(2026, 5, 20, 12, 1),
      ),
      incrementUnread: false,
    );
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Ich bin da.',
        createdAt: DateTime(2026, 5, 20, 12, 2),
        source: ImpulseMessageSource.ai,
        status: ImpulseMessageStatus.sent,
        readAt: DateTime(2026, 5, 20, 12, 2),
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(CompanionChatConstants.title), findsOneWidget);
    expect(find.text('Ich bin da.'), findsOneWidget);

    await tester.tap(
      find.byKey(Key('impulse_chat_tile_${CompanionChatConstants.chatId}')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text(CompanionChatConstants.title), findsWidgets);
    expect(find.text('Hallo Talvori'), findsOneWidget);
    expect(find.text('Ich bin da.'), findsOneWidget);
  });

  testWidgets('chat hub shows search field and filters chats', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_search',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Daily hello',
        usedWords: ['hello'],
      ),
    ]);
    await repository.ensureCategoryChat('seed-category-travel', 'Travel');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('impulse_inbox_search_field')), findsOneWidget);
    await tester.enterText(
      find.byKey(const Key('impulse_inbox_search_field')),
      'Travel',
    );
    await tester.pump();

    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Tagesimpuls'),
      ),
      findsNothing,
    );
  });

  testWidgets('chat filter chips filter chats and combine with search', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_filters',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Daily saved hello',
        usedWords: ['hello'],
      ),
    ]);
    final category = await repository.ensureCategoryChat(
      'seed-category-travel',
      'Travel',
    );
    await repository.setChatFavorite(category.id, true);
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: category.id,
        text: 'Category saved text',
        createdAt: DateTime(2026, 5, 20, 12, 1),
        source: ImpulseMessageSource.ai,
        isStarred: true,
      ),
      incrementUnread: false,
    );
    await repository.createCustomAiChat('Grammatikfragen');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    expect(
      find.byKey(const Key('impulse_inbox_chat_filter_chips')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('chat_filter_favorites')), findsOneWidget);

    await tester.tap(find.byKey(const Key('chat_filter_categories')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Grammatikfragen'),
      ),
      findsNothing,
    );

    await tester.tap(find.byKey(const Key('chat_filter_favorites')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Grammatikfragen'),
      ),
      findsNothing,
    );

    await tester.enterText(
      find.byKey(const Key('impulse_inbox_search_field')),
      'Travel',
    );
    await tester.pump();
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const Key('impulse_inbox_search_field')),
      'Grammatik',
    );
    await tester.pump();
    expect(find.text('Nichts gefunden'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('impulse_inbox_search_field')),
      '',
    );
    await tester.pump();
    await tester.drag(
      find.byKey(const Key('impulse_inbox_chat_filter_chips')),
      const Offset(-520, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_filter_customAi')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Grammatikfragen'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsNothing,
    );

    await tester.drag(
      find.byKey(const Key('impulse_inbox_chat_filter_chips')),
      const Offset(520, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_filter_unread')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Tagesimpuls'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsNothing,
    );

    await tester.drag(
      find.byKey(const Key('impulse_inbox_chat_filter_chips')),
      const Offset(-420, 0),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_filter_saved')));
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Travel'),
      ),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('impulse_inbox_chat_list')),
        matching: find.text('Grammatikfragen'),
      ),
      findsNothing,
    );
  });

  testWidgets('favorites filter empty state and search combination work', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_favorites_filter_search',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final favorite = await repository.ensureCategoryChat(
      'seed-category-english',
      'Englisch üben',
    );
    await repository.createCustomAiChat('Grammatikfragen');
    await repository.setChatFavorite(favorite.id, true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('chat_filter_favorites')));
    await tester.pumpAndSettle();
    expect(find.text('Englisch üben'), findsOneWidget);
    expect(find.text('Grammatikfragen'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('impulse_inbox_search_field')),
      'Grammatik',
    );
    await tester.pump();
    expect(find.text('Nichts gefunden'), findsOneWidget);

    final emptyRepository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_favorites_filter_empty',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await emptyRepository.createCustomAiChat('Kein Favorit');
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(emptyRepository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(
          home: ImpulsPostfachScreen(key: Key('empty_favorites_inbox')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('chat_filter_favorites')));
    await tester.pumpAndSettle();

    expect(find.text('Keine Favoriten'), findsOneWidget);
    expect(
      find.text(
        'Markiere wichtige Chats als Favorit, damit du sie schneller wiederfindest.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('favorite chats are shown first in all filter', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_favorites_sorted_first',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final favorite = await repository.ensureCategoryChat(
      'seed-category-travel',
      'Travel',
    );
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: favorite.id,
        text: 'Older favorite',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
      incrementUnread: false,
    );
    await repository.setChatFavorite(favorite.id, true);
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Newer daily',
        usedWords: ['newer'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final favoriteTop = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('impulse_inbox_chat_list')),
            matching: find.text('Travel'),
          ),
        )
        .dy;
    final dailyTop = tester
        .getTopLeft(
          find.descendant(
            of: find.byKey(const Key('impulse_inbox_chat_list')),
            matching: find.text('Tagesimpuls'),
          ),
        )
        .dy;

    expect(favoriteTop, lessThan(dailyTop));
  });

  testWidgets('long press opens chat actions and protects daily impulse chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_actions_daily',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Daily hello',
        usedWords: ['hello'],
      ),
    ]);
    final daily = (await repository.listChats()).single;

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${daily.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('chat_actions_sheet_${daily.id}')), findsOneWidget);
    expect(find.byKey(Key('chat_action_read_${daily.id}')), findsOneWidget);
    expect(find.byKey(Key('chat_action_hide_${daily.id}')), findsNothing);
    expect(find.byKey(Key('chat_action_rename_${daily.id}')), findsNothing);

    await tester.tap(find.byKey(Key('chat_action_more_${daily.id}')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('chat_more_actions_sheet_${daily.id}')),
      findsOneWidget,
    );
    expect(find.byKey(Key('chat_more_delete_${daily.id}')), findsNothing);
    expect(find.byKey(Key('chat_more_hide_${daily.id}')), findsNothing);
    expect(find.byKey(Key('chat_more_rename_${daily.id}')), findsNothing);
  });

  testWidgets('chat actions mark read and hide category chats from the list', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_actions_category',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final category = await repository.ensureCategoryChat(
      'seed-category-travel',
      'Travel',
    );
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: category.id,
        text: 'Kategorie Antwort',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${category.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_read_${category.id}')));
    await tester.pumpAndSettle();

    expect((await repository.listChats()).single.unreadCount, 0);
    expect(find.byKey(const Key('impulse_inbox_unread_badge')), findsNothing);
    expect(find.byKey(const Key('impulse_toast')), findsOneWidget);
    expect(find.text('Chat als gelesen markiert'), findsOneWidget);

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${category.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_hide_${category.id}')));
    await tester.pumpAndSettle();

    expect(await repository.listChats(), isEmpty);
    expect(find.text('Travel'), findsNothing);
    expect(
      (await repository.getCategoryChat('seed-category-travel'))?.enabled,
      isFalse,
    );
  });

  testWidgets('chat actions toggle favorite and mute locally', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_actions_favorite_mute',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final custom = await repository.createCustomAiChat('Training');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${custom.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_favorite_${custom.id}')));
    await tester.pumpAndSettle();

    var loaded = (await repository.listChats()).single;
    expect(loaded.isFavorite, isTrue);
    expect(
      find.byKey(Key('chat_favorite_indicator_${custom.id}')),
      findsOneWidget,
    );
    expect(find.text('Favorit gesetzt'), findsOneWidget);

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${custom.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_mute_${custom.id}')));
    await tester.pumpAndSettle();

    loaded = (await repository.listChats()).single;
    expect(loaded.isMuted, isTrue);
    expect(
      find.byKey(Key('chat_muted_indicator_${custom.id}')),
      findsOneWidget,
    );
    expect(find.text('Chat stumm geschaltet'), findsOneWidget);
  });

  testWidgets('swipe exposes quick actions for category chat', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_swipe_category',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final category = await repository.ensureCategoryChat(
      'seed-category-travel',
      'Travel',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(
      find.byKey(Key('impulse_chat_swipe_area_${category.id}')),
      const Offset(-420, 0),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('chat_swipe_actions_${category.id}')),
      findsOneWidget,
    );
    expect(find.byKey(Key('chat_swipe_more_${category.id}')), findsOneWidget);
    expect(find.byKey(Key('chat_swipe_hide_${category.id}')), findsOneWidget);

    final titleRect = tester.getRect(
      find.descendant(
        of: find.byKey(Key('impulse_chat_tile_${category.id}')),
        matching: find.text('Travel'),
      ),
    );
    final hideRect = tester.getRect(
      find.byKey(Key('chat_swipe_hide_${category.id}')),
    );
    final moreRect = tester.getRect(
      find.byKey(Key('chat_swipe_more_${category.id}')),
    );
    final frameRect = tester.getRect(
      find.byKey(Key('chat_swipe_actions_${category.id}')),
    );
    expect(titleRect.right, lessThan(hideRect.left));
    expect(hideRect.left, greaterThanOrEqualTo(frameRect.left));
    expect(hideRect.right, lessThanOrEqualTo(frameRect.right));
    expect(moreRect.left, greaterThanOrEqualTo(frameRect.left));
    expect(moreRect.right, lessThanOrEqualTo(frameRect.right));
  });

  testWidgets('more menu opens chatinfo and saved messages for one chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_more_productive',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    final message = await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Gespeicherter Satz',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
      incrementUnread: false,
    );
    await repository.updateMessageStarred(chat.id, message.id, isStarred: true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_more_${chat.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('chat_more_saved_${chat.id}')), findsOneWidget);
    expect(find.byKey(Key('chat_more_info_${chat.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('chat_more_saved_${chat.id}')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(Key('chat_saved_messages_sheet_${chat.id}')),
      findsOneWidget,
    );
    expect(find.byKey(Key('chat_saved_message_${message.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('chat_saved_message_${message.id}')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(
      tester
          .widget<ImpulseChatDetailScreen>(find.byType(ImpulseChatDetailScreen))
          .initialMessageId,
      message.id,
    );
  });

  testWidgets('more menu opens local chatinfo sheet', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_info_sheet',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.createCustomAiChat('Training');
    await repository.setChatFavorite(chat.id, true);
    await repository.setChatMuted(chat.id, true);
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Lokaler Verlauf',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.user,
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_more_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_more_info_${chat.id}')));
    await tester.pumpAndSettle();

    expect(find.byKey(Key('chat_info_sheet_${chat.id}')), findsOneWidget);
    expect(find.text('Eigener KI-Chat'), findsOneWidget);
    expect(find.text('1 lokal'), findsOneWidget);
    expect(find.text('Favorit'), findsOneWidget);
    expect(find.text('Stumm'), findsOneWidget);
    expect(find.text('Aktiv'), findsOneWidget);
    expect(
      find.text('Dieser Verlauf ist lokal auf diesem Gerät gespeichert.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'custom AI chat can be renamed cleared and deleted from list menu',
    (tester) async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_inbox_chat_actions_custom',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final custom = await repository.createCustomAiChat('Alter Chat');
      await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: custom.id,
          text: 'Lokaler Verlauf',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.user,
        ),
        incrementUnread: false,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            impulseInboxRepositoryProvider.overrideWithValue(repository),
            impulseInboxAiChatClientProvider.overrideWithValue(
              _FakeAiChatClient('Okay.'),
            ),
          ],
          child: const MaterialApp(home: ImpulsPostfachScreen()),
        ),
      );
      await tester.pumpAndSettle();

      await tester.longPress(find.byKey(Key('impulse_chat_tile_${custom.id}')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(Key('chat_action_rename_${custom.id}')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(Key('chat_action_rename_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const Key('custom_chat_rename_field')),
        'Neuer Chat',
      );
      await tester.tap(
        find.byKey(const Key('custom_chat_rename_confirm_button')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Neuer Chat'), findsOneWidget);

      await tester.longPress(find.byKey(Key('impulse_chat_tile_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('chat_action_more_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('chat_more_clear_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('custom_chat_clear_confirm_button')),
      );
      await tester.pumpAndSettle();

      expect(await repository.listMessages(custom.id), isEmpty);
      expect((await repository.listAllChats()).single.title, 'Neuer Chat');

      await tester.longPress(find.byKey(Key('impulse_chat_tile_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('chat_action_more_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(Key('chat_more_delete_${custom.id}')),
      );
      await tester.tap(find.byKey(Key('chat_more_delete_${custom.id}')));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const Key('custom_chat_delete_confirm_button')),
      );
      await tester.pumpAndSettle();

      expect(await repository.listAllChats(), isEmpty);
      expect(find.text('Neuer Chat'), findsNothing);
    },
  );

  testWidgets('plus button creates custom AI chat without redundant options', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_custom_chat',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('impulse_inbox_add_chat_button')));
    await tester.pumpAndSettle();
    expect(find.text('Eigenen KI-Chat erstellen'), findsOneWidget);
    expect(find.text('Tagesimpuls öffnen'), findsNothing);
    expect(find.text('Kategorie-Chat hinzufügen'), findsNothing);

    await tester.enterText(
      find.byKey(const Key('custom_chat_name_field')),
      'Grammatikfragen',
    );
    await tester.tap(
      find.byKey(const Key('custom_chat_create_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Grammatikfragen'), findsOneWidget);
    expect(find.text('Eigener KI-Chat'), findsOneWidget);

    final chats = await repository.listChats();
    expect(chats.single.sourceType, ImpulseChatSourceType.customAi);
  });

  testWidgets('back from internal tabs returns to chats tab first', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_internal_tab_back',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    for (final tab in ['Du', 'Gespeichert', 'Kategorien']) {
      await tester.tap(find.text(tab).last);
      await tester.pumpAndSettle();
      expect(find.text('Impuls-Postfach'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Impuls-Postfach'), findsOneWidget);
      expect(find.byKey(const Key('impulse_inbox_chat_list')), findsNothing);
      expect(find.text('Noch keine Chats'), findsOneWidget);
    }
  });

  testWidgets('saved tab shows starred messages and opens source chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_saved_tab',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    final message = await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Wichtiger Beispielsatz',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );
    await repository.updateMessageStarred(chat.id, message.id, isStarred: true);
    await repository.setCategoryChatEnabled('seed-category-basics', false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Gespeichert'));
    await tester.pumpAndSettle();

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Wichtiger Beispielsatz'), findsOneWidget);
    expect(find.text('Kategorie-Chat'), findsOneWidget);

    await tester.tap(find.byKey(Key('saved_message_tile_${message.id}')));
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Wichtiger Beispielsatz'), findsOneWidget);
    expect((await repository.listChats()).single.id, chat.id);
  });

  testWidgets(
    'saved message opens chat and highlights target message briefly',
    (tester) async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_inbox_saved_highlight',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureDailyImpulseChat();
      ImpulseMessage? target;
      for (var index = 0; index < 12; index++) {
        final message = await repository.addMessage(
          ImpulseMessage(
            id: '',
            chatId: chat.id,
            text: 'Nachricht $index',
            createdAt: DateTime(2026, 5, 20, 12, index),
            source: index.isEven
                ? ImpulseMessageSource.ai
                : ImpulseMessageSource.user,
            readAt: DateTime(2026, 5, 20, 12, index),
          ),
          incrementUnread: false,
        );
        if (index == 3) target = message;
      }
      await repository.updateMessageStarred(
        chat.id,
        target!.id,
        isStarred: true,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            impulseInboxRepositoryProvider.overrideWithValue(repository),
            impulseInboxAiChatClientProvider.overrideWithValue(
              _FakeAiChatClient('Okay.'),
            ),
          ],
          child: const MaterialApp(home: ImpulsPostfachScreen()),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Gespeichert'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('saved_message_tile_${target.id}')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
      expect(
        tester
            .widget<ImpulseChatDetailScreen>(
              find.byType(ImpulseChatDetailScreen),
            )
            .initialMessageId,
        target.id,
      );
      expect(find.text('Nachricht 3'), findsOneWidget);
      expect(
        find.byKey(
          Key('impulse_message_highlight_${target.id}'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
      expect(
        find.byKey(
          Key('impulse_message_highlight_${target.id}'),
          skipOffstage: false,
        ),
        findsNothing,
      );
    },
  );

  testWidgets('missing target message opens chat without crashing', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_missing_highlight_target',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Bleibt sichtbar',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: MaterialApp(
          home: ImpulseChatDetailScreen(
            chatId: chat.id,
            initialMessageId: 'missing-message',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Bleibt sichtbar'), findsOneWidget);
    expect(
      find.text('Gespeicherte Nachricht wurde nicht gefunden.'),
      findsOneWidget,
    );
  });

  testWidgets('saved tab shows empty state', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_saved_empty',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Gespeichert'));
    await tester.pumpAndSettle();

    expect(find.text('Noch nichts gespeichert'), findsOneWidget);
    expect(
      find.text(
        'Markiere wichtige Impulse, Erklärungen oder Beispielsätze mit einem Stern.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('you tab edits and persists local AI profile', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_you_profile',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Du'));
    await tester.pumpAndSettle();

    expect(
      find.text('Passe an, wie Talvori dir im Chat antwortet.'),
      findsOneWidget,
    );
    expect(find.text('Kurz & direkt'), findsOneWidget);
    expect(find.text('Prüfung'), findsOneWidget);

    await tester.tap(find.text('Trainer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ausführlich'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prüfung'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('impulse_inbox_you_tab_list')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(
        const Key(
          'ai_profile_Erklärungssprache_ImpulseExplanationLanguage.mixed',
        ),
      ),
    );
    await tester.pumpAndSettle();

    final profile = await repository.loadAiProfile();
    expect(profile.style, ImpulseAiStyle.trainer);
    expect(profile.answerLength, ImpulseAnswerLength.detailed);
    expect(profile.learningGoal, ImpulseLearningGoal.exam);
    expect(profile.explanationLanguage, ImpulseExplanationLanguage.mixed);
    expect(find.textContaining('Trainer-Modus'), findsOneWidget);
  });

  testWidgets('chat action sheet edits local AI preferences for one chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_ai_preferences',
    );
    final chat = await repository.createCustomAiChat('Grammatik');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_ai_preferences_${chat.id}')));
    await tester.pumpAndSettle();

    expect(find.text('KI-Stil für diesen Chat'), findsOneWidget);
    expect(
      find.text('Diese Einstellungen gelten nur für diesen Chat.'),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const Key('chat_ai_style_ImpulseAiStyle.trainer')),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('chat_ai_answer_length_ImpulseAnswerLength.short')),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('chat_ai_save_button')));
    await tester.tap(find.byKey(const Key('chat_ai_save_button')));
    await tester.pumpAndSettle();

    var loaded = (await repository.listAllChats()).single;
    expect(loaded.aiProfileOverride.style, ImpulseAiStyle.trainer);
    expect(loaded.aiProfileOverride.answerLength, ImpulseAnswerLength.short);

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_ai_preferences_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('chat_ai_reset_button')));
    await tester.tap(find.byKey(const Key('chat_ai_reset_button')));
    await tester.pumpAndSettle();

    loaded = (await repository.listAllChats()).single;
    expect(loaded.hasAiProfileOverride, isFalse);
  });

  testWidgets('chat info shows AI preference status and action', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_chat_info_ai_preferences',
    );
    final chat = await repository.createCustomAiChat('Grammatik');
    await repository.updateChatAiProfileOverride(
      chat.id,
      const ImpulseChatAiProfileOverride(style: ImpulseAiStyle.casual),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.byKey(Key('impulse_chat_tile_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_action_more_${chat.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('chat_more_info_${chat.id}')));
    await tester.pumpAndSettle();

    expect(find.text('KI-Stil'), findsOneWidget);
    expect(find.text('Eigene Einstellungen'), findsOneWidget);
    expect(find.textContaining('Locker'), findsOneWidget);
    expect(
      find.byKey(Key('chat_info_ai_preferences_${chat.id}')),
      findsOneWidget,
    );
  });

  testWidgets('you tab manages hidden chats and reactivates category chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_you_hidden_management',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final hidden = await repository.ensureCategoryChat(
      'seed-category-travel',
      'Travel',
    );
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: hidden.id,
        text: 'Alter Verlauf bleibt',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
      incrementUnread: false,
    );
    await repository.setCategoryChatEnabled('seed-category-travel', false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Du'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const Key('chat_management_panel'), skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('Ausgeblendet · 1', skipOffstage: false), findsOneWidget);

    await tester.drag(
      find.byKey(const Key('impulse_inbox_you_tab_list')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manage_hidden_chats_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('hidden_chats_list')), findsOneWidget);
    expect(find.byKey(Key('hidden_chat_tile_${hidden.id}')), findsOneWidget);

    await tester.tap(find.byKey(Key('hidden_chat_reactivate_${hidden.id}')));
    await tester.pumpAndSettle();

    final reactivated = await repository.getCategoryChat(
      'seed-category-travel',
    );
    expect(reactivated?.enabled, isTrue);
    expect(
      (await repository.listMessages(hidden.id)).single.text,
      'Alter Verlauf bleibt',
    );
    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
  });

  testWidgets('you tab shows favorite chats overview and opens them', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_you_favorites',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final favorite = await repository.createCustomAiChat('Lieblingschat');
    await repository.setChatFavorite(favorite.id, true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Du'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('impulse_inbox_you_tab_list')),
      const Offset(0, -900),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('favorite_chats_panel')), findsOneWidget);
    expect(find.text('Lieblingschat'), findsOneWidget);

    await tester.tap(find.byKey(Key('favorite_chat_tile_${favorite.id}')));
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Lieblingschat'), findsOneWidget);
  });

  testWidgets('hidden custom chat can be locally deleted from management', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_you_hidden_custom_delete',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final custom = await repository.createCustomAiChat('Grammatikfragen');
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: custom.id,
        text: 'Lokaler Verlauf',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.user,
      ),
      incrementUnread: false,
    );
    await repository.setChatEnabled(custom.id, false);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Du'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const Key('impulse_inbox_you_tab_list')),
      const Offset(0, -420),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('manage_hidden_chats_button')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('hidden_chat_delete_${custom.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Eigenen Chat löschen?'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('custom_chat_delete_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(await repository.listAllChats(), isEmpty);
    expect(await repository.listMessages(custom.id), isEmpty);
  });

  testWidgets('category tab can add and reactivate category chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_category_tab',
    );
    final categoryItems = [
      ...const LocalCategoryDetailGroupResolver()
          .resolve('health_fitness')
          .map(
            (item) => item.wordHubKey == 'health_fitness'
                ? item.copyWith(
                    localCategoryId: _healthWordWorldId,
                    vocabsCount: 3,
                  )
                : item.localCategoryId == null
                ? item
                : item.copyWith(vocabsCount: 3),
          ),
      const LocalCategoryDetailGroupItem(
        wordHubKey: 'missing-chat-category',
        displayLabel: 'Missing Chat Category',
        localCategoryId: 'seed-category-missing',
        vocabsCount: 3,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoryDetailGroupItemsProvider.overrideWith(
            (ref, wordHubKey) async => categoryItems,
          ),
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Kategorien').last);
    await tester.pumpAndSettle();
    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Hinzufügen'), findsWidgets);

    await tester.tap(
      find.byKey(Key('impulse_inbox_category_tile_$_healthWordWorldId')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);

    await repository.setCategoryChatEnabled(_healthWordWorldId, false);
    await repository.ensureCategoryChat(_healthWordWorldId, 'Health & Fitness');
    final chat = await repository.getCategoryChat(_healthWordWorldId);
    expect(chat?.enabled, isTrue);
  });

  testWidgets('category tab shows active hidden and missing chat statuses', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_category_statuses',
    );
    await repository.ensureCategoryChat(_healthWordWorldId, 'Health & Fitness');
    await repository.ensureCategoryChat('seed-category-travel', 'Travel');
    await repository.setCategoryChatEnabled('seed-category-travel', false);
    final categoryItems = [
      ...const LocalCategoryDetailGroupResolver()
          .resolve('health_fitness')
          .map(
            (item) => item.wordHubKey == 'health_fitness'
                ? item.copyWith(
                    localCategoryId: _healthWordWorldId,
                    vocabsCount: 3,
                  )
                : item.localCategoryId == null
                ? item
                : item.copyWith(vocabsCount: 3),
          ),
      const LocalCategoryDetailGroupItem(
        wordHubKey: 'missing-chat-category',
        displayLabel: 'Missing Chat Category',
        localCategoryId: 'seed-category-missing',
        vocabsCount: 3,
      ),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localCategoryDetailGroupItemsProvider.overrideWith(
            (ref, wordHubKey) async => categoryItems,
          ),
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Okay.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Kategorien').last);
    await tester.pumpAndSettle();

    expect(find.text('Aktiv'), findsOneWidget);
    expect(find.text('Ausgeblendet'), findsOneWidget);
    expect(find.text('Noch kein Chat'), findsWidgets);
    expect(find.text('Wieder einblenden'), findsOneWidget);
  });

  testWidgets('chat list shows active category chat and hides disabled one', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_category_chat_list',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final activeChat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    await repository.ensureCategoryChat('seed-category-travel', 'Travel');
    await repository.setCategoryChatEnabled('seed-category-travel', false);
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: activeChat.id,
        text: 'Was bedeutet move?',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.user,
        readAt: DateTime(2026, 5, 20, 12),
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Was bedeutet move?'), findsOneWidget);
    expect(find.text('Travel'), findsNothing);
  });

  testWidgets('chat detail shows bubble and marks chat as read', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_detail',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'You moved like a superstar.',
        usedWords: ['move', 'superstar'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();
    await tester.tap(
      find.byKey(
        const Key(
          'impulse_chat_tile_${SharedPreferencesImpulseInboxRepository.dailyImpulseChatId}',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('You moved like a superstar.'), findsOneWidget);
    expect(
      find.byKey(const Key('impulse_chat_date_separator')),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget.key is ValueKey<String> &&
            (widget.key! as ValueKey<String>).value.startsWith(
              'impulse_message_bubble_',
            ),
      ),
      findsOneWidget,
    );
    expect(find.text('move'), findsOneWidget);
    expect(find.text('superstar'), findsOneWidget);

    final chats = await repository.listChats();
    expect(chats.single.unreadCount, 0);
  });

  testWidgets('category chat detail shows category title and empty hint', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_category_detail',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basics'), findsOneWidget);
    expect(find.text('Kategorie-Chat'), findsOneWidget);
    expect(find.text('Noch keine Nachrichten'), findsOneWidget);
    expect(
      find.text('Stelle Talvori eine Frage zu dieser Kategorie.'),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category_chat_options_button')),
      findsOneWidget,
    );
  });

  testWidgets('daily impulse chat does not show category disable action', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_daily_no_disable_action',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('category_chat_options_button')), findsNothing);
  });

  testWidgets('category chat can be disabled without deleting messages', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_category_disable',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    await repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chat.id,
        text: 'Alte lokale Nachricht',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Basics'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('category_chat_options_button')));
    await tester.pumpAndSettle();
    expect(find.text('Kategorie-Chat deaktivieren?'), findsOneWidget);
    await tester.tap(
      find.byKey(const Key('category_chat_disable_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.text('Basics'), findsNothing);
    expect(await repository.listChats(), isEmpty);
    expect(
      (await repository.listMessages(chat.id)).single.text,
      'Alte lokale Nachricht',
    );

    final reactivated = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    expect(reactivated.id, chat.id);
    expect((await repository.listChats()).single.id, chat.id);
    expect(
      (await repository.listMessages(chat.id)).single.text,
      'Alte lokale Nachricht',
    );
  });

  testWidgets('chat detail renders assistant left and user right bubbles', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_bubble_alignment',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'assistant-message',
        chatId: chat.id,
        text: 'Assistant impulse',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );
    await repository.addMessage(
      ImpulseMessage(
        id: 'user-message',
        chatId: chat.id,
        text: 'User response',
        createdAt: DateTime(2026, 5, 20, 12, 1),
        source: ImpulseMessageSource.user,
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final assistantAlign = tester.widget<Align>(
      find
          .ancestor(
            of: find.text('Assistant impulse'),
            matching: find.byType(Align),
          )
          .first,
    );
    final userAlign = tester.widget<Align>(
      find
          .ancestor(
            of: find.text('User response'),
            matching: find.byType(Align),
          )
          .first,
    );

    expect(assistantAlign.alignment, Alignment.centerLeft);
    expect(userAlign.alignment, Alignment.centerRight);
    expect(find.byIcon(Icons.done_all_rounded), findsNothing);
  });

  testWidgets('short user messages stay compact like chat bubbles', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_compact_short_bubble',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'short-user-message',
        chatId: chat.id,
        text: 'ok',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.user,
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final bubbleSize = tester.getSize(
      find.byKey(const Key('impulse_message_bubble_short-user-message')),
    );
    final screenWidth = tester.getSize(find.byType(Scaffold)).width;

    expect(bubbleSize.width, lessThan(screenWidth * 0.35));
    expect(find.text('ok'), findsOneWidget);
  });

  testWidgets('emoji-only messages render outside regular bubbles', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_emoji_only_message',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'emoji-only-message',
        chatId: chat.id,
        text: '👍',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.user,
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_message_emoji_emoji-only-message')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('impulse_message_bubble_emoji-only-message')),
      findsNothing,
    );
    expect(find.text('👍'), findsOneWidget);
  });

  testWidgets('text with emoji remains a regular bubble', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_text_with_emoji_message',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'text-with-emoji-message',
        chatId: chat.id,
        text: 'ok 😊',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.user,
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_message_bubble_text-with-emoji-message')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('impulse_message_emoji_text-with-emoji-message')),
      findsNothing,
    );
    expect(find.text('ok 😊'), findsOneWidget);
  });

  testWidgets('consecutive messages are grouped with tail only on the last', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_grouped_bubbles',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'grouped-first',
        chatId: chat.id,
        text: 'First impulse',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );
    await repository.addMessage(
      ImpulseMessage(
        id: 'grouped-second',
        chatId: chat.id,
        text: 'Second impulse',
        createdAt: DateTime(2026, 5, 20, 12, 1),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_message_tail_grouped-first')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('impulse_message_tail_grouped-second')),
      findsOneWidget,
    );
  });

  testWidgets('long press opens action menu and stores emoji reaction', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_message_reaction',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'react-message',
        chatId: chat.id,
        text: 'Reactable impulse',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Reactable impulse'));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_message_action_menu')),
      findsOneWidget,
    );
    expect(find.text('Antworten'), findsOneWidget);
    expect(find.text('Kopieren'), findsOneWidget);

    await tester.tap(find.byKey(const Key('impulse_message_reaction_👍')));
    await tester.pumpAndSettle();

    final loaded = (await repository.listMessages(chat.id)).single;
    expect(loaded.reaction, '👍');
    expect(
      find.byKey(const Key('impulse_message_reaction_react-message')),
      findsOneWidget,
    );
  });

  testWidgets('message action menu can copy and toggle star', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_message_copy_star',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'star-message',
        chatId: chat.id,
        text: 'Star this impulse',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Star this impulse'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('impulse_message_action_Kopieren')));
    await tester.pump();

    await tester.longPress(find.text('Star this impulse'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('impulse_message_action_Mit Stern markieren')),
    );
    await tester.pumpAndSettle();

    final loaded = (await repository.listMessages(chat.id)).single;
    expect(loaded.isStarred, isTrue);
    expect(find.byKey(const Key('impulse_message_star_icon')), findsOneWidget);
  });

  testWidgets('reply action stores reply metadata when sending', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_message_reply',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    final original = await repository.addMessage(
      ImpulseMessage(
        id: 'reply-source-message',
        chatId: chat.id,
        text: 'Original impulse message',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('Original impulse message'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('impulse_message_action_Antworten')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('impulse_chat_reply_preview')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('impulse_chat_message_input')),
      'Meine Antwort',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('impulse_chat_send_button')));
    await tester.pumpAndSettle();

    final messages = await repository.listMessages(chat.id);
    final userMessage = messages.firstWhere(
      (message) => message.text == 'Meine Antwort',
    );
    expect(userMessage.replyToMessageId, original.id);
    expect(userMessage.replyPreviewText, 'Original impulse message');
    expect(
      find.byKey(Key('impulse_message_reply_preview_${userMessage.id}')),
      findsOneWidget,
    );
  });

  testWidgets('delete action removes assistant and user messages', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_message_delete',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'delete-assistant',
        chatId: chat.id,
        text: 'Assistant delete me',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );
    await repository.addMessage(
      ImpulseMessage(
        id: 'delete-user',
        chatId: chat.id,
        text: 'User delete me',
        createdAt: DateTime(2026, 5, 20, 12, 1),
        source: ImpulseMessageSource.user,
        readAt: DateTime(2026, 5, 20, 12, 1),
      ),
      incrementUnread: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('User delete me'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('impulse_message_action_Löschen')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('impulse_message_delete_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('User delete me'), findsNothing);

    await tester.longPress(find.text('Assistant delete me'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('impulse_message_action_Löschen')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const Key('impulse_message_delete_confirm_button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Assistant delete me'), findsNothing);
    expect(await repository.listMessages(chat.id), isEmpty);
    expect((await repository.listChats()).single.lastMessageText, isNull);
  });

  testWidgets('more action opens secondary menu', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_message_more',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'more-message',
        chatId: chat.id,
        text: 'More options',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.longPress(find.text('More options'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('impulse_message_action_Mehr ...')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('impulse_message_more_menu')), findsOneWidget);
    expect(find.text('Fixieren'), findsOneWidget);
    expect(find.text('Sprechen'), findsOneWidget);
    expect(find.text('Übersetzen'), findsOneWidget);
  });

  testWidgets('chat input sends user message and stores AI reply', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_send_message',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'You moved like a superstar.',
        usedWords: ['move'],
      ),
    ]);
    final aiClient = _FakeAiChatClient('Natürlich. Move bedeutet bewegen.');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(aiClient),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('impulse_chat_message_input')), findsOneWidget);
    expect(
      find.byKey(const Key('impulse_chat_microphone_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('impulse_chat_send_button')), findsNothing);

    await tester.enterText(
      find.byKey(const Key('impulse_chat_message_input')),
      'Was bedeutet move?',
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      find.byKey(const Key('impulse_chat_microphone_button')),
      findsNothing,
    );
    final activeButton = tester.widget<IconButton>(
      find.byKey(const Key('impulse_chat_send_button')),
    );
    expect(activeButton.onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('impulse_chat_send_button')));
    await tester.pumpAndSettle();

    expect(find.text('Was bedeutet move?'), findsOneWidget);
    expect(find.text('Natürlich. Move bedeutet bewegen.'), findsOneWidget);
    expect(aiClient.requests.single.message, 'Was bedeutet move?');

    final messages = await repository.listMessages(chat.id);
    expect(
      messages.map((message) => message.text),
      contains('Was bedeutet move?'),
    );
    expect(
      messages.map((message) => message.text),
      contains('Natürlich. Move bedeutet bewegen.'),
    );
    expect(
      messages
          .firstWhere((message) => message.text == 'Was bedeutet move?')
          .source,
      ImpulseMessageSource.user,
    );
    expect((await repository.listChats()).single.unreadCount, 0);
  });

  testWidgets('category chat sends category context to AI client', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_category_send_message',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    final aiClient = _FakeAiChatClient('Move passt gut zu Basics.');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(aiClient),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('impulse_chat_message_input')),
      'Gib mir einen Beispielsatz.',
    );
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.byKey(const Key('impulse_chat_send_button')));
    await tester.pumpAndSettle();

    expect(find.text('Gib mir einen Beispielsatz.'), findsOneWidget);
    expect(find.text('Move passt gut zu Basics.'), findsOneWidget);
    final context = aiClient.requests.single.context as Map<String, Object?>;
    expect(context['chatType'], 'category');
    expect(context['categoryId'], 'seed-category-basics');
    expect(context['categoryTitle'], 'Basics');
  });

  test('category chat sends read-only word sample to AI context', () async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_category_word_context',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    final aiClient = _FakeAiChatClient('Antwort');
    final controller = ImpulseInboxController(
      repository: repository,
      aiChatClient: aiClient,
      categoryWordSampler: (categoryId) async => [
        {'word': 'move', 'translation': 'bewegen'},
        {'word': 'serve', 'translation': 'servieren'},
      ],
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await controller.loadChats();

    await controller.sendChatMessage(chat.id, 'Nutze ein Wort.');

    final context = aiClient.requests.single.context as Map<String, Object?>;
    expect(context['chatType'], 'category');
    expect(context['categoryWordsSample'], isA<List<Map<String, String>>>());
    expect((context['categoryWordsSample'] as List).first['word'], 'move');
    expect(
      context['categoryWordsInstruction'],
      contains('Verändere keine Lernstände'),
    );
  });

  test(
    'AI profile is included in chat context beside category context',
    () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_inbox_ai_profile_context',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      await repository.saveAiProfile(
        const ImpulseAiProfile(
          style: ImpulseAiStyle.trainer,
          answerLength: ImpulseAnswerLength.short,
          learningGoal: ImpulseLearningGoal.school,
          explanationLanguage: ImpulseExplanationLanguage.mixed,
        ),
      );
      final chat = await repository.ensureCategoryChat(
        'seed-category-basics',
        'Basics',
      );
      final aiClient = _FakeAiChatClient('Antwort');
      final controller = ImpulseInboxController(
        repository: repository,
        aiChatClient: aiClient,
        categoryWordSampler: (categoryId) async => [
          {'word': 'move', 'translation': 'bewegen'},
        ],
        clock: () => DateTime(2026, 5, 20, 12),
      );
      await controller.loadChats();

      await controller.sendChatMessage(chat.id, 'Erklär das bitte.');

      final context = aiClient.requests.single.context as Map<String, Object?>;
      expect(context['aiStyle'], 'trainer');
      expect(context['answerLength'], 'short');
      expect(context['learningGoal'], 'school');
      expect(context['explanationLanguage'], 'mixed');
      expect(context['chatType'], 'category');
      expect(context['categoryWordsSample'], isA<List<Map<String, String>>>());
    },
  );

  test(
    'chat AI overrides replace global profile values in chat context',
    () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_inbox_ai_profile_override_context',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      await repository.saveAiProfile(
        const ImpulseAiProfile(
          style: ImpulseAiStyle.motivating,
          answerLength: ImpulseAnswerLength.normal,
          learningGoal: ImpulseLearningGoal.everyday,
          explanationLanguage: ImpulseExplanationLanguage.german,
        ),
      );
      final chat = await repository.ensureCategoryChat(
        'seed-category-basics',
        'Basics',
      );
      await repository.updateChatAiProfileOverride(
        chat.id,
        const ImpulseChatAiProfileOverride(
          style: ImpulseAiStyle.trainer,
          answerLength: ImpulseAnswerLength.detailed,
        ),
      );
      final aiClient = _FakeAiChatClient('Antwort');
      final controller = ImpulseInboxController(
        repository: repository,
        aiChatClient: aiClient,
        categoryWordSampler: (categoryId) async => [
          {'word': 'move', 'translation': 'bewegen'},
        ],
        clock: () => DateTime(2026, 5, 20, 12),
      );
      await controller.loadChats();

      await controller.sendChatMessage(chat.id, 'Erklär das bitte.');

      final context = aiClient.requests.single.context as Map<String, Object?>;
      expect(context['aiStyle'], 'trainer');
      expect(context['answerLength'], 'detailed');
      expect(context['learningGoal'], 'everyday');
      expect(context['explanationLanguage'], 'german');
      expect(context['aiProfileSource'], 'chat_override');
      expect(context['chatType'], 'category');
      expect(context['categoryWordsSample'], isA<List<Map<String, String>>>());
    },
  );

  test('audio message transcript is sent to AI beside chat context', () async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_audio_transcript_context',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureCategoryChat(
      'seed-category-basics',
      'Basics',
    );
    final aiClient = _FakeAiChatClient('Das passt zu deiner Kategorie.');
    final controller = ImpulseInboxController(
      repository: repository,
      aiChatClient: aiClient,
      categoryWordSampler: (categoryId) async => [
        {'word': 'move', 'translation': 'bewegen'},
      ],
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await controller.loadChats();

    await controller.sendChatAudioMessage(
      chat.id,
      audioPath: '/tmp/talvori-audio-context.m4a',
      durationMs: 2400,
      waveformSeed: 9,
      audioTranscript: 'Kannst du mir move erklären?',
      audioLanguage: 'de_DE',
    );

    expect(aiClient.requests.single.message, 'Kannst du mir move erklären?');
    final context = aiClient.requests.single.context as Map<String, Object?>;
    expect(context['chatType'], 'category');
    expect(context['categoryWordsSample'], isA<List<Map<String, String>>>());
    expect(context['voiceMessageTranscript'], 'Kannst du mir move erklären?');
    expect(context['voiceMessageInstruction'], contains('gesprochen'));
    final messages = await repository.listMessages(chat.id);
    expect(
      messages.any(
        (message) =>
            message.contentType == ImpulseMessageContentType.audio &&
            message.audioTranscript == 'Kannst du mir move erklären?' &&
            message.audioLanguage == 'de_DE',
      ),
      isTrue,
    );
    expect(
      messages.any(
        (message) => message.text == 'Das passt zu deiner Kategorie.',
      ),
      isTrue,
    );
  });

  test(
    'audio message without transcript is stored without AI request',
    () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_inbox_audio_without_transcript',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureDailyImpulseChat();
      final aiClient = _FakeAiChatClient('Sollte nicht gerufen werden.');
      final controller = ImpulseInboxController(
        repository: repository,
        aiChatClient: aiClient,
        clock: () => DateTime(2026, 5, 20, 12),
      );
      await controller.loadChats();

      await controller.sendChatAudioMessage(
        chat.id,
        audioPath: '/tmp/talvori-audio-no-transcript.m4a',
        durationMs: 2400,
      );

      expect(aiClient.requests, isEmpty);
      expect(
        controller.state.chatErrors[chat.id],
        'Ich konnte die Sprachnachricht nicht erkennen.',
      );
      final messages = await repository.listMessages(chat.id);
      expect(messages.single.contentType, ImpulseMessageContentType.audio);
      expect(messages.single.audioTranscript, isNull);
    },
  );

  testWidgets('holding microphone starts recording UI and sends audio bubble', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_message_hold',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    final voiceService = _FakeVoiceMessageService(
      stopResult: const ImpulseVoiceMessageResult.completed(
        audioPath: '/tmp/talvori-voice-hold.m4a',
        durationMs: 2400,
        waveformSeed: 7,
        transcript: 'Erkläre mir move.',
        language: 'de_DE',
      ),
    );
    final aiClient = _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(aiClient),
          impulseVoiceMessageServiceProvider.overrideWithValue(voiceService),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_chat_microphone_button')),
      findsOneWidget,
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('impulse_chat_microphone_button'))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    expect(
      find.byKey(const Key('impulse_voice_recording_bar')),
      findsOneWidget,
    );
    expect(find.text('← Wischen zum Abbrechen'), findsOneWidget);
    expect(find.text('hoch sperren'), findsNothing);
    expect(find.text('hoch'), findsOneWidget);
    expect(
      find.byKey(const Key('impulse_voice_cancel_hint_right')),
      findsOneWidget,
    );
    final barRect = tester.getRect(
      find.byKey(const Key('impulse_voice_recording_bar')),
    );
    final lockRect = tester.getRect(
      find.byKey(const Key('impulse_voice_lock_button')),
    );
    final scaffoldRect = tester.getRect(find.byType(Scaffold));
    expect(lockRect.right, lessThanOrEqualTo(scaffoldRect.right));
    expect(lockRect.left, greaterThanOrEqualTo(scaffoldRect.left));
    expect(lockRect.top, lessThan(barRect.top));
    await gesture.up();
    await tester.pumpAndSettle();

    final messages = await repository.listMessages(chat.id);
    final audioMessage = messages.singleWhere(
      (message) => message.contentType == ImpulseMessageContentType.audio,
    );
    expect(audioMessage.localAudioPath, '/tmp/talvori-voice-hold.m4a');
    expect(audioMessage.audioDurationMs, 2400);
    expect(audioMessage.audioTranscript, 'Erkläre mir move.');
    expect(audioMessage.audioLanguage, 'de_DE');
    expect(audioMessage.source, ImpulseMessageSource.user);
    expect(
      find.byKey(Key('impulse_message_audio_${audioMessage.id}')),
      findsOneWidget,
    );
    expect(voiceService.startCalls, 1);
    expect(voiceService.lastLocaleId, 'de_DE');
    expect(voiceService.stopCalls, 1);
    expect(aiClient.requests.single.message, 'Erkläre mir move.');
  });

  testWidgets('locked recording shows pause delete and send controls', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_locked',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    final voiceService = _FakeVoiceMessageService(
      stopResult: const ImpulseVoiceMessageResult.completed(
        audioPath: '/tmp/talvori-voice-locked.m4a',
        durationMs: 5100,
        waveformSeed: 13,
        transcript: 'Wie nutze ich dieses Wort?',
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Das erklaere ich dir kurz.'),
          ),
          impulseVoiceMessageServiceProvider.overrideWithValue(voiceService),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('impulse_chat_microphone_button'))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await gesture.moveBy(const Offset(0, -90));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_voice_locked_controls')),
      findsOneWidget,
    );
    expect(voiceService.stopCalls, 0);
    final silentHeight = tester
        .getSize(find.byKey(const Key('impulse_voice_locked_waveform_bar_1')))
        .height;
    voiceService.emitAmplitude(0.9);
    await tester.pump(const Duration(milliseconds: 220));
    final speakingHeight = tester
        .getSize(find.byKey(const Key('impulse_voice_locked_waveform_bar_1')))
        .height;
    expect(speakingHeight, greaterThan(silentHeight));
    expect(
      find.byKey(const Key('impulse_voice_delete_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('impulse_voice_pause_button')), findsOneWidget);
    expect(find.byKey(const Key('impulse_voice_send_button')), findsOneWidget);

    await tester.tap(find.byKey(const Key('impulse_voice_pause_button')));
    await tester.pump();
    expect(voiceService.pauseCalls, 1);
    await tester.tap(find.byKey(const Key('impulse_voice_pause_button')));
    await tester.pump();
    expect(voiceService.resumeCalls, 1);

    await tester.tap(find.byKey(const Key('impulse_voice_send_button')));
    await tester.pumpAndSettle();

    final messages = await repository.listMessages(chat.id);
    expect(
      messages.any(
        (message) =>
            message.contentType == ImpulseMessageContentType.audio &&
            message.localAudioPath == '/tmp/talvori-voice-locked.m4a',
      ),
      isTrue,
    );
  });

  testWidgets('locked delete closes recording without sending or snackbar', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_locked_delete',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    final voiceService = _FakeVoiceMessageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Das erklaere ich dir kurz.'),
          ),
          impulseVoiceMessageServiceProvider.overrideWithValue(voiceService),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('impulse_chat_microphone_button'))),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_voice_locked_controls')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const Key('impulse_voice_delete_button')));
    await tester.pump();

    expect(
      find.byKey(const Key('impulse_voice_locked_controls')),
      findsNothing,
    );
    expect(
      find.byKey(const Key('impulse_voice_discard_animation')),
      findsOneWidget,
    );
    expect(find.text('Aufnahme verworfen.'), findsNothing);
    expect(voiceService.cancelCalls, 1);
    expect(voiceService.stopCalls, 0);
    expect(await repository.listMessages(chat.id), isEmpty);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('quick microphone tap starts locked recording mode', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_quick_tap',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    final voiceService = _FakeVoiceMessageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
          impulseVoiceMessageServiceProvider.overrideWithValue(voiceService),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('impulse_chat_microphone_button'))),
    );
    await tester.pump(const Duration(milliseconds: 80));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_voice_locked_controls')),
      findsOneWidget,
    );
    expect(voiceService.startCalls, 1);
    expect(voiceService.cancelCalls, 0);
    expect(voiceService.stopCalls, 0);
    expect(await repository.listMessages(chat.id), isEmpty);
  });

  testWidgets('swiping left cancels voice recording', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_cancel',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    final voiceService = _FakeVoiceMessageService();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
          impulseVoiceMessageServiceProvider.overrideWithValue(voiceService),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('impulse_chat_microphone_button'))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await gesture.moveBy(const Offset(-90, 0));
    await tester.pumpAndSettle();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Aufnahme verworfen.'), findsNothing);
    expect(
      find.byKey(const Key('impulse_voice_discard_animation')),
      findsOneWidget,
    );
    expect(voiceService.cancelCalls, 1);
    expect(voiceService.stopCalls, 0);
    expect(await repository.listMessages(chat.id), isEmpty);
    await tester.pump(const Duration(milliseconds: 600));
  });

  testWidgets('voice permission denied shows a controlled message', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_denied',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
          impulseVoiceMessageServiceProvider.overrideWithValue(
            _FakeVoiceMessageService(
              startResult: ImpulseVoiceMessageResult.denied(),
            ),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('impulse_chat_microphone_button'))),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(find.text('Mikrofon nicht erlaubt.'), findsOneWidget);
    expect(
      find.byKey(const Key('impulse_chat_microphone_button')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('impulse_chat_send_button')), findsNothing);
  });

  testWidgets('tapping chat history dismisses the keyboard', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_dismiss_keyboard',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();
    await repository.addMessage(
      ImpulseMessage(
        id: 'keyboard-message',
        chatId: chat.id,
        text: 'Keyboard test',
        createdAt: DateTime(2026, 5, 20, 12),
        source: ImpulseMessageSource.ai,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            _FakeAiChatClient('Gern, hier ist ein kurzer Kontext.'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('impulse_chat_message_input')));
    await tester.pump();
    expect(tester.testTextInput.isVisible, isTrue);

    await tester.tap(find.byKey(const Key('impulse_chat_message_list')));
    await tester.pump();

    expect(tester.testTextInput.isVisible, isFalse);
  });

  testWidgets('chat input shows error when AI reply fails', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_send_error',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final chat = await repository.ensureDailyImpulseChat();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
          impulseInboxAiChatClientProvider.overrideWithValue(
            const _FailingAiChatClient(),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('impulse_chat_message_input')),
      'Kannst du helfen?',
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('impulse_chat_send_button')));
    await tester.pumpAndSettle();

    expect(find.text('Kannst du helfen?'), findsOneWidget);
    expect(find.byKey(const Key('impulse_chat_error_message')), findsOneWidget);
    expect(
      find.text('KI-Antwort konnte nicht erzeugt werden.'),
      findsOneWidget,
    );
  });

  testWidgets('opening chat removes unread badge after returning to inbox', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_badge_read',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Read state lands here.',
        usedWords: ['read'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('impulse_inbox_unread_badge')), findsOneWidget);

    await tester.tap(
      find.byKey(
        const Key(
          'impulse_chat_tile_${SharedPreferencesImpulseInboxRepository.dailyImpulseChatId}',
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.byKey(const Key('impulse_inbox_unread_badge')), findsNothing);
    expect((await repository.listChats()).single.unreadCount, 0);
  });

  testWidgets('notification tap opens impulse chat detail', (tester) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_route',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final messages = await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'A small impulse lands here.',
        usedWords: ['impulse'],
      ),
    ]);
    final chats = await repository.listChats();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pump();

    ImpulseInboxNotificationRouter.handlePayload(
      ImpulseInboxNotificationPayload.encodeImpulseMessage(
        chatId: chats.single.id,
        messageId: messages.single.id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(
      NotificationTapDebugStore.value.value.lastParsedType,
      'impulse_message',
    );
    expect(NotificationTapDebugStore.value.value.lastChatId, chats.single.id);
    expect(
      NotificationTapDebugStore.value.value.lastMessageId,
      messages.single.id,
    );
    expect(
      NotificationTapDebugStore.value.value.lastRouteTarget,
      'chat_detail',
    );
    expect(
      NotificationTapDebugStore.value.value.lastRouteResult,
      'success_stack_home_inbox_chat_detail',
    );
    expect(find.text('A small impulse lands here.'), findsOneWidget);
    expect(find.text('Tagesimpuls'), findsOneWidget);
    expect(find.byType(ImpulsPostfachScreen), findsNothing);
    expect(find.byType(CourseScreen), findsNothing);
    expect((await repository.listChats()).single.unreadCount, 0);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsNothing);
    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.text('Impuls-Postfach'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(ImpulsPostfachScreen), findsNothing);
  });

  testWidgets('notification route removes visible Tagesimpuls route', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_replaces_tagesimpuls_route',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final messages = await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Visible chat wins.',
        usedWords: ['visible'],
      ),
    ]);
    final chats = await repository.listChats();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pump();

    ImpulseInboxNotificationRouter.navigatorKey.currentState!.push(
      MaterialPageRoute(
        builder: (_) => const Scaffold(body: Text('Tagesimpuls-Bereich')),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Tagesimpuls-Bereich'), findsOneWidget);

    ImpulseInboxNotificationRouter.handlePayload(
      ImpulseInboxNotificationPayload.encodeImpulseMessage(
        chatId: chats.single.id,
        messageId: messages.single.id,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Visible chat wins.'), findsOneWidget);
    expect(find.text('Tagesimpuls-Bereich'), findsNothing);
    expect(
      NotificationTapDebugStore.value.value.lastRouteResult,
      'success_stack_home_inbox_chat_detail',
    );

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.text('Tagesimpuls-Bereich'), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tagesimpuls-Bereich'), findsNothing);
  });

  testWidgets('simulated impulse payload opens impulse chat detail', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_simulated_route',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final messages = await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Simulated payload lands here.',
        usedWords: ['simulate'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pump();

    ImpulseInboxNotificationRouter.simulateImpulseMessage(
      messageId: messages.single.id,
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Simulated payload lands here.'), findsOneWidget);
    expect(find.byType(CourseScreen), findsNothing);
  });

  testWidgets('cold-start notification payload is queued and flushed', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_cold_start',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    final messages = await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Cold start impulse.',
        usedWords: ['impulse'],
      ),
    ]);
    final chats = await repository.listChats();

    ImpulseInboxNotificationRouter.handlePayload(
      ImpulseInboxNotificationPayload.encodeImpulseMessage(
        chatId: chats.single.id,
        messageId: messages.single.id,
      ),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pumpAndSettle();

    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Cold start impulse.'), findsOneWidget);
  });

  testWidgets('malformed impulse inbox payload falls back to inbox', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_fallback',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pump();

    ImpulseInboxNotificationRouter.handlePayload('impuls-postfach::message-1');
    await tester.pumpAndSettle();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.byType(ImpulseChatDetailScreen), findsNothing);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(ImpulsPostfachScreen), findsNothing);
  });

  testWidgets('unknown notification payload falls back to inbox', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_unknown_fallback',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pump();

    ImpulseInboxNotificationRouter.handlePayload('tagesimpuls:test');
    await tester.pumpAndSettle();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.byType(ImpulseChatDetailScreen), findsNothing);
  });

  testWidgets('missing chat in notification payload falls back to inbox', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_notification_missing_chat_fallback',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          navigatorKey: ImpulseInboxNotificationRouter.navigatorKey,
          home: const Scaffold(body: Text('Home')),
        ),
      ),
    );
    await tester.pump();
    ImpulseInboxNotificationRouter.markReady();
    await tester.pump();

    ImpulseInboxNotificationRouter.handlePayload(
      ImpulseInboxNotificationPayload.encodeImpulseMessage(
        chatId: 'missing-chat',
        messageId: 'message-1',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.byType(ImpulseChatDetailScreen), findsNothing);
  });
}

class _FakeAiChatClient implements AiChatClient {
  _FakeAiChatClient(this.reply);

  final String reply;
  final List<AiChatRequest> requests = [];

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) async {
    requests.add(request);
    return AiChatResult(reply: reply);
  }
}

class _FailingAiChatClient implements AiChatClient {
  const _FailingAiChatClient();

  @override
  Future<AiChatResult> sendMessage(AiChatRequest request) {
    throw const AiChatException('ai_request_failed');
  }
}

class _FakeVoiceMessageService implements ImpulseVoiceMessageService {
  _FakeVoiceMessageService({
    this.startResult = const ImpulseVoiceMessageResult.started(),
    this.stopResult = const ImpulseVoiceMessageResult.completed(
      audioPath: '/tmp/talvori-voice.m4a',
      durationMs: 2200,
      waveformSeed: 5,
    ),
  });

  final ImpulseVoiceMessageResult startResult;
  final ImpulseVoiceMessageResult stopResult;
  final _amplitudeController = StreamController<double>.broadcast();

  int startCalls = 0;
  int stopCalls = 0;
  int cancelCalls = 0;
  int pauseCalls = 0;
  int resumeCalls = 0;
  int playCalls = 0;
  int stopPlaybackCalls = 0;
  String? lastLocaleId;

  void emitAmplitude(double level) {
    _amplitudeController.add(level);
  }

  @override
  Stream<double> amplitudeLevels({
    Duration interval = const Duration(milliseconds: 180),
  }) {
    return _amplitudeController.stream;
  }

  @override
  Future<ImpulseVoiceMessageResult> startRecording({String? localeId}) async {
    startCalls += 1;
    lastLocaleId = localeId;
    return startResult;
  }

  @override
  Future<ImpulseVoiceMessageResult> stopRecording() async {
    stopCalls += 1;
    return stopResult;
  }

  @override
  Future<ImpulseVoiceMessageResult> cancelRecording() async {
    cancelCalls += 1;
    return const ImpulseVoiceMessageResult.cancelled();
  }

  @override
  Future<ImpulseVoiceMessageResult> pauseRecording() async {
    pauseCalls += 1;
    return const ImpulseVoiceMessageResult.paused();
  }

  @override
  Future<ImpulseVoiceMessageResult> resumeRecording() async {
    resumeCalls += 1;
    return const ImpulseVoiceMessageResult.resumed();
  }

  @override
  Future<ImpulseVoicePlaybackResult> play(String path) async {
    playCalls += 1;
    return const ImpulseVoicePlaybackResult.success();
  }

  @override
  Future<void> stopPlayback() async {
    stopPlaybackCalls += 1;
  }

  @override
  Future<void> dispose() async {
    await _amplitudeController.close();
  }
}
