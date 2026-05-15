import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_category_id_resolver.dart';

void main() {
  group('LocalCategoryIdResolver', () {
    test('local_category_id_resolver_maps_basics_debug_category', () {
      const resolver = LocalCategoryIdResolver();

      final categoryId = resolver.resolve('basics');

      expect(categoryId, 'basics');
    });

    test('local_category_id_resolver_normalizes_known_key', () {
      const resolver = LocalCategoryIdResolver();

      expect(resolver.resolve(' basics '), 'basics');
      expect(resolver.resolve('BASICS'), 'basics');
      expect(resolver.resolve('Basics'), 'basics');
    });

    test('local_category_id_resolver_returns_null_for_unknown_category', () {
      const resolver = LocalCategoryIdResolver();

      expect(resolver.resolve('unknown'), isNull);
      expect(resolver.resolve('travel'), isNull);
      expect(resolver.resolve(''), isNull);
    });
  });
}
