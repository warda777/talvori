import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/core/language/language_code.dart';

void main() {
  group('TalvoriLanguages', () {
    test('maps German UI labels to stable language codes', () {
      expect(TalvoriLanguages.normalizeCode('Deutsch'), 'de');
      expect(TalvoriLanguages.normalizeCode('Englisch'), 'en');
      expect(TalvoriLanguages.normalizeCode('Spanisch'), 'es');
      expect(TalvoriLanguages.normalizeCode('Französisch'), 'fr');
    });

    test('normalizes existing upper-case language codes', () {
      expect(TalvoriLanguages.normalizeCode('DE'), 'de');
      expect(TalvoriLanguages.normalizeCode('EN'), 'en');
      expect(TalvoriLanguages.normalizeCode('ES'), 'es');
      expect(TalvoriLanguages.normalizeCode('FR'), 'fr');
    });

    test('keeps unknown values safe and normalized', () {
      expect(
        TalvoriLanguages.normalizeCode(' Klingon Prime '),
        'klingon-prime',
      );
      expect(TalvoriLanguages.germanLabelFor('xx'), 'xx');
    });

    test('maps codes back to readable labels', () {
      expect(TalvoriLanguages.germanLabelFor('de'), 'Deutsch');
      expect(TalvoriLanguages.germanLabelFor('en'), 'Englisch');
      expect(TalvoriLanguages.englishLabelFor('es'), 'Spanish');
      expect(TalvoriLanguages.englishLabelFor('fr'), 'French');
    });

    test('normalizes language pairs from labels and codes', () {
      expect(TalvoriLanguages.normalizeLanguagePair('EN-DE'), 'en-de');
      expect(TalvoriLanguages.normalizeLanguagePair('en_de'), 'en-de');
      expect(
        TalvoriLanguages.normalizeLanguagePair('Englisch → Deutsch'),
        'en-de',
      );
      expect(
        TalvoriLanguages.normalizeLanguagePair('Englisch-Deutsch'),
        'en-de',
      );
    });

    test('contains internally prepared later languages', () {
      expect(TalvoriLanguages.normalizeCode('Chinesisch'), 'zh');
      expect(TalvoriLanguages.normalizeCode('Hindi'), 'hi');
      expect(TalvoriLanguages.normalizeCode('Japanisch'), 'ja');
      expect(TalvoriLanguages.normalizeCode('Russisch'), 'ru');
      expect(TalvoriLanguages.normalizeCode('Arabisch'), 'ar');
      expect(
        TalvoriLanguages.visibleMvpLanguages.map((language) => language.code),
        ['de', 'en', 'es', 'fr'],
      );
    });
  });
}
