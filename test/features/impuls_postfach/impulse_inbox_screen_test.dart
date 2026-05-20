import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
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
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();

    expect(find.text('Impuls-Postfach'), findsOneWidget);
    expect(find.text('Tagesimpuls'), findsOneWidget);
    expect(find.text('You moved like a superstar.'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
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
        ],
        child: const MaterialApp(home: ImpulsPostfachScreen()),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('Tagesimpuls'));
    await tester.pumpAndSettle();

    expect(find.text('You moved like a superstar.'), findsOneWidget);
    expect(find.text('move'), findsOneWidget);
    expect(find.text('superstar'), findsOneWidget);

    final chats = await repository.listChats();
    expect(chats.single.unreadCount, 0);
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
