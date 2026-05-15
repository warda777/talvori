import 'category_detail_local_category_adapter.dart';

class CategoryDetailLocalStartPathResult {
  const CategoryDetailLocalStartPathResult({
    required this.localCategoryId,
  });

  final String? localCategoryId;

  bool get canOpenLocalDebugLearning => localCategoryId != null;
}

class CategoryDetailLocalStartPath {
  const CategoryDetailLocalStartPath({
    required CategoryDetailLocalCategoryAdapter categoryAdapter,
  }) : _categoryAdapter = categoryAdapter;

  final CategoryDetailLocalCategoryAdapter _categoryAdapter;

  CategoryDetailLocalStartPathResult resolve({String? categorySlug}) {
    final localCategoryId = _categoryAdapter.resolveLocalCategoryId(
      categorySlug: categorySlug,
    );

    return CategoryDetailLocalStartPathResult(
      localCategoryId: localCategoryId,
    );
  }
}
