import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyShowOnboardingOnStart = 'showOnboardingOnStart';

/// Persistente Einstellung: Onboarding bei jedem App-Start anzeigen.
/// Default: false (abgeschaltet).
final showOnboardingOnStartProvider =
    StateNotifierProvider<OnboardingSettingsNotifier, bool>((ref) {
  return OnboardingSettingsNotifier();
});

class OnboardingSettingsNotifier extends StateNotifier<bool> {
  OnboardingSettingsNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_keyShowOnboardingOnStart) ?? false;
  }

  Future<void> setShowOnStart(bool value) async {
    state = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowOnboardingOnStart, value);
  }
}
