import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

void main() {
  group('SharedPreferencesImpulseInboxRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('creates daily impulse chat once', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );

      final first = await repository.ensureDailyImpulseChat();
      final second = await repository.ensureDailyImpulseChat();
      final chats = await repository.listChats();

      expect(
        first.id,
        SharedPreferencesImpulseInboxRepository.dailyImpulseChatId,
      );
      expect(second.id, first.id);
      expect(chats, hasLength(1));
      expect(chats.single.title, 'Tagesimpuls');
    });

    test('stores daily impulse messages and unread count', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );

      final messages = await repository.addDailyImpulseMessages(const [
        TagesimpulsGeneratedImpulse(
          slot: 'morning',
          message: 'You moved like a superstar.',
          usedWords: ['move', 'superstar'],
        ),
      ]);
      final chats = await repository.listChats();
      final loadedMessages = await repository.listMessages(chats.single.id);

      expect(messages, hasLength(1));
      expect(chats.single.unreadCount, 1);
      expect(chats.single.lastMessageText, 'You moved like a superstar.');
      expect(loadedMessages.single.usedWords, ['move', 'superstar']);
    });

    test('mark chat read clears unread count and sets readAt', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      await repository.addDailyImpulseMessages(const [
        TagesimpulsGeneratedImpulse(
          slot: 'morning',
          message: 'Message',
          usedWords: ['move'],
        ),
      ]);
      final chat = (await repository.listChats()).single;

      await repository.markChatRead(chat.id);
      final chats = await repository.listChats();
      final messages = await repository.listMessages(chat.id);

      expect(chats.single.unreadCount, 0);
      expect(messages.single.readAt, isNotNull);
    });
  });
}
