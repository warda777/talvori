import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/tagesimpuls_selection_item.dart';

abstract class TagesimpulsSelectionRepository {
  Future<List<TagesimpulsSelectionItem>> loadItems();
  Future<void> saveItems(List<TagesimpulsSelectionItem> items);
  Future<void> clear();
}

class SharedPreferencesTagesimpulsSelectionRepository
    implements TagesimpulsSelectionRepository {
  SharedPreferencesTagesimpulsSelectionRepository({
    this.storageKey = 'talvori_tagesimpuls_selection_v1',
  });

  final String storageKey;

  @override
  Future<List<TagesimpulsSelectionItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(TagesimpulsSelectionItem.fromJson)
        .where((item) => item.text.trim().isNotEmpty)
        .toList(growable: false);
  }

  @override
  Future<void> saveItems(List<TagesimpulsSelectionItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(items.map((item) => item.toJson()).toList());
    await prefs.setString(storageKey, encoded);
  }

  @override
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
