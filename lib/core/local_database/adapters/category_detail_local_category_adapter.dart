import 'package:talvori/core/local_database/adapters/local_category_id_resolver.dart';

class CategoryDetailLocalCategoryAdapter {
  const CategoryDetailLocalCategoryAdapter({
    required LocalCategoryIdResolver resolver,
  }) : _resolver = resolver;

  final LocalCategoryIdResolver _resolver;

  String? resolveLocalCategoryId({String? categoryKey, String? categorySlug}) {
    if (categoryKey != null) {
      final localCategoryId = _resolver.resolve(categoryKey);
      if (localCategoryId != null) {
        return localCategoryId;
      }
    }

    if (categorySlug != null) {
      return _resolver.resolve(categorySlug);
    }

    return null;
  }
}
