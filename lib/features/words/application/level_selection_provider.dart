import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

final levelSelectionProvider =
    StateProvider<LevelSelectionMode>((ref) => LevelSelectionMode.s0toS5);

// Single-Zielstufe 1..5
final singleStageProvider = StateProvider<int>((ref) => 1);

// NEU: Auswahl läuft (bis Nutzer eine Stufe tippt)
final selectingSingleProvider = StateProvider<bool>((ref) => false);

// Session-Buckets für Single-Modus (nur Learn-Modus)
class SingleSessionBuckets {
  int src; // S{n}
  int sx;  // virtuell
  int sy;  // virtuell
  SingleSessionBuckets({required this.src, this.sx = 0, this.sy = 0});
}

final singleSessionBucketsProvider = StateProvider<SingleSessionBuckets>((ref) => SingleSessionBuckets(src: 0));

// State für die drei Zähler (nur Learn-Mode)
class SingleSessionCounts { 
  final int src, sr1, sr2;
  const SingleSessionCounts(this.src, this.sr1, this.sr2);
}

final singleSessionCountsProvider = StateProvider<SingleSessionCounts>((_) => const SingleSessionCounts(0, 0, 0));

// Sicht/Filter der Stufen aus Modus ableiten
final allowedStagesProvider = Provider<Set<int>>((ref) {
  final mode = ref.watch(levelSelectionProvider);
  switch (mode) {
    case LevelSelectionMode.s0toS5:
      return {0,1,2,3,4,5};
    case LevelSelectionMode.s1toS5:
      return {1,2,3,4,5};           // ← KEIN 0!
    case LevelSelectionMode.single:
      final st = ref.watch(singleStageProvider);
      return {st.clamp(1,5)};       // genau eine Stufe
  }
});
