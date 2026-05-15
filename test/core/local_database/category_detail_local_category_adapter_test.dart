import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/category_detail_local_category_adapter.dart';
import 'package:talvori/core/local_database/adapters/local_category_id_resolver.dart';

void main() {
  group('CategoryDetailLocalCategoryAdapter', () {
    test('adapter_maps_basics_to_local_category_id', () {
      const resolver = LocalCategoryIdResolver();
      const adapter = CategoryDetailLocalCategoryAdapter(resolver: resolver);

      final localCategoryId = adapter.resolveLocalCategoryId(
        categoryKey: 'basics',
      );

      expect(localCategoryId, 'basics');
    });

    test('adapter_returns_null_for_unknown_category', () {
      const resolver = LocalCategoryIdResolver();
      const adapter = CategoryDetailLocalCategoryAdapter(resolver: resolver);

      expect(adapter.resolveLocalCategoryId(categoryKey: 'unknown'), isNull);
      expect(adapter.resolveLocalCategoryId(categoryKey: 'travel'), isNull);
      expect(adapter.resolveLocalCategoryId(categoryKey: null), isNull);
      expect(adapter.resolveLocalCategoryId(categoryKey: ''), isNull);
    });

    test('adapter_uses_category_slug_when_key_missing', () {
      const resolver = LocalCategoryIdResolver();
      const adapter = CategoryDetailLocalCategoryAdapter(resolver: resolver);

      expect(
        adapter.resolveLocalCategoryId(
          categoryKey: null,
          categorySlug: 'basics',
        ),
        'basics',
      );
      expect(
        adapter.resolveLocalCategoryId(categoryKey: '', categorySlug: 'BASICS'),
        'basics',
      );
      expect(
        adapter.resolveLocalCategoryId(
          categoryKey: 'unknown',
          categorySlug: 'basics',
        ),
        'basics',
      );
      expect(
        adapter.resolveLocalCategoryId(
          categoryKey: null,
          categorySlug: 'unknown',
        ),
        isNull,
      );
    });
  });
}
