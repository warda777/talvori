import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';

void main() {
  group('LocalCategoryDetailGroupResolver', () {
    test('maps_health_fitness_to_seed_category_basics', () {
      const resolver = LocalCategoryDetailGroupResolver();

      final items = resolver.resolve('health_fitness');

      expect(items, hasLength(1));
      expect(items.single.displayLabel, 'Health & Fitness');
      expect(items.single.localCategoryId, 'seed-category-basics');
      expect(items.single.vocabsCount, isNull);
    });

    test('returns_empty_list_for_unknown_key', () {
      const resolver = LocalCategoryDetailGroupResolver();

      expect(resolver.resolve('unknown'), isEmpty);
      expect(resolver.resolve('travel'), isEmpty);
      expect(resolver.resolve(''), isEmpty);
    });

    test('does_not_use_global_basics_fallback', () {
      const resolver = LocalCategoryDetailGroupResolver();

      expect(resolver.resolve('basics'), isEmpty);
      expect(resolver.resolve('food_cooking'), isEmpty);
    });
  });
}
