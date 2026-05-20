import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/tagesimpuls/notifications/tagesimpuls_notification_settings.dart';

void main() {
  group('SharedPreferencesTagesimpulsNotificationSettingsRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('defaults to automatic one daily impulse', () async {
      final repository =
          SharedPreferencesTagesimpulsNotificationSettingsRepository();

      final settings = await repository.loadSettings();

      expect(settings.enabled, isTrue);
      expect(settings.frequencyPerDay, 1);
      expect(settings.preferredWindow, TagesimpulsPreferredWindow.automatic);
    });

    test('persists disabled custom frequency and window', () async {
      final repository =
          SharedPreferencesTagesimpulsNotificationSettingsRepository();

      await repository.saveSettings(
        const TagesimpulsNotificationSettings(
          enabled: false,
          frequencyPerDay: 3,
          preferredWindow: TagesimpulsPreferredWindow.afternoon,
        ),
      );
      final settings = await repository.loadSettings();

      expect(settings.enabled, isFalse);
      expect(settings.frequencyPerDay, 3);
      expect(settings.preferredWindow, TagesimpulsPreferredWindow.afternoon);
    });

    test('persists custom notification time', () async {
      final repository =
          SharedPreferencesTagesimpulsNotificationSettingsRepository();

      await repository.saveSettings(
        const TagesimpulsNotificationSettings(
          preferredWindow: TagesimpulsPreferredWindow.custom,
          customHour: 12,
          customMinute: 7,
        ),
      );
      final settings = await repository.loadSettings();

      expect(settings.preferredWindow, TagesimpulsPreferredWindow.custom);
      expect(settings.customHour, 12);
      expect(settings.customMinute, 7);
    });
  });

  group('TagesimpulsNotificationSettingsController', () {
    test('stores planned times and next planned at in state', () {
      final controller = TagesimpulsNotificationSettingsController(
        repository: _MemorySettingsRepository(),
      );
      final first = DateTime(2026, 5, 20, 12, 30);
      final second = DateTime(2026, 5, 20, 16);

      controller.setPlannedTimes([
        second,
        first,
      ], 'Nächster Impuls: heute um 12:30 Uhr.');

      expect(controller.state.nextPlannedAt, first);
      expect(controller.state.plannedTimes, [first, second]);
      expect(controller.state.plannedCount, 2);
      expect(
        controller.state.displayStatus,
        TagesimpulsNotificationDisplayStatus.active,
      );
    });

    test('needs words clears planned times', () {
      final controller = TagesimpulsNotificationSettingsController(
        repository: _MemorySettingsRepository(),
      );
      controller.setPlannedTimes([
        DateTime(2026, 5, 20, 12, 30),
      ], 'Nächster Impuls: heute um 12:30 Uhr.');

      controller.setNeedsWordsStatus('Füge mindestens 3 Wörter hinzu.');

      expect(controller.state.nextPlannedAt, isNull);
      expect(controller.state.plannedTimes, isEmpty);
      expect(controller.state.plannedCount, 0);
      expect(
        controller.state.displayStatus,
        TagesimpulsNotificationDisplayStatus.needsWords,
      );
    });

    test('prunes expired planned times and keeps next future time', () {
      final controller = TagesimpulsNotificationSettingsController(
        repository: _MemorySettingsRepository(),
      );
      final expired = DateTime(2026, 5, 20, 12);
      final future = DateTime(2026, 5, 20, 16);
      controller.setPlannedTimes([
        expired,
        future,
      ], 'Nächster Impuls: heute um 12:00 Uhr.');

      final changed = controller.pruneExpiredPlannedTimes(
        DateTime(2026, 5, 20, 12, 1),
        (scheduledAt) => 'Nächster Impuls: heute um 16:00 Uhr.',
      );

      expect(changed, isTrue);
      expect(controller.state.nextPlannedAt, future);
      expect(controller.state.plannedTimes, [future]);
      expect(
        controller.state.nextPlannedInfo,
        'Nächster Impuls: heute um 16:00 Uhr.',
      );
    });

    test('clears planned state when every planned time expired', () {
      final controller = TagesimpulsNotificationSettingsController(
        repository: _MemorySettingsRepository(),
      );
      controller.setPlannedTimes([
        DateTime(2026, 5, 20, 12),
      ], 'Nächster Impuls: heute um 12:00 Uhr.');

      final changed = controller.pruneExpiredPlannedTimes(
        DateTime(2026, 5, 20, 12, 1),
        (scheduledAt) => 'Nächster Impuls',
      );

      expect(changed, isTrue);
      expect(controller.state.nextPlannedAt, isNull);
      expect(controller.state.plannedTimes, isEmpty);
      expect(controller.state.nextPlannedInfo, isNull);
    });

    test('set custom time enables custom window and persists time', () async {
      final repository = _MemorySettingsRepository();
      final controller = TagesimpulsNotificationSettingsController(
        repository: repository,
      );

      final settings = await controller.setCustomTime(hour: 12, minute: 7);

      expect(settings.preferredWindow, TagesimpulsPreferredWindow.custom);
      expect(settings.customHour, 12);
      expect(settings.customMinute, 7);
      expect(
        repository.settings.preferredWindow,
        TagesimpulsPreferredWindow.custom,
      );
      expect(repository.settings.customHour, 12);
      expect(repository.settings.customMinute, 7);
    });
  });
}

class _MemorySettingsRepository
    implements TagesimpulsNotificationSettingsRepository {
  TagesimpulsNotificationSettings settings =
      const TagesimpulsNotificationSettings();

  @override
  Future<TagesimpulsNotificationSettings> loadSettings() async => settings;

  @override
  Future<void> saveSettings(TagesimpulsNotificationSettings settings) async {
    this.settings = settings;
  }
}
