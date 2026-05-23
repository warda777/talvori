import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/core/local_database/models/local_learning_source.dart';
import 'package:talvori/core/local_database/models/local_word.dart';
import 'package:talvori/core/local_database/providers/local_words_for_source_provider.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/home/ui/screens/boss_fight_game_screen.dart';
import 'package:talvori/features/home/ui/screens/context_challenge_game_screen.dart';
import 'package:talvori/features/home/ui/screens/daily_word_quest_game_screen.dart';
import 'package:talvori/features/home/ui/screens/gap_word_game_screen.dart';
import 'package:talvori/features/home/ui/screens/hangman_game_screen.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';
import 'package:talvori/features/home/ui/screens/listen_and_write_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_duel_preview_screen.dart';
import 'package:talvori/features/home/ui/screens/word_recognition_game_screen.dart';
import 'package:talvori/features/home/ui/screens/speed_round_game_screen.dart';
import 'package:talvori/features/home/ui/screens/vocab_screen.dart';
import 'package:talvori/features/home/ui/screens/word_hunt_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_match_game_screen.dart';
import 'package:talvori/features/home/ui/screens/word_puzzle_game_screen.dart';
import 'package:talvori/features/home/ui/widgets/bottom_nav.dart';
import 'package:talvori/features/rewards/ui/screens/rewards_center_screen.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/words/ui/cards/word_card.dart';
import 'package:talvori/features/words/ui/screens/local_learning_source_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/local_learning_sources_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';

void main() {
  LocalWord localWord({
    required String id,
    required String term,
    String translation = 'Übersetzung',
  }) {
    final now = DateTime(2026, 5, 22, 12);
    return LocalWord(
      id: id,
      categoryId: LocalLearningSource.myWords.id,
      term: term,
      translation: translation,
      sourceLanguage: 'en',
      targetLanguage: 'de',
      sortOrder: 0,
      isArchived: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  setUpAll(() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.'
          'eyJyb2xlIjoiYW5vbiIsImlzcyI6InRlc3QiLCJpYXQiOjAsImV4cCI6MTg5MzQ1NjAwMH0.'
          'test-signature',
    );
  });

  testWidgets('home_screen_renders_on_small_height_without_bottom_overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 520);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final previousOnError = FlutterError.onError;
    final bottomOverflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed') &&
          message.contains('bottom')) {
        bottomOverflows.add(details);
      }
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();

    expect(bottomOverflows, isEmpty);
    expect(find.text('0/5'), findsOneWidget);
    expect(find.text('Wortspiele'), findsOneWidget);
    expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
    expect(find.byIcon(Icons.grid_view_rounded), findsNothing);
    expect(find.text('Impuls vorbereiten'), findsNothing);
    expect(find.text('Impuls-Vorschau'), findsNothing);
  });

  testWidgets('home screen shows impulse inbox entry with unread badge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_home_impulse_inbox_entry',
      clock: () => DateTime(2026, 5, 20, 12),
    );
    await repository.addDailyImpulseMessages(const [
      TagesimpulsGeneratedImpulse(
        slot: 'morning',
        message: 'Your daily impulse is waiting.',
        usedWords: ['daily'],
      ),
    ]);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      find.byKey(const Key('home-impuls-postfach-button')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('home-impuls-postfach-unread-badge')),
      findsOneWidget,
    );

    expect(find.text('Impuls vorbereiten'), findsNothing);
  });

  testWidgets('home impulse inbox entry opens impulse inbox screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final previousOnError = FlutterError.onError;
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) return;
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);
    SharedPreferences.setMockInitialValues({});
    final repository = SharedPreferencesImpulseInboxRepository(
      storageKey: 'test_home_impulse_inbox_open',
      clock: () => DateTime(2026, 5, 20, 12),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          impulseInboxRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).onImpulseInbox();
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.text('Noch keine Chats'), findsOneWidget);
  });

  testWidgets('home counter opens Vocabs directly', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final observer = _RecordingNavigatorObserver();

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          navigatorObservers: [observer],
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final counterFinder = find.byKey(const Key('home-my-words-counter-button'));
    final beforeTapRect = tester.getRect(counterFinder);

    await tester.tap(counterFinder);
    await tester.pump(const Duration(milliseconds: 100));
    final duringTapRect = tester.getRect(counterFinder);
    expect(duringTapRect.center.dx, beforeTapRect.center.dx);
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byType(LocalWordListScreen), findsOneWidget);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.text('Wortquellen'), findsNothing);
    expect(find.text('Meine Wörter'), findsWidgets);
    expect(find.text('All words'), findsNothing);
    expect(find.text('My words'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Words I know'), findsNothing);
    expect(find.text('My mix'), findsNothing);
    expect(observer.pushedRouteNames, contains('local-vocabs-my_words'));
    expect(
      observer.pushedRouteNames,
      isNot(contains('local-source-detail-my_words')),
    );
    expect(
      observer.pushedRouteNames,
      isNot(contains(LocalLearningSourcesScreen.routeName)),
    );

    expect(
      observer.pushedRouteNames.whereType<String>().last,
      'local-vocabs-my_words',
    );
  });

  testWidgets('home play opens category popup', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-my-words-play-button')));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();

    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
    expect(find.text('Kategorie'), findsOneWidget);
    expect(
      find.byKey(const Key('category-popup-all-words-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category-popup-favorites-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category-popup-my-words-tile')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('category-popup-known-words-tile')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('category-popup-my-mix-tile')), findsOneWidget);
    expect(find.text('Übungsmodus'), findsNothing);
    expect(find.text('All words'), findsNothing);
    expect(find.text('My words'), findsNothing);
    expect(find.text('Favorites'), findsNothing);
    expect(find.text('Words I know'), findsNothing);
    expect(find.text('My mix'), findsNothing);
  });

  testWidgets(
    'home browser button shows Standardbrowser Chrome Brave choices',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final opened = <Uri>[];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
              opened.add(uri);
              return true;
            }),
          ],
          child: const MaterialApp(home: HomeScreen()),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byKey(const Key('home-browser-return-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(opened, isEmpty);
      expect(find.byKey(const Key('home-browser-open-sheet')), findsOneWidget);
      expect(find.text('Browser öffnen'), findsOneWidget);
      expect(find.text('Standardbrowser'), findsOneWidget);
      expect(find.text('Safari'), findsNothing);
      expect(find.text('Chrome'), findsOneWidget);
      expect(find.text('Brave'), findsOneWidget);
      expect(find.text('Eigene Webseite hinterlegen'), findsOneWidget);
      expect(find.text('Anderer Browser'), findsNothing);
      expect(find.byKey(const Key('home-browser-option-safari')), findsNothing);
      expect(find.byKey(const Key('home-browser-option-other')), findsNothing);
      expect(
        find.textContaining('Safari öffnet sich über Standardbrowser'),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('home-browser-missing-url-sheet')),
        findsNothing,
      );
      expect(find.text('Talvori-Leser'), findsNothing);
      expect(find.text('Keine Seite gespeichert'), findsNothing);
    },
  );

  testWidgets('home browser custom start page can be saved', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-set-start-url')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(
      find.byKey(const Key('home-browser-start-url-sheet')),
      findsOneWidget,
    );
    expect(find.text('Eigene Webseite'), findsOneWidget);
    final input = tester.widget<TextField>(
      find.byKey(const Key('home-browser-start-url-input')),
    );
    expect(input.controller?.text, isEmpty);

    await tester.enterText(
      find.byKey(const Key('home-browser-start-url-input')),
      'bbc.com',
    );
    await tester.tap(find.byKey(const Key('home-browser-start-url-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getString(homeBrowserCustomStartUrlStorageKey),
      'https://bbc.com',
    );
  });

  testWidgets('home browser custom start page rejects invalid url', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-set-start-url')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await tester.enterText(
      find.byKey(const Key('home-browser-start-url-input')),
      'keine webseite',
    );
    await tester.tap(find.byKey(const Key('home-browser-start-url-save')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(homeBrowserCustomStartUrlStorageKey), isNull);
    expect(find.byKey(const Key('home-browser-open-toast')), findsOneWidget);
    expect(find.text('Bitte gib eine gültige Webseite ein.'), findsOneWidget);
  });

  test('home browser start url normalization accepts only web urls', () {
    expect(normalizeHomeBrowserStartUrl(null), isNull);
    expect(normalizeHomeBrowserStartUrl(''), isNull);
    expect(
      normalizeHomeBrowserStartUrl('bbc.com'),
      Uri.parse('https://bbc.com'),
    );
    expect(
      normalizeHomeBrowserStartUrl('https://www.wikipedia.org'),
      Uri.parse('https://www.wikipedia.org'),
    );
    expect(normalizeHomeBrowserStartUrl('ftp://example.com'), isNull);
    expect(normalizeHomeBrowserStartUrl('keine webseite'), isNull);
  });

  testWidgets('home browser standard choice opens system browser url', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final opened = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBrowserUrlResolverProvider.overrideWithValue(
            () async => Uri.parse('https://www.bbc.com'),
          ),
          homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return true;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-option-system')));
    await tester.pump(const Duration(seconds: 2));

    expect(opened, [Uri.parse('https://www.bbc.com')]);
    expect(find.text('Talvori-Leser'), findsNothing);
    expect(find.text('Kategorie'), findsNothing);
    expect(find.text('Vocabs'), findsNothing);
    expect(find.byType(ImpulsPostfachScreen), findsNothing);
  });

  testWidgets('home browser brave choice tries brave then default fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final opened = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBrowserUrlResolverProvider.overrideWithValue(
            () async => Uri.parse('https://www.bbc.com'),
          ),
          homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            return uri.scheme == 'https';
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-option-brave')));
    await tester.pump(const Duration(seconds: 2));

    expect(opened, [
      Uri.parse('brave://open-url?url=https%3A%2F%2Fwww.bbc.com'),
      Uri.parse('https://www.bbc.com'),
    ]);
    expect(
      find.text('Brave ist nicht verfügbar. Standardbrowser wird geöffnet.'),
      findsOneWidget,
    );
    expect(find.text('Talvori-Leser'), findsNothing);
  });

  testWidgets('home browser chrome choice tries chrome then default fallback', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final opened = <Uri>[];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeBrowserUrlResolverProvider.overrideWithValue(
            () async => Uri.parse('https://www.bbc.com'),
          ),
          homeExternalBrowserLauncherProvider.overrideWithValue((uri) async {
            opened.add(uri);
            if (uri.scheme == 'googlechromes') {
              throw StateError('Chrome unavailable');
            }
            return uri.scheme == 'https';
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.byKey(const Key('home-browser-option-chrome')));
    await tester.pump(const Duration(seconds: 2));

    expect(opened, [
      Uri.parse('googlechromes://www.bbc.com'),
      Uri.parse('https://www.bbc.com'),
    ]);
    expect(
      find.text('Chrome ist nicht verfügbar. Standardbrowser wird geöffnet.'),
      findsOneWidget,
    );
    expect(find.text('Talvori-Leser'), findsNothing);
  });

  testWidgets('home browser choice sheet has no overflow on compact height', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final previousOnError = FlutterError.onError;
    final overflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        overflows.add(details);
      } else {
        previousOnError?.call(details);
      }
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeExternalBrowserLauncherProvider.overrideWithValue((_) async {
            return true;
          }),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-browser-return-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('home-browser-open-sheet')), findsOneWidget);
    expect(find.text('Standardbrowser'), findsOneWidget);
    expect(find.text('Safari'), findsNothing);
    expect(find.text('Chrome'), findsOneWidget);
    expect(find.text('Brave'), findsOneWidget);
    expect(find.text('Eigene Webseite hinterlegen'), findsOneWidget);
    expect(find.text('Anderer Browser'), findsNothing);
    expect(find.byKey(const Key('home-browser-option-safari')), findsNothing);
    expect(find.byKey(const Key('home-browser-option-other')), findsNothing);
    expect(overflows, isEmpty);
  });

  testWidgets('home top right button opens progress hub', (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.byKey(const Key('home-progress-hub-button')));
    await tester.pumpAndSettle();

    expect(find.byType(RewardsCenterScreen), findsOneWidget);
    expect(find.text('Fortschritt'), findsOneWidget);
    expect(find.text('Liga'), findsOneWidget);
    expect(find.text('Belohnungen'), findsOneWidget);
    expect(find.text('Statistik'), findsOneWidget);
  });

  testWidgets('bottom word games button opens word games directly', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: HomeScreen())),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Wortspiele'), findsOneWidget);

    await tester.tap(find.byKey(const Key('home-practice-button')));
    await tester.pumpAndSettle();

    expect(find.byType(VocabScreen), findsOneWidget);
    expect(find.text('Wortspiele'), findsWidgets);
    expect(find.text('Vocabs'), findsNothing);
    expect(find.text('Course'), findsNothing);
    expect(find.text('Üben wird vorbereitet.'), findsNothing);
    expect(find.text('Kategorie'), findsNothing);
    expect(find.byKey(const Key('category-popup-my-words-tile')), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
  });

  testWidgets('word games screen shows all game cards without legacy mocks', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    expect(find.byType(VocabScreen), findsOneWidget);
    expect(find.text('Wortspiele'), findsOneWidget);
    const visibleTexts = [
      'Schnellspiele',
      'Wörter bauen',
      'Smart Challenges',
      'Blitzrunde',
      'Wort-Match',
      'Hör & Schreib',
      'Lückenwort',
      'Wort-Jagd',
      'Wort erkennen',
      'Wort-Duell',
      'Hör-Fang',
      'Wort-Puzzle',
      'Hangman',
      'Silben-Regen',
      'Wortpfad',
      'Wortsuche',
      'Kontext-Challenge',
      'Gegenwort',
      'Synonym-Rätsel',
      'Boss-Fight',
      'Daily Word Quest',
    ];
    for (final text in visibleTexts) {
      expect(find.text(text), findsOneWidget);
    }
    expect(
      tester.getTopLeft(find.text('Wort-Duell')).dy,
      lessThan(tester.getTopLeft(find.text('Wörter bauen')).dy),
    );
    expect(find.text('Vocab Practice'), findsNothing);
    expect(find.text('Übungsarten'), findsNothing);
    expect(find.text('Bedeutung finden'), findsNothing);
    expect(find.text('Bedeutungs-Duell'), findsNothing);
    expect(find.text('Try Game shuffle'), findsNothing);
    expect(find.text('Vocab classic'), findsNothing);
    expect(find.text('Build words'), findsNothing);
    expect(find.text('Choose the word'), findsNothing);
    expect(find.text('Guess the word'), findsNothing);
    expect(find.text('Coming soon (tap to vote!)'), findsNothing);
    expect(find.text('Perfection'), findsNothing);
    expect(find.text('Klassisch üben'), findsNothing);
    expect(find.text('Frei wiederholen'), findsNothing);
  });

  testWidgets('word games screen has no tile overflow on iPhone width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final previousOnError = FlutterError.onError;
    final overflows = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final message = details.exceptionAsString();
      if (message.contains('RenderFlex overflowed')) {
        overflows.add(details);
        return;
      }
      previousOnError?.call(details);
    };
    addTearDown(() => FlutterError.onError = previousOnError);

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();
    await tester.fling(find.byType(ListView), const Offset(0, -520), 1000);
    await tester.pumpAndSettle();
    await tester.fling(find.byType(ListView), const Offset(0, -720), 1000);
    await tester.pumpAndSettle();

    expect(find.text('Wortspiele'), findsOneWidget);
    expect(find.text('Daily Word Quest'), findsOneWidget);
    expect(overflows, isEmpty);
  });

  testWidgets('word game subtitles can use a third line on compact cards', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    final blitzSubtitle = tester.widget<Text>(
      find.text('60 Sekunden, so viele Wörter wie möglich'),
    );
    final bossTile = find.byKey(const ValueKey('word-game-boss_fight'));
    await tester.scrollUntilVisible(
      bossTile,
      220,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    final bossSubtitle = tester.widget<Text>(
      find.text('Besiege deine schwierigsten Wörter'),
    );

    expect(blitzSubtitle.maxLines, greaterThanOrEqualTo(3));
    expect(blitzSubtitle.overflow, TextOverflow.fade);
    expect(bossSubtitle.maxLines, greaterThanOrEqualTo(3));
    expect(bossSubtitle.overflow, TextOverflow.fade);
  });

  testWidgets('context challenge card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-context_challenge')));
    await tester.pumpAndSettle();

    expect(find.byType(ContextChallengeGameScreen), findsOneWidget);
    expect(find.text('Kontext-Challenge'), findsWidgets);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
  });

  testWidgets('word hunt card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_hunt')));
    await tester.pumpAndSettle();

    expect(find.byType(WordHuntGameScreen), findsOneWidget);
    expect(find.text('Wort-Jagd'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('speed round card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-speed_round')));
    await tester.pumpAndSettle();

    expect(find.byType(SpeedRoundGameScreen), findsOneWidget);
    expect(find.text('Blitzrunde'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word recognition card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_recognition')));
    await tester.pumpAndSettle();

    expect(find.byType(WordRecognitionGameScreen), findsOneWidget);
    expect(find.text('Wort erkennen'), findsWidgets);
    expect(
      find.byKey(const ValueKey('word-recognition-start-button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('word-recognition-hint')), findsNothing);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word duel card opens preview screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    final duelTile = find.byKey(const ValueKey('word-game-word_duel'));
    await tester.ensureVisible(duelTile);
    await tester.pump();
    await tester.tap(duelTile);
    await tester.pumpAndSettle();

    expect(find.byType(WordDuelPreviewScreen), findsOneWidget);
    expect(find.text('Wort-Duell'), findsWidgets);
    expect(
      find.textContaining('echtes Duell gegen andere Talvori-Spieler'),
      findsOneWidget,
    );
    expect(find.text('Bedeutungs-Duell'), findsNothing);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('listen and write card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'emergency', term: 'emergency')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-listen_write')));
    await tester.pumpAndSettle();

    expect(find.byType(ListenAndWriteGameScreen), findsOneWidget);
    expect(find.text('Hör & Schreib'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('gap word card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'emergency', term: 'emergency')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-gap_word')));
    await tester.pumpAndSettle();

    expect(find.byType(GapWordGameScreen), findsOneWidget);
    expect(find.text('Lückenwort'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word match card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_match')));
    await tester.pumpAndSettle();

    expect(find.byType(WordMatchGameScreen), findsOneWidget);
    expect(find.text('Wort-Match'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word puzzle card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'emergency', term: 'emergency')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-word_puzzle')));
    await tester.pumpAndSettle();

    expect(find.byType(WordPuzzleGameScreen), findsOneWidget);
    expect(find.text('Wort-Puzzle'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('hangman card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [localWord(id: 'level', term: 'level')];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('word-game-hangman')));
    await tester.pumpAndSettle();

    expect(find.byType(HangmanGameScreen), findsOneWidget);
    expect(find.text('Hangman'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('daily word quest card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
              localWord(id: 'level', term: 'level', translation: 'Stufe'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-game-daily_word_quest')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('word-game-daily_word_quest')));
    await tester.pumpAndSettle();

    expect(find.byType(DailyWordQuestGameScreen), findsOneWidget);
    expect(find.text('Daily Word Quest'), findsOneWidget);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('boss fight card opens game screen', (tester) async {
    tester.view.physicalSize = const Size(390, 3200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          localWordsForSourceProvider.overrideWith((ref, source) async {
            return [
              localWord(
                id: 'emergency',
                term: 'emergency',
                translation: 'Notfall',
              ),
              localWord(id: 'shelter', term: 'shelter', translation: 'Schutz'),
              localWord(id: 'rescue', term: 'rescue', translation: 'Rettung'),
              localWord(id: 'water', term: 'water', translation: 'Wasser'),
            ];
          }),
        ],
        child: const MaterialApp(home: VocabScreen()),
      ),
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('word-game-boss_fight')),
      240,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byKey(const ValueKey('word-game-boss_fight')));
    await tester.pumpAndSettle();

    expect(find.byType(BossFightGameScreen), findsOneWidget);
    expect(find.text('Boss-Fight'), findsWidgets);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('word games hub has no prepared dummy card left', (tester) async {
    tester.view.physicalSize = const Size(390, 2600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: VocabScreen())),
    );
    await tester.pump();

    const gameIds = [
      'speed_round',
      'word_hunt',
      'word_recognition',
      'word_duel',
      'audio_catch',
      'word_match',
      'word_puzzle',
      'gap_word',
      'hangman',
      'syllable_rain',
      'word_path',
      'word_search',
      'listen_write',
      'context_challenge',
      'odd_word',
      'synonym_riddle',
      'boss_fight',
      'daily_word_quest',
    ];

    for (final id in gameIds) {
      expect(find.byKey(ValueKey('word-game-$id')), findsOneWidget);
    }
    expect(find.byKey(const ValueKey('word-game-training_camp')), findsNothing);
    expect(find.text('Trainingscamp'), findsNothing);
    expect(find.byKey(const Key('word-game-prepared-toast')), findsNothing);
    expect(find.text('Dieses Wortspiel wird vorbereitet.'), findsNothing);
  });

  testWidgets('local sources open source details and keep back stack', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: LocalLearningSourcesScreen()),
      ),
    );
    await tester.pump();

    for (final entry in const [
      (Key('local-source-all-words-tile'), 'Alle Wörter'),
      (Key('local-source-favorites-tile'), 'Favoriten'),
      (Key('local-source-my-words-tile'), 'Meine Wörter'),
      (Key('local-source-known-words-tile'), 'Wörter, die ich kenne'),
      (Key('local-source-my-mix-tile'), 'Mein Mix'),
    ]) {
      await tester.tap(find.byKey(entry.$1));
      await tester.pumpAndSettle();

      expect(find.byType(LocalLearningSourceDetailScreen), findsOneWidget);
      expect(find.text(entry.$2), findsWidgets);
      final wheel = tester.widget<CategoryWheel>(find.byType(CategoryWheel));
      expect(wheel.categories, const [
        'Alle Wörter',
        'Favoriten',
        'Meine Wörter',
        'Wörter, die ich kenne',
        'Mein Mix',
      ]);
      expect(find.text('Übungsmodus'), findsNothing);
      expect(find.text('All Words'), findsNothing);
      expect(find.text('My words'), findsNothing);
      expect(find.text('Favorites'), findsNothing);
      expect(find.text('Words I know'), findsNothing);
      expect(find.text('My mix'), findsNothing);

      wheel.onChanged(1, 'Favoriten');
      await tester.pump();
      final updatedWheel = tester.widget<CategoryWheel>(
        find.byType(CategoryWheel),
      );
      expect(updatedWheel.initialIndex, 1);

      Navigator.of(
        tester.element(find.byType(LocalLearningSourceDetailScreen)),
      ).pop();
      await tester.pumpAndSettle();
      expect(find.byType(LocalLearningSourcesScreen), findsOneWidget);
      expect(find.text('Wortquellen'), findsOneWidget);
    }
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final pushedRouteNames = <String?>[];
  final poppedRouteNames = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    pushedRouteNames.add(route.settings.name);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    poppedRouteNames.add(route.settings.name);
  }
}
