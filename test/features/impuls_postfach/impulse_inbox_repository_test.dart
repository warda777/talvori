import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
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

    test(
      'ensureCategoryChat creates and updates a category chat once',
      () async {
        final repository = SharedPreferencesImpulseInboxRepository(
          clock: () => DateTime(2026, 5, 20, 12),
        );

        final first = await repository.ensureCategoryChat(
          'seed-category-basics',
          'Basics',
        );
        final second = await repository.ensureCategoryChat(
          'seed-category-basics',
          'Basics aktualisiert',
        );
        final chats = await repository.listChats();

        expect(first.id, 'impulse-chat-category-seed-category-basics');
        expect(second.id, first.id);
        expect(second.sourceType, ImpulseChatSourceType.category);
        expect(second.sourceId, 'seed-category-basics');
        expect(second.title, 'Basics aktualisiert');
        expect(second.avatarKey, 'category:seed-category-basics');
        expect(chats, hasLength(1));
      },
    );

    test('disabled category chat is hidden but keeps old messages', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureCategoryChat(
        'seed-category-travel',
        'Travel',
      );
      await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: 'Was bedeutet journey?',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.user,
          readAt: DateTime(2026, 5, 20, 12),
        ),
        incrementUnread: false,
      );

      await repository.setCategoryChatEnabled('seed-category-travel', false);
      expect(await repository.listChats(), isEmpty);

      await repository.setCategoryChatEnabled('seed-category-travel', true);
      final chats = await repository.listChats();
      final messages = await repository.listMessages(chat.id);

      expect(chats.single.id, chat.id);
      expect(messages.single.text, 'Was bedeutet journey?');
      expect(
        await repository.getCategoryChat('seed-category-travel'),
        isNotNull,
      );
    });

    test('creates custom AI chat and persists avatar image path', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );

      final chat = await repository.createCustomAiChat('Grammatikfragen');
      await repository.updateChatAvatarImagePath(chat.id, '/tmp/avatar.png');

      final allChats = await repository.listAllChats();
      final loaded = allChats.single;

      expect(loaded.sourceType, ImpulseChatSourceType.customAi);
      expect(loaded.sourceId, chat.id);
      expect(loaded.title, 'Grammatikfragen');
      expect(loaded.avatarKey, 'custom:${chat.id}');
      expect(loaded.avatarImagePath, '/tmp/avatar.png');
    });

    test('custom AI chat can be hidden without deleting messages', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.createCustomAiChat('Reisevokabeln');
      await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: 'Trainiere mit mir.',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.user,
          readAt: DateTime(2026, 5, 20, 12),
        ),
        incrementUnread: false,
      );

      await repository.setChatEnabled(chat.id, false);

      expect(await repository.listChats(), isEmpty);
      expect(await repository.listAllChats(), hasLength(1));
      expect(
        (await repository.listMessages(chat.id)).single.text,
        'Trainiere mit mir.',
      );
    });

    test(
      'daily impulse chat cannot be hidden through generic chat toggle',
      () async {
        final repository = SharedPreferencesImpulseInboxRepository(
          clock: () => DateTime(2026, 5, 20, 12),
        );
        final daily = await repository.ensureDailyImpulseChat();

        await repository.setChatEnabled(daily.id, false);

        final chats = await repository.listChats();
        expect(chats.single.id, daily.id);
        expect(chats.single.enabled, isTrue);
        expect(await repository.listHiddenChats(), isEmpty);
      },
    );

    test('custom AI chat can be renamed locally', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final custom = await repository.createCustomAiChat('Alter Name');
      final category = await repository.ensureCategoryChat(
        'seed-category-basics',
        'Basics',
      );

      await repository.renameCustomAiChat(custom.id, 'Neuer Name');
      await repository.renameCustomAiChat(category.id, 'Kategorie Rename');

      final allChats = await repository.listAllChats();
      expect(
        allChats.firstWhere((chat) => chat.id == custom.id).title,
        'Neuer Name',
      );
      expect(
        allChats.firstWhere((chat) => chat.id == category.id).title,
        'Basics',
      );
    });

    test('clearChat removes messages but keeps custom chat shell', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final custom = await repository.createCustomAiChat('Training');
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

      await repository.clearChat(custom.id);

      final chat = (await repository.listAllChats()).single;
      expect(chat.id, custom.id);
      expect(chat.lastMessageText, isNull);
      expect(chat.lastMessageAt, isNull);
      expect(chat.unreadCount, 0);
      expect(await repository.listMessages(custom.id), isEmpty);
    });

    test(
      'listHiddenChats returns disabled category and custom chats only',
      () async {
        final repository = SharedPreferencesImpulseInboxRepository(
          clock: () => DateTime(2026, 5, 20, 12),
        );
        final daily = await repository.ensureDailyImpulseChat();
        final category = await repository.ensureCategoryChat(
          'seed-category-travel',
          'Travel',
        );
        final custom = await repository.createCustomAiChat('Reisevokabeln');

        await repository.setChatEnabled(daily.id, false);
        await repository.setCategoryChatEnabled('seed-category-travel', false);
        await repository.setChatEnabled(custom.id, false);

        final hidden = await repository.listHiddenChats();

        expect(
          hidden.map((chat) => chat.id),
          containsAll([category.id, custom.id]),
        );
        expect(hidden.map((chat) => chat.id), isNot(contains(daily.id)));

        await repository.setChatEnabled(custom.id, true);
        expect((await repository.listHiddenChats()).map((chat) => chat.id), [
          category.id,
        ]);
      },
    );

    test(
      'deleteCustomAiChat removes only custom chat and local messages',
      () async {
        final repository = SharedPreferencesImpulseInboxRepository(
          clock: () => DateTime(2026, 5, 20, 12),
        );
        final custom = await repository.createCustomAiChat('Grammatikfragen');
        final category = await repository.ensureCategoryChat(
          'seed-category-basics',
          'Basics',
        );
        await repository.addMessage(
          ImpulseMessage(
            id: '',
            chatId: custom.id,
            text: 'Custom text',
            createdAt: DateTime(2026, 5, 20, 12),
            source: ImpulseMessageSource.user,
          ),
          incrementUnread: false,
        );

        await repository.deleteCustomAiChat(custom.id);
        await repository.deleteCustomAiChat(category.id);

        expect((await repository.listAllChats()).map((chat) => chat.id), [
          category.id,
        ]);
        expect(await repository.listMessages(custom.id), isEmpty);
        expect(
          await repository.getCategoryChat('seed-category-basics'),
          isNotNull,
        );
      },
    );

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

    test('mute and favorite status are stored locally', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.ensureDailyImpulseChat();

      await repository.setChatMuted(chat.id, true);
      await repository.setChatFavorite(chat.id, true);

      var loaded = (await repository.listChats()).single;
      expect(loaded.isMuted, isTrue);
      expect(loaded.mutedAt, DateTime(2026, 5, 20, 12));
      expect(loaded.isFavorite, isTrue);
      expect(loaded.favoritedAt, DateTime(2026, 5, 20, 12));

      await repository.setChatMuted(chat.id, false);
      await repository.setChatFavorite(chat.id, false);

      loaded = (await repository.listChats()).single;
      expect(loaded.isMuted, isFalse);
      expect(loaded.mutedAt, isNull);
      expect(loaded.isFavorite, isFalse);
      expect(loaded.favoritedAt, isNull);
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

    test(
      'starred messages are collected from all chats including hidden chats',
      () async {
        final repository = SharedPreferencesImpulseInboxRepository(
          clock: () => DateTime(2026, 5, 20, 12),
        );
        final daily = await repository.ensureDailyImpulseChat();
        final category = await repository.ensureCategoryChat(
          'seed-category-basics',
          'Basics',
        );
        final dailyMessage = await repository.addMessage(
          ImpulseMessage(
            id: '',
            chatId: daily.id,
            text: 'Daily saved',
            createdAt: DateTime(2026, 5, 20, 12),
            source: ImpulseMessageSource.ai,
          ),
        );
        final categoryMessage = await repository.addMessage(
          ImpulseMessage(
            id: '',
            chatId: category.id,
            text: 'Category saved',
            createdAt: DateTime(2026, 5, 20, 13),
            source: ImpulseMessageSource.ai,
          ),
        );

        await repository.updateMessageStarred(
          daily.id,
          dailyMessage.id,
          isStarred: true,
        );
        await repository.updateMessageStarred(
          category.id,
          categoryMessage.id,
          isStarred: true,
        );
        await repository.setCategoryChatEnabled('seed-category-basics', false);

        final saved = await repository.listStarredMessages();

        expect(saved.map((item) => item.message.text), [
          'Category saved',
          'Daily saved',
        ]);
        expect(saved.first.chat.enabled, isFalse);

        await repository.updateMessageStarred(
          category.id,
          categoryMessage.id,
          isStarred: false,
        );
        expect(
          (await repository.listStarredMessages()).map(
            (item) => item.message.text,
          ),
          ['Daily saved'],
        );

        await repository.deleteMessage(daily.id, dailyMessage.id);
        expect(await repository.listStarredMessages(), isEmpty);
      },
    );

    test('starred messages can be filtered for one chat', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final daily = await repository.ensureDailyImpulseChat();
      final custom = await repository.createCustomAiChat('Training');
      final dailyMessage = await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: daily.id,
          text: 'Daily saved',
          createdAt: DateTime(2026, 5, 20, 12),
          source: ImpulseMessageSource.ai,
        ),
      );
      final customMessage = await repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: custom.id,
          text: 'Custom saved',
          createdAt: DateTime(2026, 5, 20, 13),
          source: ImpulseMessageSource.user,
        ),
        incrementUnread: false,
      );

      await repository.updateMessageStarred(
        daily.id,
        dailyMessage.id,
        isStarred: true,
      );
      await repository.updateMessageStarred(
        custom.id,
        customMessage.id,
        isStarred: true,
      );

      final saved = await repository.listStarredMessagesForChat(custom.id);

      expect(saved, hasLength(1));
      expect(saved.single.chat.id, custom.id);
      expect(saved.single.message.text, 'Custom saved');
    });

    test('AI profile has defaults and can be saved locally', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_profile_defaults',
      );

      expect(
        (await repository.loadAiProfile()).style,
        ImpulseAiStyle.motivating,
      );

      await repository.saveAiProfile(
        const ImpulseAiProfile(
          style: ImpulseAiStyle.trainer,
          answerLength: ImpulseAnswerLength.detailed,
          learningGoal: ImpulseLearningGoal.exam,
          explanationLanguage: ImpulseExplanationLanguage.mixed,
        ),
      );

      final loaded = await repository.loadAiProfile();
      expect(loaded.style, ImpulseAiStyle.trainer);
      expect(loaded.answerLength, ImpulseAnswerLength.detailed);
      expect(loaded.learningGoal, ImpulseLearningGoal.exam);
      expect(loaded.explanationLanguage, ImpulseExplanationLanguage.mixed);
    });

    test('chat AI profile overrides are stored and reset locally', () async {
      final repository = SharedPreferencesImpulseInboxRepository(
        storageKey: 'test_chat_profile_overrides',
        clock: () => DateTime(2026, 5, 20, 12),
      );
      final chat = await repository.createCustomAiChat('Grammatik');

      await repository.updateChatAiProfileOverride(
        chat.id,
        ImpulseChatAiProfileOverride(
          style: ImpulseAiStyle.trainer,
          answerLength: ImpulseAnswerLength.detailed,
          updatedAt: DateTime(2026, 5, 20, 12),
        ),
      );

      var loaded = (await repository.listAllChats()).single;
      expect(loaded.hasAiProfileOverride, isTrue);
      expect(loaded.aiProfileOverride.style, ImpulseAiStyle.trainer);
      expect(
        loaded.aiProfileOverride.answerLength,
        ImpulseAnswerLength.detailed,
      );
      expect(loaded.aiProfileOverride.learningGoal, isNull);

      await repository.resetChatAiProfileOverride(chat.id);

      loaded = (await repository.listAllChats()).single;
      expect(loaded.hasAiProfileOverride, isFalse);
    });
  });
}
