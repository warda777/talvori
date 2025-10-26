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
}

@riverpod
class CategoryController extends _$CategoryController {
  final _repo = CategoryRepository();
  static final Map<String, _CacheEntry> _cache = {};
  Timer? _debounce;

  @override
  CategoryState build() {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    // Initial load
    _loadCategories();
    return const CategoryState();
  }

  Future<void> _loadCategories() async {
    state = state.copyWith(loading: true, error: null);

    // Cache prüfen
    final cached = _cache['categories'];
    if (cached != null && cached.isFresh) {
      state = state.copyWith(
        categories: cached.categories,
        loading: false,
        offline: false,
      );
      return;
    }

    // Snapshot zuerst laden (sofortige UI)
    final snapshot = await _loadSnapshot();
    if (snapshot.isNotEmpty) {
      state = state.copyWith(
        categories: snapshot,
        loading: false,
        offline: false,
      );
      // Hintergrund-Refresh starten
      _refreshInBackground();
      return;
    }

    // Kein Snapshot → normal laden
    await _loadFromServer();
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

  void _refreshInBackground() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        final categories = await _repo.fetchCategories();
        _cache['categories'] = _CacheEntry(categories);
        // State aktualisieren, falls sich etwas geändert hat
        state = state.copyWith(
          categories: categories,
          offline: false,
          error: null,
        );
      } catch (_) {
        // Hintergrund-Fehler ignorieren
      }
    });
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