import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const onboardingCompletedKey = 'talvori_onboarding_completed_v1';
const onboardingPlacementLevelKey = 'talvori_onboarding_placement_level_v1';
const onboardingPlacementKnownWordsKey =
    'talvori_onboarding_placement_known_words_v1';
const onboardingReferralSourceKey = 'talvori_onboarding_referral_source_v1';
const onboardingTopicInterestsKey = 'talvori_onboarding_topic_interests_v1';
const onboardingMotivationsKey = 'talvori_onboarding_motivations_v1';
const onboardingWeeklyGoalKey = 'talvori_onboarding_weekly_goal_v1';
const onboardingUncertaintyAreaKey = 'talvori_onboarding_uncertainty_area_v1';
const onboardingSelfAssessmentKey = 'talvori_onboarding_self_assessment_v1';

final onboardingStateServiceProvider = Provider<OnboardingStateService>((ref) {
  return const OnboardingStateService();
});

final hasCompletedOnboardingProvider = FutureProvider<bool>((ref) async {
  return ref.watch(onboardingStateServiceProvider).hasCompletedOnboarding();
});

class OnboardingStateService {
  const OnboardingStateService();

  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingCompletedKey) ?? false;
  }

  Future<void> complete({
    required String placementLevel,
    required int knownWords,
    required String referralSource,
    required List<String> topicInterests,
    required List<String> motivations,
    required String weeklyGoal,
    required String uncertaintyArea,
    required String selfAssessment,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
    await prefs.setString(onboardingPlacementLevelKey, placementLevel);
    await prefs.setInt(onboardingPlacementKnownWordsKey, knownWords);
    await prefs.setString(onboardingReferralSourceKey, referralSource);
    await prefs.setStringList(onboardingTopicInterestsKey, topicInterests);
    await prefs.setStringList(onboardingMotivationsKey, motivations);
    await prefs.setString(onboardingWeeklyGoalKey, weeklyGoal);
    await prefs.setString(onboardingUncertaintyAreaKey, uncertaintyArea);
    await prefs.setString(onboardingSelfAssessmentKey, selfAssessment);
  }

  Future<void> skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingCompletedKey, true);
    await prefs.setString(onboardingReferralSourceKey, 'Nicht angegeben');
    await prefs.setStringList(onboardingTopicInterestsKey, const []);
    await prefs.setStringList(onboardingMotivationsKey, const []);
    await prefs.setString(onboardingWeeklyGoalKey, '10 Wörter pro Woche');
    await prefs.setString(onboardingUncertaintyAreaKey, 'Nicht angegeben');
    await prefs.setString(onboardingSelfAssessmentKey, 'Nicht angegeben');
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(onboardingCompletedKey);
    await prefs.remove(onboardingPlacementLevelKey);
    await prefs.remove(onboardingPlacementKnownWordsKey);
    await prefs.remove(onboardingReferralSourceKey);
    await prefs.remove(onboardingTopicInterestsKey);
    await prefs.remove(onboardingMotivationsKey);
    await prefs.remove(onboardingWeeklyGoalKey);
    await prefs.remove(onboardingUncertaintyAreaKey);
    await prefs.remove(onboardingSelfAssessmentKey);
  }
}
