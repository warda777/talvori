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
