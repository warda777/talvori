import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/companion/application/companion_discovery_tip_resolver.dart';
import 'package:talvori/features/companion/domain/companion_discovery_context.dart';
import 'package:talvori/features/companion/domain/companion_discovery_tip.dart';

void main() {
  const resolver = CompanionDiscoveryTipResolver();

  CompanionDiscoveryContext context({
    int myWordsCount = 1,
    int favoritesCount = 0,
    bool hasUsedBrowserShare = true,
    bool hasUsedWordGames = true,
    bool hasCreatedDailyImpulse = true,
    bool hasOpenedLearningLevels = true,
    bool hasOpenedLanguageTools = true,
    bool hasOpenedWordWorlds = true,
  }) {
    return CompanionDiscoveryContext(
      myWordsCount: myWordsCount,
      favoritesCount: favoritesCount,
      hasUsedBrowserShare: hasUsedBrowserShare,
      hasUsedWordGames: hasUsedWordGames,
      hasCreatedDailyImpulse: hasCreatedDailyImpulse,
      hasOpenedLearningLevels: hasOpenedLearningLevels,
      hasOpenedLanguageTools: hasOpenedLanguageTools,
      hasOpenedWordWorlds: hasOpenedWordWorlds,
    );
  }

  test('empty my words count resolves to browser share', () {
    final tip = resolver.resolve(context(myWordsCount: 0));

    expect(tip?.type, CompanionDiscoveryTipType.browserShare);
  });

  test('unused browser share resolves to browser share', () {
    final tip = resolver.resolve(context(hasUsedBrowserShare: false));

    expect(tip?.type, CompanionDiscoveryTipType.browserShare);
  });

  test('unused word games resolve after browser share is done', () {
    final tip = resolver.resolve(context(hasUsedWordGames: false));

    expect(tip?.type, CompanionDiscoveryTipType.wordGames);
  });

  test('daily impulse resolves after word games are used', () {
    final tip = resolver.resolve(context(hasCreatedDailyImpulse: false));

    expect(tip?.type, CompanionDiscoveryTipType.dailyImpulse);
  });

  test('priority stays stable when several discovery flags are unused', () {
    final tip = resolver.resolve(
      context(
        hasUsedWordGames: false,
        hasCreatedDailyImpulse: false,
        hasOpenedWordWorlds: false,
      ),
    );

    expect(tip?.type, CompanionDiscoveryTipType.wordGames);
  });

  test('fully used discovery context falls back to motivation', () {
    final tip = resolver.resolve(context());

    expect(tip?.type, CompanionDiscoveryTipType.motivation);
  });
}
