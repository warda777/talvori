import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/impuls_postfach/application/impulse_inbox_provider.dart';
import 'package:talvori/features/impuls_postfach/data/impulse_inbox_repository.dart';
import 'package:talvori/features/impuls_postfach/ui/screens/impuls_postfach_screen.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';
import 'package:talvori/features/tagesimpuls/ai/tagesimpuls_ai_client.dart';

void main() {
  setUpAll(() async {
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
    expect(find.byIcon(Icons.grid_view_rounded), findsOneWidget);
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

    await tester.tap(find.byKey(const Key('home-impuls-postfach-button')));
    await tester.pump(const Duration(milliseconds: 260));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();

    expect(find.byType(ImpulsPostfachScreen), findsOneWidget);
    expect(find.text('Noch keine Chats'), findsOneWidget);
  });
}
