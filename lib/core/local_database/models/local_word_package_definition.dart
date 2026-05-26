const localLevelPackageCategoryPrefix = 'level-package:';
const localLanguageToolCategoryPrefix = 'language-tool:';

enum LocalWordPackageMode { levelOnly, topic, partOfSpeech, languageTool }

class LocalLevelPackageGroup {
  const LocalLevelPackageGroup({required this.level, required this.packages});

  final String level;
  final List<LocalLevelPackageDefinition> packages;
}

class LocalLevelPackageDefinition {
  const LocalLevelPackageDefinition({
    required this.key,
    required this.level,
    required this.label,
    this.mode = LocalWordPackageMode.levelOnly,
    this.topicNames = const <String>[],
    this.languageToolCategoryNames = const <String>[],
    this.maxWords = 50,
  });

  final String key;
  final String level;
  final String label;
  final LocalWordPackageMode mode;
  final List<String> topicNames;
  final List<String> languageToolCategoryNames;
  final int maxWords;
}

class LocalLanguageToolDefinition {
  const LocalLanguageToolDefinition({
    required this.key,
    required this.label,
    required this.categoryNames,
    this.maxWords = 50,
  });

  final String key;
  final String label;
  final List<String> categoryNames;
  final int maxWords;
}

const localLevelPackageGroups = <LocalLevelPackageGroup>[
  LocalLevelPackageGroup(
    level: 'A1',
    packages: [
      LocalLevelPackageDefinition(
        key: 'a1_starter',
        level: 'A1',
        label: 'A1 Starter',
        maxWords: 40,
      ),
      LocalLevelPackageDefinition(
        key: 'a1_alltag',
        level: 'A1',
        label: 'A1 Alltag',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Home & Living', 'Relationships'],
      ),
      LocalLevelPackageDefinition(
        key: 'a1_verben',
        level: 'A1',
        label: 'A1 Verben',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'a1_nomen',
        level: 'A1',
        label: 'A1 Nomen',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'a1_adjektive',
        level: 'A1',
        label: 'A1 Adjektive',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'a1_reisen_orientierung',
        level: 'A1',
        label: 'A1 Reisen & Orientierung',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Travel', 'Transport'],
      ),
      LocalLevelPackageDefinition(
        key: 'a1_essen_einkaufen',
        level: 'A1',
        label: 'A1 Essen & Einkaufen',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Food & Cooking', 'Money & Shopping'],
      ),
    ],
  ),
  LocalLevelPackageGroup(
    level: 'A2',
    packages: [
      LocalLevelPackageDefinition(
        key: 'a2_alltag',
        level: 'A2',
        label: 'A2 Alltag',
      ),
      LocalLevelPackageDefinition(
        key: 'a2_arbeit_schule',
        level: 'A2',
        label: 'A2 Arbeit & Schule',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Work & Careers', 'School & Studies'],
      ),
      LocalLevelPackageDefinition(
        key: 'a2_reisen',
        level: 'A2',
        label: 'A2 Reisen',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Travel', 'Transport'],
      ),
      LocalLevelPackageDefinition(
        key: 'a2_verben',
        level: 'A2',
        label: 'A2 Verben',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'a2_nomen',
        level: 'A2',
        label: 'A2 Nomen',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'a2_adjektive',
        level: 'A2',
        label: 'A2 Adjektive',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'a2_kommunikation',
        level: 'A2',
        label: 'A2 Kommunikation',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Relationships', 'Thoughts'],
      ),
    ],
  ),
  LocalLevelPackageGroup(
    level: 'B1',
    packages: [
      LocalLevelPackageDefinition(
        key: 'b1_alltag_meinungen',
        level: 'B1',
        label: 'B1 Alltag & Meinungen',
      ),
      LocalLevelPackageDefinition(
        key: 'b1_arbeit_bildung',
        level: 'B1',
        label: 'B1 Arbeit & Bildung',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Work & Careers', 'School & Studies'],
      ),
      LocalLevelPackageDefinition(
        key: 'b1_medien_gesellschaft',
        level: 'B1',
        label: 'B1 Medien & Gesellschaft',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Media & News', 'Law & Politics', 'Environment'],
      ),
      LocalLevelPackageDefinition(
        key: 'b1_verben',
        level: 'B1',
        label: 'B1 Verben',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'b1_nomen',
        level: 'B1',
        label: 'B1 Nomen',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'b1_adjektive',
        level: 'B1',
        label: 'B1 Adjektive',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'b1_redemittel',
        level: 'B1',
        label: 'B1 Redemittel',
        mode: LocalWordPackageMode.languageTool,
        languageToolCategoryNames: ['Phrases & Idioms'],
      ),
    ],
  ),
  LocalLevelPackageGroup(
    level: 'B2',
    packages: [
      LocalLevelPackageDefinition(
        key: 'b2_diskussion',
        level: 'B2',
        label: 'B2 Diskussion',
      ),
      LocalLevelPackageDefinition(
        key: 'b2_beruf_studium',
        level: 'B2',
        label: 'B2 Beruf & Studium',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Work & Careers', 'School & Studies'],
      ),
      LocalLevelPackageDefinition(
        key: 'b2_gesellschaft',
        level: 'B2',
        label: 'B2 Gesellschaft',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Law & Politics', 'Environment', 'Relationships'],
      ),
      LocalLevelPackageDefinition(
        key: 'b2_wissenschaft_technik',
        level: 'B2',
        label: 'B2 Wissenschaft & Technik',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Science', 'Tech & Innovation'],
      ),
      LocalLevelPackageDefinition(
        key: 'b2_verben',
        level: 'B2',
        label: 'B2 Verben',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'b2_nomen',
        level: 'B2',
        label: 'B2 Nomen',
        mode: LocalWordPackageMode.partOfSpeech,
      ),
      LocalLevelPackageDefinition(
        key: 'b2_redemittel',
        level: 'B2',
        label: 'B2 Redemittel',
        mode: LocalWordPackageMode.languageTool,
        languageToolCategoryNames: ['Phrases & Idioms'],
      ),
    ],
  ),
  LocalLevelPackageGroup(
    level: 'C1',
    packages: [
      LocalLevelPackageDefinition(
        key: 'c1_argumentation',
        level: 'C1',
        label: 'C1 Argumentation',
      ),
      LocalLevelPackageDefinition(
        key: 'c1_wissenschaft',
        level: 'C1',
        label: 'C1 Wissenschaft',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Science'],
      ),
      LocalLevelPackageDefinition(
        key: 'c1_beruflich',
        level: 'C1',
        label: 'C1 Beruflich',
        mode: LocalWordPackageMode.topic,
        topicNames: ['Work & Careers'],
      ),
      LocalLevelPackageDefinition(
        key: 'c1_abstrakte_begriffe',
        level: 'C1',
        label: 'C1 Abstrakte Begriffe',
      ),
      LocalLevelPackageDefinition(
        key: 'c1_stil_ausdruck',
        level: 'C1',
        label: 'C1 Stil & Ausdruck',
      ),
      LocalLevelPackageDefinition(
        key: 'c1_redemittel',
        level: 'C1',
        label: 'C1 Redemittel',
        mode: LocalWordPackageMode.languageTool,
        languageToolCategoryNames: ['Phrases & Idioms'],
      ),
    ],
  ),
  LocalLevelPackageGroup(
    level: 'C2',
    packages: [
      LocalLevelPackageDefinition(
        key: 'c2_praeziser_ausdruck',
        level: 'C2',
        label: 'C2 Präziser Ausdruck',
      ),
      LocalLevelPackageDefinition(
        key: 'c2_fachsprache',
        level: 'C2',
        label: 'C2 Fachsprache',
      ),
      LocalLevelPackageDefinition(
        key: 'c2_nuancen',
        level: 'C2',
        label: 'C2 Nuancen',
      ),
      LocalLevelPackageDefinition(
        key: 'c2_stilmittel',
        level: 'C2',
        label: 'C2 Stilmittel',
      ),
      LocalLevelPackageDefinition(
        key: 'c2_seltene_woerter',
        level: 'C2',
        label: 'C2 Seltene Wörter',
      ),
      LocalLevelPackageDefinition(
        key: 'c2_redemittel',
        level: 'C2',
        label: 'C2 Redemittel',
        mode: LocalWordPackageMode.languageTool,
        languageToolCategoryNames: ['Phrases & Idioms'],
      ),
    ],
  ),
];

const localLanguageToolDefinitions = <LocalLanguageToolDefinition>[
  LocalLanguageToolDefinition(
    key: 'top_500',
    label: 'Top 500 Wörter',
    categoryNames: ['Top 500 Words'],
    maxWords: 50,
  ),
  LocalLanguageToolDefinition(
    key: 'phrases_idioms',
    label: 'Redewendung',
    categoryNames: ['Phrases & Idioms'],
  ),
  LocalLanguageToolDefinition(
    key: 'irregular_verbs',
    label: 'Unregelmäßige Verben',
    categoryNames: ['Irregular Verbs'],
  ),
  LocalLanguageToolDefinition(
    key: 'grammar_syntax',
    label: 'Grammatik & Satzbau',
    categoryNames: ['Grammar & Syntax'],
  ),
];

LocalLevelPackageDefinition? localLevelPackageByKey(String key) {
  for (final group in localLevelPackageGroups) {
    for (final package in group.packages) {
      if (package.key == key) return package;
    }
  }
  return null;
}

LocalLanguageToolDefinition? localLanguageToolByKey(String key) {
  for (final tool in localLanguageToolDefinitions) {
    if (tool.key == key) return tool;
  }
  return null;
}
