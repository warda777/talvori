// lib/features/words/application/srs_logic.dart
import 'package:talvori/features/words/data/supabase_word_repository.dart';

List<int> buildSmartCardOrder(List<WordUserView> queue) {
  final now = DateTime.now();

  bool isDue(WordUserView w) => w.nextDueAt != null && !w.nextDueAt!.isAfter(now);

  // Buckets
  final s = List.generate(6, (_) => {'due': <int>[], 'wait': <int>[]});
  final rest = <int>[];

  for (int i = 0; i < queue.length; i++) {
    final w = queue[i];
    final stage = w.srsStage.clamp(0, 5);
    final due = isDue(w);
    if (stage >= 0 && stage <= 5) {
      (due ? s[stage]['due']! : s[stage]['wait']!).add(i);
    } else {
      rest.add(i);
    }
  }

  for (final group in s) {
    group['due']!.shuffle();
    group['wait']!.shuffle();
  }
  rest.shuffle();

  // Gewichtung
  const pattern = [1, 4, 5, 3, 2, 2];
  const headSize = 150;

  final head = <int>[];
  final weights = [...pattern];

  void reset() {
    for (int i = 0; i < weights.length; i++) {
      weights[i] = pattern[i];
    }
  }

  while (head.length < headSize && s.any((x) => x['due']!.isNotEmpty || x['wait']!.isNotEmpty)) {
    for (int stage = 5; stage >= 0; stage--) {
      while (weights[stage] > 0 && s[stage]['due']!.isNotEmpty && head.length < headSize) {
        head.add(s[stage]['due']!.removeLast());
        weights[stage]--;
      }
    }
    for (int stage = 5; stage >= 0; stage--) {
      while (weights[stage] > 0 && s[stage]['wait']!.isNotEmpty && head.length < headSize) {
        head.add(s[stage]['wait']!.removeLast());
        weights[stage]--;
      }
    }
    if (weights.every((x) => x == 0)) reset();
  }

  final tail = [
    for (final group in s) ...group['due']!,
    for (final group in s) ...group['wait']!,
    ...rest
  ]..shuffle();

  return [...head, ...tail];
}
