import 'package:talvori/core/assets/talvori_mascot_assets.dart';

class CompanionState {
  const CompanionState({
    required this.isExpanded,
    required this.bubbleVisible,
    required this.mascotMood,
    required this.title,
    required this.message,
  });

  factory CompanionState.initial() {
    return const CompanionState(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: TalvoriMascotMood.greeting,
      title: 'Talvori',
      message: 'Bereit für dein nächstes Wort?',
    );
  }

  final bool isExpanded;
  final bool bubbleVisible;
  final TalvoriMascotMood mascotMood;
  final String title;
  final String message;

  CompanionState copyWith({
    bool? isExpanded,
    bool? bubbleVisible,
    TalvoriMascotMood? mascotMood,
    String? title,
    String? message,
  }) {
    return CompanionState(
      isExpanded: isExpanded ?? this.isExpanded,
      bubbleVisible: bubbleVisible ?? this.bubbleVisible,
      mascotMood: mascotMood ?? this.mascotMood,
      title: title ?? this.title,
      message: message ?? this.message,
    );
  }
}
