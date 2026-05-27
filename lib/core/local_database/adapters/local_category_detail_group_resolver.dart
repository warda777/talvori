class LocalCategoryDetailGroupItem {
  const LocalCategoryDetailGroupItem({
    required this.wordHubKey,
    required this.displayLabel,
    this.localCategoryId,
    this.vocabsCount,
  });

  final String wordHubKey;
  final String displayLabel;
  final String? localCategoryId;
  final int? vocabsCount;

  LocalCategoryDetailGroupItem copyWith({
    String? wordHubKey,
    String? displayLabel,
    String? localCategoryId,
    int? vocabsCount,
  }) {
    return LocalCategoryDetailGroupItem(
      wordHubKey: wordHubKey ?? this.wordHubKey,
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

    if (_wordHubItems.any((item) => item.wordHubKey == normalizedKey)) {
      return _wordHubItems;
    }

    return const [];
  }

  LocalCategoryDetailGroupItem? resolveCategory(String wordHubKey) {
    final normalizedKey = wordHubKey.trim().toLowerCase();
    for (final item in _wordHubItems) {
      if (item.wordHubKey == normalizedKey) {
        return item;
      }
    }
    return null;
  }
}

const _wordHubItems = <LocalCategoryDetailGroupItem>[
  LocalCategoryDetailGroupItem(
    wordHubKey: 'health_fitness',
    displayLabel: 'Health & Fitness',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'home_living',
    displayLabel: 'Home & Living',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'food_cooking',
    displayLabel: 'Food & Cooking',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'style_fashion',
    displayLabel: 'Style & Fashion',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'money_shopping',
    displayLabel: 'Money & Shopping',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'productivity',
    displayLabel: 'Productivity',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'personality',
    displayLabel: 'Personality',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'feelings',
    displayLabel: 'Feelings',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'relationships',
    displayLabel: 'Relationships',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'thoughts',
    displayLabel: 'Thoughts',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'tech_innovation',
    displayLabel: 'Tech & Innovation',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'work_careers',
    displayLabel: 'Work & Careers',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'school_studies',
    displayLabel: 'School & Studies',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'media_news',
    displayLabel: 'Media & News',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'law_politics',
    displayLabel: 'Law & Politics',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'environment',
    displayLabel: 'Environment',
  ),
  LocalCategoryDetailGroupItem(wordHubKey: 'animals', displayLabel: 'Animals'),
  LocalCategoryDetailGroupItem(wordHubKey: 'nature', displayLabel: 'Nature'),
  LocalCategoryDetailGroupItem(wordHubKey: 'space', displayLabel: 'Space'),
  LocalCategoryDetailGroupItem(wordHubKey: 'science', displayLabel: 'Science'),
  LocalCategoryDetailGroupItem(wordHubKey: 'sports', displayLabel: 'Sports'),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'travel',
    displayLabel: 'Travel',
    localCategoryId: 'seed-category-travel',
  ),
  LocalCategoryDetailGroupItem(wordHubKey: 'gaming', displayLabel: 'Gaming'),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'transport',
    displayLabel: 'Transport',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'music_entertainment',
    displayLabel: 'Music & Entertainment',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'art_literature',
    displayLabel: 'Art & Literature',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'top_500',
    displayLabel: 'Top 500 Words',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'phrases_idioms',
    displayLabel: 'Phrases & Idioms',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'irregular_verbs',
    displayLabel: 'Irregular Verbs',
  ),
  LocalCategoryDetailGroupItem(
    wordHubKey: 'grammar_syntax',
    displayLabel: 'Grammar & Syntax',
  ),
  LocalCategoryDetailGroupItem(wordHubKey: 'a1', displayLabel: 'A1'),
  LocalCategoryDetailGroupItem(wordHubKey: 'a2', displayLabel: 'A2'),
  LocalCategoryDetailGroupItem(wordHubKey: 'b1', displayLabel: 'B1'),
  LocalCategoryDetailGroupItem(wordHubKey: 'b2', displayLabel: 'B2'),
  LocalCategoryDetailGroupItem(wordHubKey: 'c1', displayLabel: 'C1'),
  LocalCategoryDetailGroupItem(wordHubKey: 'c2', displayLabel: 'C2'),
];
