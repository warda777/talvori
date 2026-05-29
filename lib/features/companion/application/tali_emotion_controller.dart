import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talvori/core/assets/talvori_mascot_assets.dart';

final taliEmotionControllerProvider =
    NotifierProvider<TaliEmotionController, TaliEmotion>(
      TaliEmotionController.new,
    );

class TaliEmotionController extends Notifier<TaliEmotion> {
  Timer? _fallbackTimer;

  @override
  TaliEmotion build() {
    ref.onDispose(() {
      _fallbackTimer?.cancel();
      _fallbackTimer = null;
    });
    return TaliEmotion.neutral;
  }

  void setEmotion(TaliEmotion emotion) {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
    state = emotion;
  }

  void showTemporaryEmotion(
    TaliEmotion emotion, {
    Duration duration = const Duration(seconds: 2),
    TaliEmotion fallback = TaliEmotion.neutral,
  }) {
    _fallbackTimer?.cancel();
    state = emotion;
    _fallbackTimer = Timer(duration, () {
      state = fallback;
      _fallbackTimer = null;
    });
  }

  void handleEvent(
    TaliEvent event, {
    bool temporary = false,
    Duration duration = const Duration(seconds: 2),
    TaliEmotion fallback = TaliEmotion.neutral,
  }) {
    final emotion = TalvoriMascotAssets.emotionForEvent(event);
    if (temporary) {
      showTemporaryEmotion(emotion, duration: duration, fallback: fallback);
    } else {
      setEmotion(emotion);
    }
  }

  void reset() {
    setEmotion(TaliEmotion.neutral);
  }
}
