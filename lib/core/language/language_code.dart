class TalvoriLanguage {
  const TalvoriLanguage({
    required this.code,
    required this.germanLabel,
    required this.englishLabel,
    this.aliases = const <String>[],
  });

  final String code;
  final String germanLabel;
  final String englishLabel;
  final List<String> aliases;

  bool matches(String value) {
    final normalized = normalizeLanguageToken(value);
    if (normalized.isEmpty) return false;
    return normalized == code ||
        normalized == normalizeLanguageToken(germanLabel) ||
        normalized == normalizeLanguageToken(englishLabel) ||
        aliases.any((alias) => normalizeLanguageToken(alias) == normalized);
  }
}

class TalvoriLanguages {
  const TalvoriLanguages._();

  static const german = TalvoriLanguage(
    code: 'de',
    germanLabel: 'Deutsch',
    englishLabel: 'German',
    aliases: ['deutschland', 'deu', 'ger'],
  );

  static const english = TalvoriLanguage(
    code: 'en',
    germanLabel: 'Englisch',
    englishLabel: 'English',
    aliases: ['eng'],
  );

  static const spanish = TalvoriLanguage(
    code: 'es',
    germanLabel: 'Spanisch',
    englishLabel: 'Spanish',
    aliases: ['espanol', 'español', 'spa'],
  );

  static const french = TalvoriLanguage(
    code: 'fr',
    germanLabel: 'Französisch',
    englishLabel: 'French',
    aliases: ['franzoesisch', 'fra', 'fre'],
  );

  static const chinese = TalvoriLanguage(
    code: 'zh',
    germanLabel: 'Chinesisch',
    englishLabel: 'Chinese',
    aliases: ['chinese', 'zho', 'chi'],
  );

  static const hindi = TalvoriLanguage(
    code: 'hi',
    germanLabel: 'Hindi',
    englishLabel: 'Hindi',
    aliases: ['hin'],
  );

  static const japanese = TalvoriLanguage(
    code: 'ja',
    germanLabel: 'Japanisch',
    englishLabel: 'Japanese',
    aliases: ['japanese', 'jpn'],
  );

  static const russian = TalvoriLanguage(
    code: 'ru',
    germanLabel: 'Russisch',
    englishLabel: 'Russian',
    aliases: ['russian', 'rus'],
  );

  static const arabic = TalvoriLanguage(
    code: 'ar',
    germanLabel: 'Arabisch',
    englishLabel: 'Arabic',
    aliases: ['arabic', 'ara'],
  );

  static const supported = <TalvoriLanguage>[
    german,
    english,
    spanish,
    french,
    chinese,
    hindi,
    japanese,
    russian,
    arabic,
  ];

  static const visibleMvpLanguages = <TalvoriLanguage>[
    german,
    english,
    spanish,
    french,
  ];

  static TalvoriLanguage? resolve(String value) {
    for (final language in supported) {
      if (language.matches(value)) return language;
    }
    return null;
  }

  static String normalizeCode(String value) {
    final resolved = resolve(value);
    if (resolved != null) return resolved.code;
    return normalizeLanguageToken(value);
  }

  static String germanLabelFor(String value) {
    final resolved = resolve(value);
    if (resolved != null) return resolved.germanLabel;
    return value.trim();
  }

  static String englishLabelFor(String value) {
    final resolved = resolve(value);
    if (resolved != null) return resolved.englishLabel;
    return value.trim();
  }

  static String normalizeLanguagePair(String value) {
    final normalized = value
        .trim()
        .replaceAll(RegExp(r'\s*(->|→)\s*'), '-')
        .replaceAll('_', '-')
        .replaceAll(RegExp(r'\s+-\s+'), '-');
    if (normalized.isEmpty) return '';

    final parts = normalized.split('-');
    if (parts.length == 2) {
      final left = normalizeCode(parts[0]);
      final right = normalizeCode(parts[1]);
      if (left.isEmpty || right.isEmpty) return '';
      return '$left-$right';
    }
    return normalizeLanguageToken(normalized);
  }
}

String normalizeLanguageToken(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ä', 'ae')
      .replaceAll('ö', 'oe')
      .replaceAll('ü', 'ue')
      .replaceAll('ß', 'ss')
      .replaceAll('_', '-')
      .replaceAll(RegExp(r'[^a-z0-9-]+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}
