import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'mix_groups.dart';

/// State: ausgewählte Labels
class MixSelection extends StateNotifier<Set<String>> {
  MixSelection() : super(<String>{});

  bool isSelected(String label) => state.contains(label);

  void setSelected(String label, bool v) {
    final next = Set<String>.of(state);
    v ? next.add(label) : next.remove(label);
    state = next;
  }

  void toggle(String label) => setSelected(label, !isSelected(label));

  void selectAll(Iterable<String> labels) {
    final next = Set<String>.of(state)..addAll(labels);
    state = next;
  }

  void toggleAll(Iterable<String> labels) {
    final allSel = labels.every((l) => state.contains(l));
    final next = Set<String>.of(state);
    for (final l in labels) {
      if (allSel) {
        next.remove(l);
      } else {
        next.add(l);
      }
    }
    state = next;
  }

  bool areAllSelected(Iterable<String> labels) =>
      labels.isNotEmpty && labels.every(state.contains);
}

final mixSelectionProvider =
    StateNotifierProvider<MixSelection, Set<String>>((ref) => MixSelection());
