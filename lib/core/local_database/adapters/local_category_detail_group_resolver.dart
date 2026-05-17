class LocalCategoryDetailGroupResolver {
  const LocalCategoryDetailGroupResolver();

  List<String> resolve(String wordHubKey) {
    final normalizedKey = wordHubKey.trim().toLowerCase();

    if (normalizedKey == 'health_fitness') {
      return const ['seed-category-basics'];
    }

    return const [];
  }
}
