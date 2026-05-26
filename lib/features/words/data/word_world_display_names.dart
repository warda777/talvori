String wordWorldDisplayName(String wordHubKey, String nativeLanguage) {
  return wordHubItemDisplayName(
    wordHubKey,
    fallbackName: null,
    nativeLanguage: nativeLanguage,
  );
}

String wordHubItemDisplayName(
  String wordHubKey, {
  String? fallbackName,
  required String nativeLanguage,
}) {
  final languageKey = _languageKey(nativeLanguage);
  final normalizedKey = _normalizationKeys(wordHubKey, fallbackName);

  if (languageKey == 'de') {
    return _firstMapped(_germanWordHubItemNames, normalizedKey) ??
        _firstMapped(_englishWordHubItemNames, normalizedKey) ??
        _fallbackDisplayName(fallbackName ?? wordHubKey);
  }

  return _firstMapped(_englishWordHubItemNames, normalizedKey) ??
      _fallbackDisplayName(fallbackName ?? wordHubKey);
}

String wordHubGroupDisplayName(
  String groupKey, {
  String? fallbackName,
  required String nativeLanguage,
}) {
  final languageKey = _languageKey(nativeLanguage);
  final normalizedKey = _normalizationKeys(groupKey, fallbackName);

  if (languageKey == 'de') {
    return _firstMapped(_germanWordHubGroupNames, normalizedKey) ??
        _firstMapped(_englishWordHubGroupNames, normalizedKey) ??
        _fallbackDisplayName(fallbackName ?? groupKey);
  }

  return _firstMapped(_englishWordHubGroupNames, normalizedKey) ??
      _fallbackDisplayName(fallbackName ?? groupKey);
}

String _languageKey(String value) {
  final normalized = value.trim().toLowerCase();
  if (normalized == 'de' || normalized.startsWith('deutsch')) return 'de';
  if (normalized == 'en' || normalized.startsWith('englisch')) return 'en';
  if (normalized.startsWith('english')) return 'en';
  if (normalized.startsWith('german')) return 'de';
  return 'de';
}

List<String> _normalizationKeys(String value, String? fallbackName) {
  final values = <String>[value, if (fallbackName != null) fallbackName];
  final keys = <String>[];
  for (final raw in values) {
    final lower = raw.trim().toLowerCase();
    if (lower.isEmpty) continue;
    keys.add(lower);
    keys.add(lower.replaceAll('&', 'and'));
    keys.add(
      lower
          .replaceAll('&', 'and')
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), ''),
    );
  }
  return keys.toSet().toList(growable: false);
}

String? _firstMapped(Map<String, String> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value != null) return value;
  }
  return null;
}

String _fallbackDisplayName(String value) {
  final trimmed = value.trim();
  if (RegExp(r'^[abc][12]$', caseSensitive: false).hasMatch(trimmed)) {
    return trimmed.toUpperCase();
  }

  final words = trimmed
      .replaceAll('_', ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .map((word) {
        if (RegExp(r'^[abc][12]$', caseSensitive: false).hasMatch(word)) {
          return word.toUpperCase();
        }
        return word.length == 1
            ? word.toUpperCase()
            : '${word[0].toUpperCase()}${word.substring(1)}';
      });
  return words.join(' ');
}

const _germanWordHubGroupNames = <String, String>{
  'life_daily_flow': 'Alltag & Leben',
  'life & daily flow': 'Alltag & Leben',
  'people_mind': 'Menschen & Persönlichkeit',
  'people & mind': 'Menschen & Persönlichkeit',
  'society_systems': 'Gesellschaft & Systeme',
  'society & systems': 'Gesellschaft & Systeme',
  'nature_beyond': 'Natur & Weltraum',
  'nature & beyond': 'Natur & Weltraum',
  'action_adventure': 'Action & Abenteuer',
  'action & adventure': 'Action & Abenteuer',
  'culture_creativity': 'Kultur & Kreativität',
  'culture & creativity': 'Kultur & Kreativität',
  'language_tools': 'Sprachwerkzeuge',
  'language tools': 'Sprachwerkzeuge',
  'levels_progress': 'Level & Fortschritt',
  'levels & progress': 'Level & Fortschritt',
};

const _englishWordHubGroupNames = <String, String>{
  'life_daily_flow': 'Life & Daily Flow',
  'life & daily flow': 'Life & Daily Flow',
  'people_mind': 'People & Mind',
  'people & mind': 'People & Mind',
  'society_systems': 'Society & Systems',
  'society & systems': 'Society & Systems',
  'nature_beyond': 'Nature & Beyond',
  'nature & beyond': 'Nature & Beyond',
  'action_adventure': 'Action & Adventure',
  'action & adventure': 'Action & Adventure',
  'culture_creativity': 'Culture & Creativity',
  'culture & creativity': 'Culture & Creativity',
  'language_tools': 'Language Tools',
  'language tools': 'Language Tools',
  'levels_progress': 'Levels & Progress',
  'levels & progress': 'Levels & Progress',
};

const _germanWordHubItemNames = <String, String>{
  'health_fitness': 'Gesundheit & Fitness',
  'home_living': 'Zuhause & Alltag',
  'food_cooking': 'Essen & Kochen',
  'style_fashion': 'Stil & Mode',
  'money_shopping': 'Geld & Einkaufen',
  'productivity': 'Produktivität',
  'personality': 'Persönlichkeit',
  'feelings': 'Gefühle',
  'relationships': 'Beziehungen',
  'thoughts': 'Gedanken',
  'law_politics': 'Recht & Politik',
  'environment': 'Umwelt',
  'school_studies': 'Schule & Studium',
  'science': 'Wissenschaft',
  'space': 'Weltraum',
  'nature': 'Natur',
  'animals': 'Tiere',
  'tech_innovation': 'Technik & Innovation',
  'media_news': 'Medien & Nachrichten',
  'sports': 'Sport',
  'travel': 'Reisen',
  'gaming': 'Gaming / Spiele',
  'transport': 'Verkehr / Transport',
  'music_entertainment': 'Musik & Unterhaltung',
  'art_literature': 'Kunst & Literatur',
  'work_careers': 'Arbeit & Karriere',
  'top_500': 'Top 500 Wörter',
  'top 500 words': 'Top 500 Wörter',
  'phrases_idioms': 'Redewendung',
  'phrases & idioms': 'Redewendung',
  'irregular_verbs': 'Unregelmäßige Verben',
  'irregular verbs': 'Unregelmäßige Verben',
  'grammar_syntax': 'Grammatik & Satzbau',
  'grammar & syntax': 'Grammatik & Satzbau',
  'a1': 'A1',
  'a2': 'A2',
  'b1': 'B1',
  'b2': 'B2',
  'c1': 'C1',
  'c2': 'C2',
};

const _englishWordHubItemNames = <String, String>{
  'health_fitness': 'Health & Fitness',
  'home_living': 'Home & Living',
  'food_cooking': 'Food & Cooking',
  'style_fashion': 'Style & Fashion',
  'money_shopping': 'Money & Shopping',
  'productivity': 'Productivity',
  'personality': 'Personality',
  'feelings': 'Feelings',
  'relationships': 'Relationships',
  'thoughts': 'Thoughts',
  'law_politics': 'Law & Politics',
  'environment': 'Environment',
  'school_studies': 'School & Studies',
  'science': 'Science',
  'space': 'Space',
  'nature': 'Nature',
  'animals': 'Animals',
  'tech_innovation': 'Tech & Innovation',
  'media_news': 'Media & News',
  'sports': 'Sports',
  'travel': 'Travel',
  'gaming': 'Gaming',
  'transport': 'Transport',
  'music_entertainment': 'Music & Entertainment',
  'art_literature': 'Art & Literature',
  'work_careers': 'Work & Careers',
  'top_500': 'Top 500 Words',
  'top 500 words': 'Top 500 Words',
  'phrases_idioms': 'Phrases & Idioms',
  'phrases & idioms': 'Phrases & Idioms',
  'irregular_verbs': 'Irregular Verbs',
  'irregular verbs': 'Irregular Verbs',
  'grammar_syntax': 'Grammar & Syntax',
  'grammar & syntax': 'Grammar & Syntax',
  'a1': 'A1',
  'a2': 'A2',
  'b1': 'B1',
  'b2': 'B2',
  'c1': 'C1',
  'c2': 'C2',
};
