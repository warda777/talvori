class LocalCategoryDetailGroupItem {
  const LocalCategoryDetailGroupItem({
    required this.displayLabel,
    required this.localCategoryId,
    this.vocabsCount,
  });

  final String displayLabel;
  final String localCategoryId;
  final int? vocabsCount;

  LocalCategoryDetailGroupItem copyWith({
    String? displayLabel,
    String? localCategoryId,
    int? vocabsCount,
  }) {
    return LocalCategoryDetailGroupItem(
      displayLabel: displayLabel ?? this.displayLabel,
      localCategoryId: localCategoryId ?? this.localCategoryId,
      vocabsCount: vocabsCount ?? this.vocabsCount,
    );
  }
}

class LocalCategoryDetailGroupResolver {
  const LocalCategoryDetailGroupResolver();

  List<LocalCategoryDetailGroupItem> resolve(String wordHubKey) {
    final normalizedKey = wordHubKey.trim().toLowerCase();

    if (normalizedKey == 'health_fitness') {
      return const [
        LocalCategoryDetailGroupItem(
          displayLabel: 'Health & Fitness',
          localCategoryId: 'seed-category-basics',
        ),
      ];
    }

    return const [];
  }
}
