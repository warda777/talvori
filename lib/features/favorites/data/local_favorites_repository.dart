import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalFavoritesRepository {
  Future<List<String>> loadWordIds();
  Future<void> saveWordIds(List<String> wordIds);
}

class SharedPreferencesLocalFavoritesRepository
    implements LocalFavoritesRepository {
  SharedPreferencesLocalFavoritesRepository({
    this.storageKey = 'talvori_local_favorites_word_ids_v1',
  });

  final String storageKey;

  @override
  Future<List<String>> loadWordIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.trim().isEmpty) return const [];

    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];

    return decoded
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
  }

  @override
  Future<void> saveWordIds(List<String> wordIds) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = wordIds
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList(growable: false);
    await prefs.setString(storageKey, jsonEncode(normalized));
  }
}
