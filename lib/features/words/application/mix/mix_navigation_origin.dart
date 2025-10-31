/// Definiert, woher die Mix-Navigation gestartet wurde, um Back-Button-Logik zu steuern.
class MixNavigationOrigin {
  final MixNavigationSource source;
  final String? categoryId;
  final String? categoryTitle;
  final int? quickSetsIndex; // Für QuickSets: speichert den aktuellen Tab-Index im Wheel

  const MixNavigationOrigin.categoryPopup()
      : source = MixNavigationSource.categoryPopup,
        categoryId = null,
        categoryTitle = null,
        quickSetsIndex = null;

  const MixNavigationOrigin.mixBuilder({
    String? this.categoryId,
    String? this.categoryTitle,
    int? this.quickSetsIndex,
  }) : source = MixNavigationSource.mixBuilder;

  bool get isFromCategoryPopup => source == MixNavigationSource.categoryPopup;
  bool get isFromMixBuilder => source == MixNavigationSource.mixBuilder;
}

enum MixNavigationSource {
  categoryPopup,
  mixBuilder,
}

