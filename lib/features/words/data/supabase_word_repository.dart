import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/domain/word.dart';
// Wir brauchen nur die Typen für den Filter:
import 'package:talvori/features/words/application/word_list_controller.dart'
    show WordListFilter, WordFilterKind, SortMode;
import 'package:flutter/foundation.dart'; // für debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:talvori/features/words/ui/widgets/level_selector_buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // falls noch nicht
import 'package:talvori/features/words/application/srs_mode_controller.dart';


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
  final String? level;
  final bool inMyWords;
  final bool pickedUser;
  final bool favoriteUser;
  final int srsStage;
  final DateTime? nextDueAt;
  final DateTime? userAddedAt;

  WordUserView({
    required this.id,
    required this.text,
    required this.translation,
    this.level,
    this.inMyWords = false,
    this.pickedUser = false,
    this.favoriteUser = false,
    this.srsStage = 0,
    this.nextDueAt,
    this.userAddedAt,
  });

  WordUserView.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as String?) ?? '',
        text = (j['text'] as String?) ?? '',
        translation = (j['translation'] as String?) ?? '',
        level = j['level'] as String?,
        inMyWords = (j['in_my_words'] as bool?) ?? false,
        pickedUser = (j['picked_user'] as bool?) ?? false,
        favoriteUser = (j['favorite_user'] as bool?) ?? false,
        srsStage = (j['srs_stage_user'] as int?) ?? 0,
        nextDueAt = j['next_due_at_user'] != null ? DateTime.parse(j['next_due_at_user']) : null,
        userAddedAt = j['user_added_at'] != null ? DateTime.parse(j['user_added_at']) : null;
  
  WordUserView copyWith({
    int? srsStage,
    DateTime? nextDueAt,
    bool setDueNull = false,
  }) {
    return WordUserView(
      id: id,
      text: text,
      translation: translation,
      level: level,
      inMyWords: inMyWords,
      pickedUser: pickedUser,
      favoriteUser: favoriteUser,
      srsStage: srsStage ?? this.srsStage,
      nextDueAt: setDueNull ? null : (nextDueAt ?? this.nextDueAt),
      userAddedAt: userAddedAt,
    );
  }
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
  final res = await Supabase.instance.client
      .rpc('fn_user_workload_today', params: {'cat': categoryId});

  late final Map<String, dynamic> j;
  if (res is Map<String, dynamic>) {
    j = res;
  } else if (res is List && res.isNotEmpty && res.first is Map<String, dynamic>) {
    j = res.first as Map<String, dynamic>;
  } else {
    j = const {}; // fallback
  }

  return WorkloadToday(
    newTotal: (j['newTotal'] ?? j['new_total'] ?? 0) as int,
    dueToday: (j['dueToday'] ?? j['due_today'] ?? 0) as int,
  );
}


/// Lern-Queue (alle Wörter der Kategorie – Größe dynamisch aus Progress)
Future<List<WordUserView>> fetchLearnQueueAll(String categoryId) async {
  final prog = await fetchCategoryProgress(categoryId);
  final take = (prog.total > 0) ? prog.total : 2000; // Fallback
  final rows = await _sb.rpc('fn_user_learn_queue', params: {'cat': categoryId, 'take': take});
  final list = (rows as List).cast<Map<String, dynamic>>();
  return list.map((j) => WordUserView.fromJson(j)).toList();
}

/// Lern-Queue für Learn Mode (nur S0 + fällige S1-S5)
Future<List<WordUserView>> fetchLearnQueueForMode(
  String categoryId, {
  required LevelSelectionMode mode,
  int? singleStage, // 1..5 (nur relevant bei single)
}) async {
  // Korrekte RPC-Funktion mit korrekten Parameter-Namen
  final modeStr = switch (mode) {
    LevelSelectionMode.s0toS5 => 'all',
    LevelSelectionMode.s1toS5 => 'reviews',
    LevelSelectionMode.single => 'single',
  };

  final params = <String, dynamic>{
    'category_id': categoryId,        // ✅ genau so benannt
    'mode': modeStr,                  // 'all' | 'reviews' | 'single'
    if (mode == LevelSelectionMode.single) 'single_stage': singleStage, // 1..5
    'limit': 50,                      // falls in SQL unterstützt
  };

  final res = await _sb.rpc('fn_user_learn_queue_mode', params: params);
  final list = (res as List).cast<Map<String, dynamic>>();
  return list.map((j) => WordUserView.fromJson(j)).toList();
}


/// Review-Ergebnis senden (true = richtig, false = falsch)
Future<(int stage, DateTime due)> submitReview(
  String wordId,
  bool correct, {
  required SrsSystem srsSystem,
}) async {
  final modeStr = switch (srsSystem) {
    SrsSystem.time => 'time',
    SrsSystem.adaptive => 'adaptive',
    SrsSystem.hybrid => 'hybrid',
  };

  final rows = await _sb.rpc('fn_user_review_mode', params: {
    'p_word': wordId,
    'p_result': correct,
    'p_mode': modeStr,
  });

  final list = (rows as List).cast<Map<String, dynamic>>();
  final row = list.first;

  final stage = (row['srs_stage'] as int?) ?? 0;
  final dueStr = row['next_due_at'] as String?;
  final due = dueStr != null ? DateTime.parse(dueStr) : DateTime.now();

  return (stage, due);
}

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
  final r = rows.cast<Map<String, dynamic>>().first;

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

  // ⬇️ NEU: Helper-Funktion zum Erstellen von Query-Parametern aus Filter
  Map<String, String> _buildQueryParamsForFilter(WordListFilter filter) {
    final params = <String, String>{};
    
    switch (filter.kind) {
      case WordFilterKind.category:
        // hier kommt künftig schon ein Slug an (s.u. Controller),
        // deshalb direkt:
        params['category_slug'] = 'eq.${filter.value}';
        break;
      case WordFilterKind.level:
        params['level'] = 'eq.${filter.value}';
        break;
      case WordFilterKind.pos:
        params['pos'] = 'eq.${filter.value}';
        break;
      case WordFilterKind.domain:
        params['group_slug'] = 'eq.${filter.value}';
        break;
      case WordFilterKind.about:
        // QuickSets-Slugs mit User-Flags filtern
        switch (filter.value) {
          case 'my-words':
            params['in_my_words'] = 'eq.true';
            break;
          case 'favorites':
            params['favorite_user'] = 'eq.true';
            break;
          case 'known-words':
            params['srs_stage_user'] = 'gte.1';
            break;
          case 'my-mix':
            params['picked_user'] = 'eq.true';
            break;
          default:
            params['category_slug'] = 'eq.${filter.value}';
        }
        break;
      case WordFilterKind.query:
        // Query-Filter hat keine zusätzlichen Parameter
        break;
    }
    
    return params;
  }

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

    Future<String> _ensureCategorySlug(String value) async {
    // Wenn 'value' already a slug, einfach zurückgeben (heuristik: enthält keine '{' und keine ':' und keine Großbuchstaben)
    final isUuidLike = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(value);
    if (!isUuidLike) return value; // already a slug

    // sonst: per UUID -> slug nachschlagen
    final row = await _sb
        .from('categories')
        .select('slug')
        .eq('id', value)
        .maybeSingle();
    if (row == null || row['slug'] == null) {
      throw Exception('Kategorie-Slug nicht gefunden für id=$value');
    }
    return row['slug'] as String;
  }

  /// Fetch WordUserViews (mit User-Flags) für Filter
  Future<List<WordUserView>?> fetchWordUserViewsByFilter(
    WordListFilter filter, {
    int limit = 5000,
    int offset = 0,
    String? query,
    SortMode? sort,
  }) async {
    try {
      // Verwende Supabase SDK statt manueller HTTP-Requests
      // WICHTIG: Filter müssen VOR order() und range() angewendet werden
      dynamic query_builder = _sb
          .from('v_words_user')
          .select('id,text,translation,level,pos,category_slug,group_slug,'
                  'in_my_words,favorite_user,picked_user,'
                  'srs_stage_user,next_due_at_user,user_added_at');

      // Filter anwenden (MUSS vor order/range kommen)
      switch (filter.kind) {
        case WordFilterKind.category:
          // ⬇️ Category-Filter NICHT über v_words_user (dort gibt's keine Kategorie!),
          //     sondern über words_view laufen lassen.
          //     Wir nehmen die ID (du hast sie schon ermittelt), alternativ slug->id vorab auflösen.
          {
            // Ermittle category_id: value kann UUID oder Slug sein
            String categoryId = filter.value;
            final isUuidLike = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(filter.value);
            if (!isUuidLike) {
              // Ist ein Slug, auflösen zu ID
              final row = await _sb
                  .from('categories')
                  .select('id')
                  .eq('slug', filter.value)
                  .maybeSingle();
              if (row != null && row['id'] != null) {
                categoryId = row['id'] as String;
              } else {
                // Slug nicht gefunden, leer zurückgeben
                return [];
              }
            }

            final data = await _sb
                .from('words_view')
                .select('id,text,translation,level,pos,category_id')
                .eq('category_id', categoryId)        // ✅ words_view hat category_id
                .order('text', ascending: true);

            final list = (data as List).cast<Map<String, dynamic>>();
            // Map auf WordUserView (User-Flags fehlen hier bewusst → Defaults)
            return list.map((j) => WordUserView(
              id: (j['id'] as String?) ?? '',
              text: (j['text'] as String?) ?? '',
              translation: (j['translation'] as String?) ?? '',
              level: j['level'] as String?,
              inMyWords: false,
              pickedUser: false,
              favoriteUser: false,
              srsStage: 0,
              nextDueAt: null,
              userAddedAt: null,
            )).toList();
          }
        case WordFilterKind.level:
          query_builder = query_builder.eq('level', filter.value);
          break;
        case WordFilterKind.pos:
          query_builder = query_builder.eq('pos', filter.value);
          break;
        case WordFilterKind.domain:
          query_builder = query_builder.eq('group_slug', filter.value);
          break;
        case WordFilterKind.about:
          switch (filter.value) {
            case 'my-words':
              // Direkt aus user_words filtern (picked=true)
              final user = _sb.auth.currentUser;
              if (user == null) return [];
              
              // Hole word_ids aus user_words
              final userWordsData = await _sb
                  .from('user_words')
                  .select('word_id')
                  .eq('user_id', user.id)
                  .eq('picked', true);
              
              final userWordsList = (userWordsData as List).cast<Map<String, dynamic>>();
              if (userWordsList.isEmpty) return [];
              
              final wordIds = userWordsList
                  .map((e) => e['word_id'] as String)
                  .toList();
              
              // Filtere v_words_user nach diesen word_ids
              query_builder = query_builder.inFilter('id', wordIds);
              break;
            case 'favorites':
              query_builder = query_builder.eq('favorite_user', true);
              break;
            case 'known-words':
              query_builder = query_builder.gte('srs_stage_user', 1);
              break;
            case 'my-mix':
              query_builder = query_builder.eq('picked_user', true);
              break;
            default:
              query_builder = query_builder.eq('category_slug', filter.value);
          }
          break;
        case WordFilterKind.query:
          break;
      }

      // Text-Suche (auch vor order/range)
      if (query != null && query.trim().isNotEmpty) {
        final q = query.trim();
        query_builder = query_builder.or('text.ilike.%$q%,translation.ilike.%$q%');
      }

      // Sortierung (nach Filtern)
      if (sort == SortMode.newest) {
        query_builder = query_builder.order('user_added_at', ascending: false);
      } else {
        query_builder = query_builder.order('text', ascending: true);
      }

      debugPrint('🌐 Querying v_words_user with filter: ${filter.kind} = ${filter.value}');
      
      final data = await query_builder;
      final List list = data as List;
      
      debugPrint('✅ Loaded ${list.length} words');
      
      return list.map((j) => WordUserView.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWordUserViewsByFilter error: $e');
      debugPrint('Stack: $stackTrace');
      rethrow;
    }
  }

  Future<List<Word>?> fetchByFilter(
    WordListFilter filter, {
    int limit = 50,
    int offset = 0,
    String? query,
    SortMode? sort,
  }) async {
    // ⬇️ NEU: Verwende v_words_user für User-Flags (statt words_view)
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/v_words_user';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;

    // Lokaler Schlüssel pro Filter+Sort-Kombination
    final etagKey = '${filter.kind}:${filter.value}:${sort ?? ''}:${query ?? ''}';
    final prefs = await SharedPreferences.getInstance();
    final oldEtag = prefs.getString('etag_$etagKey');

    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      if (oldEtag != null) 'If-None-Match': oldEtag,
    };

    // Querystring aufbauen
    // ⬇️ NEU: User-Flags mit auswählen (für QuickSets-Filter)
    final params = <String>[
      'select=id,text,translation,level,pos,category_id,in_my_words,favorite_user,srs_stage_user,picked_user,user_added_at',
      'limit=$limit',
      'offset=$offset',
      'order=${sort == SortMode.newest ? 'user_added_at.desc' : 'text.asc'}',
    ];

    // Filter (per eq)
    switch (filter.kind) {
      case WordFilterKind.category:
        params.add('category_id=eq.${filter.value}');
        break;
      case WordFilterKind.level:
        params.add('level=eq.${filter.value}');
        break;
      case WordFilterKind.pos:
        params.add('pos=eq.${filter.value}');
        break;
      case WordFilterKind.domain:
        params.add('group_slug=eq.${filter.value}');
        break;
      case WordFilterKind.about:
        // ⬇️ NEU: QuickSets-Slugs mit User-Flags filtern
        switch (filter.value) {
          case 'my-words':
            params.add('in_my_words=eq.true');          // ← nutzt bool-Spalte
            break;
          case 'favorites':
            params.add('favorite_user=eq.true');        // ← nutzt bool-Spalte
            break;
          case 'known-words':
            params.add('srs_stage_user=gte.1');         // ← "ich kenne" = ab S1
            break;
          case 'my-mix':
            params.add('picked_user=eq.true');          // ← dein Mix
            break;
          default:
            params.add('category_slug=eq.${filter.value}'); // fallback
        }
        break;
      case WordFilterKind.query:
        break;
    }

    if (query != null && query.trim().isNotEmpty) {
      final q = query.trim();
      params.add('or=(text.ilike.%$q%,translation.ilike.%$q%)');
    }

    final uri = Uri.parse('$baseUrl?${params.join('&')}');

    // Anfrage senden
    final resp = await http.get(uri, headers: headers);

    // 👇 nur Debug
    // ignore: avoid_print
    print('ETag fetch ${uri.path}: ${resp.statusCode} (If-None-Match=${headers['If-None-Match'] != null})');

    if (resp.statusCode == 304) {
      return null; // WICHTIG: „unverändert" – UI nicht überschreiben!
    }

    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.reasonPhrase}');
    }

    // Neuen ETag speichern
    final newEtag = resp.headers['etag'];
    if (newEtag != null) {
      await prefs.setString('etag_$etagKey', newEtag);
    }

    // Daten parsen
    final List data = jsonDecode(resp.body);
    // ⬇️ NEU: Map srs_stage_user zu srs_stage für Word.fromJson
    final words = data.map((m) {
      final Map<String, dynamic> json = Map<String, dynamic>.from(m);
      // v_words_user hat srs_stage_user, Word.fromJson erwartet srs_stage
      if (json.containsKey('srs_stage_user') && !json.containsKey('srs_stage')) {
        json['srs_stage'] = json['srs_stage_user'];
      }
      return Word.fromJson(json);
    }).toList();

    // Dedupe nach ID
    final seen = <String>{};
    final unique = <Word>[];
    for (final w in words) {
      if (seen.add(w.id)) unique.add(w);
    }
    return unique;
  }

  // ⬇️ NEU: Count-APIs für QuickSets (nutzen HTTP-API wie fetchByFilter)
  Future<int> countByFilter(WordListFilter filter) async {
    final isCategory = filter.kind == WordFilterKind.category;

    final baseUrl = isCategory
        ? '${dotenv.env['SUPABASE_URL']}/rest/v1/words_view'  // ✅
        : '${dotenv.env['SUPABASE_URL']}/rest/v1/v_words_user';

    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;

    final params = <String>[
      'select=id',
      'limit=1',
      'prefer=count=exact',
    ];

    if (isCategory) {
      // Ermittle category_id: value kann UUID oder Slug sein
      String categoryId = filter.value;
      final isUuidLike = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(filter.value);
      if (!isUuidLike) {
        // Ist ein Slug, auflösen zu ID
        final row = await _sb
            .from('categories')
            .select('id')
            .eq('slug', filter.value)
            .maybeSingle();
        if (row != null && row['id'] != null) {
          categoryId = row['id'] as String;
        } else {
          return 0; // Slug nicht gefunden
        }
      }
      params.add('category_id=eq.$categoryId');           // ✅ words_view hat category_id
    } else {
      final qp = _buildQueryParamsForFilter(filter);
      params.addAll(qp.entries.map((e) => '${e.key}=${e.value}'));
    }

    final uri = Uri.parse('$baseUrl?${params.join('&')}');
    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      'Prefer': 'count=exact',
    };

    final resp = await http.head(uri, headers: headers);
    final cr = resp.headers['content-range'];
    if (cr != null) {
      final m = RegExp(r'/(\d+)$').firstMatch(cr);
      if (m != null) return int.parse(m.group(1)!);
    }
    return 0;
  }

  Future<int> countLearnedByFilter(WordListFilter filter) async {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/v_words_user';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;
    
    final params = <String>[
      'select=id',
      'limit=1',
      'prefer=count=exact',
      'srs_stage_user=gte.1',
    ];
    
    final queryParams = _buildQueryParamsForFilter(filter);
    params.addAll(queryParams.entries.map((e) => '${e.key}=${e.value}'));
    
    final uri = Uri.parse('$baseUrl?${params.join('&')}');
    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      'Prefer': 'count=exact',
    };
    
    final resp = await http.head(uri, headers: headers);
    final countHeader = resp.headers['content-range'];
    if (countHeader != null) {
      final match = RegExp(r'/(\d+)$').firstMatch(countHeader);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }
    return 0;
  }

  Future<int> countNewByFilter(WordListFilter filter) async {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/v_words_user';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;
    
    final params = <String>[
      'select=id',
      'limit=1',
      'prefer=count=exact',
      'srs_stage_user=eq.0',
    ];
    
    final queryParams = _buildQueryParamsForFilter(filter);
    params.addAll(queryParams.entries.map((e) => '${e.key}=${e.value}'));
    
    final uri = Uri.parse('$baseUrl?${params.join('&')}');
    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      'Prefer': 'count=exact',
    };
    
    final resp = await http.head(uri, headers: headers);
    final countHeader = resp.headers['content-range'];
    if (countHeader != null) {
      final match = RegExp(r'/(\d+)$').firstMatch(countHeader);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }
    return 0;
  }

  Future<int> countDueTodayByFilter(WordListFilter filter) async {
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/v_words_user';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;
    
    final params = <String>[
      'select=id',
      'limit=1',
      'prefer=count=exact',
      'srs_stage_user=gte.1',
      'next_due_at_user=lte.${DateTime.now().toIso8601String()}',
    ];
    
    final queryParams = _buildQueryParamsForFilter(filter);
    params.addAll(queryParams.entries.map((e) => '${e.key}=${e.value}'));
    
    final uri = Uri.parse('$baseUrl?${params.join('&')}');
    final headers = {
      'apikey': apiKey,
      'Authorization': 'Bearer $apiKey',
      'Accept': 'application/json',
      'Prefer': 'count=exact',
    };
    
    final resp = await http.head(uri, headers: headers);
    final countHeader = resp.headers['content-range'];
    if (countHeader != null) {
      final match = RegExp(r'/(\d+)$').firstMatch(countHeader);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }
    return 0;
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

  /// Batch-Markierung: Setzt mehrere Wörter auf "known" (srs_stage_user = 1)
  /// Nutzt die bestehende Update-Route (upsert auf user_words)
  Future<void> markKnownBatch(List<String> wordIds) async {
    final user = _sb.auth.currentUser;
    if (user == null || wordIds.isEmpty) return;

    // Batch-Upsert: Erstelle Records für alle wordIds mit srs_stage = 1
    final records = wordIds.map((wordId) => {
      'user_id': user.id,
      'word_id': wordId,
      'srs_stage': 1, // "known" = Stage 1
    }).toList();

    await _sb.from('user_words').upsert(
      records,
      onConflict: 'user_id,word_id',
    );
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

// --- MyWords API: fetch + count (nur user_words) ---------------------------
extension MyWordsApi on SupabaseWordRepository {
  Future<List<Word>> fetchMyWords({
    int? limit,
    int offset = 0,
    String? query,
    bool browserOnly = true, // 👈 neu
  }) async {
    final user = _sb.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    dynamic queryBuilder = _sb
        .from('user_words')
        .select('word:words(*)')
        .eq('user_id', user.id)
        .eq('picked', true);
    if (browserOnly) queryBuilder = queryBuilder.eq('source', 'browser'); // 👈 neu
    queryBuilder = queryBuilder.order('created_at', ascending: false);
    if (limit != null) {
      queryBuilder = queryBuilder.range(offset, offset + limit - 1);
    } else {
      queryBuilder = queryBuilder.range(offset, offset + 999999); // Kein Limit, aber große Range
    }
    final data = await queryBuilder;

    var items = (data as List)
        .map((row) => Word.fromJson((row as Map<String, dynamic>)['word'] as Map<String, dynamic>))
        .toList();

    final s = query?.trim().toLowerCase();
    if (s != null && s.isNotEmpty) {
      items = items.where((w) =>
        w.text.toLowerCase().contains(s) || w.translation.toLowerCase().contains(s)).toList();
    }
    return items;
  }

  Future<int> countMyWords({bool browserOnly = true}) async { // 👈 neu
    final user = _sb.auth.currentUser;
    if (user == null) return 0;

    var q = _sb
        .from('user_words')
        .select('word_id') // lightweight
        .eq('user_id', user.id)
        .eq('picked', true);
    if (browserOnly) q = q.eq('source', 'browser'); // 👈 neu

    final data = await q;
    return (data as List).length;
  }

  Future<WordUserView?> fetchWordById(String wordId) async {
    final row = await _sb
        .from('v_words_user')
        .select()
        .eq('id', wordId)
        .maybeSingle();
    return row == null ? null : WordUserView.fromJson(row);
  }
}

// --- Kategorie-Resolver -----------------------------------------------
extension CategoryLookup on SupabaseWordRepository {
  /// Sucht die Kategorie-ID (UUID) per Anzeigename (case-insensitive).
  Future<String?> findCategoryIdByName(String name) async {
    final row = await _sb
        .from('categories')
        .select('id')
        .ilike('name', name) // "Health & Fitness" ≈ "health & fitness"
        .maybeSingle();
    if (row == null) return null;
    return row['id'] as String?;
  }

  Future<String?> findCategorySlugById(String id) async {
    final row = await _sb
        .from('categories')
        .select('slug')
        .eq('id', id)
        .maybeSingle();
    return row?['slug'] as String?;
  }
}

/// Info für die UI
class CategoryInfo {
  final String id;
  final String name;
  final String slug;
  final String? groupSlug;
  final String? groupName;
  final int? orderIndex;

  CategoryInfo({
    required this.id,
    required this.name,
    required this.slug,
    this.groupSlug,
    this.groupName,
    this.orderIndex,
  });

  factory CategoryInfo.fromJson(Map<String, dynamic> j) => CategoryInfo(
        id: (j['id'] as String?) ?? '',
        name: (j['name'] as String?) ?? '',
        slug: (j['slug'] as String?) ?? '',
        groupSlug: j['group_slug'] as String?,
        groupName: j['group_name'] as String?,
        orderIndex: j['order_index'] as int?,
      );
}


Future<List<CategoryInfo>> fetchAllCategories() async {
  final rows = await _sb
      .from('categories')
      .select('id,name,slug,group_slug,group_name,order_index,type')
      .eq('type', 'topic')
      .order('group_slug', ascending: true)
      .order('order_index', ascending: true);
  return (rows as List).map((e) => CategoryInfo.fromJson(e as Map<String, dynamic>)).toList();
}

// === Single Session Hooks ===

Future<void> singleSeed(String catId, int stage) =>
  _sb.rpc('fn_single_session_seed', params: {
    'p_category_id': catId, 'p_stage': stage, 'p_limit': 200,
  });

Future<(int src, int sr1, int sr2)> singleCounts(String catId, int stage) async {
  final res = await _sb.rpc('fn_single_session_counts', params: {
    'p_category_id': catId,
    'p_stage': stage,
  });
  final list = (res as List).cast<Map<String, dynamic>>(); // ⬅ wie bei deinen anderen RPCs
  final row = list.isEmpty ? null : list.first;
  return (
    (row?['src'] ?? 0) as int,
    (row?['sr1'] ?? 0) as int,
    (row?['sr2'] ?? 0) as int
  );
}

Future<void> singleMove(String catId, int stage, String wordId, bool correct) =>
  _sb.rpc('fn_single_session_move', params: {
    'p_category_id': catId,
    'p_stage': stage,
    'p_word_id': wordId,
    'p_correct': correct, // <-- boolean statt Bucket-String
  });

Future<void> singleReset(String catId, int stage) =>
  _sb.rpc('fn_single_session_reset', params: {
    'p_category_id': catId, 'p_stage': stage,
  });

Future<Map<String, dynamic>?> fetchNextFromSingle(String catId, int stage) async {
  final res = await _sb
      .from('single_session_items')
      .select('word_id, bucket')
      .eq('category_id', catId)
      .eq('stage', stage)
      .eq('bucket', 'src')
      .limit(1);
  if (res.isEmpty) return null;
  final wordId = res[0]['word_id'];
  // Lade Wortdaten wie sonst auch:
  final w = await _sb.from('v_words_user')
      .select()
      .eq('id', wordId)
      .maybeSingle();
  return w;
}

Future<String?> singleNextWordId(String catId, int stage) async {
  final res = await _sb
      .rpc('fn_single_session_next', params: {
        'p_category_id': catId,
        'p_stage': stage,
      });

  if (res == null) return null;

  // Rückgabe kann Liste oder Map sein (je nach Supabase-Version)
  final data = res is List
      ? (res.isNotEmpty ? res.first as Map<String, dynamic> : null)
      : (res as Map<String, dynamic>?);

  if (data == null) return null;

  final wordId = data['word_id'] as String?;
  final bucket = data['bucket'] as String?;

  if (wordId == null) return null;

  // Debug-Ausgabe zur Kontrolle
  debugPrint('🧩 Next word: $wordId from bucket=$bucket');

  // Wortdaten nachladen (wie bisher)
  final w = await _sb.from('v_words_user')
      .select()
      .eq('id', wordId)
      .maybeSingle();

  return w == null ? null : wordId;
}

/// Lädt Wörter für einen bestimmten Stage einer Kategorie
Future<List<WordUserView>> fetchWordsByStage(String categoryId, int stage) async {
  try {
    final user = _sb.auth.currentUser;
    if (user == null) return [];

    // Hole category_id wenn nötig (kann UUID oder Slug sein)
    String catId = categoryId;
    final isUuidLike = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(categoryId);
    if (!isUuidLike) {
      final row = await _sb
          .from('categories')
          .select('id')
          .eq('slug', categoryId)
          .maybeSingle();
      if (row != null && row['id'] != null) {
        catId = row['id'] as String;
      } else {
        return [];
      }
    }

    // Hole alle Wörter dieser Kategorie über word_categories Join
    // Zuerst: Hole word_ids aus word_categories
    final wordCategoriesData = await _sb
        .from('word_categories')
        .select('word_id')
        .eq('category_id', catId);

    final wordCategoryIds = (wordCategoriesData as List)
        .cast<Map<String, dynamic>>()
        .map((wc) => wc['word_id'] as String)
        .toList();

    if (wordCategoryIds.isEmpty) {
      debugPrint('🔍 fetchWordsByStage: Keine Wörter in Kategorie $catId gefunden');
      return [];
    }

    // Dann: Hole die Wort-Details aus words Tabelle
    final wordsData = await _sb
        .from('words')
        .select('id,text,translation,level,pos')
        .inFilter('id', wordCategoryIds)
        .order('text', ascending: true);

    final wordsList = (wordsData as List).cast<Map<String, dynamic>>();
    if (wordsList.isEmpty) {
      debugPrint('🔍 fetchWordsByStage: Keine Wort-Details gefunden für ${wordCategoryIds.length} word_ids');
      return [];
    }

    final wordIds = wordsList.map((w) => w['id'] as String).toList();
    debugPrint('🔍 fetchWordsByStage: ${wordsList.length} Wörter gefunden für Stage $stage');

    if (stage == 0) {
      // Stage 0: Alle Wörter, die KEINEN user_words Eintrag haben ODER srs_stage = 0 haben
      // WICHTIG: Wenn wordIds leer ist oder zu groß, müssen wir anders vorgehen
      if (wordIds.isEmpty) {
        return [];
      }

      // Hole alle user_words Einträge für diesen User und diese Wörter
      // Verwende inFilter mit Chunking falls nötig (Supabase Limit: ~1000 Werte)
      final userWordsMap = <String, Map<String, dynamic>>{};
      
      // Chunking für große Listen (falls mehr als 1000 Wörter)
      const chunkSize = 1000;
      for (var i = 0; i < wordIds.length; i += chunkSize) {
        final chunk = wordIds.skip(i).take(chunkSize).toList();
        final userWordsData = await _sb
            .from('user_words')
            .select('word_id,srs_stage,next_due_at')
            .eq('user_id', user.id)
            .inFilter('word_id', chunk);
        
        for (var uw in (userWordsData as List).cast<Map<String, dynamic>>()) {
          final wordId = uw['word_id'] as String;
          userWordsMap[wordId] = uw;
        }
      }

      // Filtere: Alle Wörter, die NICHT in user_words sind ODER srs_stage = 0 haben
      final result = wordsList
          .where((w) {
            final wordId = w['id'] as String;
            final userWord = userWordsMap[wordId];
            // In Stage 0 wenn: kein user_words Eintrag ODER srs_stage = 0
            return userWord == null || (userWord['srs_stage'] as int? ?? 0) == 0;
          })
          .map((word) {
            final wordId = word['id'] as String;
            final userWord = userWordsMap[wordId];
            return WordUserView(
              id: wordId,
              text: word['text'] as String? ?? '',
              translation: word['translation'] as String? ?? '',
              level: word['level'] as String?,
              srsStage: 0,
              nextDueAt: userWord?['next_due_at'] != null
                  ? DateTime.parse(userWord!['next_due_at'])
                  : null,
            );
          })
          .toList();

      debugPrint('🔍 fetchWordsByStage(S0): ${wordsList.length} Wörter in Kategorie, ${userWordsMap.length} in user_words, ${result.length} in Stage 0');
      
      return result;
    } else {
      // Stage 1-5: Wörter mit entsprechendem srs_stage
      final userWordsData = await _sb
          .from('user_words')
          .select('word_id,srs_stage,next_due_at,last_reviewed_at')
          .eq('user_id', user.id)
          .inFilter('word_id', wordIds)
          .eq('srs_stage', stage);

      final userWordsMap = <String, Map<String, dynamic>>{};
      for (var uw in (userWordsData as List).cast<Map<String, dynamic>>()) {
        userWordsMap[uw['word_id'] as String] = uw;
      }

      return wordsList
          .where((w) => userWordsMap.containsKey(w['id'] as String))
          .map((word) {
            final wordId = word['id'] as String;
            final userWord = userWordsMap[wordId]!;
            return WordUserView(
              id: wordId,
              text: word['text'] as String? ?? '',
              translation: word['translation'] as String? ?? '',
              level: word['level'] as String?,
              srsStage: (userWord['srs_stage'] as int?) ?? 0,
              nextDueAt: userWord['next_due_at'] != null
                  ? DateTime.parse(userWord['next_due_at'])
                  : null,
            );
          })
          .toList();
    }
  } catch (e) {
    debugPrint('Error fetching words by stage: $e');
    return [];
  }
}
