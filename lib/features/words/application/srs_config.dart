// lib/features/words/application/srs_config.dart
class SrsStats {
  final double rollingAccuracy; // 0..1
  final double avgSwipeMs;      // Durchschnittliche Antwortzeit in ms (letzte N)
  final int recentTimeouts;     // letzte N
  const SrsStats({
    required this.rollingAccuracy,
    required this.avgSwipeMs,
    required this.recentTimeouts,
  });
}

class SrsPhase {
  final int length;        // wie viele Karten für diese Phase "steuern"
  final double reviewRatio; // 0..1
  const SrsPhase({required this.length, required this.reviewRatio});
}

class SrsConfig {
  final int initialNewBurst;
  final int headSize;
  final List<int> stageWeights;   // S0..S5
  final List<SrsPhase> phases;    // Ratio-Phasen nach dem Burst
  final int activePoolCap;        // wie viele Karten maximal gleichzeitig im Umlauf

  const SrsConfig({
    required this.initialNewBurst,
    required this.headSize,
    required this.stageWeights,
    required this.phases,
    required this.activePoolCap,
  });
}

/// Rechnet eine sinnvolle Konfiguration aus:
/// - totalWordsInCategory: 159..1379 etc.
/// - dueCount: aktuell fällige Anzahl
/// - stats: Leistung + Tempo
SrsConfig computeSrsConfig({
  required int totalWordsInCategory,
  required int dueCount,
  required SrsStats stats,
}) {
  // 1) Initialer Burst – keine Obergrenze (Sperre entfernt)
  final burst = _clampInt(
    (0.08 * totalWordsInCategory).round(),
    20, 9999,
  ); // ~8% der Kategorie, min 20, max praktisch unbegrenzt

  // 2) Kopfgröße (wie viele wir "steuern")
  final head = _clampInt(
    (totalWordsInCategory < 400) ? 120 : 180,
    90, 220,
  );

  // 3) Grund-Ratios
  double r1 = 0.70, r2 = 0.80, r3 = 0.90;

  // 4) Adaptieren anhand Accuracy
  if (stats.rollingAccuracy < 0.75) { r1 += 0.10; r2 += 0.05; r3 += 0.00; }
  if (stats.rollingAccuracy > 0.90) { r1 -= 0.05; r2 -= 0.05; r3 -= 0.05; }

  // 5) Adaptieren anhand Tempo / Timeouts
  if (stats.avgSwipeMs > 5000 || stats.recentTimeouts > 2) {
    r1 = (r1 + 0.10).clamp(0.6, 0.95);
    r2 = (r2 + 0.05).clamp(0.6, 0.95);
    // r3 belassen – Endphase bleibt review-lastig
  } else if (stats.avgSwipeMs < 2000) {
    r1 = (r1 - 0.05).clamp(0.6, 0.95);
  }

  // 6) Phasenlängen abhängig von vorhandenen "due"s (wenn viele fällig → schneller in hohe Review-Ratio)
  final p1Len = (dueCount > 50) ? 30 : 40;
  final p2Len = (dueCount > 100) ? 70 : 60;

  // 7) Stage-Gewichte (S0..S5) – S2/S3 leicht priorisieren
  final weights = <int>[1, 3, 4, 4, 2, 1];

  // 8) Active-Pool-Cap – wie viele Karten gleichzeitig im Umlauf:
  final cap = (totalWordsInCategory < 400) ? 80 : 120;

  return SrsConfig(
    initialNewBurst: burst,
    headSize: head,
    stageWeights: weights,
    phases: [
      SrsPhase(length: p1Len, reviewRatio: r1),
      SrsPhase(length: p2Len, reviewRatio: r2),
      const SrsPhase(length: 99999, reviewRatio: 0.90), // Rest der Session
    ],
    activePoolCap: cap,
  );
}

int _clampInt(int v, int min, int max) => v < min ? min : (v > max ? max : v);

/// Default-Config für transparente Popups + Startwerte.
/// Diese Werte sind bewusst konservativ und später feinjustierbar.
class SrsUiConfig {
  /// Maximale neue Wörter pro Tag (S0) im Traditional-Modus.
  static const int tSrsDailyNewLimit = 10;

  /// Wie viele erfolgreiche Wiederholungen in T-SRS nötig sind, um in die nächste Stage zu wechseln.
  /// Hinweis: S0->S1 ist "erste erfolgreiche Bearbeitung" (0 = sofortiger Einstieg).
  static const Map<int, int> tRepeatsToAdvance = {
    0: 0,
    1: 2, // S1 -> S2: 2 Erfolge
    2: 1, // S2 -> S3: 1 Erfolg
    3: 1, // S3 -> S4: 1 Erfolg
    4: 1, // S4 -> S5: 1 Erfolg
    5: 0, // S5 ist Zielstufe
  };

  /// Basis-Intervalle (T-SRS) in Tagen für die nächste Fälligkeit nach einem erfolgreichen Review.
  /// Wichtig: 2-6-19 ist hier als Kern sichtbar.
  static const Map<int, String> tNextIntervalLabel = {
    0: "heute",        // S0: direkt / heute
    1: "heute (kurz)", // S1: später am Tag / kurz
    2: "2 Tage",       // S2: 2
    3: "6 Tage",       // S3: 6
    4: "19 Tage",      // S4: 19
    5: "45–90 Tage",   // S5: Langzeitpflege
  };

  /// Stufen-Namen (UI) – kurz, merkbar.
  static const Map<int, String> stageTitle = {
    0: "Neu",
    1: "Einstieg",
    2: "Stabilisieren",
    3: "Festigen",
    4: "Sicher",
    5: "Langzeit",
  };
}
