import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/data/supabase_word_repository.dart';

part 'word_list_controller.g.dart';

class _CacheEntry {
  final WordListState state;
  final DateTime ts;
  _CacheEntry(this.state) : ts = DateTime.now();
  bool get fresh => DateTime.now().difference(ts) < const Duration(minutes: 5);
}

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
  final bool offline; // NEU

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
    this.offline = false, // NEU
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
    bool? offline, // NEU
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
      offline: offline ?? this.offline,
    );
  }
}

@riverpod
class WordListController extends _$WordListController {
  final _repo = SupabaseWordRepository();

  static final Map<String, _CacheEntry> _cache = {}; // key = provKey
  Timer? _debounce; // (hast du schon)
  late String _provKey; // merken

  late WordListFilter _baseFilter;
  String? _overrideCategoryId;

  static const _pageSize = 50;

  // Family-Arg kommt hier rein:
  @override
  WordListState build(String provKey) {
    _provKey = provKey;
    final link = ref.keepAlive();
    ref.onDispose(() {
      _debounce?.cancel();
      link.close();
    });

    final hit = _cache[provKey];
    if (hit != null && hit.fresh) {
      return hit.state.copyWith(isFirstLoad: false); // sofort anzeigen
    }
    return const WordListState(); // kalt, lädt via init()
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

  Future<void> _saveOfflineSnapshot(List<Word> words) async {
    try {
      final sp = await SharedPreferences.getInstance();
      final data = words.map((w) => w.toJson()).toList();
      await sp.setString('wl_snapshot_$_provKey', jsonEncode(data));
    } catch (_) {/* silent */}
  }

  Future<List<Word>?> _loadOfflineSnapshot() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('wl_snapshot_$_provKey');
      if (raw == null) return null;
      final List list = jsonDecode(raw);
      return list.map<Word>((m) => Word.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  Future<void> loadFirstPage({bool resetCache = false}) async {
    if (resetCache) _cache.remove(_provKey);
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
        offline: false,
      );
      _cache[_provKey] = _CacheEntry(state);
      await _saveOfflineSnapshot(state.words); // NEU
    } catch (e) {
      // Offline-Snapshot versuchen
      final snap = await _loadOfflineSnapshot();
      if (snap != null && snap.isNotEmpty) {
        state = state.copyWith(
          words: snap,
          isFirstLoad: false,
          isLoadingMore: false,
          hasMore: false,
          error: 'Offline – zeige zuletzt geladene Liste',
          offline: true, // NEU
        );
        _cache[_provKey] = _CacheEntry(state);
      } else {
        state = state.copyWith(
          isFirstLoad: false,
          isLoadingMore: false,
          error: e.toString(),
          offline: false,
        );
      }
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
        offline: false,
      );
      _cache[_provKey] = _CacheEntry(state);
      await _saveOfflineSnapshot(state.words); // NEU
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
      _cache[_provKey] = _CacheEntry(state);
    });
  }

  // optional weiterhin verfügbar
  void setQuery(String q) => state = state.copyWith(query: q);

  void setSort(SortMode s) async {
    if (state.sort == s) return;
    state = state.copyWith(sort: s);
    await loadFirstPage(); // NEU: serverseitig neu laden
    _cache[_provKey] = _CacheEntry(state);
  }

  void setSortDebounced(SortMode s, {Duration d = const Duration(milliseconds: 150)}) {
    _debounce?.cancel();
    _debounce = Timer(d, () => setSort(s));
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