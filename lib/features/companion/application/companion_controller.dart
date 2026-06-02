import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/companion/application/tali_emotion_controller.dart';
import 'package:talvori/features/companion/domain/companion_discovery_tip.dart';
import 'package:talvori/features/companion/domain/companion_state.dart';

final companionControllerProvider =
    NotifierProvider<CompanionController, CompanionState>(
      CompanionController.new,
    );

class CompanionController extends Notifier<CompanionState> {
  static const focusPrompts = [
    'Sammle heute ein Wort aus deiner echten Welt.',
    'Ein neues Wort kann später deine Welt bauen.',
    'Such dir ein Wort, das dir heute begegnet ist.',
    'Öffne den Browser, markiere ein Wort und bring es in deine Welt.',
    'Eine kurze Runde reicht, um weiterzubauen.',
    'Deine Welt wächst durch kleine Schritte.',
  ];

  static const chatPrompts = [
    'Frag Tali kurz etwas.',
    'Ich kann dir Wörter erklären oder daraus Sätze machen.',
    'Schreib mir, wobei ich dir helfen soll.',
    'Frag mich nach einem Beispiel, einer Übersetzung oder einem Satz.',
  ];

  int _focusPromptIndex = 0;
  int _chatPromptIndex = 0;

  @override
  CompanionState build() => CompanionState.initial();

  TaliEmotion _emotionForEvent(TaliEvent event) {
    ref.read(taliEmotionControllerProvider.notifier).handleEvent(event);
    return TalvoriMascotAssets.emotionForEvent(event);
  }

  void wakeUp() {
    final emotion = _emotionForEvent(TaliEvent.appReady);
    final retainedReply = state.lastReplyMessage?.trim();
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: TalvoriMascotMood.greeting,
      emotion: emotion,
      inputVisible: false,
      message: retainedReply != null && retainedReply.isNotEmpty
          ? retainedReply
          : _nextFocusPrompt(),
      clearErrorMessage: true,
    );
  }

  void compact() {
    final retainedReply = state.lastReplyMessage?.trim();
    final shouldRestoreReply =
        state.isThinking && retainedReply != null && retainedReply.isNotEmpty;
    state = state.copyWith(
      isExpanded: false,
      bubbleVisible: false,
      mascotMood: TalvoriMascotMood.idle,
      emotion: TaliEmotion.neutral,
      inputVisible: false,
      isThinking: false,
      message: shouldRestoreReply ? retainedReply : null,
    );
  }

  void toggleExpanded() {
    if (state.isExpanded) {
      compact();
    } else {
      wakeUp();
    }
  }

  void showMessage({
    required String message,
    TalvoriMascotMood? mood,
    TaliEmotion? emotion,
  }) {
    final trimmed = message.trim();
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: mood ?? state.mascotMood,
      emotion:
          emotion ??
          (mood == null
              ? state.emotion
              : TalvoriMascotAssets.emotionForLegacyMood(mood)),
      message: trimmed.isEmpty ? CompanionState.defaultMessage : trimmed,
      lastReplyMessage: trimmed.isEmpty ? null : trimmed,
      clearLastReplyMessage: trimmed.isEmpty,
      clearErrorMessage: true,
    );
  }

  void showDiscoveryTip(CompanionDiscoveryTip tip) {
    final retainedReply = state.lastReplyMessage?.trim();
    if (retainedReply != null && retainedReply.isNotEmpty) {
      state = state.copyWith(
        isExpanded: true,
        bubbleVisible: true,
        message: retainedReply,
        clearErrorMessage: true,
      );
      return;
    }

    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: tip.mood,
      emotion: TalvoriMascotAssets.emotionForLegacyMood(tip.mood),
      title: tip.title,
      message: tip.message,
      clearErrorMessage: true,
    );
  }

  void hideBubble() {
    state = state.copyWith(bubbleVisible: false);
  }

  void showBrowserShareHint() {
    showDiscoveryTip(CompanionDiscoveryTips.browserShare);
  }

  void openChatInput() {
    final retainedReply = state.lastReplyMessage?.trim();
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      message: retainedReply != null && retainedReply.isNotEmpty
          ? retainedReply
          : _nextChatPrompt(),
      clearErrorMessage: true,
    );
  }

  void closeChatInput() {
    state = state.copyWith(inputVisible: false);
  }

  void submitUserMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    final emotion = _emotionForEvent(TaliEvent.userMessageSent);
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: true,
      mascotMood: TalvoriMascotMood.thinkingChin,
      emotion: emotion,
      message: 'Ich denke kurz nach ...',
      inputText: '',
      lastUserMessage: trimmed,
      clearErrorMessage: true,
    );
  }

  void setThinking() {
    final emotion = _emotionForEvent(TaliEvent.aiThinking);
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: true,
      mascotMood: TalvoriMascotMood.thinkingChin,
      emotion: emotion,
      message: 'Ich denke kurz nach ...',
      clearErrorMessage: true,
    );
  }

  void showAiResponse(String response) {
    final trimmed = response.trim();
    final nextMessage = trimmed.isEmpty
        ? 'Ich bin da. Frag mich einfach noch mal kurz.'
        : trimmed;
    final emotion = _emotionForEvent(TaliEvent.aiResponseSuccess);
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: false,
      mascotMood: TalvoriMascotMood.happy,
      emotion: emotion,
      message: nextMessage,
      lastReplyMessage: nextMessage,
      clearErrorMessage: true,
    );
  }

  void showError(String message) {
    final trimmed = message.trim();
    final nextMessage = trimmed.isEmpty
        ? 'Das hat gerade nicht geklappt. Versuch es gleich noch einmal.'
        : trimmed;
    final emotion = _emotionForEvent(TaliEvent.aiResponseError);
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: false,
      mascotMood: TalvoriMascotMood.sad,
      emotion: emotion,
      message: nextMessage,
      lastReplyMessage: nextMessage,
      errorMessage: trimmed.isEmpty ? 'unknown' : trimmed,
    );
  }

  String _nextFocusPrompt() {
    final prompt = focusPrompts[_focusPromptIndex % focusPrompts.length];
    _focusPromptIndex = (_focusPromptIndex + 1) % focusPrompts.length;
    return prompt;
  }

  String _nextChatPrompt() {
    final prompt = chatPrompts[_chatPromptIndex % chatPrompts.length];
    _chatPromptIndex = (_chatPromptIndex + 1) % chatPrompts.length;
    return prompt;
  }
}
