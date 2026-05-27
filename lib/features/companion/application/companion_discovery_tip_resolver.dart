import 'package:talvori/features/companion/domain/companion_discovery_context.dart';
import 'package:talvori/features/companion/domain/companion_discovery_tip.dart';

class CompanionDiscoveryTipResolver {
  const CompanionDiscoveryTipResolver();

  CompanionDiscoveryTip? resolve(CompanionDiscoveryContext context) {
    if (context.myWordsCount == 0 || !context.hasUsedBrowserShare) {
      return CompanionDiscoveryTips.browserShare;
    }
    if (!context.hasUsedWordGames) {
      return CompanionDiscoveryTips.wordGames;
    }
    if (!context.hasCreatedDailyImpulse) {
      return CompanionDiscoveryTips.dailyImpulse;
    }
    if (!context.hasOpenedWordWorlds) {
      return CompanionDiscoveryTips.wordWorlds;
    }
    if (!context.hasOpenedLearningLevels) {
      return CompanionDiscoveryTips.learningLevels;
    }
    if (!context.hasOpenedLanguageTools) {
      return CompanionDiscoveryTips.languageTools;
    }
    return CompanionDiscoveryTips.motivation;
  }
}
