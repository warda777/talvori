import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

class ImpulseInboxState {
  const ImpulseInboxState({
    this.isLoading = false,
    this.chats = const [],
    this.messagesByChat = const {},
    this.respondingChatIds = const {},
    this.chatErrors = const {},
  });

  final bool isLoading;
  final List<ImpulseChat> chats;
  final Map<String, List<ImpulseMessage>> messagesByChat;
  final Set<String> respondingChatIds;
  final Map<String, String> chatErrors;

  ImpulseInboxState copyWith({
    bool? isLoading,
    List<ImpulseChat>? chats,
    Map<String, List<ImpulseMessage>>? messagesByChat,
    Set<String>? respondingChatIds,
    Map<String, String>? chatErrors,
  }) {
    return ImpulseInboxState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      messagesByChat: messagesByChat ?? this.messagesByChat,
      respondingChatIds: respondingChatIds ?? this.respondingChatIds,
      chatErrors: chatErrors ?? this.chatErrors,
    );
  }
}

class ImpulseInboxController extends StateNotifier<ImpulseInboxState> {
  ImpulseInboxController({
    required ImpulseInboxRepository repository,
    required AiChatClient aiChatClient,
    DateTime Function()? clock,
  }) : _aiChatClient = aiChatClient,
       _clock = clock,
       _repository = repository,
       super(const ImpulseInboxState(isLoading: true));

  final ImpulseInboxRepository _repository;
  final AiChatClient _aiChatClient;
  final DateTime Function()? _clock;

  DateTime get _now => _clock?.call() ?? DateTime.now();

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true);
    final chats = await _repository.listChats();
    state = state.copyWith(isLoading: false, chats: chats);
  }

  Future<ImpulseChat> ensureDailyImpulseChat() async {
    final chat = await _repository.ensureDailyImpulseChat();
    await loadChats();
    return chat;
  }

  Future<List<ImpulseMessage>> addDailyImpulseMessages(
    List<TagesimpulsGeneratedImpulse> impulses,
  ) async {
    final messages = await _repository.addDailyImpulseMessages(impulses);
    await loadChats();
    return messages;
  }

  Future<ImpulseMessage> addUserMessage(
    String chatId,
    String text, {
    ImpulseMessage? replyTo,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      throw const AiChatException('Impulse inbox message must not be empty.');
    }
    final message = await _repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chatId,
        text: trimmed,
        createdAt: _now,
        source: ImpulseMessageSource.user,
        status: ImpulseMessageStatus.sent,
        readAt: _now,
        replyToMessageId: replyTo?.id,
        replyPreviewText: replyTo == null
            ? null
            : _replyPreviewText(replyTo.text),
        replyPreviewSource: replyTo?.source,
      ),
      incrementUnread: false,
    );
    await _refreshChat(chatId);
    return message;
  }

  Future<void> sendChatMessage(
    String chatId,
    String text, {
    ImpulseMessage? replyTo,
  }) async {
    final userMessage = await addUserMessage(chatId, text, replyTo: replyTo);
    state = state.copyWith(
      respondingChatIds: {...state.respondingChatIds, chatId},
      chatErrors: {...state.chatErrors}..remove(chatId),
    );

    try {
      final contextMessages = await _repository.listMessages(chatId);
      final response = await _aiChatClient.sendMessage(
        AiChatRequest(
          message: userMessage.text,
          language: 'DE',
          context: {
            'source': 'impulse_inbox',
            'chatId': chatId,
            'recentMessages': contextMessages
                .takeLast(8)
                .map(
                  (message) => {
                    'role': message.source == ImpulseMessageSource.user
                        ? 'user'
                        : 'assistant',
                    'content': message.text,
                  },
                )
                .toList(growable: false),
          },
        ),
      );
      final reply = response.reply.trim();
      if (reply.isEmpty) {
        throw const AiChatException('AI chat response is empty.');
      }
      await _repository.addMessage(
        ImpulseMessage(
          id: '',
          chatId: chatId,
          text: reply,
          createdAt: _now,
          source: ImpulseMessageSource.ai,
          status: ImpulseMessageStatus.sent,
          readAt: _now,
        ),
        incrementUnread: false,
      );
      await _refreshChat(chatId);
    } catch (error) {
      state = state.copyWith(
        chatErrors: {...state.chatErrors, chatId: _friendlyAiError(error)},
      );
    } finally {
      state = state.copyWith(
        respondingChatIds: {...state.respondingChatIds}..remove(chatId),
      );
    }
  }

  Future<List<ImpulseMessage>> loadMessages(String chatId) async {
    final messages = await _repository.listMessages(chatId);
    state = state.copyWith(
      messagesByChat: {...state.messagesByChat, chatId: messages},
    );
    return messages;
  }

  Future<void> markChatRead(String chatId) async {
    await _repository.markChatRead(chatId);
    await _refreshChat(chatId);
  }

  Future<void> updateReaction(
    String chatId,
    String messageId,
    String reaction,
  ) async {
    await _repository.updateMessageReaction(chatId, messageId, reaction);
    await _refreshChat(chatId);
  }

  Future<void> toggleStarred(String chatId, ImpulseMessage message) async {
    await _repository.updateMessageStarred(
      chatId,
      message.id,
      isStarred: !message.isStarred,
    );
    await _refreshChat(chatId);
  }

  Future<void> togglePinned(String chatId, ImpulseMessage message) async {
    await _repository.updateMessagePinned(
      chatId,
      message.id,
      isPinned: !message.isPinned,
    );
    await _refreshChat(chatId);
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _repository.deleteMessage(chatId, messageId);
    await _refreshChat(chatId);
  }

  Future<void> _refreshChat(String chatId) async {
    final messages = await _repository.listMessages(chatId);
    final chats = await _repository.listChats();
    state = state.copyWith(
      chats: chats,
      messagesByChat: {...state.messagesByChat, chatId: messages},
    );
  }

  String _friendlyAiError(Object error) {
    final raw = error.toString();
    if (raw.contains('ai_not_configured')) {
      return 'KI ist noch nicht konfiguriert.';
    }
    if (raw.contains('quota_exceeded') || raw.contains('ai_rate_limited')) {
      return 'Limit erreicht oder Anbieter begrenzt Anfrage.';
    }
    if (raw.contains('ai_request_failed') || raw.contains('ai_auth_failed')) {
      return 'KI-Antwort konnte nicht erzeugt werden.';
    }
    return 'KI-Antwort konnte nicht erzeugt werden.';
  }

  String _replyPreviewText(String text) {
    final normalized = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 72) return normalized;
    return '${normalized.substring(0, 69)}...';
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (length <= count) return this;
    return skip(length - count);
  }
}
