import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
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

    test('legacy messages without role are treated as assistant messages', () {
      final message = ImpulseMessage.fromJson({
        'id': 'message-1',
        'chatId': 'chat-1',
        'text': 'Legacy impulse',
        'createdAt': DateTime(2026, 5, 20, 12).toIso8601String(),
      });

      expect(message.source, ImpulseMessageSource.ai);
      expect(message.status, ImpulseMessageStatus.sent);
    });

    test('user messages can update preview without unread count', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureDailyImpulseChat();

      await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: 'Kannst du das erklären?',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.user,
        ),
        incrementUnread: false,
      );
      final chats = await repository.listChats();

      expect(chats.single.lastMessageText, 'Kannst du das erklären?');
      expect(chats.single.unreadCount, 0);
    });

    test('message metadata can be updated locally', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureDailyImpulseChat();
      final message = await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: 'React to me',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.ai,
        ),
      );

      await repository.updateMessageReaction(chat.id, message.id, '👍');
      await repository.updateMessageStarred(
        chat.id,
        message.id,
        isStarred: true,
      );

      final loaded = (await repository.listMessages(chat.id)).single;
      expect(loaded.reaction, '👍');
      expect(loaded.isStarred, isTrue);
    });

    test('deleting the last message updates chat preview', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureDailyImpulseChat();
      final first = await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: 'First',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.ai,
        ),
      );
      final second = await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: 'Second',
          createdAt: DateTime(2026, 5, 20, 12, 1),
          source: ImpulseMessageSource.user,
          readAt: DateTime(2026, 5, 20, 12, 1),
        ),
        incrementUnread: false,
      );

      await repository.deleteMessage(chat.id, second.id);
      var chats = await repository.listChats();
      expect(chats.single.lastMessageText, 'First');

      await repository.deleteMessage(chat.id, first.id);
      chats = await repository.listChats();
      expect(chats.single.lastMessageText, isNull);
      expect(chats.single.lastMessageAt, isNull);
      expect(chats.single.unreadCount, 0);
      expect(await repository.listMessages(chat.id), isEmpty);
    });
  });
}
