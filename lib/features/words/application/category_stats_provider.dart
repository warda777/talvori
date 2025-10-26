import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/application/category_id_cache.dart';

// kleines DTO
class CategoryStats {
  final int total;
  final int dueToday;
  final int newTotal;
  const CategoryStats({required this.total, required this.dueToday, required this.newTotal});
}

// liefert Stats zu einer Subkategorie (per Label/ID-Auflösung)
final categoryStatsProvider = FutureProvider.family<CategoryStats?, HubSubcat>((ref, sub) async {
  final repo = ref.read(supabaseWordRepositoryProvider);

  // Cache-Lookup vor Repo-Call
  final cached = getCachedCategoryId(ref, sub.label);
  if (cached != null) {
    final prog = await fetchCategoryProgress(cached);
    final wl = await fetchWorkloadToday(cached);
    return CategoryStats(total: prog.total, dueToday: wl.dueToday, newTotal: prog.stages[0]);
  }

  final String? catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
      ? sub.supabaseId
      : await repo.findCategoryIdByName(sub.label);

  if (catId == null) return null;

  // Cache-Speicherung nach findCategoryIdByName
  setCachedCategoryId(ref, sub.label, catId);

  final prog = await fetchCategoryProgress(catId);
  final wl = await fetchWorkloadToday(catId);

  return CategoryStats(
    total: prog.total,
    dueToday: wl.dueToday,
    newTotal: prog.stages[0],
  );
});
