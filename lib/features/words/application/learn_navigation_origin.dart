/// Definiert, woher der Learn-Mode gestartet wurde, um Back-Button-Logik zu steuern.
class LearnNavigationOrigin {
  final LearnNavigationSource source;
  final String? categoryId;
  final String? categoryTitle;
  final int? initialIndex; // Für QuickSets: speichert den ursprünglichen Tab-Index

  const LearnNavigationOrigin.home()
      : source = LearnNavigationSource.home,
        categoryId = null,
        categoryTitle = null,
        initialIndex = null;

  const LearnNavigationOrigin.category({
    required String this.categoryId,
    required String this.categoryTitle,
    int? this.initialIndex,
  }) : source = LearnNavigationSource.category;

  bool get isFromHome => source == LearnNavigationSource.home;
  bool get isFromCategory => source == LearnNavigationSource.category;
  
  /// Prüft ob es sich um QuickSets handelt (virtuelle Kategorie)
  bool get isQuickSets => categoryId == 'quicksets';
}

enum LearnNavigationSource {
  home,
  category,
}

