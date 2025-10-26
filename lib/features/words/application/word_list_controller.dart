import 'dart:async';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

part 'word_list_controller.g.dart';

enum WordFilterKind { about, domain, pos, level, category, query }

@immutable
class WordListFilter {
  final WordFilterKind kind;
  final String value;
  const WordListFilter(this.kind, this.value);
}

enum SortMode { az, newest }

@immutable
class WordListState {
  final List<Word> words;
  final Set<String> picked;
  final bool isFirstLoad;
  final bool isLoadingMore;
  final bool hasMore;
  final int offset;
  final String query;
  final SortMode sort;
  final String? error; // NEU

  const WordListState({
    this.words = const [],
    this.picked = const {},
    this.isFirstLoad = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.offset = 0,
    this.query = '',
    this.sort = SortMode.az,
    this.error,
  });

  WordListState copyWith({
    List<Word>? words,
    Set<String>? picked,
    bool? isFirstLoad,
    bool? isLoadingMore,
    bool? hasMore,
    int? offset,
    String? query,
    SortMode? sort,
    String? error,
  }) {
    return WordListState(
      words: words ?? this.words,
      picked: picked ?? this.picked,
      isFirstLoad: isFirstLoad ?? this.isFirstLoad,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      offset: offset ?? this.offset,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      error: error,
    );
  }
}

@riverpod
class WordListController extends _$WordListController {
  final _repo = SupabaseWordRepository();

  late WordListFilter _baseFilter;
  String? _overrideCategoryId;
  Timer? _debounce;

  static const _pageSize = 50;

  // Family-Arg kommt hier rein:
  @override
  WordListState build(String provKey) {
    final link = ref.keepAlive(); // <- hält Instanz am Leben
    ref.onDispose(() {
      _debounce?.cancel();
      link.close();
    });
    // provKey = z.B. "${filter.kind}:${overrideCategoryId ?? filter.value}"
    return const WordListState();
  }

  Future<void> init({
    required WordListFilter filter,
    String? overrideCategoryId,
  }) async {
    _baseFilter = filter;
    _overrideCategoryId = overrideCategoryId;
    await loadFirstPage();
  }

  WordListFilter _effectiveFilter() {
    final value = _overrideCategoryId ?? _baseFilter.value;
    return WordListFilter(_baseFilter.kind, value);
  }

  Future<void> loadFirstPage() async {
    state = state.copyWith(
      isFirstLoad: true,
      words: const [],
      picked: <String>{},
      offset: 0,
      hasMore: true,
    );

    try {
      final batch = await _repo.fetchByFilter(
        _effectiveFilter(),
        limit: _pageSize,
        offset: 0,
        query: state.query.isEmpty ? null : state.query, // NEU
        sort: state.sort,                                 // NEU
      );

      Set<String> pickedIds = {};
      if (batch.isNotEmpty) {
        pickedIds = await _repo.getPickedWordIds(batch.map((w) => w.id));
      }

      state = state.copyWith(
        words: [...batch],
        picked: {...pickedIds},
        offset: batch.length,
        hasMore: batch.length == _pageSize,
        isFirstLoad: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isFirstLoad: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final batch = await _repo.fetchByFilter(
        _effectiveFilter(),
        limit: _pageSize,
        offset: state.offset,
        query: state.query.isEmpty ? null : state.query, // NEU
        sort: state.sort,                                 // NEU
      );

      Set<String> pickedIds = {};
      if (batch.isNotEmpty) {
        pickedIds = await _repo.getPickedWordIds(batch.map((w) => w.id));
      }

      state = state.copyWith(
        words: [...state.words, ...batch],
        picked: {...state.picked, ...pickedIds},
        offset: state.offset + batch.length,
        hasMore: batch.length == _pageSize,
        isLoadingMore: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isFirstLoad: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  void setQueryDebounced(String q, {Duration delay = const Duration(milliseconds: 300)}) {
    _debounce?.cancel();
    _debounce = Timer(delay, () async {
      if (state.query != q) {
        state = state.copyWith(query: q);
      }
      await loadFirstPage(); // NEU: serverseitig neu laden
    });
  }

  // optional weiterhin verfügbar
  void setQuery(String q) => state = state.copyWith(query: q);

  void setSort(SortMode s) async {
    if (state.sort == s) return;
    state = state.copyWith(sort: s);
    await loadFirstPage(); // NEU: serverseitig neu laden
  }

  Future<String?> togglePick(BuildContext ctx, Word w) async {
    final wasPicked = state.picked.contains(w.id);

    // Optimistisch
    final newPicked = {...state.picked};
    if (wasPicked) {
      newPicked.remove(w.id);
    } else {
      newPicked.add(w.id);
    }
    state = state.copyWith(picked: newPicked);

    try {
      if (wasPicked) {
        await _repo.removeFromMyWords(w.id);
        return 'Entfernt: ${w.text}';
      } else {
        await _repo.addToMyWords(w.id);
        return 'Hinzugefügt: ${w.text}';
      }
    } catch (e) {
      // Rollback
      final rollback = {...state.picked};
      if (wasPicked) {
        rollback.add(w.id);
      } else {
        rollback.remove(w.id);
      }
      state = state.copyWith(picked: rollback);
      return 'Fehler: $e';
    }
  }
}