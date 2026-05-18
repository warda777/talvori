import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/words/ui/screens/mix_builder_screen.dart';

void main() {
  testWidgets('mix builder screen uses german dark-neon labels and selection', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: MixBuilderScreen())),
    );

    await tester.pump();

    expect(find.text('Eigenen Mix erstellen'), findsOneWidget);
    expect(find.text('Suchen'), findsOneWidget);
    expect(find.text('Alle auswählen'), findsWidgets);
    expect(find.text('Deine Sammlungen'), findsOneWidget);
    expect(find.text('Möchte ich lernen'), findsOneWidget);
    expect(find.text('Action & Abenteuer'), findsOneWidget);
    expect(find.text('Gaming'), findsOneWidget);
    expect(find.text('Sport'), findsOneWidget);
    expect(find.text('Start'), findsOneWidget);

    expect(find.text('Make your own mix'), findsNothing);
    expect(find.text('Pick all'), findsNothing);
    expect(find.text('Your collections'), findsNothing);
    expect(find.text('Want to memorize'), findsNothing);
    expect(find.text('Action & Adventure'), findsNothing);

    await tester.tap(find.text('Suchen'));
    await tester.pump();

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Suchen...'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Gaming');
    await tester.pump();

    expect(find.text('Suchergebnisse'), findsOneWidget);
    expect(find.text('Gaming'), findsWidgets);

    await tester.tap(find.text('Gaming').last);
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
