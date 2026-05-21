enum LocalLearningSource {
  allWords(
    id: 'local-source-all-words',
    wordHubKey: 'all_words',
    label: 'Alle Wörter',
  ),
  favorites(
    id: 'local-source-favorites',
    wordHubKey: 'favorites',
    label: 'Favoriten',
  ),
  myWords(
    id: 'local-category-my-words',
    wordHubKey: 'my_words',
    label: 'Meine Wörter',
  ),
  knownWords(
    id: 'local-source-known-words',
    wordHubKey: 'known_words',
    label: 'Wörter, die ich kenne',
  ),
  myMix(id: 'local-source-my-mix', wordHubKey: 'my_mix', label: 'Mein Mix');

  const LocalLearningSource({
    required this.id,
    required this.wordHubKey,
    required this.label,
  });

  final String id;
  final String wordHubKey;
  final String label;

  static LocalLearningSource? fromId(String id) {
    final normalized = id.trim();
    for (final source in values) {
      if (source.id == normalized) return source;
    }
    return null;
  }

  static LocalLearningSource? fromWordHubKey(String key) {
    final normalized = key.trim().toLowerCase();
    for (final source in values) {
      if (source.wordHubKey == normalized) return source;
    }
    return null;
  }
}
