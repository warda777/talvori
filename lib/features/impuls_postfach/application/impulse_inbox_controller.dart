import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_chat.dart';
import 'package:talvori/features/impuls_postfach/models/impulse_message.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

class ImpulseInboxState {
  const ImpulseInboxState({
    this.isLoading = false,
    this.chats = const [],
    this.messagesByChat = const {},
  });

  final bool isLoading;
  final List<ImpulseChat> chats;
  final Map<String, List<ImpulseMessage>> messagesByChat;

  ImpulseInboxState copyWith({
    bool? isLoading,
    List<ImpulseChat>? chats,
    Map<String, List<ImpulseMessage>>? messagesByChat,
  }) {
    return ImpulseInboxState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      messagesByChat: messagesByChat ?? this.messagesByChat,
    );
  }
}

class ImpulseInboxController extends StateNotifier<ImpulseInboxState> {
  ImpulseInboxController({required ImpulseInboxRepository repository})
    : _repository = repository,
      super(const ImpulseInboxState(isLoading: true));

  final ImpulseInboxRepository _repository;

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

  Future<List<ImpulseMessage>> loadMessages(String chatId) async {
    final messages = await _repository.listMessages(chatId);
    state = state.copyWith(
      messagesByChat: {...state.messagesByChat, chatId: messages},
    );
    return messages;
  }

  Future<void> markChatRead(String chatId) async {
    await _repository.markChatRead(chatId);
    final messages = await _repository.listMessages(chatId);
    final chats = await _repository.listChats();
    state = state.copyWith(
      chats: chats,
      messagesByChat: {...state.messagesByChat, chatId: messages},
    );
  }
}
