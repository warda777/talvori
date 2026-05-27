class CompanionDiscoveryContext {
  const CompanionDiscoveryContext({
    required this.myWordsCount,
    required this.favoritesCount,
    required this.hasUsedBrowserShare,
    required this.hasUsedWordGames,
    required this.hasCreatedDailyImpulse,
    required this.hasOpenedLearningLevels,
    required this.hasOpenedLanguageTools,
    required this.hasOpenedWordWorlds,
    this.onboardingGoal,
  });

  const CompanionDiscoveryContext.empty()
    : myWordsCount = 0,
      favoritesCount = 0,
      hasUsedBrowserShare = false,
      hasUsedWordGames = false,
      hasCreatedDailyImpulse = false,
      hasOpenedLearningLevels = false,
      hasOpenedLanguageTools = false,
      hasOpenedWordWorlds = false,
      onboardingGoal = null;

  final int myWordsCount;
  final int favoritesCount;
  final bool hasUsedBrowserShare;
  final bool hasUsedWordGames;
  final bool hasCreatedDailyImpulse;
  final bool hasOpenedLearningLevels;
  final bool hasOpenedLanguageTools;
  final bool hasOpenedWordWorlds;
  final String? onboardingGoal;
}
