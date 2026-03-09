import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';

final levelSelectionProvider =
    StateProvider<LevelSelectionMode>((ref) => LevelSelectionMode.s0toS5);

/// Wenn true: H1–H5/A1–A5/T1–T5 Fortschritt wird NICHT gespeichert.
/// Beim Zurückkehren zum Category Detail erscheinen die alten Werte.
/// Default false: Fortschritt wird an Supabase gesendet (submitReview).
final noSaveProgressProvider = StateProvider<bool>((ref) => false);

// Single-Zielstufe 1..5
final singleStageProvider = StateProvider<int>((ref) => 1);

// NEU: Auswahl läuft (bis Nutzer eine Stufe tippt)
final selectingSingleProvider = StateProvider<bool>((ref) => false);

/// User hat Modus oder Einstellung bewusst geändert (nicht nur Screen-Load).
/// Wird in initState des CategoryDetailScreen auf false gesetzt.
final userHasInteractedWithModeProvider = StateProvider<bool>((ref) => false);

/// User kommt gerade von einer Learn-Session zurück.
/// Nur dann wird Daily Progress angezeigt; bei jeder Interaktion wird es ausgeblendet.
final returnedFromLearnSessionProvider = StateProvider<bool>((ref) => false);

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
// Hinweis: S0-Lock wird nicht hier behandelt, da categoryId benötigt wird.
// S0-Lock wird lokal in levels_card.dart und learn_mode_screen.dart gehandhabt.
final allowedStagesProvider = Provider<Set<int>>((ref) {
  final range = ref.watch(levelSelectionProvider);

  switch (range) {
    case LevelSelectionMode.s0toS5:
      // S0-S5: alle Stages (S0-Lock wird lokal behandelt)
      return {0, 1, 2, 3, 4, 5};

    case LevelSelectionMode.s1toS5:
      // H1–H5 / A1–A5 / T1–T5: immer ohne S0
      return {1, 2, 3, 4, 5};

    case LevelSelectionMode.single:
      // Single-Modus: exakt eine Stufe
      final st = ref.watch(singleStageProvider);
      return {st.clamp(1, 5)};
  }
});
