enum WordGameLanguagePair {
  englishGerman(
    sourceCode: 'en',
    answerCode: 'de',
    sourceLabel: 'Englisch',
    answerLabel: 'Deutsch',
  ),
  germanEnglish(
    sourceCode: 'de',
    answerCode: 'en',
    sourceLabel: 'Deutsch',
    answerLabel: 'Englisch',
  ),
  englishEnglish(
    sourceCode: 'en',
    answerCode: 'en',
    sourceLabel: 'Englisch',
    answerLabel: 'Englisch',
  );

  const WordGameLanguagePair({
    required this.sourceCode,
    required this.answerCode,
    required this.sourceLabel,
    required this.answerLabel,
  });

  final String sourceCode;
  final String answerCode;
  final String sourceLabel;
  final String answerLabel;

  String get label => '$sourceLabel → $answerLabel';

  bool get canSwap => sourceCode != answerCode;

  WordGameLanguagePair? swapped({
    String nativeLanguageCode = currentNativeLanguageCode,
  }) {
    if (!canSwap) return null;
    for (final pair in WordGameLanguagePair.values) {
      if (pair.sourceCode == answerCode &&
          pair.answerCode == sourceCode &&
          pair.isAllowedForNative(nativeLanguageCode)) {
        return pair;
      }
    }
    return null;
  }

  bool isAllowedForNative(String nativeLanguageCode) {
    final native = nativeLanguageCode.trim().toLowerCase();
    if (native.isEmpty) return true;
    return !(sourceCode == native && answerCode == native);
  }
}

const currentNativeLanguageCode = 'de';

List<WordGameLanguagePair> availableWordGameLanguagePairs({
  String nativeLanguageCode = currentNativeLanguageCode,
}) {
  return WordGameLanguagePair.values
      .where((pair) => pair.isAllowedForNative(nativeLanguageCode))
      .toList(growable: false);
}
