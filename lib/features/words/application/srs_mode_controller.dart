import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyLastSrsMode = 'lastSrsMode';
const _keyLastNonHybrid = 'lastNonHybrid';

// Öffentliche API
enum SrsSystem { time, adaptive, hybrid }

class SrsModeState {
  final SrsSystem mode;
  final SrsSystem lastNonHybrid;
  final bool counting;   // läuft der Countdown?
  final int count;       // 3..1 (0 = aus)

  const SrsModeState({
    required this.mode,
    required this.lastNonHybrid,
    required this.counting,
    required this.count,
  });

  SrsModeState copyWith({
    SrsSystem? mode,
    SrsSystem? lastNonHybrid,
    bool? counting,
    int? count,
  }) => SrsModeState(
        mode: mode ?? this.mode,
        lastNonHybrid: lastNonHybrid ?? this.lastNonHybrid,
        counting: counting ?? this.counting,
        count: count ?? this.count,
      );

  static const initial = SrsModeState(
    mode: SrsSystem.time,
    lastNonHybrid: SrsSystem.time,
    counting: false,
    count: 0,
  );
}

class SrsModeController extends StateNotifier<SrsModeState> {
  SrsModeController() : super(SrsModeState.initial) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeStr = prefs.getString(_keyLastSrsMode);
    final lastStr = prefs.getString(_keyLastNonHybrid);
    final mode = _parseMode(modeStr) ?? SrsSystem.time;
    final lastNonHybrid = _parseMode(lastStr) ?? mode;
    state = SrsModeState(
      mode: mode,
      lastNonHybrid: lastNonHybrid,
      counting: false,
      count: 0,
    );
  }

  static SrsSystem? _parseMode(String? s) {
    switch (s) {
      case 'time': return SrsSystem.time;
      case 'adaptive': return SrsSystem.adaptive;
      case 'hybrid': return SrsSystem.hybrid;
      default: return null;
    }
  }

  Future<void> _save(SrsSystem mode, SrsSystem lastNonHybrid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSrsMode, mode.name);
    await prefs.setString(_keyLastNonHybrid, lastNonHybrid.name);
  }

  void _updateState(SrsModeState newState) {
    state = newState;
    _save(newState.mode, newState.lastNonHybrid);
  }

  // UI ruft nur diese Methoden:

  void tap() {
    if (state.mode == SrsSystem.hybrid) {
      // zurück in letzten Nicht-Hybrid
      _updateState(state.copyWith(mode: state.lastNonHybrid));
      HapticFeedback.selectionClick();
    } else {
      toggleTimeAdaptive();
    }
  }

  void toggleTimeAdaptive() {
    final next = (state.mode == SrsSystem.time)
        ? SrsSystem.adaptive
        : SrsSystem.time;
    _updateState(state.copyWith(mode: next, lastNonHybrid: next));
    HapticFeedback.selectionClick();
  }

  /// Long-Press: Direkt in Hybrid wechseln (ohne Countdown).
  void longPress() {
    if (state.mode == SrsSystem.hybrid) return;
    _toHybrid();
  }

  void _toHybrid() {
    _updateState(state.copyWith(
      counting: false,
      count: 0,
      lastNonHybrid: state.mode,
      mode: SrsSystem.hybrid,
    ));
    HapticFeedback.mediumImpact();
  }
}

// Riverpod Provider
final srsModeControllerProvider =
    StateNotifierProvider<SrsModeController, SrsModeState>(
  (ref) => SrsModeController(),
);

// (Optional) abgeleitete Farbe pro Modus
final srsAccentColorProvider = Provider<Color>((ref) {
  switch (ref.watch(srsModeControllerProvider).mode) {
    case SrsSystem.time:    return const Color(0xFF6FD3FF);
    case SrsSystem.adaptive:return const Color(0xFF66FFA8);
    case SrsSystem.hybrid:  return const Color(0xFFE5B966);
  }
});
