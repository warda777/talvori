import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/domain/word.dart';
// Wir brauchen nur die Typen für den Filter:
import 'package:talvori/features/words/ui/screens/word_list_screen.dart'
    show WordListFilter, WordFilterKind;
import 'package:flutter/foundation.dart'; // für debugPrint


class StageCount {
  final int stage;
  final int count;
  StageCount(this.stage, this.count);
}

class WorkloadToday {
  final int dueToday;
  final int newTotal;
  WorkloadToday({required this.dueToday, required this.newTotal});
}

// Falls du keinen kombinierten Typ hast: minimaler View-Mapper für v_words_user
class WordUserView {
  final String id;
  final String text;
  final String translation;
  final bool inMyWords;
  final bool pickedUser;
  final bool favoriteUser;
  final int srsStage;
  final DateTime? nextDueAt;
  final DateTime? userAddedAt;

  WordUserView.fromJson(Map<String, dynamic> j)
      : id = j['id'] as String,
        text = j['text'] as String,
        translation = j['translation'] as String,
        inMyWords = (j['in_my_words'] as bool?) ?? false,
        pickedUser = (j['picked_user'] as bool?) ?? false,
        favoriteUser = (j['favorite_user'] as bool?) ?? false,
        srsStage = (j['srs_stage_user'] as int?) ?? 0,
        nextDueAt = j['next_due_at_user'] != null ? DateTime.parse(j['next_due_at_user']) : null,
        userAddedAt = j['user_added_at'] != null ? DateTime.parse(j['user_added_at']) : null;
}

final _sb = Supabase.instance.client;

/// 1) Stufen-Balken pro Kategorie
Future<List<StageCount>> fetchStageCounts(String categoryId) async {
  final rows = await _sb.rpc('fn_user_stage_counts', params: {'cat': categoryId});
  final list = (rows as List).cast<Map<String, dynamic>>();
  return list.map((r) => StageCount((r['stage'] as int?) ?? 0, (r['cnt'] as int?) ?? 0)).toList();
}

/// 2) „Aktuelle Aufgabe“ (fällig heute + neu gesamt) pro Kategorie
Future<WorkloadToday> fetchWorkloadToday(String categoryId) async {
  final rows = await _sb.rpc('fn_user_workload_today', params: {'cat': categoryId});
  final first = (rows as List).cast<Map<String, dynamic>>().firstOrNull ?? const {};
  return WorkloadToday(
    dueToday: (first['due_today'] as int?) ?? 0,
    newTotal: (first['new_total'] as int?) ?? 0,
  );
}

/// 3) Lern-Queue (zuerst fällige, dann neue) – liefert v_words_user
Future<List<WordUserView>> fetchLearnQueue(String categoryId, {int take = 50}) async {
  final rows = await _sb.rpc('fn_user_learn_queue', params: {'cat': categoryId, 'take': take});
  final list = (rows as List).cast<Map<String, dynamic>>();
  return list.map((j) => WordUserView.fromJson(j)).toList();
}

/// Review-Ergebnis senden (true = richtig, false = falsch)
Future<(int stage, DateTime due)> submitReview(String wordId, bool correct) async {
  final rows = await _sb.rpc('fn_user_review', params: {
    'p_word': wordId,
    'p_result': correct,
  });

  final list = (rows as List).cast<Map<String, dynamic>>();
  final row = list.first;

  final stage = (row['srs_stage'] as int?) ?? 0;
  final dueStr = row['next_due_at'] as String?;
  final due = dueStr != null ? DateTime.parse(dueStr) : DateTime.now();

  return (stage, due);
}

/// Convenience:
Future<(int stage, DateTime due)> reviewCorrect(String wordId) =>
    submitReview(wordId, true);

Future<(int stage, DateTime due)> reviewWrong(String wordId) =>
    submitReview(wordId, false);

class CategoryProgress {
  final int total;
  final List<int> stages; // [s0..s5]
  final int dueToday;
  final int newTotal;
  CategoryProgress({
    required this.total,
    required this.stages,
    required this.dueToday,
    required this.newTotal,
  });
}

Future<CategoryProgress> fetchCategoryProgress(String categoryId) async {
  final rows = await _sb.rpc('fn_user_category_progress', params: {'cat': categoryId});
  final r = (rows as List).cast<Map<String, dynamic>>().first;

  return CategoryProgress(
    total: (r['total'] as int?) ?? 0,
    stages: [
      (r['stage0'] as int?) ?? 0,
      (r['stage1'] as int?) ?? 0,
      (r['stage2'] as int?) ?? 0,
      (r['stage3'] as int?) ?? 0,
      (r['stage4'] as int?) ?? 0,
      (r['stage5'] as int?) ?? 0,
    ],
    dueToday: (r['due_today'] as int?) ?? 0,
    newTotal: (r['new_total'] as int?) ?? 0,
  );
}

class SupabaseWordRepository {
  final _sb = Supabase.instance.client;

  Future<List<Word>> fetchRecentWords({int limit = 20}) async {
    final data = await _sb
        .from('words')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);

    return (data as List)
        .map((j) => Word.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<List<Word>> fetchByFilter(
    WordListFilter filter, {
    int limit = 50,
    int offset = 0,
  }) async {
    var qb = _sb.from('words').select();

    switch (filter.kind) {
      case WordFilterKind.about:
        qb = qb.contains('tags', [filter.value]); // TEXT[]
        break;
      case WordFilterKind.domain:
        qb = qb.eq('domain', filter.value); // TEXT
        break;
      case WordFilterKind.pos:
        qb = qb.eq('pos', filter.value); // TEXT
        break;
      case WordFilterKind.level:
        qb = qb.eq('level', filter.value); // TEXT
        break;
      case WordFilterKind.query:
        final q = filter.value;
        qb = qb.or('text.ilike.%$q%,translation.ilike.%$q%');
        break;
    }

    final data = await qb
        .order('text', ascending: true)
        .range(offset, offset + limit - 1);

    return (data as List)
        .map((j) => Word.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<void> addToMyWords(String wordId) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _sb.from('user_words').upsert({
      'user_id': user.id,
      'word_id': wordId,
      'picked': true,
    });
  }

  Future<void> removeFromMyWords(String wordId) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');
    await _sb
        .from('user_words')
        .delete()
        .eq('user_id', user.id)
        .eq('word_id', wordId);
  }

  /// Optional: initiale Markierungen für eine Liste abfragen (Batch)
  Future<Set<String>> getPickedWordIds(Iterable<String> wordIds) async {
    final user = _sb.auth.currentUser;
    if (user == null || wordIds.isEmpty) return {};
    final data = await _sb
        .from('user_words')
        .select('word_id')
        .eq('user_id', user.id)
        .inFilter('word_id', wordIds.toList());

    return {
      for (final row in (data as List))
        (row as Map<String, dynamic>)['word_id'] as String
    };
  }

  Future<void> testIngestWord() async {
    final supabase = Supabase.instance.client;

    final response = await supabase.functions.invoke(
      'ingest_word',
      body: {
        'text': 'house',
        'fromLang': 'EN',
        'toLang': 'DE',
      },
    );

    debugPrint('🔹 Function response: ${response.data}');
  }

}

// --- MyWords API: fetch + count --------------------------------------------
extension MyWordsApi on SupabaseWordRepository {
  /// Gemerkte Wörter des aktuellen Users (Pagination). Optional clientseitige Suche.
  Future<List<Word>> fetchMyWords({
    int limit = 50,
    int offset = 0,
    String? query,
  }) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Join: user_words -> words (als "word")
    final data = await _sb
        .from('user_words')
        .select('word:words(*)')
        .eq('user_id', user.id)
        .eq('picked', true)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    // Map zu Word-Liste
    var items = (data as List)
        .map((row) => Word.fromJson(
              (row as Map<String, dynamic>)['word'] as Map<String, dynamic>,
            ))
        .toList();

    // Einfache clientseitige Suche
    final q = query?.trim().toLowerCase();
    if (q != null && q.isNotEmpty) {
      items = items
          .where((w) =>
              w.text.toLowerCase().contains(q) ||
              w.translation.toLowerCase().contains(q))
          .toList();
    }

    return items;
  }

  /// Anzahl der gemerkten Wörter (einfach & robust).
  Future<int> countMyWords() async {
    final user = _sb.auth.currentUser;
    if (user == null) return 0;

    final data = await _sb
        .from('user_words')
        .select('word_id') // kein head/count – einfach zählen
        .eq('user_id', user.id)
        .eq('picked', true);

    return (data as List).length;
  }
}
