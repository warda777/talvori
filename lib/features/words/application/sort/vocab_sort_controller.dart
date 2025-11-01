import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';
import 'package:talvori/features/words/ui/screens/word_list_screen.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';
import 'package:talvori/features/words/application/word_providers.dart';
import 'package:talvori/features/words/application/sort/category_stroke_colors.dart';

class VocabSortState {
  final List<WordUserView> queue;     // verbleibende Wörter (rechtsbündig angezeigt)
  final Set<String> knownIds;            // markiert als "I know"
  final Set<String> unknownIds;          // nach oben "weg" (I don't know)
  final bool loading;
  final String? currentCategoryLabel;          // aktiv im Wheel
  final Set<String> currentCategoryWordIds;    // IDs dieser Kategorie
  final int categoryWordCount;           // Anzahl Wörter in der ausgewählten Kategorie
  final int remainingInCategory;       // ↓ zählt nur bei „hoch"
  final String? centerWordId; // 👈 neu
  final int overlayCounter; // 👈 Zähler in der Box (explizit gepflegt)

  const VocabSortState({
    required this.queue,
    required this.knownIds,
    required this.unknownIds,
    required this.loading,
    this.currentCategoryLabel,
    this.currentCategoryWordIds = const {},
    this.categoryWordCount = 0,
    this.remainingInCategory = 0,
    this.centerWordId,
    this.overlayCounter = 0,
  });

  int get knownCount => knownIds.length;
  int get remainingCount => queue.length;
  int get unknownRemaining => unknownIds.length; // Zählt nur bei "hoch" runter

  // ↓ wie viele aus der aktuellen Kategorie wurden nach OBEN (unknown) gewischt?
  int get unknownInCurrentCategory =>
      currentCategoryWordIds.isEmpty
          ? 0
          : currentCategoryWordIds.where(unknownIds.contains).length;

  // ↓ Zahl zwischen ↑ ↓ : verbleibend „ungeprüft" in aktueller Kategorie,
  //   zählt NUR bei markUnknown() runter.
  int get betweenArrows {
    // Nimm die größte verlässliche Basis:
    // 1) categoryWordCount (Server-Count), sonst
    // 2) currentCategoryWordIds.length (IDs aus der geladenen Liste), sonst
    // 3) queue.length (Fallback)
    final base = (categoryWordCount > 0)
        ? categoryWordCount
        : (currentCategoryWordIds.isNotEmpty
            ? currentCategoryWordIds.length
            : queue.length);

    final v = base - unknownInCurrentCategory;
    return v < 0 ? 0 : v;
  }

  // ↓ Stroke-Farbe für die aktuelle Kategorie
  Color get currentCategoryStrokeColor {
    if (currentCategoryLabel == null) {
      return const Color(0xFFB1CCFE); // Default-Farbe
    }
    return CategoryStrokeColors.getStrokeColor(currentCategoryLabel!);
  }

  VocabSortState copy({
    List<WordUserView>? queue,
    Set<String>? knownIds,
    Set<String>? unknownIds,
    bool? loading,
    String? currentCategoryLabel,
    Set<String>? currentCategoryWordIds,
    int? categoryWordCount,
    int? remainingInCategory,
    String? centerWordId,
    int? overlayCounter,
  }) => VocabSortState(
    queue: queue ?? this.queue,
    knownIds: knownIds ?? this.knownIds,
    unknownIds: unknownIds ?? this.unknownIds,
    loading: loading ?? this.loading,
    currentCategoryLabel: currentCategoryLabel ?? this.currentCategoryLabel,
    currentCategoryWordIds: currentCategoryWordIds ?? this.currentCategoryWordIds,
    categoryWordCount: categoryWordCount ?? this.categoryWordCount,
    remainingInCategory: remainingInCategory ?? this.remainingInCategory,
    centerWordId: centerWordId ?? this.centerWordId,
    overlayCounter: overlayCounter ?? this.overlayCounter,
  );

  static const empty = VocabSortState(queue: [], knownIds: {}, unknownIds: {}, loading: true, remainingInCategory: 0);
}

class VocabSortController extends StateNotifier<VocabSortState> {
  VocabSortController(this._repo) : super(VocabSortState.empty);
  final SupabaseWordRepository _repo;
  final List<_SortAction> _history = [];

  /// initial: „All words". Später per Wheel/Filter ersetzbar.
  Future<void> loadInitial() async {
    state = state.copy(loading: true);
    final words = await _repo.fetchWordUserViewsByFilter(const WordListFilter(WordFilterKind.query, ''));
    state = state.copy(
      queue: words ?? [],
      knownIds: {},
      unknownIds: {},
      loading: false,
    );
  }

  /// Wort nach „I know" werfen
  void markKnown(WordUserView w) {
    final nextQ = List<WordUserView>.from(state.queue)..removeWhere((x) => x.id == w.id);
    final nextK = Set<String>.from(state.knownIds)..add(w.id);
    HapticFeedback.lightImpact();
    state = state.copy(queue: nextQ, knownIds: nextK);
  }

  /// Wort als „I don't know" aussortieren (gold)
  void markUnknown(WordUserView w) {
    final nextQ = List<WordUserView>.from(state.queue)..removeWhere((x) => x.id == w.id);
    final nextU = Set<String>.from(state.unknownIds)..add(w.id);
    HapticFeedback.mediumImpact();
    state = state.copy(queue: nextQ, unknownIds: nextU);
  }

  /// Wird vom Wheel bei Fokuswechsel gesetzt
  void setCenter(WordUserView w) {
    state = state.copy(centerWordId: w.id);
  }

  /// Wort ist ÜBER die Linie gewandert (hoch): abziehen
  void crossedUp(WordUserView w) {
    final nextU = Set<String>.from(state.unknownIds)..add(w.id);
    final nextOverlay = (state.overlayCounter > 0) ? state.overlayCounter - 1 : 0;
    HapticFeedback.selectionClick();
    state = state.copy(unknownIds: nextU, overlayCounter: nextOverlay);
  }

  /// Wort ist WIEDER UNTER die Linie gewandert (runter): draufrechnen
  void crossedDown(WordUserView w) {
    final nextU = Set<String>.from(state.unknownIds)..remove(w.id);
    state = state.copy(unknownIds: nextU, overlayCounter: state.overlayCounter + 1);
  }

  /// + Button: aktuelles Wort als "I know" (entfernt es aus dem Wheel, korrigiert Counter)
  Future<void> addCenterToKnown() async {
    final id = state.centerWordId;
    if (id == null) return;

    final idx = state.queue.indexWhere((x) => x.id == id);
    if (idx == -1) return;

    // Für Undo merken, ob der Eintrag „oben" markiert war
    final wasUnknown = state.unknownIds.contains(id);
    _history.add(_SortAction.single(id, idx, wasUnknown));

    // Aus Queue entfernen, known erhöhen, unknown bereinigen
    final nextQ = [...state.queue]..removeAt(idx);
    final nextK = {...state.knownIds}..add(id);
    final nextU = {...state.unknownIds}..remove(id);

    // Kategoriezählung und Set der Kategorie-IDs anpassen
    final nextCount = state.categoryWordCount > 0 ? state.categoryWordCount - 1 : 0;
    final nextCatIds = {...state.currentCategoryWordIds}..remove(id);

    // 👇 Wenn es NICHT als unknown markiert war, muss die Box trotzdem -1
    final dec = wasUnknown ? 0 : 1;
    final nextOverlay = (state.overlayCounter - dec).clamp(0, 1<<30);

    // 👉 NEU: direkt die nächste Mitte setzen (ohne Rad zu drehen)
    String? nextCenterId;
    if (nextQ.isNotEmpty) {
      final nextIndex = idx < nextQ.length ? idx : nextQ.length - 1;
      nextCenterId = nextQ[nextIndex].id;
    }

    HapticFeedback.mediumImpact();
    state = state.copy(
      queue: nextQ,
      knownIds: nextK,
      unknownIds: nextU,
      categoryWordCount: nextCount,
      currentCategoryWordIds: nextCatIds,
      centerWordId: nextCenterId, // ← sofort wieder + möglich
      overlayCounter: nextOverlay,              // 👈 update
    );

    await _repo.markKnownBatch([id]);
  }

  /// Undo für den letzten Schritt
  Future<void> undo() async {
    if (_history.isEmpty) return;
    final last = _history.removeLast();

    if (last.isBatch) {
      // Batch-Undo: ganze Kategorie zurücklegen
      final batchWords = last.batchWords!;
      if (batchWords.isEmpty) return;

      // Alle Wörter wieder in die Queue einfügen (in ursprünglicher Reihenfolge)
      final nextQ = List<WordUserView>.from(batchWords);
      
      // Alle IDs aus knownIds entfernen
      final allIds = batchWords.map((w) => w.id).toSet();
      final nextK = {...state.knownIds}..removeAll(allIds);
      
      // unknownIds bleibt leer (waren alle nicht als unknown markiert beim Batch-Add)
      final nextU = <String>{};
      
      // Kategorie-Zähler wiederherstellen
      final nextCount = last.oldCategoryCount ?? batchWords.length;
      final nextCatIds = batchWords.map((w) => w.id).toSet();
      
      // overlayCounter wiederherstellen
      final nextOverlay = last.oldOverlayCounter ?? batchWords.length;
      
      // Center auf erstes Wort setzen
      final nextCenterId = batchWords.isNotEmpty ? batchWords[0].id : null;

      state = state.copy(
        queue: nextQ,
        knownIds: nextK,
        unknownIds: nextU,
        categoryWordCount: nextCount,
        currentCategoryWordIds: nextCatIds,
        centerWordId: nextCenterId,
        overlayCounter: nextOverlay,
      );

      HapticFeedback.selectionClick();
    } else {
      // Einzelwort-Undo (wie bisher)
      final wordId = last.wordId!;
      
      // Wortdaten beschaffen (falls nicht mehr in Queue)
      WordUserView? w = state.queue.firstWhere(
        (x) => x.id == wordId,
        orElse: () => WordUserView(id: wordId, text: '', translation: ''),
      );
      final fetched = await _repo.fetchWordById(wordId);
      if (fetched != null) w = fetched;

      // An alte Position einsetzen (clamped) - w ist garantiert nicht null
      final nextQ = [...state.queue];
      final pos = (last.oldIndex ?? nextQ.length).clamp(0, nextQ.length);
      nextQ.insert(pos, w!);

      // unknown-Status wiederherstellen, falls es beim + „oben" war
      final nextU = {...state.unknownIds};
      if (last.wasUnknownMarked) {
        nextU.add(wordId);
      } else {
        nextU.remove(wordId);
      }

      // known entfernen (falls vorhanden)
      final nextK = {...state.knownIds}..remove(wordId);

      // Kategorie-Zähler & Set der Kategorie-IDs wieder erhöhen/hinzufügen
      final nextCount = state.categoryWordCount + 1;
      final nextCatIds = {...state.currentCategoryWordIds}..add(wordId);

      // 👇 Wenn es vorher NICHT unknown war, haben wir bei + abgezogen → jetzt +1
      final inc = last.wasUnknownMarked ? 0 : 1;
      final nextOverlay = state.overlayCounter + inc;

      // Mitte auf das zurückgelegte Wort setzen (sofort wieder + möglich)
      state = state.copy(
        queue: nextQ,
        knownIds: nextK,
        unknownIds: nextU,
        categoryWordCount: nextCount,
        currentCategoryWordIds: nextCatIds,
        centerWordId: wordId,
        overlayCounter: nextOverlay,             // 👈 update
      );

      HapticFeedback.selectionClick();
    }
  }

  /// Alle Wörter der aktuellen Kategorie als "I know" markieren
  Future<void> addEntireCategoryToKnown() async {
    if (state.queue.isEmpty) return;

    // Für Undo: komplette Queue vor dem Leeren speichern
    final savedQueue = List<WordUserView>.from(state.queue);
    final savedOverlayCounter = state.overlayCounter;
    final savedCategoryCount = state.categoryWordCount;
    _history.add(_SortAction.batch(savedQueue, savedOverlayCounter, savedCategoryCount));

    // Alle IDs aus der Queue sammeln
    final allWordIds = state.queue.map((w) => w.id).toList();
    
    // Alle zu knownIds hinzufügen
    final nextK = {...state.knownIds}..addAll(allWordIds);
    
    // Queue leeren
    final nextQ = <WordUserView>[];
    
    // unknownIds bereinigen (alle werden jetzt known)
    final nextU = <String>{};
    
    // Kategorie-Zähler anpassen (alle Wörter entfernt)
    final nextCount = 0;
    final nextCatIds = <String>{};
    
    // overlayCounter auf 0 setzen (alle verarbeitet)
    final nextOverlay = 0;
    
    HapticFeedback.mediumImpact();
    state = state.copy(
      queue: nextQ,
      knownIds: nextK,
      unknownIds: nextU,
      categoryWordCount: nextCount,
      currentCategoryWordIds: nextCatIds,
      overlayCounter: nextOverlay,
      centerWordId: null,
    );

    // In Datenbank persistieren
    await _repo.markKnownBatch(allWordIds);
  }

  /// Alles „I know" persistieren (z. B. srs_stage_user >=1 oder known-flag)
  Future<void> applyKnown() async {
    if (state.knownIds.isEmpty) return;
    await _repo.markKnownBatch(state.knownIds.toList()); // ← implementiert in Repo (kleiner Upsert/Update)
  }

  /// Lädt Wörter für eine spezifische Kategorie
  Future<void> loadForCategory(String categoryLabel) async {
    state = state.copy(loading: true, currentCategoryLabel: categoryLabel);

    try {
      // Versuche Kategorie-ID zu finden
      String? categoryId;
      try {
        categoryId = await _repo.findCategoryIdByName(categoryLabel);
      } catch (_) {}

      String labelSlug = categoryLabel.toLowerCase().replaceAll(' ', '-');
      String? slug;
      if (categoryId != null) {
        slug = await _repo.findCategorySlugById(categoryId);
      }
      final useSlug = slug ?? labelSlug;

      // Wörter + Count mit category_slug
      final filter = WordListFilter(WordFilterKind.category, useSlug);
      final words = await _repo.fetchWordUserViewsByFilter(filter) ?? [];
      int count = 0;
      try {
        count = await _repo.countByFilter(filter);
      } catch (e) {
        debugPrint('⚠️ countByFilter error: $e, using words.length: ${words.length}');
        count = words.length;
      }

      // Fallback: Wenn count 0 ist, aber words vorhanden sind, nutze words.length
      final finalCount = count > 0 ? count : words.length;
      debugPrint('📊 loadForCategory: category=$categoryLabel, count=$count, words.length=${words.length}, finalCount=$finalCount');

      state = state.copy(
        queue: words,
        loading: false,
        categoryWordCount: finalCount,
        currentCategoryLabel: categoryLabel,
        currentCategoryWordIds: words.map((w) => w.id).toSet(),
        // 👇 wichtig: sauber neu initialisieren
        overlayCounter: finalCount,     // ← Box zeigt direkt die volle Zahl
        remainingInCategory: finalCount,
        knownIds: {},              // ← reset
        unknownIds: {},            // ← reset
        centerWordId: null,        // ← reset
      );
    } catch (e, stackTrace) {
      debugPrint('❌ loadForCategory error: $e');
      debugPrint('Stack: $stackTrace');
      // Bei Fehler: loading auf false setzen und leere Queue
      state = state.copy(
        queue: [],
        loading: false,
        categoryWordCount: 0,
        currentCategoryLabel: categoryLabel,
        currentCategoryWordIds: {},
        overlayCounter: 0,
        remainingInCategory: 0,
      );
    }
  }

  /// Zählt Wörter für eine Kategorie (ohne Queue zu ändern)
  Future<void> updateCategoryCount(String categoryLabel) async {
    // Versuche Kategorie-ID zu finden
    String? categoryId;
    try {
      categoryId = await _repo.findCategoryIdByName(categoryLabel);
    } catch (_) {}

    String labelSlug = categoryLabel.toLowerCase().replaceAll(' ', '-');
    String? slug;
    if (categoryId != null) {
      slug = await _repo.findCategorySlugById(categoryId);
    }
    final useSlug = slug ?? labelSlug;

    // Count mit category_slug
    final filter = WordListFilter(WordFilterKind.category, useSlug);
    final count = await _repo.countByFilter(filter);
    state = state.copy(
      currentCategoryLabel: categoryLabel,
      categoryWordCount: count,
    );
  }
}

final vocabSortControllerProvider =
    StateNotifierProvider<VocabSortController, VocabSortState>((ref) {
  final repo = (ref.read(wordHubControllerProvider.notifier).repo) as SupabaseWordRepository;
  final c = VocabSortController(repo);
  // Lazy load (Screen ruft explizit c.loadInitial())
  return c;
});

/// Hilfsklasse für Undo-History
class _SortAction {
  final String? wordId;               // Einzelnes Wort (für + Button)
  final List<WordUserView>? batchWords; // Alle Wörter (für Add Button)
  final int? oldIndex;               // Position im Wheel
  final bool wasUnknownMarked;       // war in unknownIds?
  final int? oldOverlayCounter;      // Counter vor der Operation
  final int? oldCategoryCount;       // Kategorie-Count vor der Operation
  
  // Einzelwort-Action
  _SortAction.single(this.wordId, this.oldIndex, this.wasUnknownMarked)
      : batchWords = null,
        oldOverlayCounter = null,
        oldCategoryCount = null;
  
  // Batch-Action (ganze Kategorie)
  _SortAction.batch(this.batchWords, this.oldOverlayCounter, this.oldCategoryCount)
      : wordId = null,
        oldIndex = null,
        wasUnknownMarked = false;
  
  bool get isBatch => batchWords != null;
}
