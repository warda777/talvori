import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/companion/application/companion_controller.dart';
import 'package:talvori/features/companion/application/tali_emotion_controller.dart';
import 'package:talvori/features/companion/domain/companion_discovery_tip.dart';

void main() {
  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  test('initial state greets the user', () {
    final container = createContainer();

    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.mascotMood, TalvoriMascotMood.greeting);
    expect(state.emotion, TaliEmotion.neutral);
    expect(state.title, 'Talvori');
    expect(state.message, 'Bereit für dein nächstes Wort?');
    expect(state.inputVisible, isFalse);
    expect(state.isThinking, isFalse);
    expect(state.lastReplyMessage, isNull);
  });

  test('compact hides the bubble and shows the idle mascot', () {
    final container = createContainer();

    container.read(companionControllerProvider.notifier).openChatInput();
    container.read(companionControllerProvider.notifier).compact();
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isFalse);
    expect(state.bubbleVisible, isFalse);
    expect(state.mascotMood, TalvoriMascotMood.idle);
    expect(state.emotion, TaliEmotion.neutral);
    expect(state.inputVisible, isFalse);
    expect(state.isThinking, isFalse);
  });

  test('wakeUp expands the companion and shows the bubble', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.compact();
    controller.wakeUp();
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.mascotMood, TalvoriMascotMood.greeting);
    expect(state.emotion, TaliEmotion.neutral);
    expect(CompanionController.focusPrompts, contains(state.message));
  });

  test('wakeUp rotates stable focus prompts without rebuild randomness', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.compact();
    controller.wakeUp();
    final firstPrompt = container.read(companionControllerProvider).message;
    controller.compact();
    controller.wakeUp();
    final secondPrompt = container.read(companionControllerProvider).message;

    expect(CompanionController.focusPrompts, contains(firstPrompt));
    expect(CompanionController.focusPrompts, contains(secondPrompt));
    expect(secondPrompt, isNot(firstPrompt));
  });

  test('toggleExpanded switches between expanded and compact states', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.toggleExpanded();
    var state = container.read(companionControllerProvider);

    expect(state.isExpanded, isFalse);
    expect(state.bubbleVisible, isFalse);
    expect(state.mascotMood, TalvoriMascotMood.idle);

    controller.toggleExpanded();
    state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.mascotMood, TalvoriMascotMood.greeting);
  });

  test('showMessage updates the bubble text and optional mood', () {
    final container = createContainer();

    container
        .read(companionControllerProvider.notifier)
        .showMessage(
          message: 'Stark, weiter so.',
          mood: TalvoriMascotMood.proud,
        );
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.mascotMood, TalvoriMascotMood.proud);
    expect(state.emotion, TaliEmotion.starEyes);
    expect(state.message, 'Stark, weiter so.');
    expect(state.lastReplyMessage, 'Stark, weiter so.');
  });

  test('showMessage can set an explicit Tali emotion', () {
    final container = createContainer();

    container
        .read(companionControllerProvider.notifier)
        .showMessage(
          message: 'Kurz cool bleiben.',
          mood: TalvoriMascotMood.proud,
          emotion: TaliEmotion.cool,
        );
    final state = container.read(companionControllerProvider);

    expect(state.mascotMood, TalvoriMascotMood.proud);
    expect(state.emotion, TaliEmotion.cool);
    expect(state.message, 'Kurz cool bleiben.');
  });

  test('showDiscoveryTip displays a local discovery tip', () {
    final container = createContainer();

    container
        .read(companionControllerProvider.notifier)
        .showDiscoveryTip(CompanionDiscoveryTips.wordGames);
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.title, CompanionDiscoveryTips.wordGames.title);
    expect(state.message, CompanionDiscoveryTips.wordGames.message);
    expect(state.mascotMood, CompanionDiscoveryTips.wordGames.mood);
    expect(
      state.emotion,
      TalvoriMascotAssets.emotionForLegacyMood(
        CompanionDiscoveryTips.wordGames.mood,
      ),
    );
  });

  test('hideBubble only hides the bubble', () {
    final container = createContainer();

    container.read(companionControllerProvider.notifier).hideBubble();
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isFalse);
    expect(state.mascotMood, TalvoriMascotMood.greeting);
  });

  test('showBrowserShareHint shows the browser-share guidance', () {
    final container = createContainer();

    container.read(companionControllerProvider.notifier).showBrowserShareHint();
    final state = container.read(companionControllerProvider);

    expect(state.bubbleVisible, isTrue);
    expect(state.message, CompanionDiscoveryTips.browserShare.message);
    expect(state.mascotMood, CompanionDiscoveryTips.browserShare.mood);
  });

  test('openChatInput expands the companion and shows input state', () {
    final container = createContainer();

    container.read(companionControllerProvider.notifier).openChatInput();
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.inputVisible, isTrue);
    expect(state.mascotMood, TalvoriMascotMood.greeting);
    expect(state.emotion, TaliEmotion.neutral);
    expect(CompanionController.chatPrompts, contains(state.message));
    expect(state.message, isNot(CompanionDiscoveryTips.browserShare.message));
  });

  test('openChatInput uses chat prompt instead of browser discovery text', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.showBrowserShareHint();
    controller.openChatInput();
    final state = container.read(companionControllerProvider);

    expect(state.inputVisible, isTrue);
    expect(CompanionController.chatPrompts, contains(state.message));
    expect(state.message, isNot(CompanionDiscoveryTips.browserShare.message));
  });

  test('closeChatInput only hides the input', () {
    final container = createContainer();

    final controller = container.read(companionControllerProvider.notifier);
    controller.openChatInput();
    controller.closeChatInput();
    final state = container.read(companionControllerProvider);

    expect(state.inputVisible, isFalse);
    expect(state.bubbleVisible, isTrue);
  });

  test('submitUserMessage stores the prompt and enters thinking state', () {
    final container = createContainer();

    container
        .read(companionControllerProvider.notifier)
        .submitUserMessage('  Was soll ich üben?  ');
    final state = container.read(companionControllerProvider);

    expect(state.inputVisible, isTrue);
    expect(state.isThinking, isTrue);
    expect(state.lastUserMessage, 'Was soll ich üben?');
    expect(state.message, 'Ich denke kurz nach ...');
    expect(state.mascotMood, TalvoriMascotMood.thinkingChin);
    expect(state.emotion, TaliEmotion.thinking);
    expect(container.read(taliEmotionControllerProvider), TaliEmotion.thinking);
  });

  test('showAiResponse displays a short answer and leaves thinking state', () {
    final container = createContainer();

    final controller = container.read(companionControllerProvider.notifier);
    controller.submitUserMessage('Hallo');
    controller.showAiResponse('Nimm ein kleines Paket.');
    final state = container.read(companionControllerProvider);

    expect(state.isThinking, isFalse);
    expect(state.inputVisible, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.message, 'Nimm ein kleines Paket.');
    expect(state.lastReplyMessage, 'Nimm ein kleines Paket.');
    expect(state.mascotMood, TalvoriMascotMood.happy);
    expect(state.emotion, TaliEmotion.happy);
    expect(container.read(taliEmotionControllerProvider), TaliEmotion.happy);
  });

  test('compact and wakeUp keep the last companion reply', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.showAiResponse('Das bleibt in der Bubble.');
    controller.compact();
    var state = container.read(companionControllerProvider);

    expect(state.isExpanded, isFalse);
    expect(state.bubbleVisible, isFalse);
    expect(state.message, 'Das bleibt in der Bubble.');
    expect(state.lastReplyMessage, 'Das bleibt in der Bubble.');

    controller.wakeUp();
    state = container.read(companionControllerProvider);

    expect(state.isExpanded, isTrue);
    expect(state.bubbleVisible, isTrue);
    expect(state.message, 'Das bleibt in der Bubble.');

    controller.openChatInput();
    state = container.read(companionControllerProvider);

    expect(state.inputVisible, isTrue);
    expect(state.message, 'Das bleibt in der Bubble.');
  });

  test('discovery tips do not overwrite a retained reply', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.showAiResponse('Behalte diese Antwort.');
    controller.compact();
    controller.showDiscoveryTip(CompanionDiscoveryTips.wordGames);
    final state = container.read(companionControllerProvider);

    expect(state.bubbleVisible, isTrue);
    expect(state.message, 'Behalte diese Antwort.');
    expect(state.lastReplyMessage, 'Behalte diese Antwort.');
  });

  test('new companion replies replace the retained reply', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.showAiResponse('Erste Antwort.');
    controller.submitUserMessage('Neue Frage');
    controller.showAiResponse('Zweite Antwort.');
    final state = container.read(companionControllerProvider);

    expect(state.message, 'Zweite Antwort.');
    expect(state.lastReplyMessage, 'Zweite Antwort.');
  });

  test('showError displays a friendly error state', () {
    final container = createContainer();

    container
        .read(companionControllerProvider.notifier)
        .showError('Gerade klappt es nicht.');
    final state = container.read(companionControllerProvider);

    expect(state.isThinking, isFalse);
    expect(state.inputVisible, isTrue);
    expect(state.errorMessage, 'Gerade klappt es nicht.');
    expect(state.message, 'Gerade klappt es nicht.');
    expect(state.mascotMood, TalvoriMascotMood.sad);
    expect(state.emotion, TaliEmotion.surprised);
    expect(
      container.read(taliEmotionControllerProvider),
      TaliEmotion.surprised,
    );
  });
}
