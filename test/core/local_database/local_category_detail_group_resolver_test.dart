import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/local_database/adapters/local_category_detail_group_resolver.dart';

void main() {
  group('LocalCategoryDetailGroupResolver', () {
    test('returns_wordhub_category_items_for_known_taxonomy_key', () {
      const resolver = LocalCategoryDetailGroupResolver();

      final items = resolver.resolve('health_fitness');

      expect(items.length, greaterThan(30));
      expect(items.take(6).map((item) => item.displayLabel), [
        'Health & Fitness',
        'Home & Living',
        'Food & Cooking',
        'Style & Fashion',
        'Money & Shopping',
        'Productivity',
      ]);
      expect(items.map((item) => item.displayLabel), contains('Travel'));
      expect(
        items.map((item) => item.displayLabel),
        isNot(contains('Exam Practice')),
      );

      final health = items.singleWhere(
        (item) => item.wordHubKey == 'health_fitness',
      );
      final travel = items.singleWhere((item) => item.wordHubKey == 'travel');
      final home = items.singleWhere(
        (item) => item.wordHubKey == 'home_living',
      );

      expect(health.displayLabel, 'Health & Fitness');
      expect(health.localCategoryId, isNull);
      expect(travel.displayLabel, 'Travel');
      expect(travel.localCategoryId, 'seed-category-travel');
      expect(home.displayLabel, 'Home & Living');
      expect(home.localCategoryId, isNull);
      expect(items.map((item) => item.localCategoryId).whereType<String>(), [
        'seed-category-travel',
      ]);
      expect(items.every((item) => item.vocabsCount == null), isTrue);
    });

    test('returns_empty_list_for_unknown_key', () {
      const resolver = LocalCategoryDetailGroupResolver();

      expect(resolver.resolve('unknown'), isEmpty);
      expect(resolver.resolve(''), isEmpty);
    });

    test('does_not_use_global_basics_fallback', () {
      const resolver = LocalCategoryDetailGroupResolver();

      expect(resolver.resolve('basics'), isEmpty);
      expect(resolver.resolveCategory('basics'), isNull);
      expect(
        resolver.resolveCategory('health_fitness')?.localCategoryId,
        isNull,
      );
      expect(resolver.resolve('food_cooking'), isNotEmpty);
      expect(resolver.resolveCategory('food_cooking')?.localCategoryId, isNull);
    });
  });
}
