import 'package:talvori/core/assets/talvori_mascot_assets.dart';

class CompanionState {
  const CompanionState({
    required this.isExpanded,
    required this.bubbleVisible,
    required this.mascotMood,
    required this.emotion,
    required this.title,
    required this.message,
    required this.inputVisible,
    required this.isThinking,
    this.inputText = '',
    this.lastUserMessage,
    this.lastReplyMessage,
    this.errorMessage,
  });

  static const defaultMessage = 'Bereit für dein nächstes Wort?';

  factory CompanionState.initial() {
    return const CompanionState(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: TalvoriMascotMood.greeting,
      emotion: TaliEmotion.neutral,
      title: 'Talvori',
      message: defaultMessage,
      inputVisible: false,
      isThinking: false,
    );
  }

  final bool isExpanded;
  final bool bubbleVisible;
  final TalvoriMascotMood mascotMood;
  final TaliEmotion emotion;
  final String title;
  final String message;
  final bool inputVisible;
  final bool isThinking;
  final String inputText;
  final String? lastUserMessage;
  final String? lastReplyMessage;
  final String? errorMessage;

  CompanionState copyWith({
    bool? isExpanded,
    bool? bubbleVisible,
    TalvoriMascotMood? mascotMood,
    TaliEmotion? emotion,
    String? title,
    String? message,
    bool? inputVisible,
    bool? isThinking,
    String? inputText,
    String? lastUserMessage,
    String? lastReplyMessage,
    String? errorMessage,
    bool clearLastUserMessage = false,
    bool clearLastReplyMessage = false,
    bool clearErrorMessage = false,
  }) {
    return CompanionState(
      isExpanded: isExpanded ?? this.isExpanded,
      bubbleVisible: bubbleVisible ?? this.bubbleVisible,
      mascotMood: mascotMood ?? this.mascotMood,
      emotion: emotion ?? this.emotion,
      title: title ?? this.title,
      message: message ?? this.message,
      inputVisible: inputVisible ?? this.inputVisible,
      isThinking: isThinking ?? this.isThinking,
      inputText: inputText ?? this.inputText,
      lastUserMessage: clearLastUserMessage
          ? null
          : lastUserMessage ?? this.lastUserMessage,
      lastReplyMessage: clearLastReplyMessage
          ? null
          : lastReplyMessage ?? this.lastReplyMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}
