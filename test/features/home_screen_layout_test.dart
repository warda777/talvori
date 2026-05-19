import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:talvori/features/home/ui/screens/home_screen.dart';

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
  });
}
