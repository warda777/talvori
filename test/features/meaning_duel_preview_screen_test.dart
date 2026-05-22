import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talvori/features/home/ui/screens/meaning_duel_preview_screen.dart';

void main() {
  testWidgets('shows online duel preview without starting multiplayer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: MeaningDuelPreviewScreen()),
    );

    expect(find.text('Bedeutungs-Duell'), findsWidgets);
    expect(
      find.textContaining('echtes Duell gegen andere Talvori-Spieler'),
      findsOneWidget,
    );
    expect(find.text('Spieler einladen'), findsOneWidget);
    expect(find.text('Duell-Anfrage'), findsOneWidget);
    expect(find.text('Live-Ranking'), findsOneWidget);
    expect(find.text('Antwortzeit'), findsOneWidget);
    expect(find.text('Gewinner'), findsOneWidget);
    expect(find.text('Zurück zu Wortspiele'), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });
}
