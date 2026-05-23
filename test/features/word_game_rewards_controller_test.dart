import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/home/application/word_game_rewards_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('round reward gives more talers without hint than with hint', () {
    const repo = SharedPreferencesWordGameRewardsRepository();

    final clean = repo.calculateRoundReward(
      const WordGameRoundRewardInput(
        gameId: wordGameIdWordSearch,
        sourceKey: 'source:all',
        wordsPerRound: 1,
        playedWords: 1,
        correctWithoutHint: 1,
      ),
    );
    final hinted = repo.calculateRoundReward(
      const WordGameRoundRewardInput(
        gameId: wordGameIdWordSearch,
        sourceKey: 'source:all',
        wordsPerRound: 1,
        playedWords: 1,
        correctWithoutHint: 0,
        correctWithHint: 1,
        hintsUsed: 1,
      ),
    );

    expect(clean.talers, greaterThan(hinted.talers));
  });

  test('wrong and missed answers do not add base talers', () {
    const repo = SharedPreferencesWordGameRewardsRepository();

    final result = repo.calculateRoundReward(
      const WordGameRoundRewardInput(
        gameId: wordGameIdAudioCatch,
        sourceKey: 'source:all',
        wordsPerRound: 2,
        playedWords: 2,
        correctWithoutHint: 0,
        wrong: 1,
        missed: 1,
      ),
    );

    expect(result.talers, 20);
  });

  test('recorded round stores total talers and active weekday', () async {
    const repo = SharedPreferencesWordGameRewardsRepository();
    final monday = DateTime(2026, 5, 18, 12);

    final snapshot = await repo.recordRound(
      WordGameRoundRewardInput(
        gameId: wordGameIdSpeedRound,
        sourceKey: 'source:all',
        wordsPerRound: 10,
        playedWords: 10,
        correctWithoutHint: 8,
        wrong: 2,
        occurredAt: monday,
        roundId: 'round-1',
      ),
    );

    expect(snapshot.totalTalers, 100);
    expect(snapshot.totalRounds, 1);
    expect(snapshot.activeWeekDays(monday), [
      true,
      false,
      false,
      false,
      false,
      false,
      false,
    ]);
  });

  test('streak grows on consecutive days and breaks after a gap', () async {
    const repo = SharedPreferencesWordGameRewardsRepository();

    for (final date in [
      DateTime(2026, 5, 18, 12),
      DateTime(2026, 5, 19, 12),
      DateTime(2026, 5, 21, 12),
    ]) {
      await repo.recordRound(
        WordGameRoundRewardInput(
          gameId: wordGameIdWordPuzzle,
          sourceKey: 'source:all',
          wordsPerRound: 1,
          playedWords: 1,
          correctWithoutHint: 1,
          occurredAt: date,
          roundId: date.toIso8601String(),
        ),
      );
    }

    final snapshot = await repo.loadSnapshot();
    expect(snapshot.currentStreak, anyOf(0, 1));
    expect(snapshot.bestStreak, 2);
  });

  test('badges unlock when conditions are met', () async {
    const repo = SharedPreferencesWordGameRewardsRepository();

    await repo.recordRound(
      WordGameRoundRewardInput(
        gameId: wordGameIdWordHunt,
        sourceKey: 'source:all',
        wordsPerRound: 10,
        playedWords: 10,
        correctWithoutHint: 10,
        occurredAt: DateTime(2026, 5, 23, 12),
        roundId: 'perfect',
      ),
    );

    final snapshot = await repo.loadSnapshot();
    expect(snapshot.earnedBadgeIds, contains('first_round'));
    expect(snapshot.earnedBadgeIds, contains('talers_100'));
    expect(snapshot.earnedBadgeIds, contains('perfect_round'));
  });

  test('same round id is not recorded twice', () async {
    const repo = SharedPreferencesWordGameRewardsRepository();
    const input = WordGameRoundRewardInput(
      gameId: wordGameIdHangman,
      sourceKey: 'source:all',
      wordsPerRound: 1,
      playedWords: 1,
      correctWithoutHint: 1,
      roundId: 'same-round',
    );

    await repo.recordRound(input);
    final snapshot = await repo.recordRound(input);

    expect(snapshot.totalRounds, 1);
  });
}
