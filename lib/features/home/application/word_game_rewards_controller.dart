import 'dart:convert';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const wordGameIdSpeedRound = 'speed-round';
const wordGameIdWordHunt = 'word-hunt';
const wordGameIdWordMatch = 'word-match';
const wordGameIdWordPuzzle = 'word-puzzle';
const wordGameIdGapWord = 'gap-word';
const wordGameIdListenWrite = 'listen-write';
const wordGameIdWordRecognition = 'word-recognition';
const wordGameIdHangman = 'hangman';
const wordGameIdDailyQuest = 'daily-word-quest';
const wordGameIdBossFight = 'boss-fight';
const wordGameIdContextChallenge = 'context-challenge';
const wordGameIdAudioCatch = 'audio-catch';
const wordGameIdSyllableRain = 'syllable-rain';
const wordGameIdWordPath = 'word-path';
const wordGameIdWordSearch = 'word-search';
const wordGameIdOppositeWord = 'gegenwort';
const wordGameIdSynonymRiddle = 'synonym-riddle';

final wordGameRewardsSnapshotProvider = FutureProvider<WordGameRewardsSnapshot>(
  (ref) {
    return const SharedPreferencesWordGameRewardsRepository().loadSnapshot();
  },
);

class WordGameRoundRewardInput {
  const WordGameRoundRewardInput({
    required this.gameId,
    required this.sourceKey,
    required this.wordsPerRound,
    required this.playedWords,
    required this.correctWithoutHint,
    this.correctWithHint = 0,
    this.wrong = 0,
    this.missed = 0,
    this.hintsUsed = 0,
    this.completed = true,
    this.isAiGame = false,
    this.isPremiumAiGame = false,
    this.durationMillis,
    this.occurredAt,
    this.roundId,
  });

  final String gameId;
  final String sourceKey;
  final int wordsPerRound;
  final int playedWords;
  final int correctWithoutHint;
  final int correctWithHint;
  final int wrong;
  final int missed;
  final int hintsUsed;
  final bool completed;
  final bool isAiGame;
  final bool isPremiumAiGame;
  final int? durationMillis;
  final DateTime? occurredAt;
  final String? roundId;

  int get correctTotal => correctWithoutHint + correctWithHint;
  bool get perfect =>
      completed &&
      playedWords > 0 &&
      wrong == 0 &&
      missed == 0 &&
      hintsUsed == 0;
}

class WordGameRewardResult {
  const WordGameRewardResult({
    required this.points,
    required this.talers,
    required this.badgeIds,
  });

  final int points;
  final int talers;
  final Set<String> badgeIds;
}

class WordGameGameStats {
  const WordGameGameStats({
    required this.gameId,
    required this.rounds,
    required this.talers,
    required this.correct,
    required this.wrong,
    required this.missed,
  });

  final String gameId;
  final int rounds;
  final int talers;
  final int correct;
  final int wrong;
  final int missed;

  Map<String, Object?> toJson() => {
    'gameId': gameId,
    'rounds': rounds,
    'talers': talers,
    'correct': correct,
    'wrong': wrong,
    'missed': missed,
  };

  static WordGameGameStats fromJson(Map<String, Object?> json) {
    return WordGameGameStats(
      gameId: json['gameId'] as String? ?? '',
      rounds: json['rounds'] as int? ?? 0,
      talers: json['talers'] as int? ?? 0,
      correct: json['correct'] as int? ?? 0,
      wrong: json['wrong'] as int? ?? 0,
      missed: json['missed'] as int? ?? 0,
    );
  }

  WordGameGameStats add(WordGameRoundRewardInput input, int talers) {
    return WordGameGameStats(
      gameId: gameId,
      rounds: rounds + 1,
      talers: this.talers + talers,
      correct: correct + input.correctTotal,
      wrong: wrong + input.wrong,
      missed: missed + input.missed,
    );
  }
}

class WordGameRewardsSnapshot {
  const WordGameRewardsSnapshot({
    required this.totalTalers,
    required this.totalRounds,
    required this.totalCorrect,
    required this.totalWrong,
    required this.totalMissed,
    required this.totalHintsUsed,
    required this.bestRoundTalers,
    required this.currentStreak,
    required this.bestStreak,
    required this.talersByDate,
    required this.roundsByGame,
    required this.earnedBadgeIds,
    required this.recordedRoundIds,
  });

  factory WordGameRewardsSnapshot.empty() {
    return const WordGameRewardsSnapshot(
      totalTalers: 0,
      totalRounds: 0,
      totalCorrect: 0,
      totalWrong: 0,
      totalMissed: 0,
      totalHintsUsed: 0,
      bestRoundTalers: 0,
      currentStreak: 0,
      bestStreak: 0,
      talersByDate: <String, int>{},
      roundsByGame: <String, WordGameGameStats>{},
      earnedBadgeIds: <String>{},
      recordedRoundIds: <String>{},
    );
  }

  final int totalTalers;
  final int totalRounds;
  final int totalCorrect;
  final int totalWrong;
  final int totalMissed;
  final int totalHintsUsed;
  final int bestRoundTalers;
  final int currentStreak;
  final int bestStreak;
  final Map<String, int> talersByDate;
  final Map<String, WordGameGameStats> roundsByGame;
  final Set<String> earnedBadgeIds;
  final Set<String> recordedRoundIds;

  int talersForDate(DateTime date) => talersByDate[_dateKey(date)] ?? 0;

  int talersThisWeek([DateTime? now]) {
    final today = _dateOnly(now ?? DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    var sum = 0;
    for (var i = 0; i < 7; i += 1) {
      sum += talersForDate(monday.add(Duration(days: i)));
    }
    return sum;
  }

  List<bool> activeWeekDays([DateTime? now]) {
    final today = _dateOnly(now ?? DateTime.now());
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return [
      for (var i = 0; i < 7; i += 1)
        talersForDate(monday.add(Duration(days: i))) > 0,
    ];
  }

  String get mostPlayedGameId {
    if (roundsByGame.isEmpty) return '-';
    return roundsByGame.values
        .reduce((a, b) => a.rounds >= b.rounds ? a : b)
        .gameId;
  }

  Map<String, Object?> toJson() => {
    'totalTalers': totalTalers,
    'totalRounds': totalRounds,
    'totalCorrect': totalCorrect,
    'totalWrong': totalWrong,
    'totalMissed': totalMissed,
    'totalHintsUsed': totalHintsUsed,
    'bestRoundTalers': bestRoundTalers,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'talersByDate': talersByDate,
    'roundsByGame': roundsByGame.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'earnedBadgeIds': earnedBadgeIds.toList()..sort(),
    'recordedRoundIds': recordedRoundIds.toList()..sort(),
  };

  static WordGameRewardsSnapshot fromJson(Map<String, Object?> json) {
    final games = <String, WordGameGameStats>{};
    final rawGames = json['roundsByGame'];
    if (rawGames is Map) {
      for (final entry in rawGames.entries) {
        final value = entry.value;
        if (value is Map) {
          games['${entry.key}'] = WordGameGameStats.fromJson(
            value.cast<String, Object?>(),
          );
        }
      }
    }
    return WordGameRewardsSnapshot(
      totalTalers: json['totalTalers'] as int? ?? 0,
      totalRounds: json['totalRounds'] as int? ?? 0,
      totalCorrect: json['totalCorrect'] as int? ?? 0,
      totalWrong: json['totalWrong'] as int? ?? 0,
      totalMissed: json['totalMissed'] as int? ?? 0,
      totalHintsUsed: json['totalHintsUsed'] as int? ?? 0,
      bestRoundTalers: json['bestRoundTalers'] as int? ?? 0,
      currentStreak: json['currentStreak'] as int? ?? 0,
      bestStreak: json['bestStreak'] as int? ?? 0,
      talersByDate: _intMap(json['talersByDate']),
      roundsByGame: games,
      earnedBadgeIds: _stringSet(json['earnedBadgeIds']),
      recordedRoundIds: _stringSet(json['recordedRoundIds']),
    );
  }

  WordGameRewardsSnapshot copyWith({
    int? totalTalers,
    int? totalRounds,
    int? totalCorrect,
    int? totalWrong,
    int? totalMissed,
    int? totalHintsUsed,
    int? bestRoundTalers,
    int? currentStreak,
    int? bestStreak,
    Map<String, int>? talersByDate,
    Map<String, WordGameGameStats>? roundsByGame,
    Set<String>? earnedBadgeIds,
    Set<String>? recordedRoundIds,
  }) {
    return WordGameRewardsSnapshot(
      totalTalers: totalTalers ?? this.totalTalers,
      totalRounds: totalRounds ?? this.totalRounds,
      totalCorrect: totalCorrect ?? this.totalCorrect,
      totalWrong: totalWrong ?? this.totalWrong,
      totalMissed: totalMissed ?? this.totalMissed,
      totalHintsUsed: totalHintsUsed ?? this.totalHintsUsed,
      bestRoundTalers: bestRoundTalers ?? this.bestRoundTalers,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      talersByDate: talersByDate ?? this.talersByDate,
      roundsByGame: roundsByGame ?? this.roundsByGame,
      earnedBadgeIds: earnedBadgeIds ?? this.earnedBadgeIds,
      recordedRoundIds: recordedRoundIds ?? this.recordedRoundIds,
    );
  }
}

class SharedPreferencesWordGameRewardsRepository {
  const SharedPreferencesWordGameRewardsRepository();

  static const _snapshotKey = 'talvori_word_game_rewards_v1.snapshot';

  WordGameRewardResult calculateRoundReward(WordGameRoundRewardInput input) {
    final base = input.correctWithoutHint * 10 + input.correctWithHint * 5;
    final completionBonus = input.completed ? 20 : 0;
    final perfectBonus = input.perfect ? 30 : 0;
    final aiBonus = input.completed && input.isAiGame ? 10 : 0;
    final talers = max(0, base + completionBonus + perfectBonus + aiBonus);
    return WordGameRewardResult(
      points: max(
        0,
        input.correctTotal * 100 - input.wrong * 25 - input.missed * 25,
      ),
      talers: talers,
      badgeIds: const <String>{},
    );
  }

  Future<WordGameRewardsSnapshot> loadSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_snapshotKey);
    if (raw == null || raw.trim().isEmpty) {
      return WordGameRewardsSnapshot.empty();
    }
    try {
      final json = jsonDecode(raw);
      if (json is Map) {
        return WordGameRewardsSnapshot.fromJson(json.cast<String, Object?>());
      }
    } on Object {
      // Keep rewards robust: a corrupt local snapshot should not break games.
    }
    return WordGameRewardsSnapshot.empty();
  }

  Future<WordGameRewardsSnapshot> recordRound(
    WordGameRoundRewardInput input,
  ) async {
    final now = input.occurredAt ?? DateTime.now();
    final roundId =
        input.roundId ??
        '${input.gameId}.${input.sourceKey}.${now.microsecondsSinceEpoch}';
    final snapshot = await loadSnapshot();
    if (snapshot.recordedRoundIds.contains(roundId)) {
      return snapshot;
    }

    final reward = calculateRoundReward(input);
    final dateKey = _dateKey(now);
    final talersByDate = {...snapshot.talersByDate};
    talersByDate[dateKey] = (talersByDate[dateKey] ?? 0) + reward.talers;

    final games = {...snapshot.roundsByGame};
    final currentGame =
        games[input.gameId] ??
        WordGameGameStats(
          gameId: input.gameId,
          rounds: 0,
          talers: 0,
          correct: 0,
          wrong: 0,
          missed: 0,
        );
    games[input.gameId] = currentGame.add(input, reward.talers);

    final streak = _calculateCurrentStreak(talersByDate.keys, now);
    final badges = _earnedBadges(
      totalTalers: snapshot.totalTalers + reward.talers,
      totalRounds: snapshot.totalRounds + 1,
      totalCorrect: snapshot.totalCorrect + input.correctTotal,
      bestStreak: max(snapshot.bestStreak, streak),
      perfectRound: input.perfect,
      gameStats: games,
      aiRounds: input.isAiGame ? 1 : 0,
      previousBadges: snapshot.earnedBadgeIds,
    );

    final updated = snapshot.copyWith(
      totalTalers: snapshot.totalTalers + reward.talers,
      totalRounds: snapshot.totalRounds + 1,
      totalCorrect: snapshot.totalCorrect + input.correctTotal,
      totalWrong: snapshot.totalWrong + input.wrong,
      totalMissed: snapshot.totalMissed + input.missed,
      totalHintsUsed: snapshot.totalHintsUsed + input.hintsUsed,
      bestRoundTalers: max(snapshot.bestRoundTalers, reward.talers),
      currentStreak: streak,
      bestStreak: max(snapshot.bestStreak, streak),
      talersByDate: talersByDate,
      roundsByGame: games,
      earnedBadgeIds: badges,
      recordedRoundIds: {...snapshot.recordedRoundIds, roundId},
    );
    await saveSnapshot(updated);
    return updated;
  }

  Future<void> saveSnapshot(WordGameRewardsSnapshot snapshot) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_snapshotKey, jsonEncode(snapshot.toJson()));
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_snapshotKey);
  }
}

Set<String> _earnedBadges({
  required int totalTalers,
  required int totalRounds,
  required int totalCorrect,
  required int bestStreak,
  required bool perfectRound,
  required Map<String, WordGameGameStats> gameStats,
  required int aiRounds,
  required Set<String> previousBadges,
}) {
  final badges = {...previousBadges};
  if (totalRounds >= 1) badges.add('first_round');
  if (totalTalers >= 100) badges.add('talers_100');
  if (totalTalers >= 1000) badges.add('talers_1000');
  if (bestStreak >= 3) badges.add('series_starter');
  if (bestStreak >= 7) badges.add('weekly_hero');
  if (perfectRound) badges.add('perfect_round');

  final huntGames = {
    wordGameIdWordHunt,
    wordGameIdAudioCatch,
    wordGameIdSyllableRain,
  };
  final puzzleGames = {
    wordGameIdWordPuzzle,
    wordGameIdWordPath,
    wordGameIdWordSearch,
  };
  final huntCorrect = gameStats.values
      .where((stats) => huntGames.contains(stats.gameId))
      .fold(0, (sum, stats) => sum + stats.correct);
  final puzzleCorrect = gameStats.values
      .where((stats) => puzzleGames.contains(stats.gameId))
      .fold(0, (sum, stats) => sum + stats.correct);
  final totalAiRounds = gameStats.values
      .where(
        (stats) => const {
          wordGameIdContextChallenge,
          wordGameIdOppositeWord,
          wordGameIdSynonymRiddle,
        }.contains(stats.gameId),
      )
      .fold(aiRounds, (sum, stats) => sum + stats.rounds);
  if (huntCorrect >= 50) badges.add('word_hunter');
  if (puzzleCorrect >= 50) badges.add('puzzle_pro');
  if (totalAiRounds >= 5) badges.add('ai_explorer');
  if (totalCorrect >= 250) badges.add('word_power');
  return badges;
}

int _calculateCurrentStreak(Iterable<String> activeDates, DateTime now) {
  final active = activeDates.toSet();
  var cursor = _dateOnly(now);
  var streak = 0;
  while (active.contains(_dateKey(cursor))) {
    streak += 1;
    cursor = cursor.subtract(const Duration(days: 1));
  }
  return streak;
}

String _dateKey(DateTime date) {
  final local = _dateOnly(date);
  final month = local.month.toString().padLeft(2, '0');
  final day = local.day.toString().padLeft(2, '0');
  return '${local.year}-$month-$day';
}

DateTime _dateOnly(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

Map<String, int> _intMap(Object? value) {
  if (value is! Map) return const <String, int>{};
  return value.map((key, value) {
    final parsed = value is int ? value : int.tryParse('$value') ?? 0;
    return MapEntry('$key', parsed);
  });
}

Set<String> _stringSet(Object? value) {
  if (value is List) return value.map((item) => '$item').toSet();
  return const <String>{};
}
