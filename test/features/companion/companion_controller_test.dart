import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/assets/talvori_mascot_assets.dart';
import 'package:talvori/features/companion/application/companion_controller.dart';
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
    expect(state.title, 'Talvori');
    expect(state.message, 'Bereit für dein nächstes Wort?');
    expect(state.inputVisible, isFalse);
    expect(state.isThinking, isFalse);
  });

  test('compact hides the bubble and shows the bored mascot', () {
    final container = createContainer();

    container.read(companionControllerProvider.notifier).openChatInput();
    container.read(companionControllerProvider.notifier).compact();
    final state = container.read(companionControllerProvider);

    expect(state.isExpanded, isFalse);
    expect(state.bubbleVisible, isFalse);
    expect(state.mascotMood, TalvoriMascotMood.bored);
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
  });

  test('toggleExpanded switches between expanded and compact states', () {
    final container = createContainer();
    final controller = container.read(companionControllerProvider.notifier);

    controller.toggleExpanded();
    var state = container.read(companionControllerProvider);

    expect(state.isExpanded, isFalse);
    expect(state.bubbleVisible, isFalse);
    expect(state.mascotMood, TalvoriMascotMood.bored);

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
    expect(state.message, 'Stark, weiter so.');
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
    expect(state.mascotMood, TalvoriMascotMood.thinkingChin);
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
    expect(state.mascotMood, TalvoriMascotMood.happy);
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
  });
}
