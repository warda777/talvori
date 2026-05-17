class LocalCategoryDetailGroupItem {
  const LocalCategoryDetailGroupItem({
    required this.displayLabel,
    required this.localCategoryId,
  });

  final String displayLabel;
  final String localCategoryId;
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
