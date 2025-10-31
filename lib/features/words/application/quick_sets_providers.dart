import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';

class QuickSetsStats {
  final int total;
  final int learned;
  final int dueToday;
  final int newTotal;
  const QuickSetsStats({required this.total, required this.learned, required this.dueToday, required this.newTotal});
}

// Mapping 0..4 wie im QuickSets-Screen
WordListFilter quicksetsFilterFor(int idx) {
  switch (idx) {
    case 0: return const WordListFilter(WordFilterKind.query, '');
    case 1: return const WordListFilter(WordFilterKind.about, 'my-words');
    case 2: return const WordListFilter(WordFilterKind.about, 'favorites');
    case 3: return const WordListFilter(WordFilterKind.about, 'known-words');
    case 4: return const WordListFilter(WordFilterKind.about, 'my-mix');
    default:return const WordListFilter(WordFilterKind.query, '');
  }
}

final quickSetsStatsProvider = FutureProvider.family<QuickSetsStats, int>((ref, index) async {
  // ⬇️ NEU: Direkt auf Repository-Provider zugreifen
  final repo = ref.read(supabaseWordRepositoryProvider);

  final f = quicksetsFilterFor(index);

  final results = await Future.wait<int>([
    repo.countByFilter(f),
    repo.countLearnedByFilter(f),
    repo.countDueTodayByFilter(f),
    repo.countNewByFilter(f),
  ]);

  return QuickSetsStats(
    total: results[0],
    learned: results[1],
    dueToday: results[2],
    newTotal: results[3],
  );
});
