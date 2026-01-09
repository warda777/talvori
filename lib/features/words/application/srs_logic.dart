// lib/features/words/application/srs_logic.dart
import 'dart:math';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/srs_config.dart';

List<int> buildSmartCardOrder(
  List<WordUserView> queue, {
  SrsConfig? config,
  int allowedMaxStage = 1, // default = nur S0/S1
}) {
  final now = DateTime.now();
  if (queue.isEmpty) return const [];

  // Fallback-Config
  final cfg = config ??
      const SrsConfig(
        initialNewBurst: 10,
        headSize: 150,
        stageWeights: [1, 3, 4, 4, 2, 1],
        phases: [
          SrsPhase(length: 40, reviewRatio: 0.70),
          SrsPhase(length: 60, reviewRatio: 0.80),
          SrsPhase(length: 99999, reviewRatio: 0.90),
        ],
        activePoolCap: 120,
      );

  // --- (optional) aktiven Pool begrenzen -----------------------------
  final pool = _capActivePool(queue, cfg.activePoolCap, now);

  // --- Buckets -------------------------------------------------------
  final dueByStage  = List.generate(6, (_) => <int>[]);
  final waitByStage = List.generate(6, (_) => <int>[]);
  final rest        = <int>[];
  final forbidden   = <int>[]; // Karten mit st > allowedMaxStage

  bool isDue(WordUserView w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now);

  for (var i = 0; i < pool.length; i++) {
    final w  = pool[i];
    final st = w.srsStage.clamp(0, 5);
    final due = isDue(w);

    if (st > allowedMaxStage) {
      forbidden.add(i);
      continue;
    }
    (due ? dueByStage[st] : waitByStage[st]).add(i);
  }

  void shuffleAll() {
    for (var s = 0; s < 6; s++) {
      dueByStage[s].shuffle();
      waitByStage[s].shuffle();
    }
    rest.shuffle();
  }
  shuffleAll();

  int? pullAnyDue() {
    for (var s = allowedMaxStage; s >= 0; s--) {
      if (dueByStage[s].isNotEmpty) return dueByStage[s].removeLast();
    }
    return null;
  }

  int? pullReview() {
    for (var s = allowedMaxStage; s >= 1; s--) {
      if (dueByStage[s].isNotEmpty) return dueByStage[s].removeLast();
    }
    if (dueByStage[0].isNotEmpty) return dueByStage[0].removeLast();
    // gewichtete wait-Reviews (nur bis allowedMaxStage)
    final weighted = <int>[];
    for (var s = 1; s <= allowedMaxStage; s++) {
      if (waitByStage[s].isEmpty) continue;
      for (var k = 0; k < cfg.stageWeights[s]; k++) {
        weighted.add(s);
      }
    }
    if (weighted.isEmpty) return null;
    final s = weighted[Random().nextInt(weighted.length)];
    return waitByStage[s].removeLast();
  }

  int? pullNew() => waitByStage[0].isNotEmpty ? waitByStage[0].removeLast() : null;

  // --- Head ----------------------------------------------------------
  final head = <int>[];

  // Debug-Log für Gate-Logik
  print('🚪 SRS Logic: allowedMaxStage=$allowedMaxStage, forbidden=${forbidden.length}');

  // kleine due-Vorstreuung
  while (head.length < min(12, cfg.headSize)) {
    final d = pullAnyDue();
    if (d == null) break;
    head.add(d);
  }

  // initialer Burst (Neue)
  while (head.length < cfg.headSize &&
      head.where((i) => pool[i].srsStage == 0 && !isDue(pool[i])).length < cfg.initialNewBurst) {
    final d = pullAnyDue();
    if (d != null) { head.add(d); continue; }
    final n = pullNew();
    if (n == null) break;
    head.add(n);
  }

  // Phasen (Ratios)
  int produced = 0;
  for (final p in cfg.phases) {
    final target = min(cfg.headSize, head.length + p.length);
    while (head.length < target) {
      final d = pullAnyDue();
      if (d != null) { head.add(d); continue; }

      // Verhältnis prüfen
      final revCount = head.where((ix) {
        final w = pool[ix];
        final isNewWait = (w.srsStage == 0) && !isDue(w);
        return !isNewWait;
      }).length;
      final newCount = head.length - revCount;
      final currentRatio = revCount / max(1, revCount + newCount);

      int? pick;
      if (currentRatio < p.reviewRatio) {
        pick = pullReview() ?? pullNew();
      } else {
        pick = pullNew() ?? pullReview();
      }
      if (pick == null) break;
      head.add(pick);
      produced++;
      if (head.length >= cfg.headSize) break;
    }
    if (head.length >= cfg.headSize) break;
  }

  // Tail NUR aus erlaubten Buckets, dann erst Verbotene anhängen:
  final tail = <int>[];
  for (var s = allowedMaxStage; s >= 0; s--) {
    tail.addAll(dueByStage[s]);
  }
  for (var s = allowedMaxStage; s >= 0; s--) {
    tail.addAll(waitByStage[s]);
  }
  tail.addAll(rest);
  tail.addAll(forbidden); // ganz hinten
  tail.shuffle();

  // Indizes wieder auf Original-queue beziehen:
  // `pool` ist ggf. beschnitten – wir müssen auf die Original-Indizes abbilden.
  final poolToOriginal = <int, int>{};
  for (var i = 0; i < pool.length; i++) {
    poolToOriginal[i] = queue.indexWhere((w) => w.id == pool[i].id);
  }

  List<int> mapBack(List<int> arr) => [
        for (final i in arr)
          poolToOriginal[i] ?? i // fallback (sollte nicht passieren)
      ];

  return <int>[...mapBack(head), ...mapBack(tail)];
}

// Beschneidet die aktive Menge auf `cap` Karten: due zuerst, dann restl. Mischung
List<WordUserView> _capActivePool(List<WordUserView> queue, int cap, DateTime now) {
  if (queue.length <= cap) return queue;

  final due = <WordUserView>[];
  final wait = <WordUserView>[];

  bool isDue(WordUserView w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now);
  for (final w in queue) {
    (isDue(w) ? due : wait).add(w);
  }
  due.shuffle();
  wait.shuffle();

  final take = <WordUserView>[];
  take.addAll(due.take(cap));
  if (take.length < cap) {
    take.addAll(wait.take(cap - take.length));
  }
  return take;
}

enum SrsPopupMode { tSrs, aSrs, hybrid }
enum SrsPopupRange { s0toS5, s1toS5, single }

class SrsPopupText {
  static String stageHeader(int stage, SrsPopupMode mode) {
    final title = SrsUiConfig.stageTitle[stage] ?? "Stufe $stage";
    final modeLabel = switch (mode) {
      SrsPopupMode.tSrs => "T-SRS",
      SrsPopupMode.aSrs => "A-SRS",
      SrsPopupMode.hybrid => "Hybrid",
    };
    return "S$stage – $title • $modeLabel";
  }

  static String rangeLabel(SrsPopupRange range) {
    return switch (range) {
      SrsPopupRange.s0toS5 => "Bereich: S0–S5 (Neu + Wiederholen)",
      SrsPopupRange.s1toS5 => "Bereich: S1–S5 (nur Wiederholen)",
      SrsPopupRange.single => "Bereich: Single (gezieltes Training ohne Stage-Wechsel)",
    };
  }

  static String whatIs(int stage) {
    return switch (stage) {
      0 => "S0 enthält neue Wörter, die noch nicht in den Wiederholungs-Kreislauf eingestuft sind.",
      1 => "S1 ist die Einstiegsstufe: Wörter sind begonnen, aber noch unsicher.",
      2 => "S2 bedeutet: erste Stabilität, aber noch nicht zuverlässig abrufbar.",
      3 => "S3 festigt den Abruf über größere Abstände.",
      4 => "S4 steht für hohe Sicherheit; Wiederholungen prüfen die Langzeit-Stabilität.",
      5 => "S5 ist die Langzeitstufe: seltene Wiederholungen zur Auffrischung.",
      _ => "Stufe $stage beschreibt den aktuellen Lern- und Stabilitätsgrad.",
    };
  }

  static String tSrsLogicForStage(int stage, {required bool s0Locked}) {
    if (stage == 0) {
      if (s0Locked) {
        return "S0 ist aktuell gesperrt. Dadurch werden keine neuen Wörter eingeführt. "
            "Nutze S1–S5, um vorhandene Wörter zu festigen.";
      }
      return "T-SRS arbeitet mit festen Stufen und klaren Regeln. "
          "Neue Wörter werden bewusst begrenzt, damit Wiederholungen nicht verdrängt werden.";
    }

    final need = SrsUiConfig.tRepeatsToAdvance[stage] ?? 1;
    final nextLabel = SrsUiConfig.tNextIntervalLabel[stage + 1] ?? "später";

    if (stage >= 1 && stage <= 4) {
      return "In T-SRS steigt ein Wort nach klaren Kriterien auf. "
          "Nach $need erfolgreichen Wiederholungen wechselt es in S${stage + 1}. "
          "Dort liegt der nächste typische Abstand bei: $nextLabel.";
    }

    return "S5 ist die Zielstufe im T-SRS. Wörter bleiben hier langfristig und werden nur selten geprüft.";
  }

  static String aSrsLogicForStage(int stage) {
    return "A-SRS passt Wiederholungen dynamisch an dein Lernverhalten an. "
        "Wörter steigen auf, wenn sie stabil abrufbar sind, "
        "und bleiben länger (oder kommen früher wieder), wenn Unsicherheit oder Fehler auftreten. "
        "Die App versucht, dich möglichst nah am optimalen Zeitpunkt vor dem Vergessen zu trainieren.";
  }

  static String hybridLogicForStage(int stage) {
    return "Hybrid kombiniert beides: "
        "Die Stufenlogik bleibt klar wie im T-SRS (du weißt, warum ein Wort in S$stage ist), "
        "aber Timing und Wiederholungsabstände werden wie im A-SRS feinjustiert (früher/später je nach Stabilität).";
  }

  static String progressionBlock({
    required int stage,
    required SrsPopupMode mode,
    required bool s0Locked,
    required SrsPopupRange range,
  }) {
    // Single: explizit keine Stage-Änderung – laut Architektur.
    if (range == SrsPopupRange.single) {
      return "Single-Modus: Dieses Training verändert keine SRS-Stufe. "
          "Es dient dem gezielten Üben innerhalb einer Stufe, ohne Auf-/Abstieg.";
    }

    if (mode == SrsPopupMode.tSrs) {
      if (stage == 0) {
        return s0Locked
            ? "S0 ist gesperrt. Keine neuen Wörter werden eingeführt."
            : "S0 → S1: Ein Wort wird eingestuft, sobald es erstmals erfolgreich bearbeitet wurde.";
      }
      if (stage >= 1 && stage <= 4) {
        final need = SrsUiConfig.tRepeatsToAdvance[stage] ?? 1;
        return "Aufstieg: Nach $need erfolgreichen Wiederholungen → S${stage + 1}. "
            "Fehler führen typischerweise zu mehr Wiederholung (und ggf. Rückstufung, je nach Engine-Regel).";
      }
      return "S5: Langzeitpflege – seltene Wiederholungen zur Stabilisierung.";
    }

    if (mode == SrsPopupMode.aSrs) {
      return "Aufstieg: wenn ein Wort über mehrere Wiederholungen stabil sitzt. "
          "Bleiben/Zurück: wenn Fehler oder Unsicherheit auftreten. "
          "Timing wird dynamisch angepasst (früher/später).";
    }

    // Hybrid
    return "Aufstieg (klar wie T-SRS): abhängig von stabiler Leistung und Stufenlogik. "
        "Timing (adaptiv wie A-SRS): Abstände werden je nach Stabilität früher oder später gesetzt.";
  }

  static String colorLegend({required bool s0Locked}) {
    final lines = <String>[
      "Leuchtend: Diese Stufe ist aktiv oder im Fokus.",
      "Gedimmt: Nicht aktiv oder aktuell nicht im gewählten Bereich.",
      "Kurzer Impuls/Glow: Fortschritt (z. B. Aufstieg) wurde erreicht.",
    ];
    if (s0Locked) {
      lines.insert(2, "Schloss/Gesperrt: S0 ist blockiert (keine neuen Wörter).");
    }
    return lines.join("\n");
  }
}
