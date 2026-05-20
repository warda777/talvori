import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

abstract class ImpulseInboxRepository {
  Future<ImpulseChat> ensureDailyImpulseChat();
  Future<List<ImpulseChat>> listChats();
  Future<List<ImpulseMessage>> listMessages(String chatId);
  Future<ImpulseMessage> addMessage(ImpulseMessage message);
  Future<List<ImpulseMessage>> addDailyImpulseMessages(
    List<TagesimpulsGeneratedImpulse> impulses,
  );
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
  Future<List<ImpulseChat>> listChats() async {
    final store = await _loadStore();
    final chats = store.chats.values.where((chat) => chat.enabled).toList();
    chats.sort((a, b) {
      final aDate = a.lastMessageAt ?? a.createdAt;
      final bDate = b.lastMessageAt ?? b.createdAt;
      return bDate.compareTo(aDate);
    });
    return chats;
  }

  @override
  Future<List<ImpulseMessage>> listMessages(String chatId) async {
    final store = await _loadStore();
    final messages = store.messages[chatId] ?? const <ImpulseMessage>[];
    return [...messages]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  @override
  Future<ImpulseMessage> addMessage(ImpulseMessage message) async {
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
      unreadCount: existingChat.unreadCount + 1,
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
  Future<void> clearChat(String chatId) async {
    final store = await _loadStore();
    final chat = store.chats[chatId];
    if (chat == null) return;
    store.messages[chatId] = const [];
    store.chats[chatId] = chat.copyWith(
      lastMessageAt: null,
      lastMessageText: null,
      unreadCount: 0,
    );
    await _saveStore(store);
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

    return _ImpulseInboxStore(chats: chats, messages: messages);
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
    });
    await prefs.setString(storageKey, encoded);
  }

  String _messageId(String chatId, int index) {
    final timestamp = _now.microsecondsSinceEpoch;
    return '$chatId-message-$timestamp-$index';
  }
}

class _ImpulseInboxStore {
  _ImpulseInboxStore({required this.chats, required this.messages});

  factory _ImpulseInboxStore.empty() {
    return _ImpulseInboxStore(chats: {}, messages: {});
  }

  final Map<String, ImpulseChat> chats;
  final Map<String, List<ImpulseMessage>> messages;
}
