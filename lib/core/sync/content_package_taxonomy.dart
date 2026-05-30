import 'package:talvori/core/language/language_code.dart';

class ContentPackageTaxonomy {
  const ContentPackageTaxonomy._();

  static const typeFrequency = 'frequency';
  static const typeExam = 'exam';
  static const typeTopicPack = 'topic_pack';
  static const typeGrammar = 'grammar';
  static const typePhrasePack = 'phrase_pack';
  static const typeBusiness = 'business';
  static const typeTravel = 'travel';
  static const typeCustom = 'custom';

  static const recommendedPackageTypes = <String>{
    typeFrequency,
    typeExam,
    typeTopicPack,
    typeGrammar,
    typePhrasePack,
    typeBusiness,
    typeTravel,
    typeCustom,
  };

  static String normalizePackageFamily(String value) {
    final token = normalizeLanguageToken(value);
    if (token.isEmpty) return '';
    if (_topWordsAliases.contains(token) ||
        detectTopWordsStage(value) != null) {
      return 'top_words';
    }
    return _packageFamilyAliases[token] ?? _toSnakeCase(token);
  }

  static String normalizePackageType(String value) {
    final rawToken = normalizeLanguageToken(value);
    final token = _toSnakeCase(rawToken);
    if (token.isEmpty) return '';
    return _packageTypeAliases[rawToken] ?? _packageTypeAliases[token] ?? token;
  }

  static String? detectTopWordsStage(String value) {
    final token = normalizeLanguageToken(value);
    if (token.isEmpty) return null;

    final rangeMatch = RegExp(r'top-(\d+)-(\d+)').firstMatch(token);
    if (rangeMatch != null) {
      return '${rangeMatch.group(1)}-${rangeMatch.group(2)}';
    }

    final cumulativeMatch = RegExp(r'top-(\d+)(?:-words)?$').firstMatch(token);
    if (cumulativeMatch != null) {
      return cumulativeMatch.group(1);
    }

    return null;
  }

  static bool isKnownPackageType(String value) {
    return recommendedPackageTypes.contains(normalizePackageType(value));
  }
}

const _topWordsAliases = <String>{
  'top-words',
  'top-wordschatz',
  'top-500-words',
  'top-500',
  'top-400',
  'top-300',
  'top-200',
  'top-100',
};

const _packageFamilyAliases = <String, String>{
  'toefl': 'toefl',
  'ielts': 'ielts',
  'cambridge': 'cambridge_english',
  'cambridge-english': 'cambridge_english',
  'business-english': 'business_english',
  'travel-basics': 'travel_basics',
  'school-english': 'school_english',
  'academic-english': 'academic_english',
  'exam-preparation': 'exam_preparation',
  'irregular-verbs': 'irregular_verbs',
  'phrases-idioms': 'phrases_idioms',
  'grammar-syntax': 'grammar_syntax',
};

const _packageTypeAliases = <String, String>{
  'top-words': ContentPackageTaxonomy.typeFrequency,
  'frequency': ContentPackageTaxonomy.typeFrequency,
  'exam': ContentPackageTaxonomy.typeExam,
  'exam-preparation': ContentPackageTaxonomy.typeExam,
  'topic-pack': ContentPackageTaxonomy.typeTopicPack,
  'grammar': ContentPackageTaxonomy.typeGrammar,
  'grammar-syntax': ContentPackageTaxonomy.typeGrammar,
  'phrase-pack': ContentPackageTaxonomy.typePhrasePack,
  'phrases-idioms': ContentPackageTaxonomy.typePhrasePack,
  'business': ContentPackageTaxonomy.typeBusiness,
  'business-english': ContentPackageTaxonomy.typeBusiness,
  'travel': ContentPackageTaxonomy.typeTravel,
  'travel-basics': ContentPackageTaxonomy.typeTravel,
  'custom': ContentPackageTaxonomy.typeCustom,
};

String _toSnakeCase(String value) {
  return value.replaceAll('-', '_');
}
