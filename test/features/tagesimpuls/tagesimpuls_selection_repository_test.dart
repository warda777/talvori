import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/features/tagesimpuls/data/tagesimpuls_selection_repository.dart';
import 'package:talvori/features/tagesimpuls/models/tagesimpuls_selection_item.dart';

void main() {
  group('SharedPreferencesTagesimpulsSelectionRepository', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('persists selection across repository instances', () async {
      final firstRepository = SharedPreferencesTagesimpulsSelectionRepository();
      final item = TagesimpulsSelectionItem(
        wordId: 'word-house',
        text: 'house',
        translation: 'Haus',
        categoryId: 'local-category-my-words',
        addedAt: DateTime.utc(2026, 5, 19),
      );

      await firstRepository.saveItems([item]);

      final secondRepository =
          SharedPreferencesTagesimpulsSelectionRepository();
      final loaded = await secondRepository.loadItems();

      expect(loaded, hasLength(1));
      expect(loaded.single.wordId, 'word-house');
      expect(loaded.single.text, 'house');
      expect(loaded.single.translation, 'Haus');
      expect(loaded.single.categoryId, 'local-category-my-words');
      expect(loaded.single.addedAt, DateTime.utc(2026, 5, 19));
    });

    test('clear removes persisted selection', () async {
      final repository = SharedPreferencesTagesimpulsSelectionRepository();
      await repository.saveItems([
        TagesimpulsSelectionItem(
          wordId: 'word-house',
          text: 'house',
          addedAt: DateTime.utc(2026, 5, 19),
        ),
      ]);

      await repository.clear();

      expect(await repository.loadItems(), isEmpty);
    });
  });
}
