import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/tagesimpuls/application/tagesimpuls_selection_controller.dart';
import 'package:talvori/features/tagesimpuls/data/tagesimpuls_selection_repository.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';

void main() {
  group('TagesimpulsSelectionController', () {
    test('add first word increases count', () async {
      final controller = TagesimpulsSelectionController(
        repository: _MemoryTagesimpulsRepository(),
      );
      await controller.load();

      final result = await controller.add(_item('word-1', 'house'));

      expect(result, TagesimpulsSelectionAddResult.ok);
      expect(controller.state.count, 1);
      expect(controller.state.items.single.text, 'house');
    });

    test('max 5 is enforced', () async {
      final controller = TagesimpulsSelectionController(
        repository: _MemoryTagesimpulsRepository(),
      );
      await controller.load();

      for (var i = 0; i < 5; i++) {
        expect(
          await controller.add(_item('word-$i', 'word $i')),
          TagesimpulsSelectionAddResult.ok,
        );
      }

      final result = await controller.add(_item('word-6', 'extra'));

      expect(result, TagesimpulsSelectionAddResult.full);
      expect(controller.state.count, 5);
      expect(controller.state.isFull, isTrue);
    });

    test('duplicates by word id or text are prevented', () async {
      final controller = TagesimpulsSelectionController(
        repository: _MemoryTagesimpulsRepository(),
      );
      await controller.load();

      await controller.add(_item('word-house', 'house'));

      expect(
        await controller.add(_item('word-house', 'home')),
        TagesimpulsSelectionAddResult.duplicate,
      );
      expect(
        await controller.add(_item('word-home', ' House ')),
        TagesimpulsSelectionAddResult.duplicate,
      );
      expect(controller.state.count, 1);
    });

    test('remove works', () async {
      final controller = TagesimpulsSelectionController(
        repository: _MemoryTagesimpulsRepository(),
      );
      final item = _item('word-house', 'house');
      await controller.load();
      await controller.add(item);

      final removed = await controller.remove(item);

      expect(removed, isTrue);
      expect(controller.state.items, isEmpty);
    });

    test('clear works and persists empty selection', () async {
      final repository = _MemoryTagesimpulsRepository();
      final controller = TagesimpulsSelectionController(repository: repository);
      await controller.load();
      await controller.add(_item('word-house', 'house'));

      await controller.clear();

      expect(controller.state.items, isEmpty);
      expect(await repository.loadItems(), isEmpty);
    });
  });
}

TagesimpulsSelectionItem _item(String wordId, String text) {
  return TagesimpulsSelectionItem(
    wordId: wordId,
    text: text,
    translation: 'translation',
    addedAt: DateTime.utc(2026, 5, 19),
  );
}

class _MemoryTagesimpulsRepository implements TagesimpulsSelectionRepository {
  List<TagesimpulsSelectionItem> _items = const [];

  @override
  Future<List<TagesimpulsSelectionItem>> loadItems() async {
    return List<TagesimpulsSelectionItem>.of(_items);
  }

  @override
  Future<void> saveItems(List<TagesimpulsSelectionItem> items) async {
    _items = List<TagesimpulsSelectionItem>.of(items);
  }

  @override
  Future<void> clear() async {
    _items = const [];
  }
}
