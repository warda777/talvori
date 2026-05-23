import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_category_provider.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';

void main() {
  final now = DateTime(2026, 5, 21, 12);

  LocalWord word({
    required String id,
    required String term,
    String translation = 'Übersetzung',
    TranslationStatus status = TranslationStatus.translated,
  }) {
    return LocalWord(
      id: id,
      categoryId: LocalLearningSource.myWords.id,
      term: term,
      translation: translation,
      translationStatus: status,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  Future<void> pumpProfile(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final allWords = [
      word(id: 'emergency', term: 'emergency', translation: 'Notfall'),
      word(id: 'travel', term: 'travel', translation: 'reisen'),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return switch (source) {
              LocalLearningSource.allWords => allWords,
              LocalLearningSource.myWords => allWords,
              LocalLearningSource.favorites => [allWords.first],
              LocalLearningSource.knownWords => [allWords.first],
              LocalLearningSource.myMix => [allWords.first],
            };
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            if (categoryId == LocalLearningSource.myWords.id) {
              return allWords;
            }
            if (categoryId == LocalLearningSource.favorites.id) {
              return [allWords.first];
            }
            return const <LocalWord>[];
          }),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  Future<void> scrollTo(WidgetTester tester, String text) async {
    await tester.scrollUntilVisible(
      find.text(text),
      320,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pump();
  }

  testWidgets('profile shows personal overview sections', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);

    expect(find.text('Profil'), findsOneWidget);
    expect(find.byKey(const Key('profile-settings-button')), findsOneWidget);
    expect(find.text('Auf Premium upgraden'), findsOneWidget);
    expect(find.text('Mach einen Test'), findsOneWidget);
    expect(find.text('um dein aktuelles Level zu sehen'), findsOneWidget);
    expect(find.text('Dein Fortschritt'), findsOneWidget);
    expect(find.text('Taler'), findsOneWidget);
    expect(find.text('Wochenserie'), findsOneWidget);
    expect(find.text('Belohnungen'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);

    await scrollTo(tester, 'Dein Wortschatz');
    expect(find.text('Favoriten'), findsOneWidget);
    expect(find.text('Meine Wörter'), findsOneWidget);
    expect(find.text('Sammlungen'), findsOneWidget);
    expect(find.text('Verlauf'), findsOneWidget);

    await scrollTo(tester, 'App anpassen');
    expect(find.text('Wortwelten'), findsOneWidget);
    expect(find.text('Stimmen'), findsOneWidget);
    expect(find.text('Erinnerungen'), findsOneWidget);
    expect(find.text('Widgets'), findsOneWidget);

    expect(find.text('Geschlechtsidentität'), findsNothing);
    expect(find.text('Marketing & Analysen'), findsNothing);
    expect(find.text('AGB'), findsNothing);
    expect(find.text('Einstellungen'), findsNothing);
  });

  testWidgets('profile screen renders on phone size without flex overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousOnError = FlutterError.onError;
    final flexOverflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        flexOverflows.add(details);
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await pumpProfile(tester);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();

    expect(flexOverflows, isEmpty);
  });

  testWidgets('profile close button pops profile route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return const <LocalWord>[];
          }),
          localWordsForCategoryProvider.overrideWith((ref, categoryId) async {
            return const <LocalWord>[];
          }),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProfileScreen(),
                    ),
                  ),
                  child: const Text('Profil öffnen'),
                ),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Profil öffnen'));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-close-button')));
    await tester.pumpAndSettle();

    expect(find.text('Profil öffnen'), findsOneWidget);
  });

  testWidgets('profile settings gear opens settings screen', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);

    await tester.tap(find.byKey(const Key('profile-settings-button')));
    await tester.pumpAndSettle();

    expect(find.text('Einstellungen'), findsOneWidget);
    expect(find.text('Abonnement verwalten'), findsOneWidget);
  });

  testWidgets('profile reminders card opens reminders page directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);
    await scrollTo(tester, 'Erinnerungen');
    await tester.tap(find.text('Erinnerungen'));
    await tester.pumpAndSettle();

    expect(find.text('Erinnerungen'), findsWidgets);
    expect(find.text('Tageserinnerung'), findsOneWidget);
    expect(find.text('Abonnement verwalten'), findsNothing);

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Tageserinnerung'), findsNothing);
    expect(find.text('App anpassen'), findsOneWidget);
  });

  testWidgets('profile level test card opens prepared level test page', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);

    await tester.tap(find.text('Mach einen Test'));
    await tester.pumpAndSettle();

    expect(find.text('Wortschatz-Einstufungstest'), findsOneWidget);
    expect(find.text('Miss dein aktuelles Level'), findsOneWidget);
    expect(
      find.text('Sieh, wie nah du am nächsten Level bist'),
      findsOneWidget,
    );
    expect(find.text('30 Fragen (5–6 Min.)'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    await tester.tap(find.text('Start'));
    await tester.pumpAndSettle();

    expect(find.text('Der Einstufungstest wird vorbereitet.'), findsOneWidget);

    await tester.tap(find.text('Verstanden'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Mach einen Test'), findsOneWidget);
  });

  testWidgets('profile opens an existing vocabulary target', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);
    await scrollTo(tester, 'Meine Wörter');
    await tester.tap(find.text('Meine Wörter'));
    await tester.pumpAndSettle();

    expect(find.byType(LocalWordListScreen), findsOneWidget);
    expect(find.text('emergency'), findsOneWidget);
  });

  testWidgets('profile placeholder cards show a prepared hint', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);
    await scrollTo(tester, 'Sammlungen');
    await tester.tap(find.text('Sammlungen'));
    await tester.pumpAndSettle();

    expect(find.text('Sammlungen'), findsOneWidget);
    expect(
      find.textContaining('Sammlungen werden vorbereitet'),
      findsOneWidget,
    );
  });
}
