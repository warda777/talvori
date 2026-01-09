import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider für persistente Card Glow Einstellungen
final cardGlowSettingsProvider = StateNotifierProvider<CardGlowSettingsNotifier, CardGlowSettings>((ref) {
  return CardGlowSettingsNotifier();
});

class CardGlowSettings {
  final double intensity; // 0.0 - 1.0
  final double pulseSpeed; // 0.0 - 1.0

  const CardGlowSettings({
    this.intensity = 1.0,
    this.pulseSpeed = 1.0,
  });

  CardGlowSettings copyWith({
    double? intensity,
    double? pulseSpeed,
  }) {
    return CardGlowSettings(
      intensity: intensity ?? this.intensity,
      pulseSpeed: pulseSpeed ?? this.pulseSpeed,
    );
  }
}

class CardGlowSettingsNotifier extends StateNotifier<CardGlowSettings> {
  static const String _intensityKey = 'card_glow_intensity';
  static const String _pulseSpeedKey = 'card_glow_pulse_speed';

  CardGlowSettingsNotifier() : super(const CardGlowSettings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final intensity = prefs.getDouble(_intensityKey) ?? 1.0;
      final pulseSpeed = prefs.getDouble(_pulseSpeedKey) ?? 1.0;
      state = CardGlowSettings(
        intensity: intensity,
        pulseSpeed: pulseSpeed,
      );
    } catch (_) {
      // Bei Fehler: Default-Werte verwenden
    }
  }

  Future<void> setIntensity(double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_intensityKey, value);
      state = state.copyWith(intensity: value);
    } catch (_) {
      // Bei Fehler: State trotzdem aktualisieren
      state = state.copyWith(intensity: value);
    }
  }

  Future<void> setPulseSpeed(double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_pulseSpeedKey, value);
      state = state.copyWith(pulseSpeed: value);
    } catch (_) {
      // Bei Fehler: State trotzdem aktualisieren
      state = state.copyWith(pulseSpeed: value);
    }
  }
}

