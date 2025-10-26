import 'package:talvori/features/words/domain/word.dart';
import 'package:talvori/features/words/application/word_list_controller.dart';

/// Kleiner Vertrag für das UI
abstract class WordRepository {
  Future<List<Word>?> fetchByFilter(WordListFilter filter, {int limit = 50, int offset = 0, String? query, SortMode? sort});
  Future<List<Word>> fetchRecentWords({int limit = 20});
}

/// Deine Mock-Implementierung (behält fetchRecentWords bei)
class MockWordRepository implements WordRepository {
  static final MockWordRepository I = MockWordRepository._();
  MockWordRepository._();
  factory MockWordRepository() => I;  // erlaubt MockWordRepository() in Providern

  @override
  Future<List<Word>> fetchRecentWords({int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return List.generate(limit, (i) => Word(
      id: 'w$i',
      text: 'bridge_$i',
      translation: 'Brücke',
      fromLang: 'en',
      toLang: 'de',
      createdAt: now.subtract(Duration(minutes: i)),
      srsStage: i % 5,
    ));
  }

  @override
  Future<List<Word>?> fetchByFilter(WordListFilter filter, {int limit = 50, int offset = 0, String? query, SortMode? sort}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // einfache Demo-Daten auf Basis des Filters
    return List.generate(limit, (i) {
      final idx = offset + i;
      return Word(
        id: 'mock_${filter.kind.name}_${filter.value}_$idx',
        text: '${filter.value.toLowerCase()}_$idx',
        translation: 'Übersetzung $idx',
        fromLang: 'en',
        toLang: 'de',
        createdAt: DateTime.now().subtract(Duration(days: idx)),
        favorite: idx % 7 == 0,
        srsStage: idx % 5,
      );
    });
  }
}
