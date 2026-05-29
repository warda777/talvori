import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/assets/talvori_mascot_assets.dart';

class ProfilePreferences {
  const ProfilePreferences({
    this.displayName = '',
    this.genderIdentity = '',
    this.ageRange = '',
    this.level = '',
    this.hapticsEnabled = true,
    this.soundEnabled = true,
    this.gameSoundsEnabled = true,
    this.ttsEnabled = true,
    this.animationsEnabled = true,
    this.autoPronounceCards = false,
    this.appLanguage = 'Deutsch',
    this.nativeLanguage = 'Deutsch',
    this.learningLanguage = 'Englisch',
    this.dailyReminderEnabled = false,
    this.learningRemindersEnabled = false,
    this.pendingTranslationRemindersEnabled = false,
    this.marketingAnalyticsEnabled = false,
    this.mascotStyle = TalvoriMascotStyle.female,
  });

  final String displayName;
  final String genderIdentity;
  final String ageRange;
  final String level;
  final bool hapticsEnabled;
  final bool soundEnabled;
  final bool gameSoundsEnabled;
  final bool ttsEnabled;
  final bool animationsEnabled;
  final bool autoPronounceCards;
  final String appLanguage;
  final String nativeLanguage;
  final String learningLanguage;
  final bool dailyReminderEnabled;
  final bool learningRemindersEnabled;
  final bool pendingTranslationRemindersEnabled;
  final bool marketingAnalyticsEnabled;
  final TalvoriMascotStyle mascotStyle;

  ProfilePreferences copyWith({
    String? displayName,
    String? genderIdentity,
    String? ageRange,
    String? level,
    bool? hapticsEnabled,
    bool? soundEnabled,
    bool? gameSoundsEnabled,
    bool? ttsEnabled,
    bool? animationsEnabled,
    bool? autoPronounceCards,
    String? appLanguage,
    String? nativeLanguage,
    String? learningLanguage,
    bool? dailyReminderEnabled,
    bool? learningRemindersEnabled,
    bool? pendingTranslationRemindersEnabled,
    bool? marketingAnalyticsEnabled,
    TalvoriMascotStyle? mascotStyle,
  }) {
    return ProfilePreferences(
      displayName: displayName ?? this.displayName,
      genderIdentity: genderIdentity ?? this.genderIdentity,
      ageRange: ageRange ?? this.ageRange,
      level: level ?? this.level,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      gameSoundsEnabled: gameSoundsEnabled ?? this.gameSoundsEnabled,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      autoPronounceCards: autoPronounceCards ?? this.autoPronounceCards,
      appLanguage: appLanguage ?? this.appLanguage,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      learningLanguage: learningLanguage ?? this.learningLanguage,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      learningRemindersEnabled:
          learningRemindersEnabled ?? this.learningRemindersEnabled,
      pendingTranslationRemindersEnabled:
          pendingTranslationRemindersEnabled ??
          this.pendingTranslationRemindersEnabled,
      marketingAnalyticsEnabled:
          marketingAnalyticsEnabled ?? this.marketingAnalyticsEnabled,
      mascotStyle: mascotStyle ?? this.mascotStyle,
    );
  }
}

abstract class ProfilePreferencesRepository {
  Future<ProfilePreferences> load();

  Future<void> save(ProfilePreferences preferences);
}

class SharedPreferencesProfilePreferencesRepository
    implements ProfilePreferencesRepository {
  static const _displayNameKey = 'talvori_profile_display_name_v1';
  static const _genderIdentityKey = 'talvori_profile_gender_identity_v1';
  static const _ageRangeKey = 'talvori_profile_age_range_v1';
  static const _levelKey = 'talvori_profile_level_v1';
  static const _hapticsKey = 'talvori_profile_haptics_enabled_v1';
  static const _soundKey = 'talvori_profile_sound_enabled_v1';
  static const _gameSoundsKey = 'talvori_profile_game_sounds_enabled_v1';
  static const _ttsKey = 'talvori_profile_tts_enabled_v1';
  static const _animationsKey = 'talvori_profile_animations_enabled_v1';
  static const _autoPronounceKey = 'talvori_profile_auto_pronounce_cards_v1';
  static const _appLanguageKey = 'talvori_profile_app_language_v1';
  static const _nativeLanguageKey = 'talvori_profile_native_language_v1';
  static const _learningLanguageKey = 'talvori_profile_learning_language_v1';
  static const _dailyReminderKey = 'talvori_profile_daily_reminder_enabled_v1';
  static const _learningRemindersKey =
      'talvori_profile_learning_reminders_enabled_v1';
  static const _pendingTranslationRemindersKey =
      'talvori_profile_pending_translation_reminders_enabled_v1';
  static const _marketingAnalyticsKey =
      'talvori_profile_marketing_analytics_enabled_v1';
  static const _mascotStyleKey = 'talvori_profile_mascot_style_v1';

  @override
  Future<ProfilePreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ProfilePreferences(
      displayName: prefs.getString(_displayNameKey) ?? '',
      genderIdentity: prefs.getString(_genderIdentityKey) ?? '',
      ageRange: prefs.getString(_ageRangeKey) ?? '',
      level: prefs.getString(_levelKey) ?? '',
      hapticsEnabled: prefs.getBool(_hapticsKey) ?? true,
      soundEnabled: prefs.getBool(_soundKey) ?? true,
      gameSoundsEnabled: prefs.getBool(_gameSoundsKey) ?? true,
      ttsEnabled: prefs.getBool(_ttsKey) ?? true,
      animationsEnabled: prefs.getBool(_animationsKey) ?? true,
      autoPronounceCards: prefs.getBool(_autoPronounceKey) ?? false,
      appLanguage: prefs.getString(_appLanguageKey) ?? 'Deutsch',
      nativeLanguage: prefs.getString(_nativeLanguageKey) ?? 'Deutsch',
      learningLanguage: prefs.getString(_learningLanguageKey) ?? 'Englisch',
      dailyReminderEnabled: prefs.getBool(_dailyReminderKey) ?? false,
      learningRemindersEnabled: prefs.getBool(_learningRemindersKey) ?? false,
      pendingTranslationRemindersEnabled:
          prefs.getBool(_pendingTranslationRemindersKey) ?? false,
      marketingAnalyticsEnabled: prefs.getBool(_marketingAnalyticsKey) ?? false,
      mascotStyle: _parseMascotStyle(prefs.getString(_mascotStyleKey)),
    );
  }

  @override
  Future<void> save(ProfilePreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_displayNameKey, preferences.displayName);
    await prefs.setString(_genderIdentityKey, preferences.genderIdentity);
    await prefs.setString(_ageRangeKey, preferences.ageRange);
    await prefs.setString(_levelKey, preferences.level);
    await prefs.setBool(_hapticsKey, preferences.hapticsEnabled);
    await prefs.setBool(_soundKey, preferences.soundEnabled);
    await prefs.setBool(_gameSoundsKey, preferences.gameSoundsEnabled);
    await prefs.setBool(_ttsKey, preferences.ttsEnabled);
    await prefs.setBool(_animationsKey, preferences.animationsEnabled);
    await prefs.setBool(_autoPronounceKey, preferences.autoPronounceCards);
    await prefs.setString(_appLanguageKey, preferences.appLanguage);
    await prefs.setString(_nativeLanguageKey, preferences.nativeLanguage);
    await prefs.setString(_learningLanguageKey, preferences.learningLanguage);
    await prefs.setBool(_dailyReminderKey, preferences.dailyReminderEnabled);
    await prefs.setBool(
      _learningRemindersKey,
      preferences.learningRemindersEnabled,
    );
    await prefs.setBool(
      _pendingTranslationRemindersKey,
      preferences.pendingTranslationRemindersEnabled,
    );
    await prefs.setBool(
      _marketingAnalyticsKey,
      preferences.marketingAnalyticsEnabled,
    );
    await prefs.setString(_mascotStyleKey, preferences.mascotStyle.name);
  }

  static TalvoriMascotStyle _parseMascotStyle(String? value) {
    return TalvoriMascotStyle.values.firstWhere(
      (style) => style.name == value,
      orElse: () => TalvoriMascotStyle.female,
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
      final preferences = await _repository.load();
      if (!mounted) return;
      state = preferences;
    } catch (_) {
      if (!mounted) return;
      state = const ProfilePreferences();
    }
  }

  Future<void> setHapticsEnabled(bool value) {
    return _save(state.copyWith(hapticsEnabled: value));
  }

  Future<void> setDisplayName(String value) {
    return _save(state.copyWith(displayName: value.trim()));
  }

  Future<void> setGenderIdentity(String value) {
    return _save(state.copyWith(genderIdentity: value));
  }

  Future<void> setAgeRange(String value) {
    return _save(state.copyWith(ageRange: value));
  }

  Future<void> setLevel(String value) {
    return _save(state.copyWith(level: value));
  }

  Future<void> setSoundEnabled(bool value) {
    return _save(state.copyWith(soundEnabled: value));
  }

  Future<void> setGameSoundsEnabled(bool value) {
    return _save(state.copyWith(gameSoundsEnabled: value));
  }

  Future<void> setTtsEnabled(bool value) {
    return _save(state.copyWith(ttsEnabled: value));
  }

  Future<void> setAnimationsEnabled(bool value) {
    return _save(state.copyWith(animationsEnabled: value));
  }

  Future<void> setAutoPronounceCards(bool value) {
    return _save(state.copyWith(autoPronounceCards: value));
  }

  Future<void> setAppLanguage(String value) {
    return _save(state.copyWith(appLanguage: value));
  }

  Future<void> setNativeLanguage(String value) {
    return _save(state.copyWith(nativeLanguage: value));
  }

  Future<void> setLearningLanguage(String value) {
    return _save(state.copyWith(learningLanguage: value));
  }

  Future<void> setDailyReminderEnabled(bool value) {
    return _save(state.copyWith(dailyReminderEnabled: value));
  }

  Future<void> setLearningRemindersEnabled(bool value) {
    return _save(state.copyWith(learningRemindersEnabled: value));
  }

  Future<void> setPendingTranslationRemindersEnabled(bool value) {
    return _save(state.copyWith(pendingTranslationRemindersEnabled: value));
  }

  Future<void> setMarketingAnalyticsEnabled(bool value) {
    return _save(state.copyWith(marketingAnalyticsEnabled: value));
  }

  Future<void> setMascotStyle(TalvoriMascotStyle value) {
    return _save(state.copyWith(mascotStyle: value));
  }

  Future<void> _save(ProfilePreferences preferences) async {
    if (!mounted) return;
    state = preferences;
    try {
      await _repository.save(preferences);
    } catch (_) {
      // Settings are convenience preferences. A storage failure must not bring
      // down startup or navigation.
    }
  }
}
