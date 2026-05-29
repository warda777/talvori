import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/companion/application/tali_emotion_controller.dart';

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('default emotion is neutral', () {
    final container = createContainer();

    expect(container.read(taliEmotionControllerProvider), TaliEmotion.neutral);
  });

  test('setEmotion updates the current emotion', () {
    final container = createContainer();

    container
        .read(taliEmotionControllerProvider.notifier)
        .setEmotion(TaliEmotion.cool);

    expect(container.read(taliEmotionControllerProvider), TaliEmotion.cool);
  });

  test('showTemporaryEmotion falls back after the duration', () async {
    final container = createContainer();

    container
        .read(taliEmotionControllerProvider.notifier)
        .showTemporaryEmotion(
          TaliEmotion.starEyes,
          duration: const Duration(milliseconds: 10),
          fallback: TaliEmotion.neutral,
        );

    expect(container.read(taliEmotionControllerProvider), TaliEmotion.starEyes);

    await Future<void>.delayed(const Duration(milliseconds: 30));

    expect(container.read(taliEmotionControllerProvider), TaliEmotion.neutral);
  });

  test('new temporary emotion cancels the previous fallback timer', () async {
    final container = createContainer();
    final controller = container.read(taliEmotionControllerProvider.notifier);

    controller.showTemporaryEmotion(
      TaliEmotion.happy,
      duration: const Duration(milliseconds: 10),
    );
    controller.showTemporaryEmotion(
      TaliEmotion.party,
      duration: const Duration(milliseconds: 40),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(container.read(taliEmotionControllerProvider), TaliEmotion.party);

    await Future<void>.delayed(const Duration(milliseconds: 40));

    expect(container.read(taliEmotionControllerProvider), TaliEmotion.neutral);
  });

  test('disposing the container cancels pending timers', () {
    final container = ProviderContainer();

    container
        .read(taliEmotionControllerProvider.notifier)
        .showTemporaryEmotion(
          TaliEmotion.surprised,
          duration: const Duration(seconds: 1),
        );

    expect(
      container.read(taliEmotionControllerProvider),
      TaliEmotion.surprised,
    );
    expect(container.dispose, returnsNormally);
  });

  test('event mapping resolves core app events', () {
    expect(
      TalvoriMascotAssets.emotionForEvent(TaliEvent.aiThinking),
      TaliEmotion.thinking,
    );
    expect(
      TalvoriMascotAssets.emotionForEvent(TaliEvent.aiResponseSuccess),
      TaliEmotion.happy,
    );
    expect(
      TalvoriMascotAssets.emotionForEvent(TaliEvent.aiResponseError),
      TaliEmotion.surprised,
    );
    expect(
      TalvoriMascotAssets.emotionForEvent(TaliEvent.pointsGained),
      TaliEmotion.starEyes,
    );
    expect(
      TalvoriMascotAssets.emotionForEvent(TaliEvent.dailyGoalReached),
      TaliEmotion.party,
    );
  });

  test('asset resolver supports male and female neutral assets', () {
    expect(
      TalvoriMascotAssets.spiritPathFor(
        TaliEmotion.neutral,
        style: TalvoriMascotStyle.female,
      ),
      TalvoriMascotAssets.taliFemaleNeutral,
    );
    expect(
      TalvoriMascotAssets.spiritPathFor(
        TaliEmotion.neutral,
        style: TalvoriMascotStyle.male,
      ),
      TalvoriMascotAssets.taliMaleNeutral,
    );
  });

  test('asset resolver falls back to neutral for unmapped emotions', () {
    expect(
      TalvoriMascotAssets.spiritPathFor(
        TaliEmotion.thinking,
        style: TalvoriMascotStyle.female,
      ),
      TalvoriMascotAssets.taliFemaleNeutral,
    );
    expect(
      TalvoriMascotAssets.spiritPathFor(
        TaliEmotion.thinking,
        style: TalvoriMascotStyle.male,
      ),
      TalvoriMascotAssets.taliMaleNeutral,
    );
  });
}
