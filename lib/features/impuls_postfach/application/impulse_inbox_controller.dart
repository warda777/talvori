import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/core/ai/ai_chat_client.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_ai_profile.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_saved_message.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

typedef ImpulseCategoryWordSampler =
    Future<List<Map<String, String>>> Function(String categoryId);

class ImpulseInboxState {
  const ImpulseInboxState({
    this.isLoading = false,
    this.chats = const [],
    this.allChats = const [],
    this.hiddenChats = const [],
    this.savedMessages = const [],
    this.aiProfile = ImpulseAiProfile.defaults,
    this.messagesByChat = const {},
    this.respondingChatIds = const {},
    this.chatErrors = const {},
  });

  final bool isLoading;
  final List<ImpulseChat> chats;
  final List<ImpulseChat> allChats;
  final List<ImpulseChat> hiddenChats;
  final List<ImpulseSavedMessage> savedMessages;
  final ImpulseAiProfile aiProfile;
  final Map<String, List<ImpulseMessage>> messagesByChat;
  final Set<String> respondingChatIds;
  final Map<String, String> chatErrors;

  ImpulseInboxState copyWith({
    bool? isLoading,
    List<ImpulseChat>? chats,
    List<ImpulseChat>? allChats,
    List<ImpulseChat>? hiddenChats,
    List<ImpulseSavedMessage>? savedMessages,
    ImpulseAiProfile? aiProfile,
    Map<String, List<ImpulseMessage>>? messagesByChat,
    Set<String>? respondingChatIds,
    Map<String, String>? chatErrors,
  }) {
    return ImpulseInboxState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      allChats: allChats ?? this.allChats,
      hiddenChats: hiddenChats ?? this.hiddenChats,
      savedMessages: savedMessages ?? this.savedMessages,
      aiProfile: aiProfile ?? this.aiProfile,
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
    ImpulseCategoryWordSampler? categoryWordSampler,
    DateTime Function()? clock,
  }) : _aiChatClient = aiChatClient,
       _categoryWordSampler = categoryWordSampler,
       _clock = clock,
       _repository = repository,
       super(const ImpulseInboxState(isLoading: true));

  final ImpulseInboxRepository _repository;
  final AiChatClient _aiChatClient;
  final ImpulseCategoryWordSampler? _categoryWordSampler;
  final DateTime Function()? _clock;

  DateTime get _now => _clock?.call() ?? DateTime.now();

  Future<void> loadChats() async {
    state = state.copyWith(isLoading: true);
    final chats = await _repository.listChats();
    final allChats = await _repository.listAllChats();
    final hiddenChats = await _repository.listHiddenChats();
    final savedMessages = await _repository.listStarredMessages();
    final aiProfile = await _repository.loadAiProfile();
    state = state.copyWith(
      isLoading: false,
      chats: chats,
      allChats: allChats,
      hiddenChats: hiddenChats,
      savedMessages: savedMessages,
      aiProfile: aiProfile,
    );
  }

  Future<ImpulseChat> ensureDailyImpulseChat() async {
    final chat = await _repository.ensureDailyImpulseChat();
    await loadChats();
    return chat;
  }

  Future<ImpulseChat> ensureCategoryChat({
    required String categoryId,
    required String title,
  }) async {
    final chat = await _repository.ensureCategoryChat(categoryId, title);
    await loadChats();
    return chat;
  }

  Future<ImpulseChat> createCustomAiChat({required String title}) async {
    final chat = await _repository.createCustomAiChat(title);
    await loadChats();
    return chat;
  }

  Future<void> renameCustomAiChat({
    required String chatId,
    required String title,
  }) async {
    await _repository.renameCustomAiChat(chatId, title);
    await loadChats();
  }

  Future<void> setChatMuted({
    required String chatId,
    required bool muted,
  }) async {
    await _repository.setChatMuted(chatId, muted);
    await loadChats();
  }

  Future<void> toggleChatMuted(ImpulseChat chat) {
    return setChatMuted(chatId: chat.id, muted: !chat.isMuted);
  }

  Future<void> setChatFavorite({
    required String chatId,
    required bool favorite,
  }) async {
    await _repository.setChatFavorite(chatId, favorite);
    await loadChats();
  }

  Future<void> toggleChatFavorite(ImpulseChat chat) {
    return setChatFavorite(chatId: chat.id, favorite: !chat.isFavorite);
  }

  Future<void> setCategoryChatEnabled({
    required String categoryId,
    required bool enabled,
  }) async {
    await _repository.setCategoryChatEnabled(categoryId, enabled);
    await loadChats();
  }

  Future<void> setChatEnabled({
    required String chatId,
    required bool enabled,
  }) async {
    await _repository.setChatEnabled(chatId, enabled);
    await loadChats();
  }

  Future<void> reactivateChat(String chatId) {
    return setChatEnabled(chatId: chatId, enabled: true);
  }

  Future<void> deleteCustomAiChat(String chatId) async {
    await _repository.deleteCustomAiChat(chatId);
    await loadChats();
  }

  Future<void> clearCustomAiChatMessages(String chatId) async {
    final allChats = state.allChats.isEmpty
        ? await _repository.listAllChats()
        : state.allChats;
    final chat = allChats.cast<ImpulseChat?>().firstWhere(
      (chat) => chat?.id == chatId,
      orElse: () => null,
    );
    if (chat?.sourceType != ImpulseChatSourceType.customAi) return;
    await _repository.clearChat(chatId);
    await loadChats();
  }

  Future<void> updateChatAvatarImagePath({
    required String chatId,
    required String? imagePath,
  }) async {
    await _repository.updateChatAvatarImagePath(chatId, imagePath);
    await loadChats();
  }

  Future<void> updateAiProfile(ImpulseAiProfile profile) async {
    await _repository.saveAiProfile(profile);
    state = state.copyWith(aiProfile: profile);
  }

  Future<void> updateChatAiProfileOverride({
    required String chatId,
    required ImpulseChatAiProfileOverride override,
  }) async {
    await _repository.updateChatAiProfileOverride(chatId, override);
    await loadChats();
  }

  Future<void> resetChatAiProfileOverride(String chatId) async {
    await _repository.resetChatAiProfileOverride(chatId);
    await loadChats();
  }

  ImpulseAiProfile effectiveAiProfileForChat(ImpulseChat? chat) {
    return chat?.aiProfileOverride.applyTo(state.aiProfile) ?? state.aiProfile;
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
        replyPreviewText: replyTo == null ? null : _replyPreviewText(replyTo),
        replyPreviewSource: replyTo?.source,
      ),
      incrementUnread: false,
    );
    await _refreshChat(chatId);
    return message;
  }

  Future<ImpulseMessage> addUserAudioMessage(
    String chatId, {
    required String audioPath,
    required int durationMs,
    int? waveformSeed,
    String? audioTranscript,
    String? audioLanguage,
    ImpulseMessage? replyTo,
  }) async {
    final normalizedPath = audioPath.trim();
    if (normalizedPath.isEmpty) {
      throw const AiChatException(
        'Impulse inbox audio path must not be empty.',
      );
    }
    final message = await _repository.addMessage(
      ImpulseMessage(
        id: '',
        chatId: chatId,
        text: 'Sprachnachricht',
        contentType: ImpulseMessageContentType.audio,
        localAudioPath: normalizedPath,
        audioDurationMs: durationMs,
        waveformSeed: waveformSeed,
        audioTranscript: audioTranscript?.trim(),
        audioLanguage: audioLanguage,
        createdAt: _now,
        source: ImpulseMessageSource.user,
        status: ImpulseMessageStatus.sent,
        readAt: _now,
        replyToMessageId: replyTo?.id,
        replyPreviewText: replyTo == null ? null : _replyPreviewText(replyTo),
        replyPreviewSource: replyTo?.source,
      ),
      incrementUnread: false,
    );
    await _refreshChat(chatId);
    return message;
  }

  Future<void> sendChatAudioMessage(
    String chatId, {
    required String audioPath,
    required int durationMs,
    int? waveformSeed,
    String? audioTranscript,
    String? audioLanguage,
    ImpulseMessage? replyTo,
  }) async {
    final userMessage = await addUserAudioMessage(
      chatId,
      audioPath: audioPath,
      durationMs: durationMs,
      waveformSeed: waveformSeed,
      audioTranscript: audioTranscript,
      audioLanguage: audioLanguage,
      replyTo: replyTo,
    );
    final transcript = audioTranscript?.trim() ?? '';
    if (transcript.isEmpty) {
      state = state.copyWith(
        chatErrors: {
          ...state.chatErrors,
          chatId: 'Ich konnte die Sprachnachricht nicht erkennen.',
        },
      );
      return;
    }

    state = state.copyWith(
      respondingChatIds: {...state.respondingChatIds, chatId},
      chatErrors: {...state.chatErrors}..remove(chatId),
    );

    try {
      final contextMessages = await _repository.listMessages(chatId);
      final chatPool = state.allChats.isEmpty ? state.chats : state.allChats;
      final chat = chatPool.cast<ImpulseChat?>().firstWhere(
        (chat) => chat?.id == chatId,
        orElse: () => null,
      );
      final response = await _aiChatClient.sendMessage(
        AiChatRequest(
          message: transcript,
          language: 'DE',
          context: await _chatContext(
            chatId: chatId,
            chat: chat,
            messages: contextMessages,
            voiceTranscript: transcript,
          ),
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
      await _refreshChat(userMessage.chatId);
    }
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
      final chatPool = state.allChats.isEmpty ? state.chats : state.allChats;
      final chat = chatPool.cast<ImpulseChat?>().firstWhere(
        (chat) => chat?.id == chatId,
        orElse: () => null,
      );
      final response = await _aiChatClient.sendMessage(
        AiChatRequest(
          message: userMessage.text,
          language: 'DE',
          context: await _chatContext(
            chatId: chatId,
            chat: chat,
            messages: contextMessages,
          ),
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

  Future<List<ImpulseSavedMessage>> loadStarredMessagesForChat(String chatId) {
    return _repository.listStarredMessagesForChat(chatId);
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
    final allChats = await _repository.listAllChats();
    final hiddenChats = await _repository.listHiddenChats();
    final savedMessages = await _repository.listStarredMessages();
    state = state.copyWith(
      chats: chats,
      allChats: allChats,
      hiddenChats: hiddenChats,
      savedMessages: savedMessages,
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

  String _replyPreviewText(ImpulseMessage message) {
    if (message.contentType == ImpulseMessageContentType.audio) {
      return 'Sprachnachricht';
    }
    final normalized = message.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (normalized.length <= 72) return normalized;
    return '${normalized.substring(0, 69)}...';
  }

  Future<Map<String, Object?>> _chatContext({
    required String chatId,
    required ImpulseChat? chat,
    required List<ImpulseMessage> messages,
    String? voiceTranscript,
  }) async {
    final sourceType = chat?.sourceType;
    final effectiveProfile = effectiveAiProfileForChat(chat);
    final context = <String, Object?>{
      'source': 'impulse_inbox',
      'chatId': chatId,
      'chatType': sourceType?.wireName ?? 'unknown',
      'chatTitle': chat?.title,
      'aiProfileSource': chat?.aiProfileOverride.hasOverrides == true
          ? 'chat_override'
          : 'global',
      'recentMessages': messages
          .takeLast(8)
          .map(
            (message) => {
              'role': message.source == ImpulseMessageSource.user
                  ? 'user'
                  : 'assistant',
              'content': message.contentType == ImpulseMessageContentType.audio
                  ? (message.audioTranscript?.trim().isNotEmpty == true
                        ? '[Gesprochene Nachricht] ${message.audioTranscript!.trim()}'
                        : '[Sprachnachricht]')
                  : message.text,
            },
          )
          .toList(growable: false),
      ...effectiveProfile.toAiContext(),
    };
    final normalizedVoiceTranscript = voiceTranscript?.trim();
    if (normalizedVoiceTranscript != null &&
        normalizedVoiceTranscript.isNotEmpty) {
      context['voiceMessageTranscript'] = normalizedVoiceTranscript;
      context['voiceMessageInstruction'] =
          'Der Nutzer hat diese Nachricht gesprochen. Antworte auf den transkribierten Inhalt. Die Audiodatei bleibt lokal und wird nicht hochgeladen.';
    }
    if (sourceType == ImpulseChatSourceType.category) {
      context['categoryId'] = chat?.sourceId;
      context['categoryTitle'] = chat?.title;
      context['instruction'] =
          'Antworte im Kontext dieser Wort-Kategorie. Verändere keine Lernstände.';
      final categoryId = chat?.sourceId?.trim();
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          _categoryWordSampler != null) {
        final sample = await _categoryWordSampler(categoryId);
        if (sample.isNotEmpty) {
          context['categoryWordsSample'] = sample;
          context['categoryWordsInstruction'] =
              'Nutze diese Wörter nur als Gesprächskontext. Verändere keine Lernstände, keine Queue und keine SRS-Werte.';
        }
      }
    }
    if (sourceType == ImpulseChatSourceType.customAi) {
      context['instruction'] =
          'Antworte als lokaler Talvori KI-Chat. Der Verlauf bleibt lokal auf diesem Gerät.';
    }
    return context;
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (length <= count) return this;
    return skip(length - count);
  }
}
