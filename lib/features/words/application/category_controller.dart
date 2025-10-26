import 'dart:async';
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/words/data/category_repository.dart';

part 'category_controller.g.dart';

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
  Future<List<Category>> build() async {
    ref.onDispose(() {
      _debounce?.cancel();
    });

    // Cache prüfen
    final cached = _cache['categories'];
    if (cached != null && cached.isFresh) {
      return cached.categories;
    }

    // Snapshot zuerst laden (sofortige UI)
    final snapshot = await _loadSnapshot();
    if (snapshot.isNotEmpty) {
      // Hintergrund-Refresh starten
      _refreshInBackground();
      return snapshot;
    }

    // Kein Snapshot → normal laden
    return await _loadFromServer();
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

  Future<List<Category>> _loadFromServer() async {
    try {
      final categories = await _repo.fetchCategories();
      _cache['categories'] = _CacheEntry(categories);
      return categories;
    } catch (e) {
      // Bei Fehler: Snapshot versuchen
      final snapshot = await _loadSnapshot();
      if (snapshot.isNotEmpty) {
        return snapshot;
      }
      rethrow;
    }
  }

  void _refreshInBackground() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 100), () async {
      try {
        final categories = await _repo.fetchCategories();
        _cache['categories'] = _CacheEntry(categories);
        // State aktualisieren, falls sich etwas geändert hat
        state = AsyncValue.data(categories);
      } catch (_) {
        // Hintergrund-Fehler ignorieren
      }
    });
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final categories = await _repo.fetchCategories();
      _cache['categories'] = _CacheEntry(categories);
      state = AsyncValue.data(categories);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}