import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/data/word_hub_taxonomy.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/application/category_id_cache.dart';
import 'package:talvori/features/words/application/srs_mode_controller.dart';

// kleines DTO
class CategoryStats {
  final int total;
  final int dueToday;
  final int newTotal;
  const CategoryStats({required this.total, required this.dueToday, required this.newTotal});
}

// ✅ Einmalig beim WordHub-Start: Ensure Progress-Rows für alle Kategorien
final ensureAllProgressProvider = FutureProvider<int>((ref) async {
  try {
    final repo = ref.read(supabaseWordRepositoryProvider);
    final srs = ref.watch(srsModeControllerProvider).mode;
    final result = await repo.ensureWordProgressForAllCategories(srsSystem: srs);
    debugPrint('✅ ensureAllProgressProvider: $result Rows erzeugt/aktualisiert');
    return result;
  } catch (e, st) {
    // ⚠️ Fehler nicht weiterwerfen, damit WordHub trotzdem lädt
    debugPrint('⚠️ ensureAllProgressProvider fehlgeschlagen: $e');
    debugPrint('⚠️ Stack: $st');
    return 0; // Fallback: 0 Rows
  }
});

// liefert Stats zu einer Subkategorie (per Label/ID-Auflösung)
final categoryStatsProvider = FutureProvider.family<CategoryStats?, HubSubcat>((ref, sub) async {
  try {
    final repo = ref.read(supabaseWordRepositoryProvider);

    final srs = ref.watch(srsModeControllerProvider).mode;

    final cached = getCachedCategoryId(ref, sub.label);
    if (cached != null) {
      final prog = await repo.fetchCategoryProgress(cached, srsSystem: srs);
      final wl   = await repo.fetchWorkloadToday(cached);
      debugPrint('📊 categoryStatsProvider (cached): ${sub.label} -> total=${prog.total}, stages=${prog.stages}');
      return CategoryStats(total: prog.total, dueToday: wl.dueToday, newTotal: prog.stages[0]);
    }

    final String? catId = (sub.supabaseId != null && sub.supabaseId!.isNotEmpty)
        ? sub.supabaseId
        : await repo.findCategoryIdByName(sub.label);

    if (catId == null) {
      debugPrint('⚠️ categoryStatsProvider: Keine catId gefunden für "${sub.label}"');
      return null;
    }

    setCachedCategoryId(ref, sub.label, catId);

    final prog = await repo.fetchCategoryProgress(catId, srsSystem: srs);
    final wl   = await repo.fetchWorkloadToday(catId);

    debugPrint('📊 categoryStatsProvider: ${sub.label} (catId=$catId) -> total=${prog.total}, stages=${prog.stages}');
    return CategoryStats(total: prog.total, dueToday: wl.dueToday, newTotal: prog.stages[0]);
  } catch (e, st) {
    debugPrint('❌ categoryStatsProvider Fehler für "${sub.label}": $e');
    debugPrint('❌ Stack: $st');
    return null; // Bei Fehler: null zurückgeben
  }
});
