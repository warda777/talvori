import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_category_adapter.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_start_path.dart';
import 'package:talvori/core/local_database/adapters/local_category_id_resolver.dart';

void main() {
  group('CategoryDetailLocalStartPath', () {
    test('local_start_path_resolves_basics_from_category_slug', () {
      const resolver = LocalCategoryIdResolver();
      const categoryAdapter = CategoryDetailLocalCategoryAdapter(
        resolver: resolver,
      );
      const startPath = CategoryDetailLocalStartPath(
        categoryAdapter: categoryAdapter,
      );

      final result = startPath.resolve(categorySlug: 'basics');

      expect(result.localCategoryId, 'basics');
      expect(result.canOpenLocalDebugLearning, isTrue);
    });

    test('local_start_path_hidden_when_no_local_mapping', () {
      const resolver = LocalCategoryIdResolver();
      const categoryAdapter = CategoryDetailLocalCategoryAdapter(
        resolver: resolver,
      );
      const startPath = CategoryDetailLocalStartPath(
        categoryAdapter: categoryAdapter,
      );

      final unknownResult = startPath.resolve(categorySlug: 'unknown');
      final travelResult = startPath.resolve(categorySlug: 'travel');
      final missingResult = startPath.resolve(categorySlug: null);

      expect(unknownResult.localCategoryId, isNull);
      expect(unknownResult.canOpenLocalDebugLearning, isFalse);
      expect(travelResult.localCategoryId, isNull);
      expect(travelResult.canOpenLocalDebugLearning, isFalse);
      expect(missingResult.localCategoryId, isNull);
      expect(missingResult.canOpenLocalDebugLearning, isFalse);
    });
  });
}
