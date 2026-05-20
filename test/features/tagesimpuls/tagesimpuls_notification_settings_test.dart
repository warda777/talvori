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
