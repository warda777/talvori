import 'dart:math' as math;
import 'package:flutter/scheduler.dart';

/// Steuert kurzfristige "Spin-Bursts" (schnelle Zusatzrotation) + liefert
/// einen Ticker für partikelbasierte Effekte.
class ChromeSpinController {
  // Aktuelle Zusatzwinkelgeschwindigkeit [Umdrehungen/Sekunde]
  double _angularVelocity = 0.0;
  // Exponentielles Abklingen (Dämpfung) pro Sekunde
  final double damping;
  // Maximal erlaubte Zusatzgeschwindigkeit
  final double maxVel;

  Ticker? _ticker;
  void Function(double dtSeconds)? onTick;
  double? _lastFrameTime; // Sekundenmarke des letzten Frames (als Instanz-Variable)

  ChromeSpinController({this.damping = 2.8, this.maxVel = 8.0});

  void attachTicker(TickerProvider vsync, void Function(double dt) onTick) {
    this.onTick = onTick;
    _ticker?.dispose();
    _lastFrameTime = null; // Reset beim Neustart

    _ticker = vsync.createTicker((elapsed) {
      final t = elapsed.inMicroseconds / 1e6;      // Gesamtzeit in s
      final dt = (_lastFrameTime == null) ? 0.0 : (t - _lastFrameTime!);
      _lastFrameTime = t;

      if (dt > 0 && dt < 0.1) { // Guard: dt sollte sinnvoll sein (< 100ms)
        onTick(dt);                      // <-- jetzt echtes Delta
      }
    });

    _ticker!.start();
  }

  void dispose() {
    _ticker?.dispose();
  }

  /// Füge einen Impuls hinzu (z.B. aus Swipe-Down). Positive Werte = schneller drehen.
  void addImpulse(double velocity) {
    _angularVelocity = (_angularVelocity + velocity).clamp(0.0, maxVel);
  }

  /// Liefert die Rotations-Zusatzzunahme in Umdrehungen für Delta-Zeit dt.
  /// Reduziert sich durch Dämpfung von selbst (e^(-damping * dt)).
  double step(double dt) {
    if (_angularVelocity <= 0.0001) {
      _angularVelocity = 0.0;
      return 0.0;
    }
    final rot = _angularVelocity * dt;           // Umdrehungen in dt
    _angularVelocity *= math.exp(-damping * dt); // dämpfen
    return rot;
  }

  bool get isActive => _angularVelocity > 0.0;
}
