import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/category_detail_debug_local_button_presenter.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_start_path.dart';

void main() {
  group('CategoryDetailDebugLocalButtonPresenter', () {
    test('debug_local_button_visible_for_basics_slug', () {
      const startPathResult = CategoryDetailLocalStartPathResult(
        localCategoryId: 'basics',
      );
      const presenter = CategoryDetailDebugLocalButtonPresenter();

      final state = presenter.present(startPathResult);

      expect(state.isVisible, isTrue);
      expect(state.localCategoryId, 'basics');
    });

    test('debug_local_button_hidden_without_local_mapping', () {
      const presenter = CategoryDetailDebugLocalButtonPresenter();

      final missingState = presenter.present(
        const CategoryDetailLocalStartPathResult(localCategoryId: null),
      );
      final blockedState = presenter.present(
        const _BlockedCategoryDetailLocalStartPathResult(
          localCategoryId: 'basics',
        ),
      );

      expect(missingState.isVisible, isFalse);
      expect(missingState.localCategoryId, isNull);
      expect(blockedState.isVisible, isFalse);
      expect(blockedState.localCategoryId, isNull);
    });
  });
}

class _BlockedCategoryDetailLocalStartPathResult
    extends CategoryDetailLocalStartPathResult {
  const _BlockedCategoryDetailLocalStartPathResult({
    required super.localCategoryId,
  });

  @override
  bool get canOpenLocalDebugLearning => false;
}
