import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';
import 'package:talvori/core/local_database/providers/local_category_detail_group_items_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_controller.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_voice_input_service.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_payload.dart';
import 'package:talvori/features/impuls_postfach/notifications/impulse_inbox_notification_router.dart';
import 'package:talvori/features/impuls_postfach/notifications/notification_tap_debug_state.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impulse_chat_detail_screen.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/home/ui/screens/course_screen.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

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
    await tester.pump();

    expect(find.text('Impuls-Postfach'), findsOneWidget);
    expect(find.text('1 Verlauf'), findsOneWidget);
    expect(find.text('Tagesimpuls'), findsOneWidget);
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
    await tester.pump();

    expect(find.text('Impuls-Postfach'), findsOneWidget);
    expect(find.text('Noch keine Impulse'), findsOneWidget);
    expect(
      find.text(
        'Deine Tagesimpulse erscheinen hier, sobald Talvori sie gesendet hat.',
      ),
      findsOneWidget,
    );
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
    expect(find.text('Tagesimpuls'), findsNothing);
  });

  testWidgets('plus menu creates custom AI chat', (tester) async {
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
    await tester.pump();

    await tester.tap(find.byKey(const Key('impulse_inbox_add_chat_button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('add_custom_ai_chat_option')), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_custom_ai_chat_option')));
    await tester.pumpAndSettle();
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

  testWidgets('category tab can add and reactivate category chat', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_category_tab',
    );
    final categoryItems = const LocalCategoryDetailGroupResolver()
        .resolve('health_fitness')
        .map(
          (item) => item.localCategoryId == null
              ? item
              : item.copyWith(vocabsCount: 3),
        )
        .toList(growable: false);

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

    await tester.tap(find.text('Kategorien'));
    await tester.pumpAndSettle();
    expect(find.text('Health & Fitness'), findsOneWidget);
    expect(find.text('Hinzufügen'), findsWidgets);

    await tester.tap(
      find.byKey(const Key('impulse_inbox_category_tile_seed-category-basics')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ImpulseChatDetailScreen), findsOneWidget);
    expect(find.text('Health & Fitness'), findsOneWidget);

    await repository.setCategoryChatEnabled('seed-category-basics', false);
    await repository.ensureCategoryChat(
      'seed-category-basics',
      'Health & Fitness',
    );
    final chat = await repository.getCategoryChat('seed-category-basics');
    expect(chat?.enabled, isTrue);
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
    await tester.tap(find.text('Tagesimpuls'));
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

  testWidgets('microphone button writes recognized speech into the input', (
    tester,
  ) async {
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_inbox_screen_voice_input',
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
          impulseVoiceInputServiceProvider.overrideWithValue(
            const _FakeVoiceInputService('Kannst du das erklaeren?'),
          ),
        ],
        child: MaterialApp(home: ImpulseChatDetailScreen(chatId: chat.id)),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('impulse_chat_microphone_button')),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('impulse_chat_microphone_button')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('Kannst du das erklaeren?'), findsOneWidget);
    expect(find.byKey(const Key('impulse_chat_send_button')), findsOneWidget);
    expect(
      find.byKey(const Key('impulse_chat_microphone_button')),
      findsNothing,
    );
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

    await tester.tap(find.text('Tagesimpuls'));
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

class _FakeVoiceInputService implements ImpulseVoiceInputService {
  const _FakeVoiceInputService(this.text);

  final String text;

  @override
  Future<ImpulseVoiceInputResult> listenForText() async {
    return ImpulseVoiceInputResult.success(text);
  }
}
