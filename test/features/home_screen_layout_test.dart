import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';
import 'package:talvori/features/home/ui/widgets/bottom_nav.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';
import 'package:talvori/features/words/ui/screens/local_learning_source_detail_screen.dart';
import 'package:talvori/features/words/ui/screens/local_learning_sources_screen.dart';
import 'package:talvori/features/words/ui/screens/local_word_list_screen.dart';
import 'package:talvori/features/words/ui/widgets/category_wheel.dart';

void main() {
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
    expect(find.text('Üben'), findsOneWidget);
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

  testWidgets('bottom practice button opens classic Vocabs Course menu', (
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

    tester.widget<HomeBottomNav>(find.byType(HomeBottomNav)).onPractice();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Vocabs'), findsOneWidget);
    expect(find.text('Course'), findsOneWidget);
    expect(find.text('Üben wird vorbereitet.'), findsNothing);
    expect(find.text('Kategorie'), findsNothing);
    expect(find.byKey(const Key('category-popup-my-words-tile')), findsNothing);
    expect(find.byType(LocalLearningSourcesScreen), findsNothing);
    expect(find.byType(LocalLearningSourceDetailScreen), findsNothing);
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
