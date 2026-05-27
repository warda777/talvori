import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/companion/domain/companion_chat_constants.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_saved_message.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

abstract class ImpulseInboxRepository {
  Future<ImpulseChat> ensureDailyImpulseChat();
  Future<ImpulseChat> ensureCompanionChat();
  Future<ImpulseChat> ensureCategoryChat(String categoryId, String title);
  Future<ImpulseChat> createCustomAiChat(String title);
  Future<void> renameCustomAiChat(String chatId, String title);
  Future<void> setChatMuted(String chatId, bool muted);
  Future<void> setChatFavorite(String chatId, bool favorite);
  Future<void> updateChatAiProfileOverride(
    String chatId,
    ImpulseChatAiProfileOverride override,
  );
  Future<void> resetChatAiProfileOverride(String chatId);
  Future<ImpulseChat?> getCategoryChat(String categoryId);
  Future<void> setCategoryChatEnabled(String categoryId, bool enabled);
  Future<void> setChatEnabled(String chatId, bool enabled);
  Future<void> updateChatAvatarImagePath(String chatId, String? imagePath);
  Future<List<ImpulseChat>> listChats();
  Future<List<ImpulseChat>> listAllChats();
  Future<List<ImpulseChat>> listHiddenChats();
  Future<List<ImpulseSavedMessage>> listStarredMessages();
  Future<List<ImpulseSavedMessage>> listStarredMessagesForChat(String chatId);
  Future<ImpulseAiProfile> loadAiProfile();
  Future<void> saveAiProfile(ImpulseAiProfile profile);
  Future<List<ImpulseMessage>> listMessages(String chatId);
  Future<ImpulseMessage> addMessage(
    ImpulseMessage message, {
    bool incrementUnread = true,
  });
  Future<List<ImpulseMessage>> addDailyImpulseMessages(
    List<TagesimpulsGeneratedImpulse> impulses,
  );
  Future<void> updateMessageReaction(
    String chatId,
    String messageId,
    String? reaction,
  );
  Future<void> updateMessageStarred(
    String chatId,
    String messageId, {
    required bool isStarred,
  });
  Future<void> updateMessagePinned(
    String chatId,
    String messageId, {
    required bool isPinned,
  });
  Future<void> deleteMessage(String chatId, String messageId);
  Future<void> deleteCustomAiChat(String chatId);
  Future<void> markChatRead(String chatId);
  Future<void> clearChat(String chatId);
}

class SharedPreferencesImpulseInboxRepository
    implements ImpulseInboxRepository {
  SharedPreferencesImpulseInboxRepository({
    this.storageKey = 'talvori_impulse_inbox_v1',
    this.clock,
  });

  static const dailyImpulseChatId = 'impulse-chat-daily-impulse';

  final String storageKey;
  final DateTime Function()? clock;

  DateTime get _now => clock?.call() ?? DateTime.now();

  @override
  Future<ImpulseChat> ensureDailyImpulseChat() async {
    final store = await _loadStore();
    final existing = store.chats[dailyImpulseChatId];
    if (existing != null) return existing;

    final chat = ImpulseChat(
      id: dailyImpulseChatId,
      sourceType: ImpulseChatSourceType.dailyImpulse,
      title: 'Tagesimpuls',
      avatarKey: 'spark',
      createdAt: _now,
    );
    store.chats[chat.id] = chat;
    await _saveStore(store);
    return chat;
  }

  @override
  Future<ImpulseChat> ensureCompanionChat() async {
    final store = await _loadStore();
    final existing = store.chats[CompanionChatConstants.chatId];
    if (existing != null) {
      final updated = existing.copyWith(
        sourceType: ImpulseChatSourceType.customAi,
        sourceId: CompanionChatConstants.chatId,
        title: CompanionChatConstants.title,
        avatarKey: CompanionChatConstants.avatarKey,
        enabled: true,
      );
      store.chats[updated.id] = updated;
      await _saveStore(store);
      return updated;
    }

    final chat = ImpulseChat(
      id: CompanionChatConstants.chatId,
      sourceType: ImpulseChatSourceType.customAi,
      sourceId: CompanionChatConstants.chatId,
      title: CompanionChatConstants.title,
      avatarKey: CompanionChatConstants.avatarKey,
      createdAt: _now,
    );
    store.chats[chat.id] = chat;
    await _saveStore(store);
    return chat;
  }

  @override
  Future<ImpulseChat> ensureCategoryChat(
    String categoryId,
    String title,
  ) async {
    final normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) {
      throw ArgumentError.value(categoryId, 'categoryId', 'must not be empty');
    }

    final store = await _loadStore();
    final chatId = _categoryChatId(normalizedCategoryId);
    final normalizedTitle = title.trim().isEmpty ? 'Kategorie' : title.trim();
    final existing = store.chats[chatId];
    if (existing != null) {
      final updated = existing.copyWith(
        sourceType: ImpulseChatSourceType.category,
        sourceId: normalizedCategoryId,
        title: normalizedTitle,
        avatarKey: 'category:$normalizedCategoryId',
        enabled: true,
      );
      store.chats[chatId] = updated;
      await _saveStore(store);
      return updated;
    }

    final chat = ImpulseChat(
      id: chatId,
      sourceType: ImpulseChatSourceType.category,
      sourceId: normalizedCategoryId,
      title: normalizedTitle,
      avatarKey: 'category:$normalizedCategoryId',
      createdAt: _now,
    );
    store.chats[chat.id] = chat;
    await _saveStore(store);
    return chat;
  }

  @override
  Future<ImpulseChat?> getCategoryChat(String categoryId) async {
    final normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) return null;
    final store = await _loadStore();
    return store.chats[_categoryChatId(normalizedCategoryId)];
  }

  @override
  Future<ImpulseChat> createCustomAiChat(String title) async {
    final normalizedTitle = title.trim().isEmpty
        ? 'Eigener KI-Chat'
        : title.trim();
    final store = await _loadStore();
    final id = _customChatId();
    final chat = ImpulseChat(
      id: id,
      sourceType: ImpulseChatSourceType.customAi,
      sourceId: id,
      title: normalizedTitle,
      avatarKey: 'custom:$id',
      createdAt: _now,
    );
    store.chats[chat.id] = chat;
    await _saveStore(store);
    return chat;
  }

  @override
  Future<void> setCategoryChatEnabled(String categoryId, bool enabled) async {
    final normalizedCategoryId = categoryId.trim();
    if (normalizedCategoryId.isEmpty) return;
    final store = await _loadStore();
    final chatId = _categoryChatId(normalizedCategoryId);
    final chat = store.chats[chatId];
    if (chat == null) return;
    store.chats[chatId] = chat.copyWith(enabled: enabled);
    await _saveStore(store);
  }

  @override
  Future<void> setChatEnabled(String chatId, bool enabled) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return;
    if (chat.sourceType == ImpulseChatSourceType.dailyImpulse && !enabled) {
      return;
    }
    store.chats[normalizedChatId] = chat.copyWith(enabled: enabled);
    await _saveStore(store);
  }

  @override
  Future<void> renameCustomAiChat(String chatId, String title) async {
    final normalizedChatId = chatId.trim();
    final normalizedTitle = title.trim();
    if (normalizedChatId.isEmpty || normalizedTitle.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null || chat.sourceType != ImpulseChatSourceType.customAi) {
      return;
    }
    store.chats[normalizedChatId] = chat.copyWith(title: normalizedTitle);
    await _saveStore(store);
  }

  @override
  Future<void> setChatMuted(String chatId, bool muted) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return;
    store.chats[normalizedChatId] = chat.copyWith(
      isMuted: muted,
      mutedAt: muted ? _now : null,
      clearMutedAt: !muted,
    );
    await _saveStore(store);
  }

  @override
  Future<void> setChatFavorite(String chatId, bool favorite) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return;
    store.chats[normalizedChatId] = chat.copyWith(
      isFavorite: favorite,
      favoritedAt: favorite ? _now : null,
      clearFavoritedAt: !favorite,
    );
    await _saveStore(store);
  }

  @override
  Future<void> updateChatAiProfileOverride(
    String chatId,
    ImpulseChatAiProfileOverride override,
  ) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return;
    store.chats[normalizedChatId] = chat.copyWith(
      aiProfileOverride: override.hasOverrides
          ? override
          : ImpulseChatAiProfileOverride.empty,
      clearAiProfileOverride: !override.hasOverrides,
    );
    await _saveStore(store);
  }

  @override
  Future<void> resetChatAiProfileOverride(String chatId) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return;
    store.chats[normalizedChatId] = chat.copyWith(clearAiProfileOverride: true);
    await _saveStore(store);
  }

  @override
  Future<void> updateChatAvatarImagePath(
    String chatId,
    String? imagePath,
  ) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return;
    final normalizedPath = imagePath?.trim();
    store.chats[normalizedChatId] = chat.copyWith(
      avatarImagePath: normalizedPath == null || normalizedPath.isEmpty
          ? null
          : normalizedPath,
      clearAvatarImagePath: normalizedPath == null || normalizedPath.isEmpty,
    );
    await _saveStore(store);
  }

  @override
  Future<List<ImpulseChat>> listChats() async {
    final store = await _loadStore();
    final chats = store.chats.values.where((chat) => chat.enabled).toList();
    _sortChats(chats);
    return chats;
  }

  @override
  Future<List<ImpulseChat>> listAllChats() async {
    final store = await _loadStore();
    final chats = store.chats.values.toList();
    _sortChats(chats);
    return chats;
  }

  @override
  Future<List<ImpulseChat>> listHiddenChats() async {
    final store = await _loadStore();
    final chats = store.chats.values
        .where(
          (chat) =>
              !chat.enabled &&
              (chat.sourceType == ImpulseChatSourceType.category ||
                  chat.sourceType == ImpulseChatSourceType.customAi),
        )
        .toList();
    _sortChats(chats);
    return chats;
  }

  @override
  Future<List<ImpulseSavedMessage>> listStarredMessages() async {
    final store = await _loadStore();
    final saved = <ImpulseSavedMessage>[];
    for (final entry in store.messages.entries) {
      final chat = store.chats[entry.key];
      if (chat == null) continue;
      for (final message in entry.value) {
        if (message.isStarred) {
          saved.add(ImpulseSavedMessage(chat: chat, message: message));
        }
      }
    }
    saved.sort((a, b) => b.message.createdAt.compareTo(a.message.createdAt));
    return saved;
  }

  @override
  Future<List<ImpulseSavedMessage>> listStarredMessagesForChat(
    String chatId,
  ) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return const [];
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null) return const [];
    final saved = (store.messages[normalizedChatId] ?? const <ImpulseMessage>[])
        .where((message) => message.isStarred)
        .map((message) => ImpulseSavedMessage(chat: chat, message: message))
        .toList(growable: false);
    saved.sort((a, b) => b.message.createdAt.compareTo(a.message.createdAt));
    return saved;
  }

  @override
  Future<ImpulseAiProfile> loadAiProfile() async {
    final store = await _loadStore();
    return store.aiProfile;
  }

  @override
  Future<void> saveAiProfile(ImpulseAiProfile profile) async {
    final store = await _loadStore();
    store.aiProfile = profile;
    await _saveStore(store);
  }

  void _sortChats(List<ImpulseChat> chats) {
    chats.sort((a, b) {
      final aDate = a.lastMessageAt ?? a.createdAt;
      final bDate = b.lastMessageAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
  }

  @override
  Future<List<ImpulseMessage>> listMessages(String chatId) async {
    final store = await _loadStore();
    final messages = store.messages[chatId] ?? const <ImpulseMessage>[];
    return [...messages]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<ImpulseMessage> addMessage(
    ImpulseMessage message, {
    bool incrementUnread = true,
  }) async {
    final store = await _loadStore();
    final existingChat = store.chats[message.chatId];
    if (existingChat == null) {
      throw StateError('Impulse chat does not exist: ${message.chatId}');
    }

    final messages = <ImpulseMessage>[
      ...(store.messages[message.chatId] ?? const <ImpulseMessage>[]),
    ];
    final normalized = message.id.trim().isEmpty
        ? message.copyWith(id: _messageId(message.chatId, messages.length))
        : message;
    messages.add(normalized);
    store.messages[message.chatId] = messages;
    store.chats[message.chatId] = existingChat.copyWith(
      lastMessageAt: normalized.createdAt,
      lastMessageText: normalized.text,
      unreadCount: incrementUnread
          ? existingChat.unreadCount + 1
          : existingChat.unreadCount,
    );
    await _saveStore(store);
    return normalized;
  }

  @override
  Future<List<ImpulseMessage>> addDailyImpulseMessages(
    List<TagesimpulsGeneratedImpulse> impulses,
  ) async {
    final chat = await ensureDailyImpulseChat();
    final messages = <ImpulseMessage>[];
    for (final impulse in impulses) {
      final text = impulse.message.trim();
      if (text.isEmpty) continue;
      final message = await addMessage(
        ImpulseMessage(
          id: '',
          chatId: chat.id,
          text: text,
          usedWords: impulse.usedWords,
          createdAt: _now,
          slot: impulse.slot,
        ),
      );
      messages.add(message);
    }
    return messages;
  }

  @override
  Future<void> markChatRead(String chatId) async {
    final store = await _loadStore();
    final chat = store.chats[chatId];
    if (chat == null) return;

    final readAt = _now;
    store.chats[chatId] = chat.copyWith(unreadCount: 0);
    store.messages[chatId] = (store.messages[chatId] ?? const [])
        .map(
          (message) => message.readAt == null
              ? message.copyWith(readAt: readAt)
              : message,
        )
        .toList(growable: false);
    await _saveStore(store);
  }

  @override
  Future<void> updateMessageReaction(
    String chatId,
    String messageId,
    String? reaction,
  ) {
    return _updateMessage(
      chatId,
      messageId,
      (message) => message.copyWith(
        reaction: reaction,
        clearReaction: reaction == null || reaction.trim().isEmpty,
      ),
    );
  }

  @override
  Future<void> updateMessageStarred(
    String chatId,
    String messageId, {
    required bool isStarred,
  }) {
    return _updateMessage(
      chatId,
      messageId,
      (message) => message.copyWith(isStarred: isStarred),
    );
  }

  @override
  Future<void> updateMessagePinned(
    String chatId,
    String messageId, {
    required bool isPinned,
  }) {
    return _updateMessage(
      chatId,
      messageId,
      (message) => message.copyWith(isPinned: isPinned),
    );
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    final store = await _loadStore();
    final chat = store.chats[chatId];
    if (chat == null) return;

    final messages = [...(store.messages[chatId] ?? const <ImpulseMessage>[])];
    final nextMessages = messages
        .where((message) => message.id != messageId)
        .toList(growable: false);
    if (nextMessages.length == messages.length) return;

    store.messages[chatId] = nextMessages;
    _recomputeChatPreview(store, chatId);
    await _saveStore(store);
  }

  @override
  Future<void> deleteCustomAiChat(String chatId) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) return;
    final store = await _loadStore();
    final chat = store.chats[normalizedChatId];
    if (chat == null || chat.sourceType != ImpulseChatSourceType.customAi) {
      return;
    }

    store.chats.remove(normalizedChatId);
    store.messages.remove(normalizedChatId);
    await _saveStore(store);
  }

  @override
  Future<void> clearChat(String chatId) async {
    final store = await _loadStore();
    final chat = store.chats[chatId];
    if (chat == null) return;
    store.messages[chatId] = const [];
    store.chats[chatId] = chat.copyWith(clearLastMessage: true, unreadCount: 0);
    await _saveStore(store);
  }

  Future<void> _updateMessage(
    String chatId,
    String messageId,
    ImpulseMessage Function(ImpulseMessage message) update,
  ) async {
    final store = await _loadStore();
    final messages = [...(store.messages[chatId] ?? const <ImpulseMessage>[])];
    final index = messages.indexWhere((message) => message.id == messageId);
    if (index < 0) return;
    messages[index] = update(messages[index]);
    store.messages[chatId] = messages;
    await _saveStore(store);
  }

  void _recomputeChatPreview(_ImpulseInboxStore store, String chatId) {
    final chat = store.chats[chatId];
    if (chat == null) return;

    final messages = [...(store.messages[chatId] ?? const <ImpulseMessage>[])];
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    if (messages.isEmpty) {
      store.chats[chatId] = chat.copyWith(
        clearLastMessage: true,
        unreadCount: 0,
      );
      return;
    }

    final last = messages.last;
    final unreadCount = messages
        .where((message) => message.readAt == null)
        .length;
    store.chats[chatId] = chat.copyWith(
      lastMessageAt: last.createdAt,
      lastMessageText: last.text,
      unreadCount: unreadCount,
    );
  }

  Future<_ImpulseInboxStore> _loadStore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return _ImpulseInboxStore.empty();

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return _ImpulseInboxStore.empty();

    final rawChats = decoded['chats'];
    final chats = <String, ImpulseChat>{};
    if (rawChats is List) {
      for (final rawChat in rawChats.whereType<Map<String, dynamic>>()) {
        final chat = ImpulseChat.fromJson(rawChat);
        if (chat.id.trim().isNotEmpty) chats[chat.id] = chat;
      }
    }

    final rawMessages = decoded['messages'];
    final messages = <String, List<ImpulseMessage>>{};
    if (rawMessages is Map) {
      for (final entry in rawMessages.entries) {
        final chatId = entry.key.toString();
        final value = entry.value;
        if (value is! List) continue;
        messages[chatId] = value
            .whereType<Map<String, dynamic>>()
            .map(ImpulseMessage.fromJson)
            .where((message) => message.id.trim().isNotEmpty)
            .toList(growable: false);
      }
    }

    return _ImpulseInboxStore(
      chats: chats,
      messages: messages,
      aiProfile: ImpulseAiProfile.fromJson(decoded['aiProfile']),
    );
  }

  Future<void> _saveStore(_ImpulseInboxStore store) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      'chats': store.chats.values.map((chat) => chat.toJson()).toList(),
      'messages': store.messages.map(
        (chatId, messages) => MapEntry(
          chatId,
          messages.map((message) => message.toJson()).toList(),
        ),
      ),
      'aiProfile': store.aiProfile.toJson(),
    });
    await prefs.setString(storageKey, encoded);
  }

  String _messageId(String chatId, int index) {
    final timestamp = _now.microsecondsSinceEpoch;
    return '$chatId-message-$timestamp-$index';
  }

  String _categoryChatId(String categoryId) {
    return 'impulse-chat-category-$categoryId';
  }

  String _customChatId() {
    return 'impulse-chat-custom-${_now.microsecondsSinceEpoch}';
  }
}

class _ImpulseInboxStore {
  _ImpulseInboxStore({
    required this.chats,
    required this.messages,
    required this.aiProfile,
  });

  factory _ImpulseInboxStore.empty() {
    return _ImpulseInboxStore(
      chats: {},
      messages: {},
      aiProfile: ImpulseAiProfile.defaults,
    );
  }

  final Map<String, ImpulseChat> chats;
  final Map<String, List<ImpulseMessage>> messages;
  ImpulseAiProfile aiProfile;
}
