import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/models/translation_status.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_provider.dart';
import 'package:talvori/core/pronunciation/word_pronunciation_service.dart';
import 'package:talvori/features/home/ui/screens/profile_screen.dart';

class _FakePronunciationService implements WordPronunciationService {
  String? spokenWord;
  String? languageCode;

  @override
  Future<WordPronunciationResult> speakWord(
    String word, {
    String? languageCode,
  }) async {
    spokenWord = word;
    this.languageCode = languageCode;
    return const WordPronunciationResult(WordPronunciationStatus.spoken);
  }

  @override
  Future<void> stop() async {}
}

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

  Future<void> pumpProfile(
    WidgetTester tester, {
    WordPronunciationService? pronunciationService,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final allWords = [
      word(id: 'emergency', term: 'emergency', translation: 'Notfall'),
      word(
        id: 'pending',
        term: 'shelter',
        translation: '',
        status: TranslationStatus.pending,
      ),
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
          if (pronunciationService != null)
            wordPronunciationServiceProvider.overrideWithValue(
              pronunciationService,
            ),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
  }

  testWidgets('profile screen uses German dark-neon structure', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Dein Lernen'), findsOneWidget);
    expect(find.text('Sprache & Aussprache'), findsOneWidget);
    expect(find.text('Benachrichtigungen'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    expect(find.text('Impuls & KI'), findsOneWidget);
    expect(find.text('App-Einstellungen'), findsOneWidget);
    expect(find.text('Browser öffnen mit'), findsOneWidget);
    expect(find.text('Systemstandard'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    expect(find.text('Daten & Hilfe'), findsOneWidget);
    expect(find.text('Share-Diagnose'), findsNothing);
    expect(find.text('Your Vocabulary'), findsNothing);
    expect(find.text('Customize the app'), findsNothing);
    expect(find.text('Deine eigenen'), findsNothing);
    expect(find.text('Sammlungen'), findsNothing);
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
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();
    await tester.drag(find.byType(ListView), const Offset(0, -900));
    await tester.pump();

    expect(flexOverflows, isEmpty);
  });

  testWidgets('profile screen shows local learning counts', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await pumpProfile(tester);

    expect(find.text('Deine Wörter'), findsWidgets);
    expect(find.text('Bekannt'), findsOneWidget);
    expect(find.text('Markiert'), findsOneWidget);
    expect(find.text('Offene Übersetzungen'), findsOneWidget);
    expect(find.text('pending oder fehlgeschlagen'), findsOneWidget);
  });

  testWidgets('pronunciation test calls pronunciation service', (tester) async {
    tester.view.physicalSize = const Size(900, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final pronunciationService = _FakePronunciationService();

    await pumpProfile(tester, pronunciationService: pronunciationService);

    final pronunciationRow = find.byKey(
      const Key('profile-pronunciation-test-row'),
    );
    await tester.ensureVisible(pronunciationRow);
    await tester.pump();
    final inkWell = tester.widget<InkWell>(
      find.descendant(of: pronunciationRow, matching: find.byType(InkWell)),
    );
    inkWell.onTap!();
    await tester.pumpAndSettle();

    expect(pronunciationService.spokenWord, 'emergency');
    expect(pronunciationService.languageCode, 'en');
  });

  testWidgets('profile back arrow pops profile route', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
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

    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Profil öffnen'), findsOneWidget);
  });
}
