import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/category_repository.dart';

part 'category_controller.g.dart';

class CategoryState {
  final List<Category> categories;
  final bool loading;
  final String? error;
  final bool offline;

  const CategoryState({
    this.categories = const [],
    this.loading = false,
    this.error,
    this.offline = false,
  });

  CategoryState copyWith({
    List<Category>? categories,
    bool? loading,
    String? error,
    bool? offline,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      loading: loading ?? this.loading,
      error: error,
      offline: offline ?? this.offline,
    );
  }
}

class _CacheEntry {
  final List<Category> categories;
  final DateTime timestamp;
  
  _CacheEntry(this.categories) : timestamp = DateTime.now();
  
  bool get isFresh => DateTime.now().difference(timestamp) < const Duration(minutes: 5);
  
  CategoryState get state => CategoryState(
    categories: categories,
    loading: false,
    offline: false,
  );
}

@riverpod
class CategoryController extends _$CategoryController {
  final _repo = CategoryRepository();
  static final Map<String, _CacheEntry> _cache = {};
  StreamSubscription? _connSub;

  @override
  CategoryState build() {
    final link = ref.keepAlive();
    ref.onDispose(() async {
      await _connSub?.cancel();
      link.close();
    });

    if (_cache['categories'] != null && _cache['categories']!.isFresh) {
      _revalidate(unawaited: true);
      return _cache['categories']!.state.copyWith(loading: false);
    }

    // Prefs-Hydration sofort starten (setzt loading=false, wenn Daten da sind)
    _hydrateFromPrefs();

    // Revalidate im Hintergrund
    _revalidate(unawaited: true);

    // nur dann als "loading" starten, wenn noch keine Items da sind
    return const CategoryState(loading: true);
  }

  Future<void> _hydrateFromPrefs() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('cache_categories_v1');
      if (raw == null) return;
      final List data = jsonDecode(raw);
      final items = data.map((m) => Category.fromJson(m as Map<String, dynamic>)).toList();
      // sofort anzeigen, kein Spinner
      state = state.copyWith(categories: items, loading: false, error: null);
      _cache['categories'] = _CacheEntry(items);
    } catch (_) {
      // ignoriere Pref-Fehler still
    }
  }

  Future<void> _revalidate({bool unawaited = false}) async {
    final future = _loadFromServer();
    if (unawaited) {
      // ignore: discarded_futures
      future;
    } else {
      await future;
    }
  }


  Future<List<Category>> _loadSnapshot() async {
    try {
      final sp = await SharedPreferences.getInstance();
      final raw = sp.getString('cached_categories');
      if (raw == null) return [];
      final List list = jsonDecode(raw);
      return list.map((m) => Category.fromJson(m as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _loadFromServer() async {
    try {
      final categories = await _repo.fetchCategories();
      _cache['categories'] = _CacheEntry(categories);
      state = state.copyWith(
        categories: categories,
        loading: false,
        offline: false,
        error: null,
      );
    } catch (e) {
      // Bei Fehler: Snapshot versuchen
      final snapshot = await _loadSnapshot();
      if (snapshot.isNotEmpty) {
        state = state.copyWith(
          categories: snapshot,
          loading: false,
          offline: true,
          error: 'Offline – zeige zuletzt geladene Kategorien',
        );
      } else {
        state = state.copyWith(
          loading: false,
          offline: false,
          error: e.toString(),
        );
      }
    }
  }


  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final categories = await _repo.fetchCategories();
      _cache['categories'] = _CacheEntry(categories);
      state = state.copyWith(
        categories: categories,
        loading: false,
        offline: false,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        offline: false,
        error: e.toString(),
      );
    }
  }
}