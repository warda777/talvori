import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/words/domain/word.dart';
// Wir brauchen nur die Typen für den Filter:
import 'package:talvori/features/words/application/word_list_controller.dart'
    show WordListFilter, WordFilterKind, SortMode;
import 'package:flutter/foundation.dart'; // für debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';
import 'dart:math' as math;
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

/// Ergebnis eines Review-RPC-Calls mit allen aktualisierten Feldern
class ReviewResult {
  final int stage;
  final DateTime? nextDueAt;
  final int streak;
  final double ef;
  final int lapses;
  final DateTime? lastReviewedAt;
  /// A-SRS: true wenn Wort gerade mastered wurde (is_mastered in DB)
  final bool isMastered;
  /// A-SRS: pass_count nach dem Review (0, 1 oder 2 in S5)
  final int passCount;

  ReviewResult({
    required this.stage,
    this.nextDueAt,
    required this.streak,
    required this.ef,
    required this.lapses,
    this.lastReviewedAt,
    this.isMastered = false,
    this.passCount = 0,
  });
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
  /// Alias für srsStage (JSON: srs_stage_user) – für Debug/Filter
  int get srsStageUser => srsStage;
  final DateTime? nextDueAt;
  final DateTime? userAddedAt;
  final bool isRequeue; // ✅ Requeue-Flag
  final int streak; // ✅ Streak für Link/Bounce-Berechnung
  final int passCount; // ✅ A-SRS: pass_count für Bounce-Logik (S1=2, S2=3, S3=3, S4=4, S5=5)

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
    this.isRequeue = false,
    this.streak = 0,
    this.passCount = 0,
  });

  /// rawStage: Keine Normalisierung (0 bleibt 0). Logik = rawStage, Display später separat.
  static int _rawStage(Map<String, dynamic> j) {
    final v = j['srs_stage'] ?? j['out_srs_stage'] ?? j['srs_stage_user'];
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  WordUserView.fromJson(Map<String, dynamic> j)
      : id = (j['id'] as String?) ?? (j['word_id'] as String?) ?? '', // ✅ Unterstützt beide: v_words_user (id) und v_words_user_srs (word_id)
        text = (j['text'] as String?) ?? '',
        translation = (j['translation'] as String?) ?? '',
        level = j['level'] as String?,
        inMyWords = (j['in_my_words'] as bool?) ?? false,
        pickedUser = (j['picked_user'] as bool?) ?? false,
        favoriteUser = (j['favorite_user'] as bool?) ?? false,
        srsStage = WordUserView._rawStage(j), // rawStage: srs_stage ?? out_srs_stage ?? srs_stage_user ?? 0
        nextDueAt = j['next_due_at_user'] != null
            ? DateTime.parse(j['next_due_at_user'])
            : null,
        userAddedAt = j['user_added_at'] != null
            ? DateTime.parse(j['user_added_at'])
            : null,
        // ✅ isRequeue: Default auf false, da is_requeue und show_after nicht mehr im Select sind (Fehler 42703 vermeiden)
        isRequeue = (j['is_requeue'] as bool?) ?? false,
        // ✅ Streak für Link/Bounce-Berechnung
        streak = (j['streak'] as int?) ?? 0,
        // ✅ A-SRS pass_count (Fallback auf streak wenn nicht vorhanden)
        passCount = (j['pass_count'] as int?) ?? (j['streak'] as int?) ?? 0;
  
  WordUserView copyWith({
    int? srsStage,
    DateTime? nextDueAt,
    bool setDueNull = false,
    bool? isRequeue,
    int? streak,
    int? passCount,
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
      isRequeue: isRequeue ?? this.isRequeue,
      streak: streak ?? this.streak,
      passCount: passCount ?? this.passCount,
    );
  }
}

final _sb = Supabase.instance.client;

// ✅ Sequenznummer für stale response protection
int _reviewSeq = 0;

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





/// Prüft SRS-Contracts nach einem Review
/// Contract-Regeln:
/// 1. DB == RPC (Server Source of Truth)
/// 2. Local == Server (wenn localAppliedStage übergeben)
/// 3. Keine Fake-Progress-Änderung bei oldStage == newStage
/// 4. Stage-Summen bleiben konsistent
void assertSrsContractsAfterReview({
  required int rpcStage,
  required DateTime? rpcNextDueAt,
  required int? dbStage,
  required DateTime? dbNextDueAt,
  int? oldStage,
  int? localAppliedStage,
  List<int>? localStagesBefore,
  List<int>? localStagesAfter,
  int? totalWordsInCategory,
  String? wordId,
  String? categoryId,
  String? traceId,
}) {
  final errors = <String>[];
  
  // Contract 1: DB == RPC (Server Source of Truth)
  if (dbStage != null) {
    if (dbStage != rpcStage) {
      errors.add('CONTRACT VIOLATION 1: DB stage ($dbStage) != RPC stage ($rpcStage)');
    }
    
    // Prüfe next_due_at (mit Toleranz für Millisekunden-Unterschiede)
    if (dbNextDueAt != null && rpcNextDueAt != null) {
      final diff = dbNextDueAt.difference(rpcNextDueAt).abs();
      if (diff.inSeconds > 1) {
        errors.add('CONTRACT VIOLATION 1: DB next_due_at ($dbNextDueAt) != RPC next_due_at ($rpcNextDueAt) [diff: ${diff.inSeconds}s]');
      }
    } else if (dbNextDueAt != rpcNextDueAt) {
      errors.add('CONTRACT VIOLATION 1: DB next_due_at ($dbNextDueAt) != RPC next_due_at ($rpcNextDueAt) [one is null]');
    }
  }
  
  // Contract 2: Local == Server (wenn localAppliedStage übergeben)
  if (localAppliedStage != null) {
    if (localAppliedStage != rpcStage) {
      errors.add('CONTRACT VIOLATION 2: Local applied stage ($localAppliedStage) != RPC stage ($rpcStage)');
    }
  }
  
  // Contract 3: Keine Fake-Progress-Änderung bei oldStage == newStage
  if (oldStage != null && oldStage == rpcStage && localStagesBefore != null && localStagesAfter != null) {
    // Wenn Stage sich nicht geändert hat, dürfen sich auch die Counts nicht ändern
    if (localStagesBefore.length == localStagesAfter.length) {
      for (int i = 0; i < localStagesBefore.length; i++) {
        if (localStagesBefore[i] != localStagesAfter[i]) {
          errors.add('CONTRACT VIOLATION 3: Stage unchanged (old=$oldStage, new=$rpcStage) but stages[$i] changed: ${localStagesBefore[i]} -> ${localStagesAfter[i]}');
        }
      }
    }
  }
  
  // Contract 4: Stage-Summen bleiben konsistent
  if (localStagesAfter != null && totalWordsInCategory != null) {
    final sum = localStagesAfter.fold<int>(0, (sum, count) => sum + count);
    if (sum != totalWordsInCategory) {
      errors.add('CONTRACT VIOLATION 4: Sum of stages ($sum) != totalWordsInCategory ($totalWordsInCategory)');
    }
  }
  
  // Logge alle Contract-Verletzungen
  if (errors.isNotEmpty) {
    debugPrint('🚨 SRS CONTRACT VIOLATIONS [$traceId ?? "N/A"]:');
    for (final error in errors) {
      debugPrint('  ❌ $error');
    }
    debugPrint('  Context: wordId=$wordId, categoryId=$categoryId, oldStage=$oldStage, rpcStage=$rpcStage');
    if (localStagesBefore != null) {
      debugPrint('  Local stages before: $localStagesBefore');
    }
    if (localStagesAfter != null) {
      debugPrint('  Local stages after: $localStagesAfter');
    }
  } else {
    debugPrint('✅ SRS CONTRACTS OK [${traceId ?? "N/A"}]: wordId=$wordId, oldStage=$oldStage -> rpcStage=$rpcStage');
  }
}

/// Review-Ergebnis senden (true = richtig, false = falsch)
Future<ReviewResult> submitReview(
  String categoryId,     // ✅ NEU
  String wordId,
  bool correct, {
  required SrsSystem srsSystem,
  int? oldStage, // ✅ Optional: oldStage für Tracing
}) async {
  debugPrint('🧪 submitReview: srsSystem=$srsSystem  correct=$correct  cat=$categoryId  word=$wordId');
  
  // ✅ Sequenznummer für stale response protection
  final seq = ++_reviewSeq;
  
  // ✅ TIME + HYBRID:
  // Beide verwenden TIME-basierte Review-Logik, aber persistieren in user_word_srs mit unterschiedlichem mode.
  if (srsSystem == SrsSystem.time || srsSystem == SrsSystem.hybrid) {
    final isHybrid = srsSystem == SrsSystem.hybrid;
    final rpcName = isHybrid ? 'fn_user_review_hybrid_mode' : 'fn_user_review_time_mode';
    final dbMode = isHybrid ? 'hybrid' : 'time';

    debugPrint('🧪 submitReview: CALL $rpcName (${isHybrid ? "HYBRID" : "TIME"})');

    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('submitReview(${isHybrid ? "HYBRID" : "TIME"}): No current user');
    }

    final rows = await _sb.rpc(rpcName, params: {
      'p_word': wordId,
      'p_category': categoryId,
      'p_result': correct,
      'p_user': userId,
    });

    // ✅ Stale response check
    if (seq != _reviewSeq) {
      throw StateError('Stale review response ignored (T-SRS)');
    }

    // ✅ Robustes Parsing: Map ODER List unterstützen
    Map<String, dynamic> row;
    if (rows is List) {
      row = (rows as List).cast<Map<String, dynamic>>().first;
    } else if (rows is Map) {
      row = Map<String, dynamic>.from(rows as Map);
    } else {
      throw StateError('Unexpected RPC response type: ${rows.runtimeType}');
    }

    final stage = (row['srs_stage'] as int?) ?? 0;
    final dueStr = row['next_due_at'] as String?;
    final due = dueStr != null ? DateTime.parse(dueStr) : null;
    
      // ✅ POST-RPC DB CHECK: Was wurde tatsächlich in der DB gespeichert? (TIME/HYBRID)
    // ✅ WICHTIG: Lese zusätzliche Felder aus DB für vollständige ReviewResult
    int streak = 0;
    double ef = 2.5;
    int lapses = 0;
    DateTime? lastReviewedAt;
    
    try {
      // Scoped read: Immer user_id + word_id + category_id + mode (Vollschlüssel)
      final dbRows = await _sb
          .from('user_word_srs')
          .select('user_id, word_id, category_id, mode, stage, ef, streak, lapses, last_reviewed_at, next_due_at, created_at, updated_at, pass_count, ever_enrolled, is_mastered, added_to_category_at')
          .eq('user_id', userId)
          .eq('word_id', wordId)
          .eq('category_id', categoryId)
          .eq('mode', dbMode)
          .maybeSingle();
      
      debugPrint('--- POST-RPC DB CHECK (scoped) [${isHybrid ? "HYBRID" : "T-SRS"}] ---');
      debugPrint('dbRows=$dbRows');
      
      if (dbRows != null) {
        streak = (dbRows['streak'] as int?) ?? 0;
        ef = (dbRows['ef'] as num?)?.toDouble() ?? 2.5;
        lapses = (dbRows['lapses'] as int?) ?? 0;
        final lastReviewedStr = dbRows['last_reviewed_at'] as String?;
        lastReviewedAt = lastReviewedStr != null ? DateTime.parse(lastReviewedStr) : null;
        
        debugPrint('db_stage=${dbRows['stage']}');
        debugPrint('db_streak=$streak');
        debugPrint('db_ef=$ef');
        debugPrint('db_lapses=$lapses');
        debugPrint('db_next_due_at=${dbRows['next_due_at']}');
        debugPrint('db_category_id=${dbRows['category_id']}');
        debugPrint('db_mode=${dbRows['mode']}');
        debugPrint('RPC_srs_stage=$stage');
        debugPrint('RPC_next_due_at=$due');
        
        // Vergleich: Stimmen RPC-Response und DB überein?
        final dbStage = (dbRows['stage'] as int?) ?? 0;
        final dbNextDueAtStr = dbRows['next_due_at'] as String?;
        final dbNextDueAt = dbNextDueAtStr != null ? DateTime.parse(dbNextDueAtStr) : null;
        
        if (dbStage != stage) {
          debugPrint('⚠️ MISMATCH: RPC sagt stage=$stage, DB hat stage=$dbStage');
        }
        
        // ✅ Contract-Assertion: DB == RPC (Contract 1)
        assertSrsContractsAfterReview(
          rpcStage: stage,
          rpcNextDueAt: due,
          dbStage: dbStage,
          dbNextDueAt: dbNextDueAt,
          oldStage: oldStage,
          wordId: wordId,
          categoryId: categoryId,
          traceId: isHybrid ? 'HYBRID' : 'T-SRS',
        );
      } else {
        debugPrint('⚠️ DB CHECK: Keine Zeile gefunden für user_id=$userId, word_id=$wordId, category_id=$categoryId');
        // Auch ohne DB-Row Contract 1 prüfen (mit null-Werten)
        assertSrsContractsAfterReview(
          rpcStage: stage,
          rpcNextDueAt: due,
          dbStage: null,
          dbNextDueAt: null,
          oldStage: oldStage,
          wordId: wordId,
          categoryId: categoryId,
          traceId: isHybrid ? 'HYBRID' : 'T-SRS',
        );
      }
    } catch (e) {
      debugPrint('⚠️ DB CHECK ERROR: $e');
      // Weiter machen, auch wenn DB-Check fehlschlägt
      // Contract-Assertion trotzdem aufrufen (mit null DB-Werten)
      assertSrsContractsAfterReview(
        rpcStage: stage,
        rpcNextDueAt: due,
        dbStage: null,
        dbNextDueAt: null,
        oldStage: oldStage,
        wordId: wordId,
        categoryId: categoryId,
        traceId: isHybrid ? 'HYBRID' : 'T-SRS',
      );
    }

    return ReviewResult(
      stage: stage,
      nextDueAt: due,
      streak: streak,
      ef: ef,
      lapses: lapses,
      lastReviewedAt: lastReviewedAt,
      passCount: 0, // T-SRS hat kein pass_count
    );
  } else {
    // A-SRS / Hybrid: Verwende fn_user_review_mode
  final modeStr = switch (srsSystem) {
    SrsSystem.adaptive => 'adaptive',
    SrsSystem.hybrid => 'hybrid',
      SrsSystem.time => throw StateError('time should not reach here'),
    };

    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('User not authenticated');
    }
    
    // ✅ Trace-ID für mehrere Calls auseinanderhalten
    final traceId = DateTime.now().millisecondsSinceEpoch.toString().substring(8);
    
    // ✅ Direkt vor dem RPC: Input + oldStage loggen
    // Hinweis: oldStage muss aus dem aktuellen Wort geholt werden (wird vom Caller übergeben oder hier geholt)
    debugPrint('--- fn_user_review_mode TRACE (REQUEST) [$traceId] ---');
    debugPrint('oldStage=${oldStage ?? 'N/A'}');
    debugPrint('user_id=$userId');
    debugPrint('word_id=$wordId');
    debugPrint('category_id=$categoryId');
    debugPrint('modeStr=$modeStr');
    debugPrint('correct=$correct');
    
    // ✅ RPC-Call mit try/catch umklammern und Output roh loggen
    try {
      final params = {
        'p_category': categoryId,
    'p_mode': modeStr,
        'p_result': correct,
        'p_user': userId,
        'p_word': wordId,
      };
      
      debugPrint('RPC params=$params');
      
      // ✅ PRE-RPC DB CHECK: Zustand VOR dem Review lesen
      try {
        final preRpcCheck = await _sb
            .from('user_word_srs')
            .select('user_id, word_id, category_id, mode, stage, ef, streak, lapses, last_reviewed_at, next_due_at, created_at, updated_at, pass_count, ever_enrolled, is_mastered, added_to_category_at')
            .eq('user_id', userId)
            .eq('word_id', wordId)
            .eq('category_id', categoryId)
            .eq('mode', modeStr)
            .maybeSingle();
        
        debugPrint('--- PRE-RPC DB CHECK [$traceId] ---');
        debugPrint('preRpcCheck=$preRpcCheck');
        if (preRpcCheck != null) {
          debugPrint('pre_stage=${preRpcCheck['stage']}');
          debugPrint('pre_pass_count=${preRpcCheck['pass_count']}');
          debugPrint('pre_streak=${preRpcCheck['streak']}');
          debugPrint('pre_ef=${preRpcCheck['ef']}');
          debugPrint('pre_lapses=${preRpcCheck['lapses']}');
        } else {
          debugPrint('⚠️ PRE-RPC: Keine Zeile gefunden für user_id=$userId, word_id=$wordId, category_id=$categoryId, mode=$modeStr');
        }
      } catch (e) {
        debugPrint('⚠️ PRE-RPC DB CHECK ERROR: $e');
        // Weiter machen, auch wenn PRE-RPC-Check fehlschlägt
      }
      
      final rows = await _sb.rpc('fn_user_review_mode', params: params);

      // ✅ Stale response check
      if (seq != _reviewSeq) {
        throw StateError('Stale review response ignored (A-SRS/Hybrid)');
      }

      debugPrint('--- fn_user_review_mode TRACE (RESPONSE) [$traceId] ---');
      debugPrint('raw=${rows.toString()}');

      // ✅ Robustes Parsing: Map ODER List unterstützen
      Map<String, dynamic> row;
      if (rows is List) {
        row = (rows as List).cast<Map<String, dynamic>>().first;
      } else if (rows is Map) {
        row = Map<String, dynamic>.from(rows as Map);
      } else {
        throw StateError('Unexpected RPC response type: ${rows.runtimeType}');
      }

  final stage = (row['srs_stage'] as int?) ?? 0;
  final dueStr = row['next_due_at'] as String?;
      final due = dueStr != null ? DateTime.parse(dueStr) : null;
      
      debugPrint('--- fn_user_review_mode TRACE (PARSED) [$traceId] ---');
      debugPrint('srs_stage=$stage');
      debugPrint('next_due_at=$due');
      
      // ✅ POST-RPC DB CHECK: Was wurde tatsächlich in der DB gespeichert?
      // ✅ WICHTIG: Lese zusätzliche Felder aus DB für vollständige ReviewResult
      int streak = 0;
      double ef = 2.5;
      int lapses = 0;
      int passCount = 0;
      DateTime? lastReviewedAt;
      bool isMastered = false;
      
    try {
      // ✅ DB CHECK: Immer user_id + word_id + category_id + mode (Vollschlüssel)
      // Verhindert "multiple (or no) rows returned" bei .maybeSingle()
      final dbRows = await _sb
          .from('user_word_srs')
          .select('user_id, word_id, category_id, mode, stage, ef, streak, lapses, last_reviewed_at, next_due_at, created_at, updated_at, pass_count, ever_enrolled, is_mastered, added_to_category_at')
          .eq('user_id', userId)
          .eq('word_id', wordId)
          .eq('category_id', categoryId)
          .eq('mode', modeStr)
          .maybeSingle();
      
      debugPrint('--- POST-RPC DB CHECK [$traceId] ---');
      debugPrint('dbRows=$dbRows');
      
      if (dbRows != null) {
        streak = (dbRows['streak'] as int?) ?? 0;
        ef = (dbRows['ef'] as num?)?.toDouble() ?? 2.5;
        lapses = (dbRows['lapses'] as int?) ?? 0;
        final lastReviewedStr = dbRows['last_reviewed_at'] as String?;
        lastReviewedAt = lastReviewedStr != null ? DateTime.parse(lastReviewedStr) : null;
        
        debugPrint('db_stage=${dbRows['stage']}');
        debugPrint('db_pass_count=${dbRows['pass_count']}');
        debugPrint('db_is_mastered=${dbRows['is_mastered']}');
        debugPrint('db_streak=$streak');
        debugPrint('db_ef=$ef');
        debugPrint('db_lapses=$lapses');
        debugPrint('db_next_due_at=${dbRows['next_due_at']}');
        debugPrint('db_category_id=${dbRows['category_id']}');
        debugPrint('db_mode=${dbRows['mode']}');
        debugPrint('RPC_srs_stage=$stage');
        debugPrint('RPC_next_due_at=$due');
        
        // Vergleich: Stimmen RPC-Response und DB überein?
        final dbStage = (dbRows['stage'] as int?) ?? 0;
        if (dbStage != stage) {
          debugPrint('⚠️ MISMATCH: RPC sagt stage=$stage, DB hat stage=$dbStage');
        }
        isMastered = (dbRows['is_mastered'] as bool? ?? false);
        passCount = (dbRows['pass_count'] as int?) ?? 0;
      } else {
        debugPrint('⚠️ DB CHECK: Keine Zeile gefunden für user_id=$userId, word_id=$wordId, category_id=$categoryId');
      }
    } catch (e) {
      debugPrint('⚠️ DB CHECK ERROR: $e');
      // Weiter machen, auch wenn DB-Check fehlschlägt
    }
      
      return ReviewResult(
        stage: stage,
        nextDueAt: due,
        streak: streak,
        ef: ef,
        lapses: lapses,
        lastReviewedAt: lastReviewedAt,
        isMastered: isMastered,
        passCount: passCount,
      );
    } catch (e, st) {
      debugPrint('--- fn_user_review_mode TRACE (ERROR) [$traceId] ---');
      debugPrint(e.toString());
      debugPrint(st.toString());
      rethrow;
    }
  }
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

  factory CategoryProgress.fromRow(Map<String, dynamic> r) {
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
}

class SupabaseWordRepository {
  final _sb = Supabase.instance.client;

  // Device-ID und Sequenznummer für deterministische Sync-Logik
  static const String _kDeviceIdKey = 'talvori_device_id';
  static const String _kDeviceSeqKey = 'talvori_device_seq';
  static const String _kLastUpdatedAtKey = 'talvori_last_updated_at';

  /// Stellt sicher, dass Progress-Rows für alle Wörter einer Kategorie existieren
  /// Gibt die Anzahl der erzeugten/aktualisierten Rows zurück
  Future<int> ensureWordProgressForCategory(
    String categoryId, {
    required SrsSystem srsSystem,
  }) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('ensureWordProgressForCategory: No current user');
    }

    // mode string: 'adaptive' | 'hybrid' | 'time'
    final modeStr = srsSystem.name;

    // device_id / device_seq / updated_at (minimal, aber deterministisch-monoton)
    final deviceId = await _getOrCreateDeviceId();
    final deviceSeq = await _nextDeviceSeq();
    final updatedAt = await _nextLogicalUpdatedAt();

    final res = await _sb.rpc(
      'fn_wp_ensure_category_progress',
      params: {
        'p_cat': categoryId,
        'p_mode': modeStr,
        'p_user': userId,
        'p_device_id': deviceId,
        'p_device_seq': deviceSeq,
        'p_updated_at': updatedAt.toIso8601String(),
      },
    );

    // Supabase kann int oder num zurückgeben
    if (res is int) return res;
    if (res is num) return res.toInt();
    throw StateError(
      'ensureWordProgressForCategory: unexpected result ${res.runtimeType}: $res',
    );
  }

  /// Stellt sicher, dass Progress-Rows für alle Kategorien existieren
  /// Gibt die Anzahl der erzeugten/aktualisierten Rows zurück
  Future<int> ensureWordProgressForAllCategories({
    required SrsSystem srsSystem,
  }) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('ensureWordProgressForAllCategories: No current user');
    }

    final modeStr = srsSystem.name;
    final deviceId = await _getOrCreateDeviceId();
    final deviceSeq = await _nextDeviceSeq();
    final updatedAt = await _nextLogicalUpdatedAt();

    final res = await _sb.rpc(
      'fn_wp_ensure_all_progress',
      params: {
        'p_mode': modeStr,
        'p_user': userId,
        'p_device_id': deviceId,
        'p_device_seq': deviceSeq,
        'p_updated_at': updatedAt.toIso8601String(),
      },
    );

    if (res is int) return res;
    if (res is num) return res.toInt();
    throw StateError(
      'ensureWordProgressForAllCategories: unexpected result ${res.runtimeType}: $res',
    );
  }

  /// Kategorie-Progress (Stage-Zahlen, total, dueToday, newTotal)
Future<CategoryProgress> fetchCategoryProgress(
  String categoryId, {
  required SrsSystem srsSystem,
}) async {
  debugPrint('📊 fetchCategoryProgress: cat=$categoryId srs=$srsSystem');

  // Mode-String exakt wie im DB-Enum
  final modeStr = srsSystem.name; // 'time' | 'adaptive' | 'hybrid'

  final userId = _sb.auth.currentUser?.id;
  if (userId == null) {
    throw StateError('fetchCategoryProgress: No current user');
  }

  final res = await _sb.rpc('fn_user_category_progress', params: {
    'p_category': categoryId,
    'p_mode': modeStr, // "adaptive"
    'p_user': userId,  // optional, aber konsistent zu deinen anderen RPCs
  });

  final row = (res as List).first as Map<String, dynamic>;
  final total = row['total'] as int;
  final stages = (row['stages'] as List).map((e) => (e as num).toInt()).toList();
  final dueToday = (row['due_today'] as num?)?.toInt() ?? 0;

  // newTotal ist normalerweise stages[0] (Stage 0)
  final newTotal = stages.isNotEmpty ? stages[0] : 0;

  final prog = CategoryProgress(
    total: total,
    stages: stages.length == 6 ? stages : List.filled(6, 0),
    dueToday: dueToday,
    newTotal: newTotal,
  );

  debugPrint(
    '📥 fetchCategoryProgress RESULT → '
    'cat=$categoryId '
    'mode=$modeStr '
    'total=$total '
    'stages=$stages '
    'dueToday=$dueToday',
  );

  return prog;
}

  /// Lern-Queue (alle Wörter der Kategorie – Größe dynamisch aus Progress)
  /// ❌ Für A-SRS wird fetchLearnQueueAdaptive verwendet
  Future<List<WordUserView>> fetchLearnQueueAll(
    String categoryId, {
    required SrsSystem srsSystem,
  }) async {
    // ✅ A-SRS: Diese Funktion darf für A-SRS NICHT verwendet werden
    // Verwende stattdessen fetchAdaptiveQueue mit limit
    if (srsSystem == SrsSystem.adaptive) {
      throw StateError(
        'fetchLearnQueueAll darf für A-SRS nicht verwendet werden. '
        'Verwende stattdessen fetchAdaptiveQueue(userId, categoryId, limit: 20)'
      );
    }

    // T-SRS/Hybrid: Alte Funktion verwenden
    final prog = await fetchCategoryProgress(categoryId, srsSystem: srsSystem);
    final take = (prog.total > 0) ? prog.total : 2000; // Fallback

    final res = await _sb.rpc('fn_user_learn_queue', params: {
      'cat': categoryId,
      'take': take,
    });

    final list = (res as List).cast<Map<String, dynamic>>();
    return list.map((j) => WordUserView.fromJson(j)).toList();
  }

  /// A-SRS Adaptive Queue (Phase 1: S1-S4, Phase 2: Final Round nur S5)
  /// Nutzt fn_fetch_adaptive_queue – Server entscheidet Phase 1 vs Phase 2
  Future<List<WordUserView>> fetchAdaptiveQueue({
    required String userId,
    required String categoryId,
    required int limit,
  }) async {
    debugPrint('📥 fetchAdaptiveQueue: cat=$categoryId limit=$limit user=$userId');

    final res = await _sb.rpc(
      'fn_fetch_adaptive_queue',
      params: {
        'p_user': userId,
        'p_category': categoryId,
        'p_limit': limit,
      },
    );

    final rows = (res as List).cast<Map<String, dynamic>>();
    // RPC liefert: word_id, stage, pass_count, is_mastered
    final ids = rows
        .map((r) => (r['word_id'] as String?))
        .whereType<String>()
        .toList();

    if (ids.isEmpty) {
      debugPrint('⚠️ fetchAdaptiveQueue: Keine Rows zurückgegeben');
      return [];
    }

    debugPrint('📥 fetchAdaptiveQueue: RPC lieferte ${ids.length} IDs');

    // Details nachladen aus v_words_user_srs
    final data = await _sb
        .from('v_words_user_srs')
        .select('word_id,text,translation,level,'
            'in_my_words,favorite_user,picked_user,'
            'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
            'ef,streak,pass_count,lapses')
        .eq('category_id', categoryId)
        .eq('srs_mode', 'adaptive')
        .inFilter('word_id', ids);

    final viewMap = {
      for (final j in (data as List).cast<Map<String, dynamic>>())
        (j['word_id'] as String): j
    };
    final rpcMap = <String, Map<String, dynamic>>{};
    for (final r in rows) {
      final id = r['word_id'] as String?;
      if (id != null) rpcMap[id] = r;
    }

    var ordered = <WordUserView>[];
    for (final id in ids) {
      final viewRow = viewMap[id];
      final rpcRow = rpcMap[id];
      if (viewRow != null && rpcRow != null) {
        final merged = Map<String, dynamic>.from(viewRow);
        merged['srs_stage'] = rpcRow['stage'] as int;
        merged['pass_count'] = rpcRow['pass_count'] as int;
        ordered.add(WordUserView.fromJson(merged));
      } else if (viewRow != null) {
        ordered.add(WordUserView.fromJson(viewRow));
      } else {
        debugPrint('⚠️ fetchAdaptiveQueue: Wort-ID $id nicht in v_words_user_srs gefunden!');
      }
    }

    if (ordered.isEmpty && ids.isNotEmpty) {
      debugPrint('📥 fetchAdaptiveQueue: View-Fallback → _fetchWordDetailsDirect');
      ordered = await _fetchWordDetailsDirect(ids: ids, categoryId: categoryId, userId: userId);
      // RPC stage/pass_count in Fallback-Ergebnis übernehmen
      final rpcById = {for (final r in rows) (r['word_id'] as String): r};
      for (var i = 0; i < ordered.length; i++) {
        final rpc = rpcById[ordered[i].id];
        if (rpc != null) {
          ordered[i] = ordered[i].copyWith(
            srsStage: rpc['stage'] as int,
            passCount: rpc['pass_count'] as int,
          );
        }
      }
    }

    debugPrint('📥 fetchAdaptiveQueue: ordered.length=${ordered.length}');
    return ordered;
  }

  /// Bootstrap: Wenn RPC leer liefert, Wörter direkt aus Kategorie laden (nach fn_enroll)
  Future<List<WordUserView>> fetchAdaptiveQueueBootstrap({
    required String userId,
    required String categoryId,
    int limit = 80,
  }) async {
    debugPrint('📥 fetchAdaptiveQueueBootstrap: cat=$categoryId limit=$limit');
    try {
      final wcData = await _sb
          .from('word_categories')
          .select('word_id')
          .eq('category_id', categoryId)
          .limit(limit);
      final wordIds = (wcData as List)
          .cast<Map<String, dynamic>>()
          .map((r) => r['word_id'] as String)
          .toList();
      debugPrint('📥 fetchAdaptiveQueueBootstrap: word_categories lieferte ${wordIds.length} word_ids');
      if (wordIds.isEmpty) {
        debugPrint('⚠️ fetchAdaptiveQueueBootstrap: word_categories LEER für category_id=$categoryId');
        return [];
      }
      final uwsData = await _sb
          .from('user_word_srs')
          .select('word_id, stage, next_due_at')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .eq('mode', 'adaptive')
          .inFilter('word_id', wordIds);
      final uwsMap = {
        for (final r in (uwsData as List).cast<Map<String, dynamic>>())
          (r['word_id'] as String): r
      };
      final wordsData = await _sb
          .from('words')
          .select('id, text, translation, level')
          .inFilter('id', wordIds);
      final result = <WordUserView>[];
      for (final r in (wordsData as List).cast<Map<String, dynamic>>()) {
        final id = r['id'] as String;
        final uws = uwsMap[id];
        result.add(WordUserView(
          id: id,
          text: (r['text'] as String?) ?? '',
          translation: (r['translation'] as String?) ?? '',
          level: r['level'] as String?,
          inMyWords: false,
          pickedUser: false,
          favoriteUser: false,
          srsStage: (uws?['stage'] as int?) ?? 0,
          nextDueAt: uws?['next_due_at'] != null
              ? DateTime.parse(uws!['next_due_at'])
              : null,
          userAddedAt: null,
          isRequeue: false,
          streak: 0,
        ));
      }
      debugPrint('📥 fetchAdaptiveQueueBootstrap: ${result.length} Wörter geladen');
      return result;
    } catch (e, st) {
      debugPrint('⚠️ fetchAdaptiveQueueBootstrap FEHLER: $e');
      debugPrint('⚠️ StackTrace: $st');
      return [];
    }
  }

  /// Fallback: Wörter direkt aus words + user_word_srs laden (wenn v_words_user_srs leer liefert)
  Future<List<WordUserView>> _fetchWordDetailsDirect({
    required List<String> ids,
    required String categoryId,
    required String userId,
  }) async {
    if (ids.isEmpty) return [];
    try {
      final wordsData = await _sb
          .from('words')
          .select('id, text, translation, level')
          .inFilter('id', ids);
      final srsData = await _sb
          .from('user_word_srs')
          .select('word_id, stage, next_due_at')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .eq('mode', 'adaptive')
          .inFilter('word_id', ids);

      final wordsMap = {
        for (final r in (wordsData as List).cast<Map<String, dynamic>>())
          (r['id'] as String): r
      };
      final srsMap = {
        for (final r in (srsData as List).cast<Map<String, dynamic>>())
          (r['word_id'] as String): r
      };

      final ordered = <WordUserView>[];
      for (final id in ids) {
        final w = wordsMap[id];
        if (w == null) continue;
        final srs = srsMap[id];
        final stage = (srs?['stage'] as int?) ?? 0;
        final nextDue = srs?['next_due_at'] != null
            ? DateTime.parse(srs!['next_due_at'])
            : null;
        ordered.add(WordUserView(
          id: id,
          text: (w['text'] as String?) ?? '',
          translation: (w['translation'] as String?) ?? '',
          level: w['level'] as String?,
          inMyWords: false,
          pickedUser: false,
          favoriteUser: false,
          srsStage: stage,
          nextDueAt: nextDue,
          userAddedAt: null,
          isRequeue: false,
          streak: 0,
        ));
      }
      return ordered;
    } catch (e) {
      debugPrint('⚠️ _fetchWordDetailsDirect: $e');
      return [];
    }
  }

  /// Lern-Queue für A-SRS (fn_get_adaptive_queue_due → fn_user_learn_queue_adaptive)
  Future<List<WordUserView>> fetchLearnQueueAdaptive(
    String categoryId, {
    int take = 2000,
  }) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('fetchLearnQueueAdaptive: No current user');
    }

    debugPrint('📥 fetchLearnQueueAdaptive: cat=$categoryId take=$take user=$userId');
    
    final res = await _sb.rpc(
      'fn_adaptive_queue_cli',
      params: {
        'category_id': categoryId,
        'user_id': userId,
        'take_limit': take,
      },
    );

    debugPrint('📥 fetchLearnQueueAdaptive: RPC response type=${res.runtimeType}, length=${res is List ? (res as List).length : 'N/A'}');
    
    final rows = (res as List).cast<Map<String, dynamic>>();
    // ✅ Log: Nach RPC-Call, Rows aus Supabase geladen
    debugPrint('🟦 _loadWords ROWS rows.length=${rows.length} firstKeys=${rows.isNotEmpty ? rows.first.keys.toList() : []}');
    debugPrint('📥 fetchLearnQueueAdaptive: rows.length=${rows.length}');
    
    if (rows.isEmpty) {
      debugPrint('⚠️ fetchLearnQueueAdaptive: Keine Rows zurückgegeben!');
      return [];
    }
    
    // Debug: Erste Row anzeigen
    if (rows.isNotEmpty) {
      debugPrint('📥 fetchLearnQueueAdaptive: Erste Row Keys=${rows.first.keys.toList()}');
      debugPrint('📥 fetchLearnQueueAdaptive: Erste Row Values=${rows.first.values.take(3).toList()}');
    }
    
    final ids = rows
        .map((r) => r['word_id'] as String?)
        .whereType<String>()
        .toList();

    debugPrint('📥 fetchLearnQueueAdaptive: ids.length=${ids.length}, erste IDs=${ids.take(5).toList()}');
    
    if (ids.isEmpty) {
      debugPrint('⚠️ fetchLearnQueueAdaptive: Keine IDs gefunden!');
      return [];
    }

    // Details nachladen (UI bleibt dumm, DB bleibt Logik)
    // ✅ v_words_user_srs verwendet word_id statt id, srs_mode für Filter
    final modeStr = 'adaptive'; // fetchLearnQueueAdaptive ist A-SRS, daher fix
    final data = await _sb
        .from('v_words_user_srs')
        .select('word_id,text,translation,level,'
            'in_my_words,favorite_user,picked_user,'
            'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
            'ef,streak,pass_count,lapses')
        .eq('category_id', categoryId)
        .eq('srs_mode', modeStr)
        .inFilter('word_id', ids);
    
    debugPrint('📥 fetchLearnQueueAdaptive: data.length=${(data as List).length}');

    // Optional: Reihenfolge wie Queue wiederherstellen
    // ✅ Mapping: word_id -> id für WordUserView (word_id ist String, kein nullable)
    final map = {
      for (final j in (data as List).cast<Map<String, dynamic>>())
        (j['word_id'] as String): j
    };

    final ordered = <WordUserView>[];
    for (final id in ids) {
      final j = map[id];
      if (j != null) {
        ordered.add(WordUserView.fromJson(j));
      } else {
        debugPrint('⚠️ fetchLearnQueueAdaptive: Wort-ID $id nicht in v_words_user_srs gefunden!');
      }
    }

    debugPrint('📥 fetchLearnQueueAdaptive: ordered.length=${ordered.length}, erste Wörter=${ordered.take(3).map((w) => w.text).toList()}');
    return ordered;
  }

  /// Lern-Queue für Learn Mode (mode-aware über DB)
  /// ❌ Für A-SRS darf diese Funktion NICHT verwendet werden - verwende stattdessen fetchAdaptiveQueue
  Future<List<WordUserView>> fetchLearnQueueForMode(
    String categoryId, {
    required LevelSelectionMode mode,
    required SrsSystem srsSystem,
    int? singleStage, // 1..5 (nur relevant bei single)
  }) async {
    // ✅ A-SRS: Diese Funktion darf für A-SRS NICHT verwendet werden
    // Verwende stattdessen fetchAdaptiveQueue mit limit
    if (srsSystem == SrsSystem.adaptive) {
      throw StateError(
        'fetchLearnQueueForMode darf für A-SRS nicht verwendet werden. '
        'Verwende stattdessen fetchAdaptiveQueue(userId, categoryId, limit: 20)'
      );
    }

    // T-SRS/Hybrid: Alte Funktionen verwenden
    final res = await _sb.rpc('fetch_learn_queue_for_mode', params: {
      'p_category_id': categoryId,
      'p_mode': srsSystem.name,     // 'time' | 'hybrid'
      'p_stage': mode == LevelSelectionMode.single ? singleStage : null,
      'p_limit': 2000,
    });

    final rows = (res as List).cast<Map<String, dynamic>>();
    final ids = rows
        .map((r) => r['word_id'] as String?)
        .whereType<String>()
        .toList();

    if (ids.isEmpty) return [];

    // Details nachladen (UI bleibt dumm, DB bleibt Logik)
    // ✅ v_words_user_srs verwendet word_id statt id, srs_mode für Filter
    final modeStr = srsSystem.name; // 'time' | 'hybrid'
    // Wichtig: IDs können groß sein (p_limit=2000). inFilter(...) ohne Chunking führt leicht zu 400 (Query zu lang).
    const chunkSize = 400;
    final map = <String, Map<String, dynamic>>{};
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.skip(i).take(chunkSize).toList();
      final data = await _sb
          .from('v_words_user_srs')
          .select('word_id,text,translation,level,'
              'in_my_words,favorite_user,picked_user,'
              'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
              'ef,streak,pass_count,lapses')
          .eq('category_id', categoryId)
          .eq('srs_mode', modeStr)
          .inFilter('word_id', chunk);

      for (final j in (data as List).cast<Map<String, dynamic>>()) {
        map[(j['word_id'] as String)] = j;
      }
    }

    // Optional: Reihenfolge wie Queue wiederherstellen
    final ordered = <WordUserView>[];
    for (final id in ids) {
      final j = map[id];
      if (j != null) {
        ordered.add(WordUserView.fromJson(j));
      } else {
        debugPrint('⚠️ fetchLearnQueueForMode: Wort-ID $id nicht in v_words_user_srs gefunden!');
      }
    }

    return ordered;
  }

  /// Holt Wörter für eine spezifische Stage (für A-SRS Nachschub-Regel)
  /// Für A-SRS: Filtert nach last_queued_counter < refillCounter (Cooldown)
  Future<List<WordUserView>> fetchWordsForStage({
    required String categoryId,
    required int stage,
    required int limit,
    required SrsSystem srsSystem,
    int? refillCounter, // Optional: für A-SRS Cooldown-Filter
  }) async {
    if (srsSystem == SrsSystem.adaptive) {
      // A-SRS: Verwende RPC mit refillCounter-Filter
      final userId = _sb.auth.currentUser?.id;
      if (userId == null) return [];
      
      // Wenn refillCounter gegeben: Filter nach Cooldown
      if (refillCounter != null) {
        try {
          final res = await _sb.rpc(
            'fn_a_srs_fetch_words_for_stage',
            params: {
              'p_user': userId,
              'p_category': categoryId,
              'p_stage': stage,
              'p_limit': limit,
              'p_refill_counter': refillCounter,
            },
          );
          
          final rows = (res as List).cast<Map<String, dynamic>>();
          final ids = rows
              .map((r) => r['word_id'] as String?)
              .whereType<String>()
              .toList();
          
          if (ids.isEmpty) return [];
          
          // Details nachladen
          final data = await _sb
              .from('v_words_user_srs')
              .select('word_id,text,translation,level,'
                  'in_my_words,favorite_user,picked_user,'
                  'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
                  'ef,streak,pass_count,lapses')
              .eq('category_id', categoryId)
              .eq('srs_mode', 'adaptive')
              .inFilter('word_id', ids);
          
          final map = {
            for (final j in (data as List).cast<Map<String, dynamic>>())
              (j['word_id'] as String): j
          };
          
          final ordered = <WordUserView>[];
          for (final id in ids) {
            final j = map[id];
            if (j != null) ordered.add(WordUserView.fromJson(j));
          }
          
          return ordered;
        } catch (e) {
          debugPrint('⚠️ fetchWordsForStage (A-SRS mit refillCounter) Fehler: $e');
          // Fallback: ohne Cooldown-Filter
        }
      }
      
      // ❌ Fallback für A-SRS entfernt: fetchWordsForStage sollte für A-SRS nicht mehr verwendet werden
      // Verwende stattdessen fetchAdaptiveQueue mit limit
      throw StateError(
        'fetchWordsForStage Fallback für A-SRS nicht mehr unterstützt. '
        'Verwende stattdessen fetchAdaptiveQueue(userId, categoryId, limit: 20)'
      );
    } else {
      // T-SRS/Hybrid: Verwende fetch_learn_queue_for_mode mit singleStage
      final res = await _sb.rpc('fetch_learn_queue_for_mode', params: {
        'p_category_id': categoryId,
        'p_mode': srsSystem.name,
        'p_stage': stage,
        'p_limit': limit,
      });

      final rows = (res as List).cast<Map<String, dynamic>>();
      final ids = rows
          .map((r) => r['word_id'] as String?)
          .whereType<String>()
          .toList();

      if (ids.isEmpty) return [];

      final modeStr = srsSystem.name;
      final data = await _sb
          .from('v_words_user_srs')
          .select('word_id,text,translation,level,'
              'in_my_words,favorite_user,picked_user,'
              'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
              'ef,streak,pass_count,lapses')
          .eq('category_id', categoryId)
          .eq('srs_mode', modeStr)
          .inFilter('word_id', ids);

      final map = {
        for (final j in (data as List).cast<Map<String, dynamic>>())
          (j['word_id'] as String): j
      };

      final ordered = <WordUserView>[];
      for (final id in ids) {
        final j = map[id];
        if (j != null) ordered.add(WordUserView.fromJson(j));
      }

      return ordered;
    }
  }



  /// A-SRS: Einzelne Karte von S0 nach S1 enrollen (fn_a_srs_s0_correct)
  /// Wird bei korrektem Swipe auf S0-Karte aufgerufen.
  Future<({int stage, DateTime? nextDueAt})> enrollFromS0ToS1({
    required String userId,
    required String categoryId,
    required String wordId,
    required String mode,
  }) async {
    final rows = await _sb.rpc(
      'fn_a_srs_s0_correct',
      params: {
        'p_user': userId,
        'p_category': categoryId,
        'p_word': wordId,
      },
    );
    Map<String, dynamic> row;
    if (rows is List) {
      row = (rows as List).cast<Map<String, dynamic>>().first;
    } else if (rows is Map) {
      row = Map<String, dynamic>.from(rows as Map);
    } else {
      throw StateError('Unexpected RPC response type: ${rows.runtimeType}');
    }
    final stage = (row['srs_stage'] as int?) ?? 1;
    final dueStr = row['next_due_at'] as String?;
    final nextDueAt = dueStr != null ? DateTime.parse(dueStr) : null;
    return (stage: stage, nextDueAt: nextDueAt);
  }

  /// A-SRS Refill:
  /// 1) fehlende user_word_srs-Zeilen anlegen
  /// 2) genau 1 Wort von S0 nach S1 enrollen
  Future<int> refillAdaptiveEnroll({
    required String userId,
    required String categoryId,
  }) async {
    try {
      await _sb.rpc(
        'fn_enroll_user_category_mode',
        params: {
          'p_category_id': categoryId,
          'p_mode': 'adaptive',
          'p_user': userId,
        },
      );

      final res = await _sb.rpc(
        'fn_a_srs_refill_enroll',
        params: {
          'p_user': userId,
          'p_category': categoryId,
        },
      );

      final enrolled = (res as num?)?.toInt() ?? 0;
      debugPrint('✅ refillAdaptiveEnroll: enrolled=$enrolled');
      return enrolled;
    } catch (e) {
      debugPrint('⚠️ refillAdaptiveEnroll Fehler: $e');
      return 0;
    }
  }

  /// A-SRS: Kategorie-Progress zurücksetzen (alle Wörter → S0)
  Future<int> resetAdaptiveCategoryProgress(String categoryId) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Kein User eingeloggt');
    }

    final result = await _sb.rpc(
      'fn_a_srs_reset_category_progress',
      params: {
        'p_category_id': categoryId,
        'p_user': userId,
      },
    );

    return (result as num?)?.toInt() ?? 0;
  }

  /// A-SRS: Finale Phase starten (alle Wörter in S5 → Final Round)
  Future<void> startAdaptiveFinalPass({required String categoryId}) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) return;
    try {
      await _sb.rpc(
        'fn_a_srs_start_final_pass',
        params: {
          'p_category_id': categoryId,
          'p_user': userId,
        },
      );
    } catch (e) {
      debugPrint('⚠️ startAdaptiveFinalPass Fehler: $e');
    }
  }

  /// A-SRS Refill-Counter atomar erhöhen und zurückgeben
  /// Nutzt RPC-Funktion für atomare Operation
  Future<int> nextRefillCounter({
    required String userId,
    required String categoryId,
    required String mode, // 'adaptive'
  }) async {
    try {
      // Verwende RPC-Funktion für atomare Increment-Operation
      final res = await _sb.rpc(
        'fn_a_srs_next_refill_counter',
        params: {
          'p_user': userId,
          'p_category': categoryId,
          'p_mode': mode,
        },
      );
      
      // RPC gibt den neuen Counter-Wert zurück
      if (res is int) return res;
      if (res is num) return res.toInt();
      if (res is Map) {
        return (res['refill_counter'] as int?) ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint('⚠️ nextRefillCounter Fehler: $e');
      // Fallback: Versuche zu lesen
      try {
        final res = await _sb
            .from('a_refill_state')
            .select('refill_counter')
            .eq('user_id', userId)
            .eq('category_id', categoryId)
            .eq('mode', mode)
            .maybeSingle();
        return (res?['refill_counter'] as int?) ?? 0;
      } catch (_) {
        return 0;
      }
    }
  }

  /// Holt S0-Wörter für Refill mit Cooldown-Filter
  Future<List<WordUserView>> fetchS0ForRefill({
    required String userId,
    required String categoryId,
    required String mode, // 'adaptive'
    required int refillCounter,
    required int limit, // Contract: s0_count pro Refill (z.B. 6)
    required int overfetch,
  }) async {
    try {
      // Query mit LEFT JOIN auf a_deck_state für Cooldown-Filter
      final query = _sb
          .from('user_word_srs')
          .select('''
            word_id,
            srs_stage_user as srs_stage_user,
            next_due_at_user as next_due_at_user,
            created_at
          ''')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .eq('mode', mode)
          .eq('stage', 0) // Stage 0
          .eq('ever_enrolled', false) // ever_enrolled = false
          .eq('is_mastered', false) // is_mastered = false
          .order('created_at', ascending: true)
          .limit(overfetch);

      // Cooldown-Filter: Exclude words that were queued in this refill cycle
      // Wir müssen das in Dart machen, da Supabase keine komplexen JOINs mit Subqueries unterstützt
      final rows = await query;
      final wordIds = (rows as List)
          .cast<Map<String, dynamic>>()
          .map((r) => r['word_id'] as String?)
          .whereType<String>()
          .toList();

      if (wordIds.isEmpty) return [];

      // Prüfe Cooldown: Hole last_queued_counter für diese Wörter
      final deckStateRows = await _sb
          .from('a_deck_state')
          .select('word_id, last_queued_counter')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .eq('mode', mode)
          .inFilter('word_id', wordIds);

      final deckStateMap = {
        for (final row in (deckStateRows as List).cast<Map<String, dynamic>>())
          (row['word_id'] as String): (row['last_queued_counter'] as int?) ?? -1
      };

      // Filtere Wörter, die in diesem Refill bereits queued wurden
      final filteredIds = wordIds.where((id) {
        final lastQueued = deckStateMap[id] ?? -1;
        return lastQueued < refillCounter;
      }).take(limit).toList();

      if (filteredIds.isEmpty) return [];

      // Hole Details für die gefilterten Wörter
      final details = await _sb
          .from('v_words_user_srs')
          .select('word_id,text,translation,level,'
              'in_my_words,favorite_user,picked_user,'
              'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
              'ef,streak,pass_count,lapses')
          .eq('category_id', categoryId)
          .eq('srs_mode', mode)
          .inFilter('word_id', filteredIds);

      return (details as List)
          .cast<Map<String, dynamic>>()
          .map((j) => WordUserView.fromJson(j))
          .toList();
    } catch (e, st) {
      debugPrint('⚠️ fetchS0ForRefill Fehler: $e');
      debugPrint('⚠️ Stack: $st');
      return [];
    }
  }

  /// Markiert Wörter als "queued" für einen Refill-Zyklus
  /// Contract: last_queued_counter ist lokal-only (word_progress_deck_state)
  Future<void> markQueuedForRefill({
    required String userId,
    required String categoryId,
    required String mode, // 'adaptive'
    required int refillCounter,
    required List<String> wordIds,
  }) async {
    if (wordIds.isEmpty) return;

    final rows = wordIds.map((wid) => {
          'user_id': userId,
          'category_id': categoryId,
          'word_id': wid,
          'mode': mode,
          'last_queued_counter': refillCounter,
        }).toList();

    await Supabase.instance.client
        .from('word_progress_deck_state')
        .upsert(rows, onConflict: 'user_id,category_id,word_id,mode');
  }

  /// Workload heute (fällig heute + neu gesamt) pro Kategorie
  Future<WorkloadToday> fetchWorkloadToday(String categoryId) async {
    final res = await _sb.rpc('fn_user_workload_today', params: {'cat': categoryId});

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
            // ✅ Für v_words_user_srs: stage statt srs_stage_user
            params['stage'] = 'gte.1';
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
    // ✅ Supabase-Client nutzen (nicht raw HTTP), damit auth.uid() für RLS funktioniert
    try {
      if (filter.kind == WordFilterKind.category) {
        // v_words_user_cats hat category_id (v_words_user hat keine)
        // filter.value kann UUID oder Slug sein → ggf. auflösen
        String categoryId = filter.value;
        final isUuidLike = RegExp(r'^[0-9a-fA-F-]{36}$').hasMatch(filter.value);
        if (!isUuidLike) {
          final row = await _sb
              .from('categories')
              .select('id')
              .eq('slug', filter.value)
              .maybeSingle();
          if (row != null && row['id'] != null) {
            categoryId = row['id'] as String;
          } else {
            debugPrint('⚠️ fetchByFilter: category slug "${filter.value}" not found');
            return [];
          }
        }

        dynamic q = _sb
            .from('v_words_user_cats')
            .select('id,text,translation,from_lang,to_lang,level,pos,category_id,'
                'in_my_words,favorite_user,srs_stage_user,picked_user,'
                'word_created_at,user_added_at')
            .eq('category_id', categoryId);

        q = sort == SortMode.newest
            ? q.order('user_added_at', ascending: false)
            : q.order('text', ascending: true);

        if (query != null && query.trim().isNotEmpty) {
          final qTrim = query.trim();
          q = q.or('text.ilike.%$qTrim%,translation.ilike.%$qTrim%');
        }

        final data = (await q.range(offset, offset + limit - 1)) as List;
        debugPrint('✅ fetchByFilter category: loaded ${data.length} rows from v_words_user_cats (categoryId=$categoryId)');
        final words = data.map((m) {
          final json = Map<String, dynamic>.from(m as Map);
          json['srs_stage'] = json['srs_stage_user'] ?? 0;
          json['created_at'] = json['word_created_at'] ?? json['user_added_at'] ?? DateTime.now().toIso8601String();
          json['favorite'] = json['favorite_user'] ?? false;
          return Word.fromJson(json);
        }).toList();

        final seen = <String>{};
        final unique = <Word>[];
        for (final w in words) {
          if (seen.add(w.id)) unique.add(w);
        }
        return unique;
      }

      // Andere Filter: v_words_user (ohne category_id)
      dynamic q = _sb
          .from('v_words_user')
          .select('id,text,translation,from_lang,to_lang,level,pos,'
              'in_my_words,favorite_user,srs_stage_user,picked_user,'
              'word_created_at,user_added_at');

      switch (filter.kind) {
        case WordFilterKind.level:
          q = q.eq('level', filter.value);
          break;
        case WordFilterKind.pos:
          q = q.eq('pos', filter.value);
          break;
        case WordFilterKind.domain:
          q = q.eq('domain', filter.value);
          break;
        case WordFilterKind.about:
          switch (filter.value) {
            case 'my-words':
              q = q.eq('in_my_words', true);
              break;
            case 'favorites':
              q = q.eq('favorite_user', true);
              break;
            case 'known-words':
              q = q.gte('srs_stage_user', 1);
              break;
            case 'my-mix':
              q = q.eq('picked_user', true);
              break;
            default:
              q = q.eq('domain', filter.value);
          }
          break;
        case WordFilterKind.query:
        case WordFilterKind.category:
          break;
      }

      if (query != null && query.trim().isNotEmpty) {
        final qTrim = query.trim();
        q = q.or('text.ilike.%$qTrim%,translation.ilike.%$qTrim%');
      }

      q = sort == SortMode.newest
          ? q.order('user_added_at', ascending: false)
          : q.order('text', ascending: true);

      final data = (await q.range(offset, offset + limit - 1)) as List;
      final words = data.map((m) {
        final json = Map<String, dynamic>.from(m as Map);
        json['srs_stage'] = json['srs_stage_user'] ?? 0;
        json['created_at'] = json['word_created_at'] ?? json['user_added_at'] ?? DateTime.now().toIso8601String();
        json['favorite'] = json['favorite_user'] ?? false;
        return Word.fromJson(json);
      }).toList();

      final seen = <String>{};
      final unique = <Word>[];
      for (final w in words) {
        if (seen.add(w.id)) unique.add(w);
      }
      return unique;
    } catch (e) {
      debugPrint('fetchByFilter error: $e');
      rethrow;
    }
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

  /// Zählt die mastered-Wörter in A-SRS pro Kategorie.
  /// Zählt nicht über stage=5, streak>=3 oder pass_count, sondern is_mastered.
  Future<int> countLearnedInStage5(String categoryId, {required SrsSystem srsSystem}) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) return 0;

    final result = await _sb
        .from('user_word_srs')
        .select('word_id')
        .eq('user_id', userId)
        .eq('category_id', categoryId)
        .eq('mode', 'adaptive')
        .eq('is_mastered', true);

    return result is List ? result.length : 0;
  }

  Future<int> countDueTodayByFilter(WordListFilter filter) async {
    // ✅ v_words_user_srs verwendet word_id statt id, stage statt srs_stage_user, next_due_at statt next_due_at_user
    final baseUrl = '${dotenv.env['SUPABASE_URL']}/rest/v1/v_words_user_srs';
    final apiKey = dotenv.env['SUPABASE_ANON_KEY']!;
    
    final params = <String>[
      'select=word_id',
      'limit=1',
      'prefer=count=exact',
      'stage=gte.1',
      'next_due_at=lte.${DateTime.now().toIso8601String()}',
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

  /// Requeue nach Ausspielung konsumieren (löschen)
  Future<void> requeueConsume({
    required String categoryId,
    required String wordId,
    required String mode, // 'adaptive' | 'hybrid' | 'time'
  }) async {
    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('requeueConsume: No current user');
    }

    debugPrint('🔄 requeueConsume: cat=$categoryId word=$wordId mode=$mode');
    
    await _sb.rpc('fn_user_requeue_consume', params: {
      'p_category_id': categoryId,
      'p_word_id': wordId,
      'p_mode': mode,
      'p_user': userId,
    });
    
    debugPrint('✅ requeueConsume: Erfolgreich');
  }

  // ---- Helper-Methoden für Device-ID, Sequenznummer und Logical Updated-At ----

  Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_kDeviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final id = const Uuid().v4();
    await prefs.setString(_kDeviceIdKey, id);
    return id;
  }

  Future<int> _nextDeviceSeq() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_kDeviceSeqKey) ?? 0;
    final next = current + 1;
    await prefs.setInt(_kDeviceSeqKey, next);
    return next;
  }

  /// Monotonic updated_at: max(now, last+1ms)
  Future<DateTime> _nextLogicalUpdatedAt() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toUtc();

    final lastIso = prefs.getString(_kLastUpdatedAtKey);
    DateTime next = now;

    if (lastIso != null) {
      final last = DateTime.parse(lastIso).toUtc();
      final lastPlus = last.add(const Duration(milliseconds: 1));
      if (lastPlus.isAfter(next)) next = lastPlus;
    }

    await prefs.setString(_kLastUpdatedAtKey, next.toIso8601String());
    return next;
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
    // ✅ v_words_user_srs verwendet word_id statt id
    final row = await _sb
        .from('v_words_user_srs')
        .select()
        .eq('word_id', wordId)
        .maybeSingle();
    return row == null ? null : WordUserView.fromJson(row);
  }

  /// Holt mehrere WordUserView Objekte anhand ihrer IDs.
  /// Wichtig: Die Reihenfolge der zurückgegebenen Liste entspricht der Reihenfolge der übergebenen IDs.
  Future<List<WordUserView>> fetchWordUserViewsByIds({
    required String categoryId,
    required List<String> ids,
    required SrsSystem srsSystem,
  }) async {
    if (ids.isEmpty) return [];

    final userId = _sb.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('fetchWordUserViewsByIds: No current user');
    }

    final modeStr = srsSystem.name; // 'adaptive' | 'hybrid' | 'time'

    // Hole Details aus v_words_user_srs
    // Chunking: große inFilter-Listen können 400 (Query zu lang) verursachen.
    const chunkSize = 400;
    final map = <String, Map<String, dynamic>>{};
    for (var i = 0; i < ids.length; i += chunkSize) {
      final chunk = ids.skip(i).take(chunkSize).toList();
      final data = await _sb
          .from('v_words_user_srs')
          .select('word_id,text,translation,level,'
              'in_my_words,favorite_user,picked_user,'
              'srs_mode,srs_stage_user,next_due_at_user,user_added_at,'
              'ef,streak,pass_count,lapses')
          .eq('category_id', categoryId)
          .eq('srs_mode', modeStr)
          .inFilter('word_id', chunk);

      for (final j in (data as List).cast<Map<String, dynamic>>()) {
        map[(j['word_id'] as String)] = j;
      }
    }

    // Reihenfolge wie IDs wiederherstellen
    final ordered = <WordUserView>[];
    for (final id in ids) {
      final j = map[id];
      if (j != null) {
        ordered.add(WordUserView.fromJson(j));
      } else {
        debugPrint('⚠️ fetchWordUserViewsByIds: Wort-ID $id nicht in v_words_user_srs gefunden!');
      }
    }

    return ordered;
  }
}

// --- Kategorie-Resolver -----------------------------------------------
extension CategoryLookup on SupabaseWordRepository {
  /// Sucht die Kategorie-ID (UUID) per Anzeigename (case-insensitive).
  Future<String?> findCategoryIdByName(String name) async {
    var row = await _sb
        .from('categories')
        .select('id')
        .ilike('name', name)
        .maybeSingle();
    if (row == null && name.contains(' & ')) {
      final alt = name.replaceAll(' & ', ' and ');
      row = await _sb.from('categories').select('id').ilike('name', alt).maybeSingle();
      if (row != null) debugPrint('📌 findCategoryIdByName: "$name" → Match via "$alt"');
    }
    if (row == null) debugPrint('⚠️ findCategoryIdByName: Kein Match für "$name"');
    return row?['id'] as String?;
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
  // ✅ v_words_user_srs verwendet word_id statt id
  final w = await _sb.from('v_words_user_srs')
      .select()
      .eq('word_id', wordId)
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

  // ✅ v_words_user_srs verwendet word_id statt id
  final w = await _sb.from('v_words_user_srs')
      .select()
      .eq('word_id', wordId)
      .maybeSingle();

  return w == null ? null : wordId;
}

/// Lädt Wörter für einen bestimmten Stage einer Kategorie.
/// Verwendet user_word_srs (modus-spezifisch), damit die Anzeige mit den
/// Stage-Zählern aus fn_user_category_progress übereinstimmt.
Future<List<WordUserView>> fetchWordsByStage(
  String categoryId,
  int stage, {
  required SrsSystem srsSystem,
}) async {
  try {
    final user = _sb.auth.currentUser;
    if (user == null) return [];

    final modeStr = srsSystem.name; // 'time' | 'adaptive' | 'hybrid'

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

    // Hole die Wort-Details aus words Tabelle
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
    debugPrint('🔍 fetchWordsByStage: ${wordsList.length} Wörter in Kategorie, Stage $stage, mode=$modeStr');

    if (stage == 0) {
      // Stage 0: Wörter ohne user_word_srs-Eintrag für diese Kategorie+Modus ODER mit stage=0
      final userWordSrsMap = <String, Map<String, dynamic>>{};
      const chunkSize = 1000;
      for (var i = 0; i < wordIds.length; i += chunkSize) {
        final chunk = wordIds.skip(i).take(chunkSize).toList();
        final uwsData = await _sb
            .from('user_word_srs')
            .select('word_id,stage,next_due_at')
            .eq('user_id', user.id)
            .eq('category_id', catId)
            .eq('mode', modeStr)
            .inFilter('word_id', chunk);
        for (var row in (uwsData as List).cast<Map<String, dynamic>>()) {
          userWordSrsMap[row['word_id'] as String] = row;
        }
      }

      final result = wordsList
          .where((w) {
            final wordId = w['id'] as String;
            final uws = userWordSrsMap[wordId];
            return uws == null || (uws['stage'] as int? ?? 0) == 0;
          })
          .map((word) {
            final wordId = word['id'] as String;
            final uws = userWordSrsMap[wordId];
            return WordUserView(
              id: wordId,
              text: word['text'] as String? ?? '',
              translation: word['translation'] as String? ?? '',
              level: word['level'] as String?,
              srsStage: 0,
              nextDueAt: uws?['next_due_at'] != null
                  ? DateTime.parse(uws!['next_due_at'])
                  : null,
            );
          })
          .toList();

      debugPrint('🔍 fetchWordsByStage(S0): ${result.length} Wörter in Stage 0 (mode=$modeStr)');
      return result;
    } else {
      // Stage 1-5: Wörter mit stage in user_word_srs für diese Kategorie+Modus
      final uwsData = await _sb
          .from('user_word_srs')
          .select('word_id,stage,next_due_at')
          .eq('user_id', user.id)
          .eq('category_id', catId)
          .eq('mode', modeStr)
          .eq('stage', stage)
          .inFilter('word_id', wordIds);

      final uwsMap = <String, Map<String, dynamic>>{};
      for (var row in (uwsData as List).cast<Map<String, dynamic>>()) {
        uwsMap[row['word_id'] as String] = row;
      }

      final result = wordsList
          .where((w) => uwsMap.containsKey(w['id'] as String))
          .map((word) {
            final wordId = word['id'] as String;
            final uws = uwsMap[wordId]!;
            return WordUserView(
              id: wordId,
              text: word['text'] as String? ?? '',
              translation: word['translation'] as String? ?? '',
              level: word['level'] as String?,
              srsStage: (uws['stage'] as int?) ?? 0,
              nextDueAt: uws['next_due_at'] != null
                  ? DateTime.parse(uws['next_due_at'])
                  : null,
            );
          })
          .toList();

      debugPrint('🔍 fetchWordsByStage(S$stage): ${result.length} Wörter (mode=$modeStr)');
      return result;
    }
  } catch (e) {
    debugPrint('Error fetching words by stage: $e');
    return [];
  }
}
