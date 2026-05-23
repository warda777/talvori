import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

enum WordGameRoundSize {
  ten(label: '10', limit: 10),
  twenty(label: '20', limit: 20),
  forty(label: '40', limit: 40),
  all(label: 'Alle', limit: null);

  const WordGameRoundSize({required this.label, required this.limit});

  final String label;
  final int? limit;

  static WordGameRoundSize fromName(String? name) {
    for (final size in values) {
      if (size.name == name) return size;
    }
    return WordGameRoundSize.ten;
  }
}

class WordGameProgressSnapshot {
  const WordGameProgressSnapshot({
    required this.playedIds,
    required this.availableCount,
  });

  final Set<String> playedIds;
  final int availableCount;

  int playedCountFor(Iterable<String> currentIds) {
    return currentIds.where(playedIds.contains).toSet().length;
  }
}

class SharedPreferencesWordGameProgressRepository {
  const SharedPreferencesWordGameProgressRepository();

  static const _prefix = 'talvori_word_game_progress_v1';

  Future<String?> loadSourceKey(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix.$gameId.source_key');
  }

  Future<void> saveSourceKey(String gameId, String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.$gameId.source_key', sourceKey);
  }

  Future<WordGameRoundSize> loadRoundSize(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    return WordGameRoundSize.fromName(
      prefs.getString('$_prefix.$gameId.round_size'),
    );
  }

  Future<void> saveRoundSize(String gameId, WordGameRoundSize size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix.$gameId.round_size', size.name);
  }

  Future<int> loadWordsPerRound(String gameId) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt('$_prefix.$gameId.words_per_round');
    if (value == null || value < 1) return 10;
    return value;
  }

  Future<void> saveWordsPerRound(String gameId, int wordsPerRound) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      '$_prefix.$gameId.words_per_round',
      wordsPerRound.clamp(1, 9999),
    );
  }

  Future<Set<String>> loadPlayedIds(String gameId, String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
            .getStringList(_playedKey(gameId, sourceKey))
            ?.where((id) => id.trim().isNotEmpty)
            .toSet() ??
        <String>{};
  }

  Future<void> markPlayedIds(
    String gameId,
    String sourceKey,
    Iterable<String> ids,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final merged = {
      ...?prefs.getStringList(_playedKey(gameId, sourceKey)),
      ...ids.where((id) => id.trim().isNotEmpty),
    }.toList()..sort();
    await prefs.setStringList(_playedKey(gameId, sourceKey), merged);
  }

  Future<void> resetProgress(String gameId, String sourceKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playedKey(gameId, sourceKey));
  }

  static String _playedKey(String gameId, String sourceKey) {
    return '$_prefix.$gameId.${_sanitize(sourceKey)}.played_ids';
  }

  static String _sanitize(String value) {
    return value.replaceAll(RegExp(r'[^a-zA-Z0-9_.-]'), '_');
  }
}

List<T> selectWordGameRoundItems<T>({
  required List<T> items,
  required String Function(T item) idOf,
  required Set<String> playedIds,
  required WordGameRoundSize roundSize,
  Random? random,
}) {
  final effectiveRandom = random ?? Random();
  final unplayed = <T>[];
  final repeated = <T>[];
  for (final item in items) {
    if (playedIds.contains(idOf(item))) {
      repeated.add(item);
    } else {
      unplayed.add(item);
    }
  }

  unplayed.shuffle(effectiveRandom);
  repeated.shuffle(effectiveRandom);

  final limit = roundSize.limit ?? items.length;
  return List<T>.unmodifiable([...unplayed, ...repeated].take(limit));
}

List<T> selectWordGameRoundItemsByCount<T>({
  required List<T> items,
  required String Function(T item) idOf,
  required Set<String> playedIds,
  required int wordsPerRound,
  Random? random,
}) {
  final effectiveRandom = random ?? Random();
  final unplayed = <T>[];
  final repeated = <T>[];
  for (final item in items) {
    if (playedIds.contains(idOf(item))) {
      repeated.add(item);
    } else {
      unplayed.add(item);
    }
  }

  unplayed.shuffle(effectiveRandom);
  repeated.shuffle(effectiveRandom);

  final limit = wordsPerRound.clamp(1, items.length);
  return List<T>.unmodifiable([...unplayed, ...repeated].take(limit));
}

int clampWordsPerRound({
  required int requested,
  required int minimum,
  required int available,
}) {
  if (available <= 0) return minimum;
  final effectiveMinimum = minimum.clamp(1, available);
  return requested.clamp(effectiveMinimum, available);
}
