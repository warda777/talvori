import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  SrsModeController() : super(SrsModeState.initial);

  Timer? _timer;

  // UI ruft nur diese Methoden:

  void tap() {
    if (state.counting) return;
    if (state.mode == SrsSystem.hybrid) {
      // zurück in letzten Nicht-Hybrid
      state = state.copyWith(mode: state.lastNonHybrid);
      HapticFeedback.selectionClick();
    } else {
      toggleTimeAdaptive();
    }
  }

  void toggleTimeAdaptive() {
    if (state.counting) return;
    final next = (state.mode == SrsSystem.time)
        ? SrsSystem.adaptive
        : SrsSystem.time;
    state = state.copyWith(mode: next, lastNonHybrid: next);
    HapticFeedback.selectionClick();
  }

  void longPressStart() {
    if (state.counting || state.mode == SrsSystem.hybrid) return;
    _cancel();
    state = state.copyWith(counting: true, count: 3);
    HapticFeedback.lightImpact();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final c = state.count;
      if (c > 1) {
        state = state.copyWith(count: c - 1);
      } else {
        t.cancel();
        _timer = null;
        _toHybrid();
      }
    });
  }

  void longPressEnd() {
    // Abbruch vor 0
    if (state.counting) _cancel();
  }

  void _toHybrid() {
    state = state.copyWith(
      counting: false,
      count: 0,
      lastNonHybrid: state.mode,
      mode: SrsSystem.hybrid,
    );
    HapticFeedback.mediumImpact();
  }

  void _cancel() {
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(counting: false, count: 0);
  }

  @override
  void dispose() {
    _cancel();
    super.dispose();
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
