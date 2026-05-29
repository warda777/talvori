import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/companion/domain/companion_discovery_tip.dart';
import 'package:talvori/features/companion/domain/companion_state.dart';

final companionControllerProvider =
    NotifierProvider<CompanionController, CompanionState>(
      CompanionController.new,
    );

class CompanionController extends Notifier<CompanionState> {
  @override
  CompanionState build() => CompanionState.initial();

  void wakeUp() {
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: TalvoriMascotMood.greeting,
      emotion: TaliEmotion.neutral,
      clearErrorMessage: true,
    );
  }

  void compact() {
    state = state.copyWith(
      isExpanded: false,
      bubbleVisible: false,
      mascotMood: TalvoriMascotMood.idle,
      emotion: TaliEmotion.neutral,
      inputVisible: false,
      isThinking: false,
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
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: mood ?? state.mascotMood,
      emotion:
          emotion ??
          (mood == null
              ? state.emotion
              : TalvoriMascotAssets.emotionForLegacyMood(mood)),
      message: message,
      clearErrorMessage: true,
    );
  }

  void showDiscoveryTip(CompanionDiscoveryTip tip) {
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
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      mascotMood: TalvoriMascotMood.thinkingChin,
      emotion: TaliEmotion.thinking,
      clearErrorMessage: true,
    );
  }

  void closeChatInput() {
    state = state.copyWith(inputVisible: false);
  }

  void submitUserMessage(String message) {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: true,
      mascotMood: TalvoriMascotMood.thinkingChin,
      emotion: TaliEmotion.thinking,
      message: 'Ich denke kurz nach ...',
      inputText: '',
      lastUserMessage: trimmed,
      clearErrorMessage: true,
    );
  }

  void setThinking() {
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: true,
      mascotMood: TalvoriMascotMood.thinkingChin,
      emotion: TaliEmotion.thinking,
      message: 'Ich denke kurz nach ...',
      clearErrorMessage: true,
    );
  }

  void showAiResponse(String response) {
    final trimmed = response.trim();
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: false,
      mascotMood: TalvoriMascotMood.happy,
      emotion: TaliEmotion.happy,
      message: trimmed.isEmpty
          ? 'Ich bin da. Frag mich einfach noch mal kurz.'
          : trimmed,
      clearErrorMessage: true,
    );
  }

  void showError(String message) {
    final trimmed = message.trim();
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      inputVisible: true,
      isThinking: false,
      mascotMood: TalvoriMascotMood.sad,
      emotion: TaliEmotion.embarrassed,
      message: trimmed.isEmpty
          ? 'Das hat gerade nicht geklappt. Versuch es gleich noch einmal.'
          : trimmed,
      errorMessage: trimmed.isEmpty ? 'unknown' : trimmed,
    );
  }
}
