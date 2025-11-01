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

  const VocabSortState({
    required this.queue,
    required this.knownIds,
    required this.unknownIds,
    required this.loading,
    this.currentCategoryLabel,
    this.currentCategoryWordIds = const {},
    this.categoryWordCount = 0,
    this.remainingInCategory = 0,
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
    final base = categoryWordCount == 0 ? queue.length : categoryWordCount;
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
  }) => VocabSortState(
    queue: queue ?? this.queue,
    knownIds: knownIds ?? this.knownIds,
    unknownIds: unknownIds ?? this.unknownIds,
    loading: loading ?? this.loading,
    currentCategoryLabel: currentCategoryLabel ?? this.currentCategoryLabel,
    currentCategoryWordIds: currentCategoryWordIds ?? this.currentCategoryWordIds,
    categoryWordCount: categoryWordCount ?? this.categoryWordCount,
    remainingInCategory: remainingInCategory ?? this.remainingInCategory,
  );

  static const empty = VocabSortState(queue: [], knownIds: {}, unknownIds: {}, loading: true, remainingInCategory: 0);
}

class VocabSortController extends StateNotifier<VocabSortState> {
  VocabSortController(this._repo) : super(VocabSortState.empty);
  final SupabaseWordRepository _repo;

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
    final rest = (state.remainingInCategory > 0) ? state.remainingInCategory - 1 : 0;
    HapticFeedback.mediumImpact();
    state = state.copy(queue: nextQ, unknownIds: nextU, remainingInCategory: rest);
  }

  /// Beim „Über die Linie" NICHT aus der Queue löschen (nur für Wheel)
  void crossedUp(WordUserView w) {
    // NICHT aus queue entfernen – nur markieren + Restzähler runter
    final nextU = Set<String>.from(state.unknownIds)..add(w.id);
    final rest = state.remainingInCategory > 0 ? state.remainingInCategory - 1 : 0;
    state = state.copy(unknownIds: nextU, remainingInCategory: rest);
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

      state = state.copy(
        queue: words,
        loading: false,
        categoryWordCount: count,
        remainingInCategory: count, // neu
        currentCategoryLabel: categoryLabel,
        currentCategoryWordIds: words.map((w) => w.id).toSet(),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ loadForCategory error: $e');
      debugPrint('Stack: $stackTrace');
      // Bei Fehler: loading auf false setzen und leere Queue
      state = state.copy(
        queue: [],
        loading: false,
        categoryWordCount: 0,
        remainingInCategory: 0,
        currentCategoryLabel: categoryLabel,
        currentCategoryWordIds: {},
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
