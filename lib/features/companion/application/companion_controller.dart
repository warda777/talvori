import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';
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
    );
  }

  void compact() {
    state = state.copyWith(
      isExpanded: false,
      bubbleVisible: false,
      mascotMood: TalvoriMascotMood.bored,
    );
  }

  void toggleExpanded() {
    if (state.isExpanded) {
      compact();
    } else {
      wakeUp();
    }
  }

  void showMessage({required String message, TalvoriMascotMood? mood}) {
    state = state.copyWith(
      isExpanded: true,
      bubbleVisible: true,
      mascotMood: mood ?? state.mascotMood,
      message: message,
    );
  }

  void hideBubble() {
    state = state.copyWith(bubbleVisible: false);
  }

  void showBrowserShareHint() {
    showMessage(
      message: 'Markiere ein Wort im Browser und teile es mit Talvori.',
      mood: TalvoriMascotMood.greeting,
    );
  }
}
