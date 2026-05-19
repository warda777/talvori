import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/favorites/application/local_favorites_controller.dart';
import 'package:talvori/features/favorites/data/local_favorites_repository.dart';

void main() {
  group('LocalFavoritesController', () {
    test('adds a word id', () async {
      final repository = _MemoryLocalFavoritesRepository();
      final controller = LocalFavoritesController(repository: repository);
      await controller.load();

      final result = await controller.addWordId('word-1');

      expect(result, LocalFavoriteAddResult.ok);
      expect(controller.state.wordIds, ['word-1']);
      expect(await repository.loadWordIds(), ['word-1']);
    });

    test('prevents duplicate word ids', () async {
      final controller = LocalFavoritesController(
        repository: _MemoryLocalFavoritesRepository(['word-1']),
      );
      await controller.load();

      final result = await controller.addWordId('word-1');

      expect(result, LocalFavoriteAddResult.duplicate);
      expect(controller.state.wordIds, ['word-1']);
    });

    test('rejects empty word ids', () async {
      final controller = LocalFavoritesController(
        repository: _MemoryLocalFavoritesRepository(),
      );
      await controller.load();

      final result = await controller.addWordId('   ');

      expect(result, LocalFavoriteAddResult.invalid);
      expect(controller.state.wordIds, isEmpty);
    });
  });
}

class _MemoryLocalFavoritesRepository implements LocalFavoritesRepository {
  _MemoryLocalFavoritesRepository([List<String> initial = const []])
    : _wordIds = List<String>.of(initial);

  List<String> _wordIds;

  @override
  Future<List<String>> loadWordIds() async {
    return List<String>.of(_wordIds);
  }

  @override
  Future<void> saveWordIds(List<String> wordIds) async {
    _wordIds = List<String>.of(wordIds);
  }
}
