import 'dart:async';
export 'reset_event.dart';

// === Heute-Statistiken: Stage-Transition ===
// Zählt "new" hoch/runter: S0 -> S1+ (+1), S1+ -> S0 (-1); repeats separat.
class StageTransitionEvent {
  final String categoryId;
  final String wordId;
  final int fromStage; // 0..5
  final int toStage;   // 0..5
  final bool wasDueBefore; // true, wenn die Karte VOR dem Schritt fällig war (für repeats)

  StageTransitionEvent({
    required this.categoryId,
    required this.wordId,
    required this.fromStage,
    required this.toStage,
    required this.wasDueBefore,
  });

  static final _ctrl = StreamController<StageTransitionEvent>.broadcast();
  static Stream<StageTransitionEvent> get stream => _ctrl.stream;
  static void emit(StageTransitionEvent e) => _ctrl.add(e);
}
