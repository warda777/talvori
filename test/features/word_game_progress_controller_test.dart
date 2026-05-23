import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/home/application/word_game_progress_controller.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'stores source selection per game without cross-game overwrite',
    () async {
      const repository = SharedPreferencesWordGameProgressRepository();

      await repository.saveSourceKey('speed-round', 'source:all');
      await repository.saveSourceKey('word-puzzle', 'world:travel');

      expect(await repository.loadSourceKey('speed-round'), 'source:all');
      expect(await repository.loadSourceKey('word-puzzle'), 'world:travel');
    },
  );

  test('stores round size per game', () async {
    const repository = SharedPreferencesWordGameProgressRepository();

    expect(await repository.loadRoundSize('word-match'), WordGameRoundSize.ten);

    await repository.saveRoundSize('word-match', WordGameRoundSize.forty);

    expect(
      await repository.loadRoundSize('word-match'),
      WordGameRoundSize.forty,
    );
  });

  test('stores manual words per round per game', () async {
    const repository = SharedPreferencesWordGameProgressRepository();

    expect(await repository.loadWordsPerRound('word-puzzle'), 10);

    await repository.saveWordsPerRound('word-puzzle', 16);
    await repository.saveWordsPerRound('speed-round', 40);

    expect(await repository.loadWordsPerRound('word-puzzle'), 16);
    expect(await repository.loadWordsPerRound('speed-round'), 40);
  });

  test('marks and resets played ids for game and selection only', () async {
    const repository = SharedPreferencesWordGameProgressRepository();

    await repository.markPlayedIds('word-puzzle', 'world:travel', [
      'one',
      'two',
    ]);
    await repository.markPlayedIds('word-puzzle', 'source:favorites', [
      'favorite',
    ]);

    expect(await repository.loadPlayedIds('word-puzzle', 'world:travel'), {
      'one',
      'two',
    });

    await repository.resetProgress('word-puzzle', 'world:travel');

    expect(
      await repository.loadPlayedIds('word-puzzle', 'world:travel'),
      isEmpty,
    );
    expect(await repository.loadPlayedIds('word-puzzle', 'source:favorites'), {
      'favorite',
    });
  });

  test(
    'round item selection prefers unplayed ids and fills with played ids',
    () {
      final items = ['a', 'b', 'c', 'd'];
      final selected = selectWordGameRoundItems<String>(
        items: items,
        idOf: (item) => item,
        playedIds: {'a', 'b'},
        roundSize: WordGameRoundSize.forty,
      );

      expect(selected.take(2).toSet(), {'c', 'd'});
      expect(selected.toSet(), {'a', 'b', 'c', 'd'});
    },
  );

  test('manual round item selection clamps to available ids', () {
    final items = ['a', 'b', 'c'];
    final selected = selectWordGameRoundItemsByCount<String>(
      items: items,
      idOf: (item) => item,
      playedIds: {'a'},
      wordsPerRound: 40,
    );

    expect(selected.length, 3);
    expect(selected.first, isNot('a'));
  });

  test('clamps manual words per round to game minimum and availability', () {
    expect(clampWordsPerRound(requested: 1, minimum: 6, available: 8), 6);
    expect(clampWordsPerRound(requested: 40, minimum: 6, available: 18), 18);
  });
}
