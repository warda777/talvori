class LocalCategoryIdResolver {
  const LocalCategoryIdResolver();

  String? resolve(String input) {
    final normalizedInput = input.trim().toLowerCase();

    if (normalizedInput == 'basics') {
      return 'basics';
    }

    return null;
  }
}
