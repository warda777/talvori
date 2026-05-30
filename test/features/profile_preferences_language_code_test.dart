import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/home/application/profile_preferences_controller.dart';

void main() {
  group('ProfilePreferences language code compatibility', () {
    test('derives stable codes from existing saved labels', () {
      const preferences = ProfilePreferences(
        appLanguage: 'Deutsch',
        nativeLanguage: 'Deutsch',
        learningLanguage: 'Englisch',
      );

      expect(preferences.appLanguageCode, 'de');
      expect(preferences.nativeLanguageCode, 'de');
      expect(preferences.learningLanguageCode, 'en');
      expect(preferences.contentLanguagePair, 'en-de');
    });

    test('derives stable codes from already-normalized saved codes', () {
      const preferences = ProfilePreferences(
        appLanguage: 'DE',
        nativeLanguage: 'ES',
        learningLanguage: 'FR',
      );

      expect(preferences.appLanguageCode, 'de');
      expect(preferences.nativeLanguageCode, 'es');
      expect(preferences.learningLanguageCode, 'fr');
      expect(preferences.contentLanguagePair, 'fr-es');
    });
  });
}
