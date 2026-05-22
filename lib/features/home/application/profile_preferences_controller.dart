import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/services/browser_return_service.dart';

class ProfilePreferences {
  const ProfilePreferences({
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.animationsEnabled = true,
    this.autoPronounceCards = false,
    this.learningRemindersEnabled = false,
    this.pendingTranslationRemindersEnabled = false,
    this.browserPreference = BrowserPreference.system,
  });

  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool animationsEnabled;
  final bool autoPronounceCards;
  final bool learningRemindersEnabled;
  final bool pendingTranslationRemindersEnabled;
  final BrowserPreference browserPreference;

  ProfilePreferences copyWith({
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? animationsEnabled,
    bool? autoPronounceCards,
    bool? learningRemindersEnabled,
    bool? pendingTranslationRemindersEnabled,
    BrowserPreference? browserPreference,
  }) {
    return ProfilePreferences(
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      autoPronounceCards: autoPronounceCards ?? this.autoPronounceCards,
      learningRemindersEnabled:
          learningRemindersEnabled ?? this.learningRemindersEnabled,
      pendingTranslationRemindersEnabled:
          pendingTranslationRemindersEnabled ??
          this.pendingTranslationRemindersEnabled,
      browserPreference: browserPreference ?? this.browserPreference,
    );
  }
}

abstract class ProfilePreferencesRepository {
  Future<ProfilePreferences> load();

  Future<void> save(ProfilePreferences preferences);
}

class SharedPreferencesProfilePreferencesRepository
    implements ProfilePreferencesRepository {
  static const _hapticsKey = 'talvori_profile_haptics_enabled_v1';
  static const _soundKey = 'talvori_profile_sound_enabled_v1';
  static const _animationsKey = 'talvori_profile_animations_enabled_v1';
  static const _autoPronounceKey = 'talvori_profile_auto_pronounce_cards_v1';
  static const _learningRemindersKey =
      'talvori_profile_learning_reminders_enabled_v1';
  static const _pendingTranslationRemindersKey =
      'talvori_profile_pending_translation_reminders_enabled_v1';

  @override
  Future<ProfilePreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfilePreferences(
      hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      animationsEnabled: prefs.getBool(_animationsKey) ?? true,
      autoPronounceCards: prefs.getBool(_autoPronounceKey) ?? false,
      learningRemindersEnabled: prefs.getBool(_learningRemindersKey) ?? false,
      pendingTranslationRemindersEnabled:
          prefs.getBool(_pendingTranslationRemindersKey) ?? false,
      browserPreference: BrowserPreference.fromStorage(
        prefs.getString(BrowserReturnService.browserPreferenceStorageKey),
      ),
    );
  }

  @override
  Future<void> save(ProfilePreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hapticsKey, preferences.hapticsEnabled);
    await prefs.setBool(_soundKey, preferences.soundEnabled);
    await prefs.setBool(_animationsKey, preferences.animationsEnabled);
    await prefs.setBool(_autoPronounceKey, preferences.autoPronounceCards);
    await prefs.setBool(
      _learningRemindersKey,
      preferences.learningRemindersEnabled,
    );
    await prefs.setBool(
      _pendingTranslationRemindersKey,
      preferences.pendingTranslationRemindersEnabled,
    );
    await prefs.setString(
      BrowserReturnService.browserPreferenceStorageKey,
      preferences.browserPreference.name,
    );
  }
}

final profilePreferencesRepositoryProvider =
    Provider<ProfilePreferencesRepository>((ref) {
      return SharedPreferencesProfilePreferencesRepository();
    });

final profilePreferencesControllerProvider =
    StateNotifierProvider<ProfilePreferencesController, ProfilePreferences>((
      ref,
    ) {
      final repository = ref.watch(profilePreferencesRepositoryProvider);
      final controller = ProfilePreferencesController(repository: repository);
      unawaited(controller.load());
      return controller;
    });

class ProfilePreferencesController extends StateNotifier<ProfilePreferences> {
  ProfilePreferencesController({
    required ProfilePreferencesRepository repository,
  }) : _repository = repository,
       super(const ProfilePreferences());

  final ProfilePreferencesRepository _repository;

  Future<void> load() async {
    try {
      state = await _repository.load();
    } catch (_) {
      state = const ProfilePreferences();
    }
  }

  Future<void> setHapticsEnabled(bool value) {
    return _save(state.copyWith(hapticsEnabled: value));
  }

  Future<void> setSoundEnabled(bool value) {
    return _save(state.copyWith(soundEnabled: value));
  }

  Future<void> setAnimationsEnabled(bool value) {
    return _save(state.copyWith(animationsEnabled: value));
  }

  Future<void> setAutoPronounceCards(bool value) {
    return _save(state.copyWith(autoPronounceCards: value));
  }

  Future<void> setLearningRemindersEnabled(bool value) {
    return _save(state.copyWith(learningRemindersEnabled: value));
  }

  Future<void> setPendingTranslationRemindersEnabled(bool value) {
    return _save(state.copyWith(pendingTranslationRemindersEnabled: value));
  }

  Future<void> setBrowserPreference(BrowserPreference value) {
    return _save(state.copyWith(browserPreference: value));
  }

  Future<void> _save(ProfilePreferences preferences) async {
    state = preferences;
    await _repository.save(preferences);
  }
}
