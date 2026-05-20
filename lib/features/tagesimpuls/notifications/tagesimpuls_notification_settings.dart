import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum TagesimpulsPreferredWindow {
  automatic,
  morning,
  noon,
  afternoon,
  evening,
  custom,
}

enum TagesimpulsNotificationDisplayStatus {
  active,
  off,
  needsWords,
  permissionDenied,
  error,
}

class TagesimpulsNotificationSettings {
  const TagesimpulsNotificationSettings({
    this.enabled = true,
    this.frequencyPerDay = 1,
    this.preferredWindow = TagesimpulsPreferredWindow.automatic,
    this.customHour = 9,
    this.customMinute = 0,
  });

  final bool enabled;
  final int frequencyPerDay;
  final TagesimpulsPreferredWindow preferredWindow;
  final int customHour;
  final int customMinute;

  TagesimpulsNotificationSettings copyWith({
    bool? enabled,
    int? frequencyPerDay,
    TagesimpulsPreferredWindow? preferredWindow,
    int? customHour,
    int? customMinute,
  }) {
    return TagesimpulsNotificationSettings(
      enabled: enabled ?? this.enabled,
      frequencyPerDay: (frequencyPerDay ?? this.frequencyPerDay).clamp(1, 5),
      preferredWindow: preferredWindow ?? this.preferredWindow,
      customHour: _normalizeHour(customHour ?? this.customHour),
      customMinute: _normalizeMinute(customMinute ?? this.customMinute),
    );
  }

  static int _normalizeHour(int value) {
    if (value < 0) return 0;
    if (value > 23) return 23;
    return value;
  }

  static int _normalizeMinute(int value) {
    if (value < 0) return 0;
    if (value > 59) return 59;
    return value;
  }
}

abstract class TagesimpulsNotificationSettingsRepository {
  Future<TagesimpulsNotificationSettings> loadSettings();

  Future<void> saveSettings(TagesimpulsNotificationSettings settings);
}

class SharedPreferencesTagesimpulsNotificationSettingsRepository
    implements TagesimpulsNotificationSettingsRepository {
  SharedPreferencesTagesimpulsNotificationSettingsRepository({
    this.enabledKey = 'talvori_tagesimpuls_notifications_enabled_v1',
    this.frequencyKey = 'talvori_tagesimpuls_notification_frequency_v1',
    this.windowKey = 'talvori_tagesimpuls_notification_window_v1',
    this.customHourKey = 'talvori_tagesimpuls_notification_custom_hour_v1',
    this.customMinuteKey = 'talvori_tagesimpuls_notification_custom_minute_v1',
  });

  final String enabledKey;
  final String frequencyKey;
  final String windowKey;
  final String customHourKey;
  final String customMinuteKey;

  @override
  Future<TagesimpulsNotificationSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(enabledKey) ?? true;
    final frequency = prefs.getInt(frequencyKey);
    final windowName = prefs.getString(windowKey);
    final customHour = prefs.getInt(customHourKey);
    final customMinute = prefs.getInt(customMinuteKey);
    return TagesimpulsNotificationSettings(
      enabled: enabled,
      frequencyPerDay: _normalizeFrequency(frequency),
      preferredWindow: _parseWindow(windowName),
      customHour: _normalizeHour(customHour),
      customMinute: _normalizeMinute(customMinute),
    );
  }

  @override
  Future<void> saveSettings(TagesimpulsNotificationSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(enabledKey, settings.enabled);
    await prefs.setInt(frequencyKey, settings.frequencyPerDay.clamp(1, 5));
    await prefs.setString(windowKey, settings.preferredWindow.name);
    await prefs.setInt(customHourKey, settings.customHour.clamp(0, 23));
    await prefs.setInt(customMinuteKey, settings.customMinute.clamp(0, 59));
  }

  int _normalizeFrequency(int? value) {
    if (value == null || value < 1 || value > 5) return 1;
    return value;
  }

  TagesimpulsPreferredWindow _parseWindow(String? value) {
    return TagesimpulsPreferredWindow.values.firstWhere(
      (window) => window.name == value,
      orElse: () => TagesimpulsPreferredWindow.automatic,
    );
  }

  int _normalizeHour(int? value) {
    if (value == null || value < 0 || value > 23) return 9;
    return value;
  }

  int _normalizeMinute(int? value) {
    if (value == null || value < 0 || value > 59) return 0;
    return value;
  }
}

class TagesimpulsNotificationSettingsState {
  const TagesimpulsNotificationSettingsState({
    this.settings = const TagesimpulsNotificationSettings(),
    this.isLoading = false,
    this.nextPlannedInfo,
    this.nextPlannedAt,
    this.plannedTimes = const [],
    this.plannedCount = 0,
    this.displayStatus = TagesimpulsNotificationDisplayStatus.active,
  });

  const TagesimpulsNotificationSettingsState.initial()
    : settings = const TagesimpulsNotificationSettings(),
      isLoading = true,
      nextPlannedInfo = null,
      nextPlannedAt = null,
      plannedTimes = const [],
      plannedCount = 0,
      displayStatus = TagesimpulsNotificationDisplayStatus.active;

  final TagesimpulsNotificationSettings settings;
  final bool isLoading;
  final String? nextPlannedInfo;
  final DateTime? nextPlannedAt;
  final List<DateTime> plannedTimes;
  final int plannedCount;
  final TagesimpulsNotificationDisplayStatus displayStatus;

  bool get enabled => settings.enabled;

  int get frequencyPerDay => settings.frequencyPerDay;

  TagesimpulsPreferredWindow get preferredWindow => settings.preferredWindow;

  int get customHour => settings.customHour;

  int get customMinute => settings.customMinute;

  bool get isOff => !settings.enabled;

  TagesimpulsNotificationSettingsState copyWith({
    TagesimpulsNotificationSettings? settings,
    bool? isLoading,
    String? nextPlannedInfo,
    DateTime? nextPlannedAt,
    List<DateTime>? plannedTimes,
    int? plannedCount,
    TagesimpulsNotificationDisplayStatus? displayStatus,
    bool clearNextPlannedInfo = false,
    bool clearPlannedTimes = false,
  }) {
    return TagesimpulsNotificationSettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      nextPlannedInfo: clearNextPlannedInfo
          ? null
          : nextPlannedInfo ?? this.nextPlannedInfo,
      nextPlannedAt: clearPlannedTimes
          ? null
          : nextPlannedAt ?? this.nextPlannedAt,
      plannedTimes: clearPlannedTimes
          ? const []
          : plannedTimes ?? this.plannedTimes,
      plannedCount: clearPlannedTimes ? 0 : plannedCount ?? this.plannedCount,
      displayStatus: displayStatus ?? this.displayStatus,
    );
  }
}

class TagesimpulsNotificationSettingsController
    extends StateNotifier<TagesimpulsNotificationSettingsState> {
  TagesimpulsNotificationSettingsController({
    required TagesimpulsNotificationSettingsRepository repository,
  }) : _repository = repository,
       super(const TagesimpulsNotificationSettingsState.initial());

  final TagesimpulsNotificationSettingsRepository _repository;

  Future<void> load() async {
    final settings = await _repository.loadSettings();
    state = state.copyWith(settings: settings, isLoading: false);
  }

  Future<TagesimpulsNotificationSettings> setEnabled(bool enabled) async {
    final settings = state.settings.copyWith(enabled: enabled);
    await _save(
      settings,
      clearNextPlannedInfo: !enabled,
      clearPlannedTimes: !enabled,
      displayStatus: enabled
          ? TagesimpulsNotificationDisplayStatus.active
          : TagesimpulsNotificationDisplayStatus.off,
    );
    return settings;
  }

  Future<TagesimpulsNotificationSettings> setFrequencyPerDay(int count) async {
    if (count < 1 || count > 5) return state.settings;
    final settings = state.settings.copyWith(
      enabled: true,
      frequencyPerDay: count,
    );
    await _save(settings);
    return settings;
  }

  Future<TagesimpulsNotificationSettings> setPreferredWindow(
    TagesimpulsPreferredWindow window,
  ) async {
    final settings = state.settings.copyWith(
      enabled: true,
      preferredWindow: window,
    );
    await _save(settings);
    return settings;
  }

  Future<TagesimpulsNotificationSettings> setCustomTime({
    required int hour,
    required int minute,
  }) async {
    final settings = state.settings.copyWith(
      enabled: true,
      preferredWindow: TagesimpulsPreferredWindow.custom,
      customHour: hour,
      customMinute: minute,
    );
    await _save(settings);
    return settings;
  }

  void setNextPlannedInfo(String? info) {
    state = state.copyWith(
      nextPlannedInfo: info,
      clearNextPlannedInfo: info == null,
    );
  }

  void setNeedsWordsStatus(String info) {
    state = state.copyWith(
      nextPlannedInfo: info,
      displayStatus: TagesimpulsNotificationDisplayStatus.needsWords,
      clearPlannedTimes: true,
    );
  }

  void clearNeedsWordsStatus() {
    if (state.displayStatus !=
        TagesimpulsNotificationDisplayStatus.needsWords) {
      return;
    }
    state = state.copyWith(
      displayStatus: TagesimpulsNotificationDisplayStatus.active,
      clearNextPlannedInfo: true,
      clearPlannedTimes: true,
    );
  }

  void setPermissionDeniedStatus(String info) {
    state = state.copyWith(
      nextPlannedInfo: info,
      displayStatus: TagesimpulsNotificationDisplayStatus.permissionDenied,
      clearPlannedTimes: true,
    );
  }

  void setErrorStatus(String info) {
    state = state.copyWith(
      nextPlannedInfo: info,
      displayStatus: TagesimpulsNotificationDisplayStatus.error,
      clearPlannedTimes: true,
    );
  }

  void setPlannedTimes(List<DateTime> plannedTimes, String info) {
    final sorted = [...plannedTimes]..sort();
    state = state.copyWith(
      nextPlannedInfo: info,
      nextPlannedAt: sorted.isEmpty ? null : sorted.first,
      plannedTimes: sorted,
      plannedCount: sorted.length,
      displayStatus: TagesimpulsNotificationDisplayStatus.active,
      clearPlannedTimes: sorted.isEmpty,
    );
  }

  bool pruneExpiredPlannedTimes(
    DateTime now,
    String Function(DateTime scheduledAt) infoBuilder,
  ) {
    final remaining =
        state.plannedTimes
            .where((time) => time.isAfter(now))
            .toList(growable: false)
          ..sort();
    if (remaining.length == state.plannedTimes.length &&
        (state.nextPlannedAt == null || state.nextPlannedAt!.isAfter(now))) {
      return false;
    }

    if (remaining.isEmpty) {
      state = state.copyWith(
        clearNextPlannedInfo: true,
        clearPlannedTimes: true,
        displayStatus: state.enabled
            ? TagesimpulsNotificationDisplayStatus.active
            : TagesimpulsNotificationDisplayStatus.off,
      );
      return true;
    }

    state = state.copyWith(
      nextPlannedInfo: infoBuilder(remaining.first),
      nextPlannedAt: remaining.first,
      plannedTimes: remaining,
      plannedCount: remaining.length,
      displayStatus: TagesimpulsNotificationDisplayStatus.active,
    );
    return true;
  }

  Future<void> _save(
    TagesimpulsNotificationSettings settings, {
    bool clearNextPlannedInfo = false,
    bool clearPlannedTimes = false,
    TagesimpulsNotificationDisplayStatus? displayStatus,
  }) async {
    state = state.copyWith(
      settings: settings,
      isLoading: false,
      clearNextPlannedInfo: clearNextPlannedInfo,
      clearPlannedTimes: clearPlannedTimes,
      displayStatus: displayStatus,
    );
    await _repository.saveSettings(settings);
  }
}

final tagesimpulsNotificationSettingsRepositoryProvider =
    Provider<TagesimpulsNotificationSettingsRepository>((ref) {
      return SharedPreferencesTagesimpulsNotificationSettingsRepository();
    });

final tagesimpulsNotificationSettingsControllerProvider =
    StateNotifierProvider<
      TagesimpulsNotificationSettingsController,
      TagesimpulsNotificationSettingsState
    >((ref) {
      final repository = ref.watch(
        tagesimpulsNotificationSettingsRepositoryProvider,
      );
      final controller = TagesimpulsNotificationSettingsController(
        repository: repository,
      );
      unawaited(controller.load());
      return controller;
    });
