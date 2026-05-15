import 'category_detail_local_start_path.dart';

class CategoryDetailDebugLocalButtonState {
  const CategoryDetailDebugLocalButtonState({
    required this.isVisible,
    required this.localCategoryId,
  });

  final bool isVisible;
  final String? localCategoryId;
}

class CategoryDetailDebugLocalButtonPresenter {
  const CategoryDetailDebugLocalButtonPresenter();

  CategoryDetailDebugLocalButtonState present(
    CategoryDetailLocalStartPathResult startPathResult,
  ) {
    if (startPathResult.canOpenLocalDebugLearning &&
        startPathResult.localCategoryId != null) {
      return CategoryDetailDebugLocalButtonState(
        isVisible: true,
        localCategoryId: startPathResult.localCategoryId,
      );
    }

    return const CategoryDetailDebugLocalButtonState(
      isVisible: false,
      localCategoryId: null,
    );
  }
}
